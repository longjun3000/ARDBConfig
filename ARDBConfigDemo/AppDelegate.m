//
//  AppDelegate.m
//  ARDBConfigDemo
//
//  Created by LongJun on 15/3/31.
//  Copyright (c) 2015年 Arwer. All rights reserved.
//

#import "AppDelegate.h"
#import "DBConfigLogic.h"

/// Document dir
#define APP_PATH_DOCUMENT	 [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
/// 本地主数据库名称
#define LOCAL_MAIN_DB_NAME      @"db.sqlite"
/// 本地主数据库完整路径
#define LOCAL_MAIN_DB_PATH      [APP_PATH_DOCUMENT stringByAppendingPathComponent:LOCAL_MAIN_DB_NAME]
#define PRINT_APP_PATH       NSLog(@"\n******** [App Path] *******\n%@\n***************************", NSHomeDirectory());


@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    //打印App的根路径
    PRINT_APP_PATH
    
    /////////////////// Init local database ////////////////////////////////////
    DBConfigLogic *dbConfigLogic = [[DBConfigLogic alloc] init];
    //    dbConfigLogic.allowDowngrade = YES; //是否允许数据库降级，默认不允许。
    BOOL checkResult = [dbConfigLogic checkDatabase:LOCAL_MAIN_DB_PATH newVersion:dbConfigLogic.dbVersion];
    if (!checkResult) {
        NSLog(@"check db fail.");

        UIAlertView *alertview = [[UIAlertView alloc] initWithTitle:@"提示"
                                                            message:@"数据库初始化失败，不能继续加载，请彻底关闭程序后再次尝试，或者联系系统管理员。"
                                                           delegate:nil
                                                  cancelButtonTitle:@"确定"
                                                  otherButtonTitles:nil, nil];
        [alertview show];
        return NO;
    }
    else {
        NSLog(@"check db success.");
    }
    ////////////////////////// END /////////////////////////////////////////////
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
