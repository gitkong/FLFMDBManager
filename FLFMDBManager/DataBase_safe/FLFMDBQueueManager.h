/*
 * author gitKong
 *
 * 个人博客 https://gitKong.github.io
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
/**
 *  @author gitKong
 *
 *  多数据库操作暂时不开放，有问题需要解决，敬请期待
 */
//#define FLFMDBQUEUEMANAGERX(DB_NAME) [FLFMDBQueueManager shareManager:DB_NAME]

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
 *  根据类名创建表，如果有则跳过，没有才创建
 
 *  flag：YES表示创建表格操作执行成功 或者 表格已经存在，NO则失败
 
 *  注意：此方法创建表格后不会自动关闭数据库，当开发者执行其他操作（删除数据库除外）后会自动关闭数据库
 
 *  建议使用insert创建表格并添加数据
 */
- (void)fl_createTable:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete;


#pragma mark -- 插入

/**
 *  @author gitKong
 *
 *  @param model 插入单个模型或者模型数组,如果此时传入的模型对应的FLDBID在表中已经存在，则替换更新旧的
 
 *  flag：YES表示插入数据操作执行成功，NO则失败
 
 *  注意：如果此时没创建表就自动先创建，表名为模型类名，数据插入完毕后会自动关闭数据库
 
 *  建议直接使用insert创建表格并添加数据，因为create方法执行完不会自动关闭数据库
 */
- (void)fl_insertModel:(id)model complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete;

#pragma mark -- 查询

/**
 *  @author gitKong
 *
 *  查询指定表是否存在
 
 *  flag：YES表示操作执行成功并且 modelClass 表格存在，NO则操作失败或者 modelClass 表格不存在
 
 *  注意：操作执行完毕会自动关闭数据库
 */
- (void)fl_isExitTable:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete;
/**
 *  @author gitKong
 *
 *  查找指定表中指定DBID的模型
 
 *  model：不等于nil，表示查询数据操作执行成功并有数据，返回查询成功的模型数据，nil则表示查询操作失败 或者 查询成功但数据为空 或者 对应的表格不存在
 
 *  注意：操作执行完毕会自动关闭数据库
 */
- (void)fl_searchModel:(Class)modelClass byID:(NSString *)FLDBID complete:(void(^)(FLFMDBQueueManager *manager,id model))complete;
/**
 *  @author gitKong
 *
 *  查找指定表中模型数组（所有的）
 
 *  modelArr：不等于nil，表示查询数据操作执行成功并有数据，返回查询成功的模型数据，nil则表示查询操作失败 或者 查询成功但数据为空 或者 对应的表格不存在
 
 *  注意：操作执行完毕会自动关闭数据库
 */
- (void)fl_searchModelArr:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager,NSArray *modelArr))complete;

#pragma mark -- 修改

/**
 *  @author gitKong
 *
 *  修改指定DBID的模型
 
 *  flag：YES表示更新操作执行成功，NO则操作失败 或者 对应的表格不存在
 
 *  注意：操作执行完毕会自动关闭数据库
 */

- (void)fl_modifyModel:(id)model byID:(NSString *)FLDBID complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete;


#pragma mark -- 删除
/**
 *  @author gitKong
 *
 *  删除指定表
 
 *  flag：YES表示删除操作执行成功，NO则操作失败 或者 对应的表格不存在
 
 *  注意：操作执行完毕会自动关闭数据库
 */
- (void)fl_dropTable:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete;
/**
 *  @author gitKong
 *
 *  删除数据库
 
 *  注意：操作不涉及到数据库操作，如果你通过create创建后执行此操作，不会关闭数据库
 
 *  @return YES 表示删除成功，NO则删除失败
 */
- (BOOL)fl_dropDB;
/**
 *  @author gitKong
 *
 *  删除指定表格的所有数据
 
 *  flag：YES表示删除操作执行成功，NO则操作失败 或者 对应的表格不存在 或者 没有对应数据可以删除
 
 *  注意：操作执行完毕会自动关闭数据库
 */
- (void)fl_deleteAllModel:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete;

/**
 *  @author gitKong
 *
 *  删除指定表中指定DBID的模型
 
 *  flag：YES表示删除操作执行成功，NO则操作失败 或者 对应的表格不存在 或者 没有对应数据可以删除
 
 *  注意：操作执行完毕会自动关闭数据库
 */
- (void)fl_deleteModel:(Class)modelClass byId:(NSString *)FLDBID complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete;
@end
