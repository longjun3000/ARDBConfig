ARDBConfig
===========
On the iOS, provide a database table structure update mechanism, ensure that the user in any version of the installer, the database structure to ensure adapter.

Such as: user A's database version is v1, user B is v2, user C never installed App; Now, all users to install and run the latest App (database version is v3) after the user A's database will "v1 --> v2 --> v3" order upgrades, user B 's database will "v2 --> v3" in order to upgrade, the user C's database will "v1 --> v2 --> v3" order to upgrade.


在iOS上，提供一个数据库表结构更新的机制，保证用户无论从哪个版本安装程序，数据库结构保证适配。

如:用户A的数据库版本是v1，用户B是v2，用户C没装过App；现在，所有用户安装并运行最新App（数据库版本是v3）后，用户A的数据库将会“v1->v2->v3”顺序升级，用户B的数据库将会“v2->v3”顺序升级，用户C的数据库将会“v1->v2->v3”顺序升级。

![image](https://github.com/longjun3000/ARDBConfig/blob/master/Screenshop01.png)

How to use ?
============
1. create a project for the first time, the situation of the new database (database version 1) :
(1) to create a new inheritance in "RLDBConfigBase" classes, such as "DBConfigLogic".
(2) to add an int type read-only property "dbVersion", realizing the get method and return 1;
(3) added to cover the superclass method "onCreate", and write down around a method a SQL and create the data table structure of the code.
(4) the application starts (e.g., "AppDelegate. M"), instantiate "DBConfigLogic" class and call "checkDatabase" method, can complete the initialization of the database.

2. the App in a version of the database structure needs to be altered (database version to 2) :
(1) in step 1, on the basis of modified dbVersion properties method in the return value is the return of 2.
(2) in step 1, on the basis of "onUpgrade" add cover the superclass method, using demonstration in the article "onUpgrade" code, only need to modify the code within the switch.
(3) if the database structure upgrade after the completion of the need to do some follow-up data processing, can be added to cover the superclass method "didChecked", code written to the database operation.
(4) the application starts (e.g., "AppDelegate. M"), instantiate "DBConfigLogic" class and call "checkDatabase" method, can complete the initialization of the database and update action.


如何使用？
========
1、第一次创建工程，新建数据库的情况（数据库版本为1）：
（1）新建一个继承于“RLDBConfigBase”的类，如“DBConfigLogic”。
（2）添加int类型只读属性“dbVersion”，实现get方法并return 1；
（3）添加覆盖父类方法“onCreate”，并在方法内写下第一次创建数据表结构的SQL及代码。
（4）在程序启动时（如“AppDelegate.m”），实例化“DBConfigLogic”类并调用“checkDatabase”方法，即可完成数据库的初始化动作。

2、App在某一版本数据库结构需要改动时（数据库版本升为2）：
（1）在步骤1的基础上，修改“dbVersion”属性方法的返回值为return 2。
（2）在步骤1的基础上，添加覆盖父类方法“onUpgrade”，使用本文“onUpgrade”内示范代码，只需修改switch内的代码。
（3）如果在数据库结构升级完成后需要做一些后续数据处理，可以添加覆盖父类的方法“didChecked”，写入数据库操作的代码。
（4）在程序启动时（如“AppDelegate.m”），实例化“DBConfigLogic”类并调用“checkDatabase”方法，即可完成数据库的初始化和升级动作。


Contact
=======
ArwerSoftware@gmail.com

联系方式
=======
ArwerSoftware@gmail.com


License
=======
The MIT License (MIT)

Copyright © 2014 LongJun

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the “Software”), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED “AS IS”, WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

