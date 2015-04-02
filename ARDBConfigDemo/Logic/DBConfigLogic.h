//
//  DBConfigLogic.h
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

#import "ARDBConfigBase.h"

@interface DBConfigLogic : ARDBConfigBase


/**
 * 当前项目的数据库版本号，如果下一次数据库表结构或数据要更改，请在原数字上加1.
 *
 * 如：第一次工程创建时dbVersion=1；软件迭代升级了几次后要修改数据库表结构或数据要更改，则修改dbVersion=2。
 */
@property (nonatomic, readonly, assign) int dbVersion;

@end
