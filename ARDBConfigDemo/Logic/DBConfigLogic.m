//
//  DBConfigLogic.m
//  ARDBConfigDemo
//
//  功能说明：
//  提供一个数据库表结构更新的机制，保证用户无论从哪个版本安装程序，数据库结构保证适配。
//  如:用户A数据库版本是v1，用户B是v2，用户C没装过App这次新装；所有用户安装运行数据库版本是v3的App后，用户A数据库会v1->v2->v3依次升级，用户B会v2->v3依次升级，用户C会v1->v2->v3依次升级数据库。
//
//  使用说明：
//  1、第一次创建工程，新建数据库的情况（数据库版本为1）：
//  （1）新建一个继承于RLDBConfigBase的类，如DBConfigLogic。
//  （2）添加int类型只读属性dbVersion，实现get方法并return 1；
//  （3）添加覆盖父类方法onCreate，并在方法内写下第一次创建数据表结构的SQL及代码。
//  （4）在程序启动时（如AppDelegate.m）实例化DBConfigLogic类并调用checkDatabase方法，即可完成数据库的初始化动作。
//
//  2、App在某一版本数据库结构需要改动时（数据库版本升为2）：
//  （1）在步骤1的基础上，修改dbVersion属性方法的返回值为return 2。
//  （2）在步骤1的基础上，添加覆盖父类方法onUpgrade，使用本文onUpgrade内示范代码，只需修改switch内的代码。
//  （3）如果在数据库结构升级完成后需要做一些后续数据处理，可以添加覆盖父类的方法didChecked，写入数据库操作的代码。
//  （4）在程序启动时（如AppDelegate.m）实例化DBConfigLogic类并调用checkDatabase方法，即可完成数据库的初始化和升级动作。
//
//  Created by LongJun on 15/3/23.
//  Copyright (c) 2015年 Arwer. All rights reserved.
//

#import "DBConfigLogic.h"

@implementation DBConfigLogic

#pragma mark - Custom Property

/**
 * 只读属性，当前项目的数据库版本号，如果下一次数据库表结构或数据要更改，请在原数字上加1.
 *
 * 如：第一次工程创建时dbVersion请设为1；软件迭代升级了几次后要修改数据库表结构或数据要更改，则修改dbVersion=2；每次升级数据库请把版本号累加。
 */
- (int)dbVersion
{
    /*
     备注：
     DB走DB的版本号，App走App的版本号，互不冲突，互不影响，这里备注只是记录而已。
     dbVersion=1，appVersion=1.0：创建第一版数据库。
     dbVersion=2，appVersion=2.3：表t_Users增加了字段MobilePhone。
     dbVersion=3，appVersion=2.4：XXX。
     */
    return 1;
}

#pragma mark - Override the parent class's methods

/**
 * 第一次创建数据库时的sql。注意不需要写事务，父类已经启动事务
 *
 * @param db FMDB的数据库对象
 */
- (BOOL)onCreate:(FMDatabase *)db
{
    NSLog(@">>> onCreate");
    
    if (!db) {
        NSAssert(0, @"db can't be null");
        return false;
    }
    
    @try {
        
        ////////////////////////// 在此处添加第一次创建表和初始化的SQL ///////////////////////////////
        BOOL result = NO;
        
        // 2 执行表创建工作
        // 2.1 用户表
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_Users (UserId TEXT NOT NULL, LoginId TEXT NOT NULL, loginPassword TEXT, UserName TEXT, Age INTEGER, Title TEXT, PRIMARY KEY (UserId));"];
        if (!result) {
            NSLog(@"create table Users Failed");
            return false;
        }
        
        // 2.2 工作日志表
        result = [db executeUpdate:@"CREATE TABLE IF NOT EXISTS t_Worklog (WorklogId TEXT NOT NULL, Title TEXT NOT NULL, Desc TEXT, Owner TEXT NOT NULL, CreatedTime TEXT NOT NULL, ModifiedTime TEXT NOT NULL, IsDeleted INTEGER, PRIMARY KEY (WorklogId));"];
        if (!result) {
            NSLog(@"create table t_Worklog Failed");
            return false;
        }
        /////////////////////////////////////// END ////////////////////////////////////////////
        
        
        //第一次创建数据库即self.dbVersion=1时，可以不用实现覆盖方法onUpgrade，此处可以直接return true;
        //self.dbVersion>1时,实现覆盖方法onUpgrade并调用它，是为了保证用户从不管从哪个版本新安装，都保证数据库版本更新到最新版。
        //如:用户A数据库版本是v1，用户B是v2，用户C没装过App这次新装；当前数据库版本是v3，安装运行App后，用户A会v1->v2->v3，用户B会v2->v3，用户C会v1->v2->v3依次升级数据库。
        return [self onUpgrade:db oldVersion:DBCONFIG_FIRST_VER newVersion:self.dbVersion];
        
    }
    @catch (NSException *exception) {
        NSAssert1(0, @"Exception: %@", exception.reason);
        return false;
    }
    @finally {
        
    }
    
}

/**
 * 数据库版本相等时需要做的事情可以在该方法实现。
 *
 * @param db FMDB的数据库对象
 * @param oldVersion 当期数据库的版本
 * @param newVersion 要更新的新的数据库的版本
 */
- (BOOL)onEqual:(FMDatabase *)db oldVersion:(int)oldVersion newVersion:(int)newVersion {
    
    NSLog(@">>> onEqual, oldVersion=%d, newVersion=%d", oldVersion, newVersion);
    
    //Such as:
    //Clear table t_Worklog (demo need)
    BOOL result = [db executeUpdate:@"DELETE FROM t_Worklog"];
    if (!result) {
        NSLog(@"remove table t_Worklog all rows Failed");
        return false;
    }
    return true;
}

/**
 * 数据库版本增加时的方法，比如数据库表结构发生变化，要从版本v1升级到版本v2
 *
 * @param db FMDB的数据库对象
 * @param oldVersion 当期数据库的版本
 * @param newVersion 要更新的新的数据库的版本
 */
- (BOOL)onUpgrade:(FMDatabase *)db oldVersion:(int)oldVersion newVersion:(int)newVersion
{
    NSLog(@">>> onUpgrade, oldVersion=%d, newVersion=%d", oldVersion, newVersion);
    
    if (!db) {
        NSAssert(0, @"db can't be null");
        return false;
    }
    
    @try {
        // 升级数据库
        // 使用for实现跨版本升级数据库，代码逻辑始终会保证顺序递增升级。
        BOOL rev = NO;
        for(int ver = oldVersion; ver < newVersion; ver++) {
            rev = NO;
            switch(ver) {
                case 1: //v1-->v2
                    rev = [self upgradeVersion1To2:db];
                    break ;
                case 2: //v2-->v3
                    rev = [self upgradeVersion2To3:db];
                    break ;
                    //有新的版本在此处添加case 3、case 4等等。
                default :
                    break ;
            }
            if (!rev) return false;
        }
        
        //
        return true;
    }
    @catch (NSException *exception) {
        NSAssert1(0, @"Exception: %@", exception.reason);
        return false;
    }
    @finally {
        
    }
}

///**
// * 数据库版本降级时的方法。实现数据库版本降级时的代码。
// * 注：默认降级是禁止的，如果要使用，在本类实例化后，设置allowDowngrade = YES;然后再调用checkDatabase方法。
// *
// * @param db FMDB的数据库对象
// * @param oldVersion 当期数据库的版本
// * @param newVersion 要更新的新的数据库的版本
// * @return YES=成功，NO=失败
// */
//- (BOOL)onDowngrade:(FMDatabase *)db oldVersion:(int)oldVersion newVersion:(int)newVersion {
//
//    NSLog(@">>> onDowngrade, oldVersion=%d, newVersion=%d", oldVersion, newVersion);
//
//    if (!db) {
//        NSAssert(0, @"db can't be null");
//        return false;
//    }
//
//    @try {
//        // 降级数据库
//        // 使用for实现跨版本降级数据库，代码逻辑始终会保证顺序递减。
//        BOOL rev = NO;
//        for(int ver = oldVersion; ver > newVersion; ver--) {
//            rev = NO;
//            switch(ver) {
//                case 3: //v3-->v2
////                    rev = [self downgradeVersion3To2:db];
//                    break ;
//                case 2: //v2-->v1
////                    rev = [self downgradeVersion2To1:db];
//                    break ;
//                default :
//                    break ;
//            }
//            if (!rev) return false;
//        }
//
//        //
//        return true;
//    }
//    @catch (NSException *exception) {
//        NSAssert1(0, @"Exception: %@", exception.reason);
//        return false;
//    }
//    @finally {
//
//    }
//}

/**
 * 数据库配置检查完成后会调用的方法。可以实现数据库版本升级后的一些后续数据处理。
 *
 * @param db FMDB的数据库对象
 * @param dbCheckIsSuccess 数据库配置检查是否成功了
 */
- (void)didChecked:(FMDatabase *)db dbCheckIsSuccess:(BOOL)dbCheckIsSuccess
{
    if (!dbCheckIsSuccess) return;
    
    //do db something
    //...
    
}

#pragma mark - Custom Method

/**
 * 数据库版本从v1升级到v2。
 *
 * 主要功能有：
 * 给t_Users表增加字段MobilePhone
 */
- (BOOL)upgradeVersion1To2:(FMDatabase *)db
{
    
    //1 判断表是否存在，取出t_Users表创建语句
    FMResultSet *rs = [db executeQuery:@"SELECT sql FROM sqlite_master WHERE type = 'table' AND tbl_name = 't_Users' "];
    NSString *tabCreateSql = nil;
    BOOL tableIsExistus = NO;
    while([rs next]) {
        tableIsExistus = YES;
        tabCreateSql = [rs stringForColumnIndex:0];
        break;
    }
    [rs close];
    if (tableIsExistus && tabCreateSql) {
        //1.2 判断要新增的列MobilePhone是否存，不存在则添加
        NSString *column_FileName = @"MobilePhone";
        NSRange range1 = [tabCreateSql rangeOfString: column_FileName];
        if (range1.length < 1) {
            NSString *sql = [NSString stringWithFormat:@"ALTER TABLE t_Users ADD %@ TEXT NULL; ", column_FileName];
            BOOL rev = [db executeUpdate:sql];
            if (!rev) {
                [db rollback];
                NSLog(@"执行以下sql时失败：\n%@\n失败原因是：%@", sql, [db lastErrorMessage]);
                NSAssert2(0, @"执行以下sql时失败：\n%@\n失败原因是：%@", sql, [db lastErrorMessage]);
                return false;
            }
        }
    }
    return true;
}

/**
 * 数据库版本从v2升级到v3。
 *
 * 主要功能有：
 * xxxxx
 */
- (BOOL)upgradeVersion2To3:(FMDatabase *)db
{
    //do something...
    return true;
}



@end
