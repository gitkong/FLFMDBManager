#一、FMDB简单介绍
>*FMDB是OC的方式封装了SQLite的C语言API，并且它对于多线程的并发操作进行了处理，所以是线程安全的；相对系统提供的CoreData，轻量好多，使用起来也很方便，除查询以外的所有操作，都称为“更新”，这里就不详细介绍了，不是本文的主题*
- #####[FMDB gitHub地址](https://github.com/ccgus/fmdb)

#二、为什么要再封装？
- **1、隔离网络第三方框架，方便修改维护**

- **2、虽然FMDB已经封装了SQLite，但依然需要写SQL语句，对于模型中属性比较多的话，拼接SQL语句将变得十分繁琐；而且对于字符串、字典、数组数据是没办法直接存入数据库，需要特殊处理。**
>因此封装面向模型，只需要传入对应的模型信息就能进行数据库操作，不需要写任何SQL语句，屏蔽内部所有操作，插入什么模型，就取出什么模型，简单易用！同时为了保证传入的都是模型数据，添加了异常提示，对传入的模型做了限制，必须是NSObject或者NSObject的子类,同时不响应事件
- **3、FMDB中操作执行异常只会打印出来（例如没有对应表的时候的操作），如果项目中打印信息比较多的话，不容易察觉。**
>因此操作异常时添加断言，准确定位操作异常位置以及异常情况

- **4、对数据库操作后需要关闭数据库，此时增加了代码量，而且容易忘记，内存没办法及时释放。**
>因此将关闭数据库操作封装在框架中，此时调用不需要关心数据库的关闭

- **5、面向模型开发，操作模型，更加面向对象，以前一般用数据库的时候一般都是直接保存后台返回的数据，此时每次取出来都要转一次模型，麻烦**

#三、API介绍（增删改查）
>**单例模式，项目中唯一，方便管理，但也只能创建一个数据库**

```
/**
 *  @author Clarence
 *
 *  单例创建，项目唯一
 */
+ (instancetype)shareManager;
```

>**创表，外界传入指定的类，工具会根据类来创建表，如果此时表已经存在，则跳过，没有才去创建，执行完这个操作后自动关闭数据库，释放内存**

```
#pragma mark -- 创表

/**
 *  @author Clarence
 *
 *  根据类名创建表，如果有则跳过，没有才创建，执行完毕后自动关闭数据库
 */
- (BOOL)fl_createTable:(Class)modelClass;
```


>**插入数据，可以传入单个模型，或者传入模型数组，此时内部处理了，遍历数组插入的期间数据库不会关闭，直到所有插入完毕后才关闭数据库；同时，如果传入的模型的FLDBID在对应表中已经存在，则执行更新操作，保证FLDBID对应数据的唯一性**

```
#pragma mark -- 插入

/**
 *  @author Clarence
 *
 *  @param model 插入单个模型或者模型数组,如果此时传入的模型对应的FLDBID在表中已经存在，则替换更新旧的
 *  如果没创建表就自动先创建，表名为模型类名
 *  此时执行完毕后自动关闭数据库
 *
 @return YES or NO
 */
- (BOOL)fl_insertModel:(id)model;
```

>**查询 提供三个方法**
- 查询表是否存在，执行完毕就会自动关闭数据库，由于此方法存在，框架工具中会出现错误提示信息，因为如果没有对应表，执行操作语句FMDB就会打印出错误信息
- 查找指定表中指定FLDBID的单个模型数据，执行完毕后自动关闭数据库，如果没有对应表，会有断言
- 查找指定表中模型数组（所有的），执行完毕后自动关闭数据库，如果没有对应表，会有断言

```
#pragma mark -- 查询
/**
 *  @author Clarence
 *
 *  查询指定表是否存在，执行完毕后自动关闭数据库
 */
- (BOOL)fl_isExitTable:(Class)modelClass;

/**
 *  @author Clarence
 *
 *  查找指定表中指定FLDBID的模型，执行完毕后自动关闭数据库，如果没有对应表，会有断言
 */
- (id)fl_searchModel:(Class)modelClass byID:(NSString *)FLDBID;
/**
 *  @author Clarence
 *
 *  查找指定表中模型数组（所有的），执行完毕后自动关闭数据库，如果没有对应表，会有断言
 */
- (NSArray *)fl_searchModelArr:(Class)modelClass;
```

>**修改 根据指定FLDBID，将新传入的模型替换旧的模型数据，执行完毕后自动关闭数据库，如果没有对应表，会有断言**

```
#pragma mark -- 修改

/**
 *  @author Clarence
 *
 *  修改指定DBID的模型，执行完毕后自动关闭数据库，如果没有对应表，会有断言
 */

- (BOOL)fl_modifyModel:(id)model byID:(NSString *)FLDBID;
```


>**删除，此时也提供了三个方法**
- 删除指定表，执行完毕后自动关闭数据库，如果没有对应表，会有断言
- 删除指定表格的所有数据，执行完毕后自动关闭数据库，如果没有对应表，会有断言
- 删除指定表中指定FLDBID的模型，执行完毕后自动关闭数据库，如果没有对应表，会有断言

```
#pragma mark -- 删除
/**
 *  @author Clarence
 *
 *  删除指定表，执行完毕后自动关闭数据库，如果没有对应表，会有断言
 */
- (BOOL)fl_dropTable:(Class)modelClass;
/**
 *  @author Clarence
 *
 *  删除指定表格的所有数据，执行完毕后自动关闭数据库，如果没有对应表，会有断言
 */
- (BOOL)fl_deleteAllModel:(Class)modelClass;

/**
 *  @author Clarence
 *
 *  删除指定表中指定FLDBID的模型，执行完毕后自动关闭数据库，如果没有对应表，会有断言
 */
- (BOOL)fl_deleteModel:(Class)modelClass byId:(NSString *)FLDBID;
```

#四、调用以及效果图（只举部分例子，详细请移步[gitHub](https://github.com/gitkong/FLFMDBManager)，有完整的Demo介绍）
> ######增

```
 [FLFMDBMANAGER fl_insertModel:arrM];
```

> ######删

```
[FLFMDBMANAGER fl_deleteModel:[FLStudentModel class] byId:model.FLDBID]
```

> ######改

```
[[FLFMDBManager shareManager] fl_modifyModel:model byID:model.FLDBID]
```

> ######查

```
[FLFMDBMANAGER fl_searchModel:[FLStudentModel class] byID:textField.text]
```

![FMDB封装效果.gif](http://upload-images.jianshu.io/upload_images/1085031-071af8fead4f57d3.gif?imageMogr2/auto-orient/strip)

#五、使用注意点以及不足之处

- 单例模式，因此只能创建一个数据库，对于聊天账号的数据存储就可能不适用

- 内部暂时使用FMDatabase这个类，线程不安全的，如果在多个线程中同时使用一个FMDatabase实例，会造成数据混乱等问题，后续会新增FMDatabaseQueue处理，线程安全

- ##### *需要在模型中添加一个属性FLDBID，NSString类型，为了绑定对应的数据，从而进行增删改查操作*

- 需要插入数据库的模型不支持继承，因为根据类名来创建表，框架内部只能读取当前类的属性，其父类的属性没办法获取

- 修改数据库中的模型数据只能通过指定的FLDBID作为条件修改

- 暂时不支持模型属性动态删减，如果删了对应属性（除了FLDBID）不影响使用，但如果增加属性了，只能从新建表存储

- 嵌套模型暂时不支持单表处理，需要创建多张表处理

- 为了保证操作安全，框架工具中添加判断表是否存在，因此如果表不存在，此时执行判断就会出现一个操作error提示,不影响使用
```
** DB Error: 1 "no such table: 对应表名"**
** DB Query: SELECT * FROM 对应表名**
```

#六、小总结

- *技术上实现并没多难，使用runtime就很容易获取当前模型类中的属性，关键还是处理一系列逻辑，代码比较简单，这里就不详细讲解了，Demo中有相对应的注释 ！*

- *每个人都有自己的编程想法和爱好，有人喜欢面向字典开发、有人喜欢面向模型开发，我就喜欢面向模型封装，屏蔽内部处理逻辑，调用只需要一句代码，享受封装的过程~*

- *喜欢给个star，如果你有什么问题或者建议，尽管留言，欢迎大家去[简书](http://www.jianshu.com/users/fe5700cfb223/latest_articles)关注我，喜欢就给个like 和 star，随时更新！谢谢支持！*
