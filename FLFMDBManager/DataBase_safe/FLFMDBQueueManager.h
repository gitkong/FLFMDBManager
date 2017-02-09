/*
 * author gitKong
 *
 * gitHub https://github.com/gitkong
 * cocoaChina http://code.cocoachina.com/user/
 * 简书 http://www.jianshu.com/users/fe5700cfb223/latest_articles
 * QQ 279761135
 * 微信公众号 原创技术分享
 * 喜欢就给个like 和 star 喔~
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#define FLDB_DEFAULT_NAME @"gitkong"

#define FLFMDBQUEUEMANAGER [FLFMDBQueueManager shareManager:FLDB_DEFAULT_NAME]

#define FLFMDBQUEUEMANAGERX(DB_NAME) [FLFMDBQueueManager shareManager:DB_NAME]

@interface FLFMDBQueueManager : NSObject
/**
 *  @author gitKong
 *
 *  单例创建，项目唯一
 */
+ (instancetype)shareManager:(NSString *)fl_dbName;

#pragma mark -- 创表

/**
 *  @author gitKong
 *
 *  根据类名创建表，如果有则跳过，没有才创建，执行完毕后自动关闭数据库
 */
- (void)fl_createTable:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete;

#pragma mark -- 插入

/**
 *  @author gitKong
 *
 *  @param model 插入单个模型或者模型数组,如果此时传入的模型对应的FLDBID在表中已经存在，则替换更新旧的
 *  如果没创建表就自动先创建，表名为模型类名
 *
 */
- (void)fl_insertModel:(id)model complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete;


#pragma mark -- 查询

/**
 *  @author gitKong
 *
 *  查询指定表是否存在，执行完毕后自动关闭数据库
 */
- (void)fl_isExitTable:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete;

/**
 *  @author gitKong
 *
 *  查找指定表中指定DBID的模型，执行完毕后自动关闭数据库
 */
- (void)fl_searchModel:(Class)modelClass byID:(NSString *)FLDBID complete:(void(^)(FLFMDBQueueManager *manager,id model))complete;

/**
 *  @author gitKong
 *
 *  查找指定表中模型数组（所有的），执行完毕后自动关闭数据库
 */
- (void)fl_searchModelArr:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager,NSArray *modelArr))complete;


#pragma mark -- 修改

/**
 *  @author gitKong
 *
 *  修改指定DBID的模型，执行完毕后自动关闭数据库
 */

- (void)fl_modifyModel:(id)model byID:(NSString *)FLDBID complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete;


#pragma mark -- 删除
/**
 *  @author gitKong
 *
 *  删除指定表，执行完毕后自动关闭数据库
 */
- (void)fl_dropTable:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete;

/**
 *  @author gitKong
 *
 *  删除数据库
 */
- (BOOL)fl_dropDB;
/**
 *  @author gitKong
 *
 *  删除指定表格的所有数据，执行完毕后自动关闭数据库
 */
- (void)fl_deleteAllModel:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete;

/**
 *  @author gitKong
 *
 *  删除指定表中指定DBID的模型，执行完毕后自动关闭数据库
 */
- (void)fl_deleteModel:(Class)modelClass byId:(NSString *)FLDBID complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete;

@end
