//
//  RLDBConfigBase.m
//  ARDBConfigDemo
//
//  Created by LongJun on 15/3/9.
//  Copyright (c) 2015年 Arwer. All rights reserved.
//
/*
 备注：
 在数据库中，我们可以使用这样写 sql语句来查询它：
 PRAGMA user_version
 或者来设置它的值
 PRAGMA user_version = 1
 更多内容参考sqlite的官方描述：http://www.sqlite.org/pragma.html
 */

#import "ARDBConfigBase.h"

@interface ARDBConfigBase()

@property (nonatomic, strong) FMDatabase *db;

@end

@implementation ARDBConfigBase



//- (instancetype)init
//{
//    if ((self = [super init])) {
//        
//    }
//    return self;
//}

/**
 * 检查数据库（初始化数据库或更新数据库）
 *
 * @param dbFullName 完整的数据库路径+数据库文件名
 * @param newVersion 新版本的版本号
 */
- (BOOL)checkDatabase:(NSString*)dbFullName newVersion:(int)newVersion
{
    if (!dbFullName) {
        NSAssert1(0, @"db path and name can't be empty (%@)", dbFullName);
        @throw [NSException exceptionWithName:@"Database name error" reason:@"Database name and path can not be empty." userInfo:nil];
        return NO;
    }
    if (newVersion < 1) {
        NSAssert1(0, @"The database version number cannot be less than 1. (%d)", newVersion);
        @throw [NSException exceptionWithName:@"Database version error" reason:@"The database version number cannot be less than 1." userInfo:nil];
        return NO;
    }
    
    self.db = [FMDatabase databaseWithPath:dbFullName];
    @try {
        if (![_db open]) {
            //            [db release];
            //NSLog(@"db open fail");
            NSAssert1(0, @"db open fail (%@)", dbFullName);
            return NO;
        }
        
        //查出当前数据库版本
        FMResultSet *rs = [_db executeQuery:@"PRAGMA user_version;"];
        int oldVersion = -1;
        if ([rs next])
        {
            oldVersion = [rs intForColumnIndex:0];
        }
        [rs close];
        
        //
        if (oldVersion <= 0) { //表示第一次创建数据库
            
            [_db beginTransaction];
            BOOL rev = [self onCreate:_db];
            if (rev) {
                rev = [_db executeUpdate:[NSString stringWithFormat:@"PRAGMA user_version = %d", newVersion]];
                if (rev)
                    [_db commit];
                else {
                    NSLog(@">>> db exec fail: %@", [_db lastError]);
                    [_db rollback];
                }
            }
            else {
                [_db rollback];
                NSLog(@">>> db exec fail: %@", [_db lastError]);
            }
            //
            [self didChecked:_db dbCheckIsSuccess:rev];
            return rev;
        }
        else { //表示已经创建了库表，接下来走onUpgrade等，由开发者在子类中决定如何升级或降级库表结构

            if (newVersion < oldVersion) { //新版本号小于旧版本号
                
                if (self.allowDowngrade) {
                    //执行用户的降级代码
                    [_db beginTransaction];
                    BOOL rev = [self onDowngrade:self.db oldVersion:oldVersion newVersion:newVersion];
                    if (rev) {
                        rev = [_db executeUpdate:[NSString stringWithFormat:@"PRAGMA user_version = %d", newVersion]];
                        if (rev)
                            [_db commit];
                        else {
                            [_db rollback];
                            NSLog(@">>> db exec fail: %@", [_db lastError]);
                        }
                    }
                    else {
                        [_db rollback];
                        NSLog(@">>> db exec fail: %@", [_db lastError]);
                    }
                    //
                    [self didChecked:_db dbCheckIsSuccess:rev];
                    return rev;
                }
                else { //禁止降级
                    NSString *errStr = [NSString stringWithFormat:@"The database new version(%d) cannot be less than the old version(%d)", newVersion, oldVersion];
                    NSAssert2(0, errStr, newVersion, oldVersion);
//                    @throw [NSException exceptionWithName:@"Database version error" reason:errStr userInfo:nil];
                    //
                    [self didChecked:_db dbCheckIsSuccess:NO];
                    return NO;
                }
            }
            else if (newVersion == oldVersion) { //新旧版本号相同
                
                //执行用户的代码
                [_db beginTransaction];
                BOOL rev = [self onEqual:self.db oldVersion:oldVersion newVersion:newVersion];
                if (rev)
                    [_db commit];
                else {
                    [_db rollback];
                    NSLog(@">>> db exec fail: %@", [_db lastError]);
                }
                //
                [self didChecked:_db dbCheckIsSuccess:rev];
                return rev;
            }
            else { //新版本号大于旧版本号则执行onUpgrade里的方法
                
                //执行用户的更新代码
                [_db beginTransaction];
                BOOL rev = [self onUpgrade:self.db oldVersion:oldVersion newVersion:newVersion];
                if (rev) {
                    rev = [_db executeUpdate:[NSString stringWithFormat:@"PRAGMA user_version = %d", newVersion]];
                    if (rev)
                        [_db commit];
                    else {
                        [_db rollback];
                        NSLog(@">>> db exec fail: %@", [_db lastError]);
                    }
                }
                else {
                    [_db rollback];
                    NSLog(@">>> db exec fail: %@", [_db lastError]);
                }
                //
                [self didChecked:_db dbCheckIsSuccess:rev];
                return rev;
            }
        }
    }
    @catch (NSException *ex) {
        
        NSAssert1(0, @"Exception: %@", ex.reason);
        
    }
    @finally {
        [self.db close];
        
    }
    return NO;
}

/**
 * 第一次创建数据库时的方法。子类需要覆盖该方法，实现第一次创建数据库时的代码
 *
 * @param db FMDB的数据库对象
 * @return YES=成功，NO=失败 
 */
- (BOOL)onCreate:(FMDatabase *)db {
    return YES;
}

/**
 * 数据库版本相等时的方法。子类可以覆盖该方法，实现数据库版本相等时的代码
 *
 * @param db FMDB的数据库对象
 * @param oldVersion 当期数据库的版本
 * @param newVersion 要更新的新的数据库的版本
 * @return YES=成功，NO=失败
 */
- (BOOL)onEqual:(FMDatabase *)db oldVersion:(int)oldVersion newVersion:(int)newVersion {
    return YES;
}

/**
 * 数据库版本增加时的方法。子类需要覆盖该方法，实现数据库版本增加时的代码
 *
 * @param db FMDB的数据库对象
 * @param oldVersion 当期数据库的版本
 * @param newVersion 要更新的新的数据库的版本
 * @return YES=成功，NO=失败
 */
- (BOOL)onUpgrade:(FMDatabase *)db oldVersion:(int)oldVersion newVersion:(int)newVersion {
    return YES;
}

/**
 * 数据库版本降级时的方法。子类可以覆盖该方法，实现数据库版本降级时的代码
 *
 * @param db FMDB的数据库对象
 * @param oldVersion 当期数据库的版本
 * @param newVersion 要更新的新的数据库的版本
 * @return YES=成功，NO=失败
 */
- (BOOL)onDowngrade:(FMDatabase *)db oldVersion:(int)oldVersion newVersion:(int)newVersion {
    return YES;
}

/**
 * 数据库配置检查完成后会调用的方法。子类可以覆盖该方法，实现数据库版本升级后的一些后续数据处理。
 *
 * @param db FMDB的数据库对象
 * @param dbCheckIsSuccess 数据库配置检查是否成功了
 */
- (void)didChecked:(FMDatabase *)db dbCheckIsSuccess:(BOOL)dbCheckIsSuccess
{

}

@end
