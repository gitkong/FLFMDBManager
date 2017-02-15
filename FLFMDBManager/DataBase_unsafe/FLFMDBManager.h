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

#define FLDB_DEFAULT_NAME @"gitkong"
#define FLFMDBMANAGER [FLFMDBManager shareManager:FLDB_DEFAULT_NAME]
#define FLFMDBMANAGERX(DB_NAME) [FLFMDBManager shareManager:DB_NAME]

@interface FLFMDBManager : NSObject

/**
 *  @author Clarence
 *
 *  单例创建，项目唯一
 */
+ (instancetype)shareManager:(NSString *)fl_dbName;

#pragma mark -- 创表

/**
 *  @author Clarence
 *
 *  根据类名创建表，如果有则跳过，没有才创建，执行完毕后自动关闭数据库
 
 *  @return YES表示创建表格操作执行成功 或者 表格已经存在，NO则失败
 */
- (BOOL)fl_createTable:(Class)modelClass;

#pragma mark -- 插入

/**
 *  @author Clarence
 *
 *  @param model 插入单个模型或者模型数组,如果此时传入的模型对应的FLDBID在表中已经存在，则替换更新旧的
 *  如果没创建表就自动先创建，表名为模型类名
 *  此时执行完毕后自动关闭数据库
 
 *  @return YES表示创建表格操作执行成功 或者 表格已经存在，NO则失败
 */
- (BOOL)fl_insertModel:(id)model;



#pragma mark -- 查询
/**
 *  @author Clarence
 *
 *  查询指定表是否存在，执行完毕后自动关闭数据库
 
 *  @return YES表示操作执行成功并且 modelClass 表格存在，NO则操作失败或者 modelClass 表格不存在
 */
- (BOOL)fl_isExitTable:(Class)modelClass;

/**
 *  @author Clarence
 *
 *  查找指定表中指定DBID的模型，执行完毕后自动关闭数据库
 
 *  @return 不等于nil，表示查询数据操作执行成功并有数据，返回查询成功的模型数据，nil则表示查询操作失败 或者 查询成功但数据为空 或者 对应的表格不存在
 */
- (id)fl_searchModel:(Class)modelClass byID:(NSString *)FLDBID;
/**
 *  @author Clarence
 *
 *  查找指定表中模型数组（所有的），执行完毕后自动关闭数据库
 
 *  @return 不等于nil，表示查询数据操作执行成功并有数据，返回查询成功的模型数据，nil则表示查询操作失败 或者 查询成功但数据为空 或者 对应的表格不存在
 */
- (NSArray *)fl_searchModelArr:(Class)modelClass;


#pragma mark -- 修改

/**
 *  @author Clarence
 *
 *  修改指定DBID的模型，执行完毕后自动关闭数据库
 
 *  @return YES表示更新操作执行成功，NO则操作失败 或者 对应的表格不存在
 */

- (BOOL)fl_modifyModel:(id)model byID:(NSString *)FLDBID;


#pragma mark -- 删除
/**
 *  @author Clarence
 *
 *  删除指定表，执行完毕后自动关闭数据库
 
 *  @return YES表示删除操作执行成功，NO则操作失败 或者 对应的表格不存在
 */
- (BOOL)fl_dropTable:(Class)modelClass;
/**
 *  @author gitKong
 *
 *  删除数据库
 
 *  @return 操作不涉及到数据库操作 YES 表示删除成功，NO则删除失败
 */
- (BOOL)fl_dropDB;
/**
 *  @author Clarence
 *
 *  删除指定表格的所有数据，执行完毕后自动关闭数据库
 
 *  @return YES表示删除操作执行成功，NO则操作失败 或者 对应的表格不存在 或者 没有对应数据可以删除
 */
- (BOOL)fl_deleteAllModel:(Class)modelClass;

/**
 *  @author Clarence
 *
 *  删除指定表中指定DBID的模型，执行完毕后自动关闭数据库
 
 *  @return YES表示删除操作执行成功，NO则操作失败 或者 对应的表格不存在 或者 没有对应数据可以删除
 */
- (BOOL)fl_deleteModel:(Class)modelClass byId:(NSString *)FLDBID;

@end
