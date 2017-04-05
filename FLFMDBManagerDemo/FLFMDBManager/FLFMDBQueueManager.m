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


#import "FLFMDBQueueManager.h"
#import <objc/runtime.h>
#import "FMDB.h"

#define FLCURRENTDBQUEUE (FMDatabaseQueue *)self.queueDictM[self.dbName]

@interface FLFMDBQueueManager ()

@property (nonatomic,copy)NSString *dbName;

@property (nonatomic,strong)NSMutableDictionary *queueDictM;

@end

@implementation FLFMDBQueueManager

+ (instancetype)shareManager:(NSString *)fl_dbName{
    
    // 1、获取沙盒中数据库的路径
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *tempDBName = nil;
    if (fl_dbName && ![fl_dbName isEqualToString:@""]) {
        tempDBName = fl_dbName;
    }
    else{
        tempDBName = FLDB_DEFAULT_NAME;
    }
    
    NSString *sqlFilePath = [path stringByAppendingPathComponent:[tempDBName stringByAppendingString:@".sqlite"]];
    
    // 2、判断 caches 文件夹是否存在.不存在则创建
    NSFileManager *manager = [NSFileManager defaultManager];
    BOOL isDirectory = YES;
    BOOL tag = [manager fileExistsAtPath:sqlFilePath isDirectory:&isDirectory];
    
    
    static FLFMDBQueueManager *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.queueDictM = [NSMutableDictionary dictionary];
        if (tag) {
            // 通过路径创建数据库
            FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:sqlFilePath];
            [instance.queueDictM setValue:queue forKey:tempDBName];
        }
    });
    
    if (!tag) {
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
        // 通过路径创建数据库
        FMDatabaseQueue *queue = [FMDatabaseQueue databaseQueueWithPath:sqlFilePath];
        if (!instance.queueDictM) {
            instance.queueDictM = [NSMutableDictionary dictionary];
        }
        [instance.queueDictM setValue:queue forKey:tempDBName];
    }
    
    instance.dbName = tempDBName;
    
    return instance;
}

#pragma mark -- public method


- (void)fl_createTable:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    // 创建完毕不关闭数据库，执行完其他操作会关闭
    [self fl_createTable:modelClass autoCloseDB:NO complete:complete];
}

- (void)fl_insertModel:(id)model complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    [self fl_insertModel:model autoCloseDB:YES complete:complete];
}

- (void)fl_insertModel:(id)model autoCloseDB:(BOOL)autoCloseDB complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    if ([model isKindOfClass:[NSArray class]] || [model isKindOfClass:[NSMutableArray class]]) {
        NSArray *modelArr = (NSArray *)model;
        [self fl_insertModelArr:modelArr autoCloseDB:autoCloseDB complete:complete];
    }
    else{
        [self fl_insertSingleModel:model inAsync:YES autoCloseDB:autoCloseDB complete:complete];
    }
}

- (void)fl_searchModel:(Class)modelClass byID:(NSString *)FLDBID complete:(void(^)(FLFMDBQueueManager *manager,id model))complete{
    [self fl_searchModel:modelClass byID:FLDBID autoCloseDB:YES complete:complete];
}

- (void)fl_searchModelArr:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager,NSArray *modelArr))complete{
    [self fl_searchModelArr:modelClass autoCloseDB:YES complete:complete];
}

- (void)fl_searchModelArr:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB complete:(void(^)(FLFMDBQueueManager *manager,NSArray *modelArr))complete{
    __block NSArray *modelArr = nil;
    __weak typeof(self) weakSelf = self;
    FLDISPATCH_ASYNC_GLOBAL(^{
        //把任务包装到事务里
        [FLCURRENTDBQUEUE inTransaction:^(FMDatabase *db, BOOL *rollback){
            typeof(self) strongSelf = weakSelf;
            modelArr = [strongSelf fl_search:db modelArr:modelClass autoCloseDB:autoCloseDB];
            // 回调
            if (complete) {
                FLDISPATCH_ASYNC_MAIN(^{
                    complete(strongSelf,modelArr);
                });
            }
            //如果有错误 返回
            if (!modelArr){
                *rollback = YES;
                return;
            }
        }];
    });
}

- (void)fl_modifyModel:(id)model byID:(NSString *)FLDBID complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    [self fl_modifyModel:model byID:FLDBID autoCloseDB:YES complete:complete];
}

- (void)fl_modifyModel:(id)model byID:(NSString *)FLDBID autoCloseDB:(BOOL)autoCloseDB complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    __block BOOL success = true;
    __weak typeof(self) weakSelf = self;
    FLDISPATCH_ASYNC_GLOBAL(^{
        //把任务包装到事务里
        [FLCURRENTDBQUEUE inTransaction:^(FMDatabase *db, BOOL *rollback){
            typeof(self) strongSelf = weakSelf;
            
            success = [strongSelf fl_modify:db model:model byID:FLDBID autoCloseDB:autoCloseDB];
            // 回调
            if (complete) {
                FLDISPATCH_ASYNC_MAIN(^{
                    complete(strongSelf,success);
                });
            }
            
            //如果有错误 返回
            if (!success){
                *rollback = YES;
                return;
            }
        }];
    });
}

- (void)fl_dropTable:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    [self fl_dropTable:modelClass autoCloseDB:YES complete:complete];
}

- (void)fl_dropTable:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    __block BOOL success = true;
    __weak typeof(self) weakSelf = self;
    FLDISPATCH_ASYNC_GLOBAL(^{
        //把任务包装到事务里
        [FLCURRENTDBQUEUE inTransaction:^(FMDatabase *db, BOOL *rollback){
            typeof(self) strongSelf = weakSelf;
            
            success = [strongSelf fl_drop:db table:modelClass autoCloseDB:autoCloseDB];
            // 回调
            if (complete) {
                FLDISPATCH_ASYNC_MAIN(^{
                    complete(strongSelf,success);
                });
            }
            
            //如果有错误 返回
            if (!success){
                *rollback = YES;
                return;
            }
        }];
    });
}

//- (void)fl_dropAllTable:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
//    NSString *sqlStr = @"select table_name from information_schema.tables where TABLE_SCHEMA = 'gitkong.sqlite'";
//    __weak typeof(self) weakSelf = self;
//    __block BOOL success = true;
//    [FLCURRENTDBQUEUE inTransaction:^(FMDatabase *db, BOOL *rollback) {
//        
//        typeof(self) strongSelf = weakSelf;
//        FMResultSet *rs = [db executeQuery:sqlStr];
//        while ([rs next]) {
//            NSString *table_name = [rs stringForColumn:@"table_name"];
//            NSLog(@"%@",table_name);
//        }
//        //strongSelf.db = db;
//        // 回调
//        if (complete) {
//            dispatch_async(dispatch_get_main_queue(), ^{
//                complete(strongSelf,success);
//            });
//        }
//    }];
//}

- (BOOL)fl_dropDB{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *sqlFilePath = [path stringByAppendingPathComponent:[self.dbName stringByAppendingString:@".sqlite"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:sqlFilePath error:NULL];
}

- (void)fl_deleteAllModel:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    [self fl_deleteAllModel:modelClass autoCloseDB:YES complete:complete];
}

- (void)fl_deleteAllModel:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    __block BOOL success = true;
    __weak typeof(self) weakSelf = self;
    
    FLDISPATCH_ASYNC_GLOBAL(^{
        //把任务包装到事务里
        [FLCURRENTDBQUEUE inTransaction:^(FMDatabase *db, BOOL *rollback){
            typeof(self) strongSelf = weakSelf;
            
            success = [strongSelf fl_delete:db allModel:modelClass autoCloseDB:autoCloseDB];
            // 回调
            if (complete) {
                FLDISPATCH_ASYNC_MAIN(^{
                    complete(strongSelf,success);
                });
            }
            
            //如果有错误 返回
            if (!success){
                *rollback = YES;
                return;
            }
        }];
    });
}

- (void)fl_deleteModel:(Class)modelClass byId:(NSString *)FLDBID complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    [self fl_deleteModel:modelClass byId:FLDBID autoCloseDB:YES complete:complete];
}

- (void)fl_deleteModel:(Class)modelClass byId:(NSString *)FLDBID autoCloseDB:(BOOL)autoCloseDB complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    __block BOOL success = true;
    __weak typeof(self) weakSelf = self;
    FLDISPATCH_ASYNC_GLOBAL(^{
        //把任务包装到事务里
        [FLCURRENTDBQUEUE inTransaction:^(FMDatabase *db, BOOL *rollback){
            typeof(self) strongSelf = weakSelf;
            
            success = [strongSelf fl_delete:db model:modelClass byId:FLDBID autoCloseDB:autoCloseDB];
            // 回调
            if (complete) {
                FLDISPATCH_ASYNC_MAIN(^{
                    complete(strongSelf,success);
                });
            }
            
            //如果有错误 返回
            if (!success){
                *rollback = YES;
                return;
            }
        }];
    });
}

- (void)fl_isExitTable:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    [self isExitTable:modelClass autoCloseDB:YES complete:complete]; 
}


#pragma mark -- private method
/**
 *  @author Clarence
 *
 *  创建表的SQL语句
 */
- (NSString *)createTableSQL:(Class)modelClass{
    NSMutableString *sqlPropertyM = [NSMutableString stringWithFormat:@"CREATE TABLE IF NOT EXISTS %@ (id INTEGER PRIMARY KEY AUTOINCREMENT ",modelClass];
    
    unsigned int outCount;
    Ivar * ivars = class_copyIvarList(modelClass, &outCount);
    for (int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)] ;
        if([[key substringToIndex:1] isEqualToString:@"_"]){
            key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
        [sqlPropertyM appendFormat:@", %@",key];
    }
    [sqlPropertyM appendString:@")"];
    /*
     *  BY gitKong
     *
     *  注意释放
     */
    free(ivars);
    return sqlPropertyM;
}

/**
 *  @author Clarence
 *
 *  创建插入表的SQL语句
 */
- (NSString *)createInsertSQL:(id)model{// OR REPLACE
    NSMutableString *sqlValueM = [NSMutableString stringWithFormat:@"INSERT INTO %@ (",[model class]];
    unsigned int outCount;
    Ivar * ivars = class_copyIvarList([model class], &outCount);
    for (int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)] ;
        //free(ivar);
        if([[key substringToIndex:1] isEqualToString:@"_"]){
            key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
        
        if (i == 0) {
            [sqlValueM appendString:key];
        }
        else{
            [sqlValueM appendFormat:@", %@",key];
        }
    }
    [sqlValueM appendString:@") VALUES ("];
    
    for (int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)] ;
        //free(ivar);
        if([[key substringToIndex:1] isEqualToString:@"_"]){
            key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
        
        id value = [model valueForKey:key];
        /**
         *  @author gitKong
         *
         *  防止属性没赋值
         */
        if (value == [NSNull null]) {
            value = @"";
        }
        if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]] || [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]]) {
//            value = [NSString stringWithFormat:@"%@",value];
            value = [self fl_ID2String:value];
        }
        if (i == 0) {
            // sql 语句中字符串需要单引号或者双引号括起来
            [sqlValueM appendFormat:@"%@",[value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'",value ? value : @""] : value ? value : 0];
        }
        else{
            [sqlValueM appendFormat:@", %@",[value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'",value ? value : @""] : value ? value : 0];
        }
    }
    //    [sqlValueM appendFormat:@" WHERE FLDBID = '%@'",[model valueForKey:@"FLDBID"]];
    [sqlValueM appendString:@");"];
    free(ivars);
    return sqlValueM;
}
    
- (id)fl_string2ID:(NSString *)str{
    if (str == nil) {
        return nil;
    }
    NSData *jsonData = [str dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    id value = [NSJSONSerialization JSONObjectWithData:jsonData
                                                        options:NSJSONReadingMutableContainers
                                                          error:&err];
    if(err){
        return nil;
    }
    return value;
}
    
- (NSString *)fl_ID2String:(id)value{
    NSError *parseError = nil;
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:value options:NSJSONWritingPrettyPrinted error:&parseError];
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
}
    
/**
 *  @author gitkong
 *
 *  指定的表是否存在
 */
- (void)isExitTable:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    __block BOOL success = true;
    __weak typeof(self) weakSelf = self;
    //把任务包装到事务里
    FLDISPATCH_ASYNC_GLOBAL(^{
        [FLCURRENTDBQUEUE inTransaction:^(FMDatabase *db, BOOL *rollback){
            typeof(self) strongSelf = weakSelf;
            
            success = [strongSelf fl_isExit:db table:modelClass autoCloseDB:autoCloseDB];

            //strongSelf.db = db;
            // 回调回去
            if (complete) {
                FLDISPATCH_ASYNC_MAIN(^{
                    complete(strongSelf,success);
                });
            }
            //如果有错误 返回
            if (!success){
                *rollback = YES;
                return;
            }
        }];
    });
}

- (BOOL)fl_isExit:(FMDatabase *)db table:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB{

//    BOOL success = [db open];
//    FMResultSet *resultSet = nil;
//    
//    resultSet = [db executeQuery:@"SELECT * FROM sqlite_master where type='table';"];
//    if (resultSet == nil) {
//        success = NO;
//    }
//    // 遍历查询结果
//    while ([resultSet next]) {
//        NSString *str1 = [resultSet stringForColumnIndex:1];
//        if ([str1 isEqualToString:NSStringFromClass(modelClass)]) {
//            success = YES;
//            break;
//        }
//        else{
//            success = NO;
//        }
//    }
//    // 操作完毕是否需要关闭
//    if (autoCloseDB) {
//        [self fl_closeDB:db];
//    }
//    return success;
    /**
     *  @author gitKong
     *
     *  以下方法不安全，会导致有时候判断不正确
     */
    BOOL success = [db open];
    if (success){
        FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", modelClass];
        if (rs) {
            success = NO;
            while ([rs next]){
                NSInteger count = [rs intForColumn:@"count"];
                
                if (0 == count){
                    success = NO;
                }
                else{
                    success = YES;
                    break;
                }
            }
        }
        else{
            success = NO;
        }
    }
    // 操作完毕是否需要关闭
    if (autoCloseDB) {
        [self fl_closeDB:db];
    }
    return success;
}



/**
 *  @author gitKong
 *
 *  创表
 */
- (void)fl_createTable:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    
    __block BOOL success = true;
    __weak typeof(self) weakSelf = self;
    
    FLDISPATCH_ASYNC_GLOBAL(^{
        //把任务包装到事务里
        [FLCURRENTDBQUEUE inTransaction:^(FMDatabase *db, BOOL *rollback){
            typeof(self) strongSelf = weakSelf;
            success = [strongSelf fl_create:db table:modelClass autoCloseDB:autoCloseDB];
            
            // 回调
            if (complete) {
                FLDISPATCH_ASYNC_MAIN(^{
                    
                    complete(strongSelf,success);
                });
            }
            
            //如果有错误 返回
            if (!success){
                *rollback = YES;
                return;
            }
        }];
    });
    
}

- (BOOL)fl_create:(FMDatabase *)db table:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB{
    if ([db open]) {
        // 创表,判断是否已经存在
        if ([self fl_isExit:db table:modelClass autoCloseDB:NO]) {
            if (autoCloseDB) {
                [self fl_closeDB:db];
            }
            return YES;
        }
        else{
            BOOL success = [db executeUpdate:[self createTableSQL:modelClass]];
            // 关闭数据库
            if (autoCloseDB) {
                [self fl_closeDB:db];
            }
            return success;
        }
    }
    else{
        // 关闭数据库
        if (autoCloseDB) {
            [self fl_closeDB:db];
        }
        return NO;
    }
}

/**
 *  @author gitKong
 *
 *  插入数据
 */
- (void)fl_insertSingleModel:(id)model inAsync:(BOOL)inAsync autoCloseDB:(BOOL)autoCloseDB complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    __block BOOL success = true;
    __weak typeof(self) weakSelf = self;
    if (inAsync) {
        FLDISPATCH_ASYNC_GLOBAL(^{
            //把任务包装到事务里
            [FLCURRENTDBQUEUE inTransaction:^(FMDatabase *db, BOOL *rollback){
                typeof(self) strongSelf = weakSelf;
                success = [strongSelf fl_insert:db model:model autoCloseDB:autoCloseDB];
                if (complete) {
                    FLDISPATCH_ASYNC_MAIN(^{
                        complete(strongSelf,success);
                    });
                }
                //如果有错误 返回
                if (!success){
                    *rollback = YES;
                    return;
                }
            }];
        });
    }
    else{
        //把任务包装到事务里
        [FLCURRENTDBQUEUE inTransaction:^(FMDatabase *db, BOOL *rollback){
            typeof(self) strongSelf = weakSelf;
            
            success = [strongSelf fl_insert:db model:model autoCloseDB:autoCloseDB];
            if (complete) {
                FLDISPATCH_ASYNC_MAIN(^{
                    complete(strongSelf,success);
                });
            }
            //如果有错误 返回
            if (!success){
                *rollback = YES;
                return;
            }
        }];
    }
    
}


- (void)fl_insertModelArr:(NSArray *)modelArr autoCloseDB:(BOOL)autoCloseDB complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    // 使用此方法会导致查询不到数据，但插入是成功的，原因不明,待解决
    //    __block BOOL success = true;
    //    __weak typeof(self) weakSelf = self;
    //    //把任务包装到事务里
    //    [FLCURRENTDBQUEUE inTransaction:^(FMDatabase *db, BOOL *rollback){
    //        typeof(self) strongSelf = weakSelf;
    //        NSLog(@"fl_insertModel----------------------db--%p",db);
    //        success = [strongSelf fl_insert:db modelArr:modelArr autoCloseDB:YES];
    //            //strongSelf.db = db;
    //
    //        complete(strongSelf,success);
    //
    //        //如果有错误 返回
    //        if (!success){
    //            *rollback = YES;
    //            return;
    //        }
    //    }];
    
    __weak typeof(self) weakSelf = self;
    FLDISPATCH_ASYNC_GLOBAL(^{
        __strong typeof(weakSelf) strongSelf = weakSelf;
        for (NSInteger index = 0; index < modelArr.count; index ++) {
            id model = modelArr[index];
            if (index == modelArr.count - 1) {
                [strongSelf fl_insertSingleModel:model inAsync:NO autoCloseDB:autoCloseDB complete:^(FLFMDBQueueManager *manager, BOOL flag) {
                    if (complete) {
                        FLDISPATCH_ASYNC_MAIN(^{
                            complete(strongSelf,flag);
                        });
                    }
                }];
                return;
            }
            [strongSelf fl_insertSingleModel:model inAsync:NO autoCloseDB:autoCloseDB complete:nil];
        }
    });
}


- (BOOL)fl_insert:(FMDatabase *)db modelArr:(NSArray *)modelArr autoCloseDB:(BOOL)autoCloseDB{
    
    BOOL success = true;
    
    for (NSInteger index = 0; index < modelArr.count; index ++) {
        id model = modelArr[index];
        // 处理过程中不关闭数据库
        success = [self fl_insert:db model:model autoCloseDB:NO];
    }
    // 操作完关闭数据库
    if (autoCloseDB) {
        [self fl_closeDB:db];
    }
    return success;
}


- (BOOL)fl_insert:(FMDatabase *)db model:(id)model autoCloseDB:(BOOL)autoCloseDB{
    NSAssert(![model isKindOfClass:[UIResponder class]], @"必须保证模型是NSObject或者NSObject的子类,同时不响应事件");
    if ([db open]) {
        // 没有表的时候，先创建再插入
        
        // 此时有三步操作，第一步处理完不关闭数据库
        NSLog(@"-----------------%@",[NSThread currentThread]);
        if (![self fl_isExit:db table:[model class] autoCloseDB:NO]) {
            // 第二步处理完不关闭数据库
            BOOL success = [self fl_create:db table:[model class] autoCloseDB:NO];
            success = [db open];
//            if (success) {
//                NSString *fl_dbid = [model valueForKey:@"FLDBID"];
//                [self fl_search:db model:[model class] byID:fl_dbid autoCloseDB:NO];
//                success = [db executeUpdate:[self createInsertSQL:model]];
//                // 最后一步操作完毕，询问是否需要关闭
//                if (autoCloseDB) {
//                    [self fl_closeDB:db];
//                }
//                return success;
//            }
            
            
            if (success) {
                NSString *fl_dbid = [model valueForKey:@"FLDBID"];
                
                id judgeModle = [self fl_search:db model:[model class] byID:fl_dbid autoCloseDB:YES];
                
                if ([[judgeModle valueForKey:@"FLDBID"] isEqualToString:fl_dbid]) {
                    BOOL updataSuccess = [self fl_modify:db model:model byID:fl_dbid autoCloseDB:NO];
                    if (autoCloseDB) {
                        [self fl_closeDB:db];
                    }
                    return updataSuccess;
                }
                else{
                    /**
                     *  @author gitKong
                     *
                     *  此时运行到这里，数据库的对应表格提示没有，暂时不明白，因此在这重新创建一次，确保表格存在
                     */
                    BOOL insertSuccess = YES;
                    insertSuccess = [self fl_create:db table:[model class] autoCloseDB:NO];
                    insertSuccess = [db open];
                    if (insertSuccess) {
                        insertSuccess = [db executeUpdate:[self createInsertSQL:model]];
                    }
                    
                    // 最后一步操作完毕，询问是否需要关闭
                    if (autoCloseDB) {
                        [self fl_closeDB:db];
                    }
                    return insertSuccess;
                }
            
            }
            else {
                // 第二步操作失败，询问是否需要关闭,可能是创表失败，或者是已经有表
                if (autoCloseDB) {
                    [self fl_closeDB:db];
                }
                return NO;
            }
        }
        // 已经创建有对应的表，直接插入
        else{
//            BOOL success = [self fl_create:db table:[model class] autoCloseDB:NO];
//            if (success) {
//                NSLog(@"---------------------------success");
//            }
            NSString *fl_dbid = [model valueForKey:@"FLDBID"];

            id judgeModle = [self fl_search:db model:[model class] byID:fl_dbid autoCloseDB:NO];
            
            if ([[judgeModle valueForKey:@"FLDBID"] isEqualToString:fl_dbid]) {
                BOOL updataSuccess = [self fl_modify:db model:model byID:fl_dbid autoCloseDB:NO];
                if (autoCloseDB) {
                    [self fl_closeDB:db];
                }
                return updataSuccess;
            }
            else{
                BOOL insertSuccess = [db executeUpdate:[self createInsertSQL:model]];
                // 最后一步操作完毕，询问是否需要关闭
                if (autoCloseDB) {
                    [self fl_closeDB:db];
                }
                return insertSuccess;
                
            }
        }
    }
    else{
        if (autoCloseDB) {
            [self fl_closeDB:db];
        }
        return NO;
    }
//    return YES;
}


/**
 *  @author gitKong
 *
 *  查询
 */
- (void)fl_searchModel:(Class)modelClass byID:(NSString *)FLDBID autoCloseDB:(BOOL)autoCloseDB complete:(void(^)(FLFMDBQueueManager *manager,id model))complete{
    __block BOOL success = true;
    __weak typeof(self) weakSelf = self;
    //把任务包装到事务里
    FLDISPATCH_ASYNC_GLOBAL(^{
        [FLCURRENTDBQUEUE inTransaction:^(FMDatabase *db, BOOL *rollback){
            typeof(self) strongSelf = weakSelf;
            // 回调
            if (complete) {
                FLDISPATCH_ASYNC_MAIN(^{
                    complete(strongSelf,[strongSelf fl_search:db model:modelClass byID:FLDBID autoCloseDB:autoCloseDB]);
                });
            }
            
            //如果有错误 返回
            if (!success){
                *rollback = YES;
                return;
            }
        }];
    });
}



- (id)fl_search:(FMDatabase *)db model:(Class)modelClass byID:(NSString *)FLDBID autoCloseDB:(BOOL)autoCloseDB{
    
    if ([db open]) {
        BOOL success = [self fl_isExit:db table:modelClass autoCloseDB:NO];
        if (!success) {
            if (autoCloseDB) {
                [self fl_closeDB:db];
            }
            return nil;
        }
        
        NSString *str = [NSString stringWithFormat:@"SELECT * FROM %@ WHERE FLDBID = '%@';",modelClass,FLDBID];
        // 查询数据
        FMResultSet *rs = [db executeQuery:str];
        // 创建对象
        id object = nil;
        // 遍历结果集
        while ([rs next]) {
            object = [[modelClass class] new];
            unsigned int outCount;
            Ivar * ivars = class_copyIvarList(modelClass, &outCount);
            for (int i = 0; i < outCount; i ++) {
                Ivar ivar = ivars[i];
                NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)] ;
                //free(ivar);
                if([[key substringToIndex:1] isEqualToString:@"_"]){
                    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }
                
                id value = [rs objectForColumnName:key];
                if ([value isKindOfClass:[NSString class]]) {
                    
                    NSData *data = [value dataUsingEncoding:NSUTF8StringEncoding];
                    id result = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                    if ([result isKindOfClass:[NSDictionary class]] || [result isKindOfClass:[NSMutableDictionary class]] || [result isKindOfClass:[NSArray class]] || [result isKindOfClass:[NSMutableArray class]]) {
                        [object setValue:result forKey:key];
                    }
                    else{
                        [object setValue:value forKey:key];
                    }
                }
                else{
                    [object setValue:value forKey:key];
                }
            }
            free(ivars);
        }
        if (autoCloseDB) {
            [self fl_closeDB:db];
        }
        return object;
    }
    else{
        if (autoCloseDB) {
            [self fl_closeDB:db];
        }
        return nil;
    }
    
}

- (NSArray *)fl_search:(FMDatabase *)db modelArr:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB{
    if ([db open]) {
        BOOL success = [self fl_isExit:db table:modelClass autoCloseDB:NO];
        if (!success) {
            if (autoCloseDB) {
                [self fl_closeDB:db];
            }
            return nil;
        }
        // 查询数据
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",modelClass]];
        if (rs == nil) {
            if (autoCloseDB) {
                [self fl_closeDB:db];
            }
            return nil;
        }
        NSMutableArray *modelArrM = [NSMutableArray array];
        // 遍历结果集
        while ([rs next]) {
            
            // 创建对象
            id object = [[modelClass class] new];
            
            unsigned int outCount;
            Ivar * ivars = class_copyIvarList(modelClass, &outCount);
            for (int i = 0; i < outCount; i ++) {
                Ivar ivar = ivars[i];
                NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)] ;
                
                if([[key substringToIndex:1] isEqualToString:@"_"]){
                    key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
                }
                
                id value = [rs objectForColumnName:key];
                if ([value isKindOfClass:[NSString class]]) {
                    id result = [self fl_string2ID:value];
                    if ([result isKindOfClass:[NSDictionary class]] || [result isKindOfClass:[NSMutableDictionary class]] || [result isKindOfClass:[NSArray class]] || [result isKindOfClass:[NSMutableArray class]]) {
                        [object setValue:result forKey:key];
                    }
                    else{
                        [object setValue:value forKey:key];
                    }
                }
                else{
                    [object setValue:value forKey:key];
                }
            }
            free(ivars);
            // 添加
            [modelArrM addObject:object];
        }
        if (autoCloseDB) {
            [self fl_closeDB:db];
        }
        /**
         *  @author gitKong
         *
         *  不能使用copy，会将数组里面的object的字典和数组属性全部转成string
         */
        return modelArrM;
    }
    else{
        if (autoCloseDB) {
            [self fl_closeDB:db];
        }
        return nil;
    }
}



- (BOOL)fl_modify:(FMDatabase *)db model:(id)model byID:(NSString *)FLDBID autoCloseDB:(BOOL)autoCloseDB{
    if ([db open]) {
        // 判断是否已经存在
        BOOL success = [self fl_isExit:db table:[model class] autoCloseDB:NO];
        if (!success) {
            if (autoCloseDB) {
                [self fl_closeDB:db];
            }
            return NO;
        }
        // 修改数据@"UPDATE t_student SET name = 'liwx' WHERE age > 12 AND age < 15;"
        NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",[model class]];
        unsigned int outCount;
//        class_copyIvarList([model superclass],&outCount);
        Ivar * ivars = class_copyIvarList([model class], &outCount);
        for (int i = 0; i < outCount; i ++) {
            Ivar ivar = ivars[i];
            NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)] ;
            if([[key substringToIndex:1] isEqualToString:@"_"]){
                key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
            id value = [model valueForKey:key];
            /**
             *  @author gitKong
             *
             *  防止属性没赋值
             */
            if (value == [NSNull null]) {
                value = @"";
            }
            if (i == 0) {
                [sql appendFormat:@"%@ = %@",key,([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]] || [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]]) ? [NSString stringWithFormat:@"'%@'",(value ? value : @"")] : value ? value : 0];
            }
            else{
                [sql appendFormat:@",%@ = %@",key,([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]] || [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]]) ? [NSString stringWithFormat:@"'%@'",(value ? value : @"")] : value ? value : 0];
            }
        }
        free(ivars);
        [sql appendFormat:@" WHERE FLDBID = '%@';",FLDBID];
        if ([db open]) {
            success = [db executeUpdate:sql];
        }
        
        if (autoCloseDB) {
            [self fl_closeDB:db];
        }
        return success;
    }
    else{
        if (autoCloseDB) {
            [self fl_closeDB:db];
        }
        return NO;
    }
}

/**
 *  @author gitKong
 *
 *  删除
 */
- (BOOL)fl_drop:(FMDatabase *)db table:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB{
    if ([db open]) {
        // 此时需要判断完关闭数据库，再重新打开
        BOOL success = [self fl_isExit:db table:modelClass autoCloseDB:YES];
        if (!success) {
            if (autoCloseDB) {
                [self fl_closeDB:db];
            }
            return NO;
        }
        success = [db open];
        if (!success) {
            if (autoCloseDB) {
                [self fl_closeDB:db];
            }
            return success;
        }
        // 删
        NSMutableString *sql = [NSMutableString stringWithFormat:@"DROP TABLE %@;",modelClass];
        success = [db executeUpdate:sql];
        if (autoCloseDB) {
            [self fl_closeDB:db];
        }
        return success;
    }
    else{
        if (autoCloseDB) {
            [self fl_closeDB:db];
        }
        return NO;
    }
}

- (BOOL)fl_delete:(FMDatabase *)db model:(Class)modelClass byId:(NSString *)FLDBID autoCloseDB:(BOOL)autoCloseDB {
    if ([db open]) {
        // 删除数据
        BOOL success = [self fl_isExit:db table:modelClass autoCloseDB:NO];
        if (!success) {
            if (autoCloseDB) {
                [self fl_closeDB:db];
            }
            return NO;
        }
        // 判断是否存在
        if ([self fl_search:db model:modelClass byID:FLDBID autoCloseDB:NO]) {
            NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@ WHERE  FLDBID = '%@';",modelClass,FLDBID];
            success = [db executeUpdate:sql];
        }
        else{
            success = NO;
        }
        if (autoCloseDB) {
            [self fl_closeDB:db];
        }
        return success;
    }
    else{
        if (autoCloseDB) {
            [self fl_closeDB:db];
        }
        return NO;
    }
}

- (BOOL)fl_delete:(FMDatabase *)db allModel:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB{
    if ([db open]) {
        // 删除数据
        BOOL success = [self fl_isExit:db table:modelClass autoCloseDB:NO];
        if (!success) {
            if (autoCloseDB) {
                [self fl_closeDB:db];
            }
            return NO;
        }
        // 数据是否存在
        NSArray *modelArr = [self fl_search:db modelArr:modelClass autoCloseDB:NO];
        if (modelArr && modelArr.count) {
            NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@;",modelClass];
            success = [db executeUpdate:sql];
        }
        else{
            success = NO;
        }
        if (autoCloseDB) {
            [self fl_closeDB:db];
        }
        return success;
    }
    else{
        if (autoCloseDB) {
            [self fl_closeDB:db];
        }
        return NO;
    }
}



- (void)fl_closeDB:(FMDatabase *)db{
    /**
     *  @author gitKong
     *
     *  处理完需要主动关闭数据库,不然多线程处理会出现文件读写操作异常，如果不关闭数据库，支持嵌套，官方不建议嵌套使用;作者处理了，可以使用嵌套
     */
    [db close];
}

void FLDISPATCH_ASYNC_GLOBAL(void(^block)()){
    dispatch_async(dispatch_get_global_queue(0, 0), block);
}

void FLDISPATCH_ASYNC_MAIN(void(^block)()){
    dispatch_async(dispatch_get_main_queue(), block);
}

@end
