/*
 * author 孔凡列
 *
 * gitHub https://github.com/gitkong
 * cocoaChina http://code.cocoachina.com/user/
 * 简书 http://www.jianshu.com/users/fe5700cfb223/latest_articles
 * QQ 279761135
 * 喜欢就给个like 和 star 喔~
 */



#import <Foundation/Foundation.h>

#define FLFMDBMANAGER [FLFMDBManager shareManager]

@interface FLFMDBManager : NSObject

/**
 *  @author Clarence
 *
 *  单例创建，项目唯一
 */
+ (instancetype)shareManager;

#pragma mark -- 创表

/**
 *  @author Clarence
 *
 *  根据类名创建表，如果有则跳过，没有才创建，执行完毕后自动关闭数据库
 */
- (BOOL)fl_createTable:(Class)modelClass;

#pragma mark -- 插入

/**
 *  @author Clarence
 *
 *  插入单个模型，如果没创建表就自动先创建，表名为模型类名
 *  此时执行完毕后自动关闭数据库
 */
- (BOOL)fl_insertModel:(id)model;
/**
 *  @author Clarence
 *
 *  插入模型数组，如果没有创建表就自动创建，表名为模型类名
 *  内部已优化处理，数组插入完毕后才关闭数据库
 */
- (BOOL)fl_insertModelArr:(NSArray *)modelArr;


#pragma mark -- 查询
/**
 *  @author Clarence
 *
 *  查询指定表是否存在，执行完毕后自动关闭数据库
 */
- (BOOL)fl_isExitTable:(Class)modelClass;

/**
 *  @author Clarence
 *
 *  查找指定表中指定DBID的模型，执行完毕后自动关闭数据库，如果没有对应表，会有断言
 */
- (id)fl_searchModel:(Class)modelClass byID:(NSString *)FLDBID;
/**
 *  @author Clarence
 *
 *  查找指定表中模型数组（所有的），执行完毕后自动关闭数据库，如果没有对应表，会有断言
 */
- (NSArray *)fl_searchModelArr:(Class)modelClass;


#pragma mark -- 修改

/**
 *  @author Clarence
 *
 *  修改指定DBID的模型，执行完毕后自动关闭数据库，如果没有对应表，会有断言
 */

- (BOOL)fl_modifyModel:(id)model byID:(NSString *)FLDBID;


#pragma mark -- 删除
/**
 *  @author Clarence
 *
 *  删除指定表，执行完毕后自动关闭数据库，如果没有对应表，会有断言
 */
- (BOOL)fl_dropTable:(Class)modelClass;
/**
 *  @author Clarence
 *
 *  删除指定表格的所有数据，执行完毕后自动关闭数据库，如果没有对应表，会有断言
 */
- (BOOL)fl_deleteAllModel:(Class)modelClass;

/**
 *  @author Clarence
 *
 *  删除指定表中指定DBID的模型，执行完毕后自动关闭数据库，如果没有对应表，会有断言
 */
- (BOOL)fl_deleteModel:(Class)modelClass byId:(NSString *)FLDBID;

@end
