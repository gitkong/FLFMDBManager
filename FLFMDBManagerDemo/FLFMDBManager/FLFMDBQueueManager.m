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

//#define FL_ISEXITTABLE(db,modelClass) \
//{NSString *classNameTip = [NSString stringWithFormat:@"%@ 表不存在，请先创建",modelClass]; \
//NSAssert([self fl_isExit:db table:modelClass autoCloseDB:NO], classNameTip);\
//}

@interface FLFMDBQueueManager ()

@property (nonatomic,strong)FMDatabaseQueue *queue;

@property (nonatomic,weak)FMDatabase *db;

@end

@implementation FLFMDBQueueManager
+ (instancetype)shareManager{
    static FLFMDBQueueManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        // 1、获取沙盒中数据库的路径
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        NSString *sqlFilePath = [path stringByAppendingPathComponent:@"clarence.sqlite"];
        
        // 2、判断 caches 文件夹是否存在.不存在则创建
        NSFileManager *manager = [NSFileManager defaultManager];
        BOOL tag = [manager fileExistsAtPath:path isDirectory:NULL];
        
        if (!tag) {
            [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
        }
        // 通过路径创建数据库
        instance.queue = [FMDatabaseQueue databaseQueueWithPath:sqlFilePath];
    });
    return instance;
}

#pragma mark -- private method


- (void)fl_createTable:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    [self fl_createTable:modelClass autoCloseDB:YES complete:complete];
}

- (void)fl_insertModel:(id)model complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    if ([model isKindOfClass:[NSArray class]] || [model isKindOfClass:[NSMutableArray class]]) {
        NSArray *modelArr = (NSArray *)model;
        [self fl_insertModelArr:modelArr complete:complete];
    }
    else{
        [self fl_insertModel:model autoCloseDB:YES complete:complete];
    }
}

- (void)fl_searchModel:(Class)modelClass byID:(NSString *)FLDBID complete:(void(^)(FLFMDBQueueManager *manager,id model))complete{
    [self fl_searchModel:modelClass byID:FLDBID autoCloseDB:YES complete:complete];
}

- (void)fl_searchModelArr:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager,NSArray *modelArr))complete{
    __block NSArray *modelArr = nil;
    __weak typeof(self) weakSelf = self;
    //把任务包装到事务里
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback){
        __weak typeof(self) strongSelf = weakSelf;
        //        NSLog(@"fl_search----------------------db--%p",db);
        modelArr = [strongSelf fl_search:db modelArr:modelClass];
        strongSelf.db = db;
        // 回调
        if (complete) {
            complete(strongSelf,modelArr);
        }
        //如果有错误 返回
        if (!modelArr){
            *rollback = YES;
            return;
        }
    }];
}

- (void)fl_modifyModel:(id)model byID:(NSString *)FLDBID complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    __block BOOL success = true;
    __weak typeof(self) weakSelf = self;
    //把任务包装到事务里
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback){
        __weak typeof(self) strongSelf = weakSelf;
        
        success = [strongSelf fl_modify:db model:model byID:FLDBID autoCloseDB:YES];
        strongSelf.db = db;
        // 回调
        if (complete) {
            complete(strongSelf,success);
        }
        
        //如果有错误 返回
        if (!success){
            *rollback = YES;
            return;
        }
    }];
}

- (void)fl_dropTable:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    __block BOOL success = true;
    __weak typeof(self) weakSelf = self;
    //把任务包装到事务里
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback){
        __weak typeof(self) strongSelf = weakSelf;
        
        success = [strongSelf fl_drop:db table:modelClass];
        strongSelf.db = db;
        // 回调
        if (complete) {
            complete(strongSelf,success);
        }
        
        //如果有错误 返回
        if (!success){
            *rollback = YES;
            return;
        }
    }];
}

- (void)fl_deleteAllModel:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    __block BOOL success = true;
    __weak typeof(self) weakSelf = self;
    //把任务包装到事务里
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback){
        __weak typeof(self) strongSelf = weakSelf;
        
        success = [strongSelf fl_delete:db allModel:modelClass];
        strongSelf.db = db;
        // 回调
        if (complete) {
            complete(strongSelf,success);
        }
        
        //如果有错误 返回
        if (!success){
            *rollback = YES;
            return;
        }
    }];
}

- (void)fl_deleteModel:(Class)modelClass byId:(NSString *)FLDBID complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    __block BOOL success = true;
    __weak typeof(self) weakSelf = self;
    //把任务包装到事务里
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback){
        __weak typeof(self) strongSelf = weakSelf;
        
        success = [strongSelf fl_delete:db model:modelClass byId:FLDBID];
        strongSelf.db = db;
        // 回调
        if (complete) {
            complete(strongSelf,success);
        }
        
        //如果有错误 返回
        if (!success){
            *rollback = YES;
            return;
        }
    }];
}

- (void)fl_isExitTable:(Class)modelClass complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    __block BOOL success = true;
    __weak typeof(self) weakSelf = self;
    //把任务包装到事务里
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback){
        __weak typeof(self) strongSelf = weakSelf;
        
        success = [strongSelf fl_isExit:db table:modelClass autoCloseDB:YES];
        strongSelf.db = db;
        // 回调
        if (complete) {
            complete(strongSelf,success);
        }
        
        //如果有错误 返回
        if (!success){
            *rollback = YES;
            return;
        }
    }];
    
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
    
    return sqlPropertyM;
}

/**
 *  @author Clarence
 *
 *  创建插入表的SQL语句
 */
- (NSString *)createInsertSQL:(id)model{
    NSMutableString *sqlValueM = [NSMutableString stringWithFormat:@"INSERT OR REPLACE INTO %@ (",[model class]];
    unsigned int outCount;
    Ivar * ivars = class_copyIvarList([model class], &outCount);
    for (int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)] ;
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
        if([[key substringToIndex:1] isEqualToString:@"_"]){
            key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
        }
        
        id value = [model valueForKey:key];
        if ([value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]] || [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]]) {
            value = [NSString stringWithFormat:@"%@",value];
        }
        if (i == 0) {
            // sql 语句中字符串需要单引号或者双引号括起来
            [sqlValueM appendFormat:@"%@",[value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'",value] : value];
        }
        else{
            [sqlValueM appendFormat:@", %@",[value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'",value] : value];
        }
    }
    //    [sqlValueM appendFormat:@" WHERE FLDBID = '%@'",[model valueForKey:@"FLDBID"]];
    [sqlValueM appendString:@");"];
    
    return sqlValueM;
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
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback){
        __weak typeof(self) strongSelf = weakSelf;
        
        success = [strongSelf fl_isExit:db table:modelClass autoCloseDB:autoCloseDB];
        strongSelf.db = db;
        // 回调回去
        if (complete) {
            complete(strongSelf,success);
        }
        //如果有错误 返回
        if (!success){
            *rollback = YES;
            return;
        }
    }];
}

- (BOOL)fl_isExit:(FMDatabase *)db table:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB{
    BOOL success = [db open];
    if (success){
        FMResultSet *rs = [db executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", modelClass];
        while ([rs next]){
            NSInteger count = [rs intForColumn:@"count"];
            
            if (0 == count){
                // 操作完毕是否需要关闭
                if (autoCloseDB) {
                    [db close];
                }
                return NO;
            }
            else{
                // 操作完毕是否需要关闭
                if (autoCloseDB) {
                    [db close];
                }
                return YES;
            }
        }
        // 操作完毕是否需要关闭
        if (autoCloseDB) {
            [db close];
        }
        return NO;
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
    //把任务包装到事务里
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback){
        __weak typeof(self) strongSelf = weakSelf;
        
        success = [strongSelf fl_create:db table:modelClass autoCloseDB:autoCloseDB];
        strongSelf.db = db;
        // 回调
        if (complete) {
            complete(strongSelf,success);
        }
        
        //如果有错误 返回
        if (!success){
            *rollback = YES;
            return;
        }
    }];
}

- (BOOL)fl_create:(FMDatabase *)db table:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB{
    if ([db open]) {
        // 创表,判断是否已经存在
        if ([self fl_isExit:db table:modelClass autoCloseDB:NO]) {
            if (autoCloseDB) {
                [db close];
            }
            return YES;
        }
        else{
            BOOL success = [db executeUpdate:[self createTableSQL:modelClass]];
            // 关闭数据库
            if (autoCloseDB) {
                [db close];
            }
            return success;
        }
    }
    else{
        return NO;
    }
}

/**
 *  @author gitKong
 *
 *  插入数据
 */
- (void)fl_insertModel:(id)model autoCloseDB:(BOOL)autoCloseDB complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    __block BOOL success = true;
    __weak typeof(self) weakSelf = self;
    //把任务包装到事务里
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback){
        __weak typeof(self) strongSelf = weakSelf;
        
        success = [strongSelf fl_insert:db model:model autoCloseDB:autoCloseDB];
        strongSelf.db = db;
        if (complete) {
            complete(strongSelf,success);
        }
        //如果有错误 返回
        if (!success){
            *rollback = YES;
            return;
        }
    }];
}


- (void)fl_insertModelArr:(NSArray *)modelArr complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    // 使用此方法会导致查询不到数据，但插入是成功的，原因不明,待解决
    //    __block BOOL success = true;
    //    __weak typeof(self) weakSelf = self;
    //    //把任务包装到事务里
    //    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback){
    //        __weak typeof(self) strongSelf = weakSelf;
    //        NSLog(@"fl_insertModel----------------------db--%p",db);
    //        success = [strongSelf fl_insert:db modelArr:modelArr autoCloseDB:YES];
    //            strongSelf.db = db;
    //
    //        complete(strongSelf,success);
    //
    //        //如果有错误 返回
    //        if (!success){
    //            *rollback = YES;
    //            return;
    //        }
    //    }];
    
    for (NSInteger index = 0; index < modelArr.count; index ++) {
        id model = modelArr[index];
        // 处理过程中不关闭数据库
        [self fl_insertModel:model autoCloseDB:NO complete:nil];
        
        if (index == modelArr.count - 1) {
            __weak typeof(self) weakSelf = self;
            [self fl_insertModel:model autoCloseDB:NO complete:^(FLFMDBQueueManager *manager, BOOL flag) {
                // 处理完毕关闭数据库
                //                NSLog(@"fl_insertModel----------------------db--%p",db);
                __strong typeof(weakSelf) strongSelf = weakSelf;
                [manager.db close];
                
                if (complete) {
                    complete(strongSelf,flag);
                }
            }];
            
        }
        
    }
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
        [db close];
    }
    return success;
}


- (BOOL)fl_insert:(FMDatabase *)db model:(id)model autoCloseDB:(BOOL)autoCloseDB{
    NSAssert(![model isKindOfClass:[UIResponder class]], @"必须保证模型是NSObject或者NSObject的子类,同时不响应事件");
    if ([db open]) {
        // 没有表的时候，先创建再插入
        
        // 此时有三步操作，第一步处理完不关闭数据库
        
        if (![self fl_isExit:db table:[model class] autoCloseDB:NO]) {
            // 第二步处理完不关闭数据库
            BOOL success = [self fl_create:db table:[model class] autoCloseDB:NO];
            if (success) {
                NSString *fl_dbid = [model valueForKey:@"FLDBID"];
                id judgeModle = [self fl_search:db model:model byID:fl_dbid autoCloseDB:NO];
                
                if ([[judgeModle valueForKey:@"FLDBID"] isEqualToString:fl_dbid]) {
                    BOOL updataSuccess = [self fl_modify:db model:model byID:fl_dbid autoCloseDB:NO];
                    if (autoCloseDB) {
                        [db close];
                    }
                    return updataSuccess;
                }
                else{
                    BOOL insertSuccess = [db executeUpdate:[self createInsertSQL:model]];
                    // 最后一步操作完毕，询问是否需要关闭
                    if (autoCloseDB) {
                        [db close];
                    }
                    return insertSuccess;
                }
                
            }
            else {
                // 第二步操作失败，询问是否需要关闭,可能是创表失败，或者是已经有表
                if (autoCloseDB) {
                    [db close];
                }
                return NO;
            }
        }
        // 已经创建有对应的表，直接插入
        else{
            NSString *fl_dbid = [model valueForKey:@"FLDBID"];
            id judgeModle = [self fl_search:db model:model byID:fl_dbid autoCloseDB:NO];
            
            if ([[judgeModle valueForKey:@"FLDBID"] isEqualToString:fl_dbid]) {
                BOOL updataSuccess = [self fl_modify:db model:model byID:fl_dbid autoCloseDB:NO];
                if (autoCloseDB) {
                    [db close];
                }
                return updataSuccess;
            }
            else{
                BOOL insertSuccess = [db executeUpdate:[self createInsertSQL:model]];
                // 最后一步操作完毕，询问是否需要关闭
                if (autoCloseDB) {
                    [db close];
                }
                return insertSuccess;
            }
        }
    }
    else{
        return NO;
    }
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
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback){
        __weak typeof(self) strongSelf = weakSelf;
        strongSelf.db = db;
        
        // 回调
        if (complete) {
            complete(strongSelf,[strongSelf fl_search:db model:modelClass byID:FLDBID autoCloseDB:autoCloseDB]);
        }
        
        //如果有错误 返回
        if (!success){
            *rollback = YES;
            return;
        }
    }];
}



- (id)fl_search:(FMDatabase *)db model:(Class)modelClass byID:(NSString *)FLDBID autoCloseDB:(BOOL)autoCloseDB{
    
    if ([db open]) {
        BOOL success = [self fl_isExit:db table:modelClass autoCloseDB:NO];
        if (!success) {
            return nil;
        }
        // 查询数据
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE FLDBID = '%@';",modelClass,FLDBID]];
        // 创建对象
        id object = [[modelClass class] new];
        // 遍历结果集
        while ([rs next]) {
            
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
        }
        if (autoCloseDB) {
            [db close];
        }
        return object;
    }
    else{
        return nil;
    }
    
}

- (NSArray *)fl_search:(FMDatabase *)db modelArr:(Class)modelClass{
    if ([db open]) {
        BOOL success = [self fl_isExit:db table:modelClass autoCloseDB:NO];
        if (!success) {
            return nil;
        }
        // 查询数据
        FMResultSet *rs = [db executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",modelClass]];
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
            
            // 添加
            [modelArrM addObject:object];
        }
        [db close];
        return modelArrM.copy;
    }
    else{
        return nil;
    }
}


/**
 *  @author gitKong
 *
 *  修改
 */
- (void)fl_modifyModel:(id)model byID:(NSString *)FLDBID autoCloseDB:(BOOL)autoCloseDB complete:(void(^)(FLFMDBQueueManager *manager, BOOL flag))complete{
    __block BOOL success = true;
    __weak typeof(self) weakSelf = self;
    //把任务包装到事务里
    [self.queue inTransaction:^(FMDatabase *db, BOOL *rollback){
        __weak typeof(self) strongSelf = weakSelf;
        success = [db open];
        if (success) {
            strongSelf.db = db;
            // 回调
            if (complete) {
                complete(strongSelf,[strongSelf fl_modify:db model:model byID:FLDBID autoCloseDB:autoCloseDB]);
            }
        }
        else{
            // 回调
            if (complete) {
                complete(strongSelf,NO);
            }
        }
        //如果有错误 返回
        if (!success){
            *rollback = YES;
            return;
        }
    }];
}

- (BOOL)fl_modify:(FMDatabase *)db model:(id)model byID:(NSString *)FLDBID autoCloseDB:(BOOL)autoCloseDB{
    if ([db open]) {
        // 判断是否已经存在
        BOOL success = [self fl_isExit:db table:[model class] autoCloseDB:NO];
        if (!success) {
            return NO;
        }
        success = [self fl_isExit:db table:[model class] autoCloseDB:NO];
        if (!success) {
            return NO;
        }
        // 修改数据@"UPDATE t_student SET name = 'liwx' WHERE age > 12 AND age < 15;"
        NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",[model class]];
        unsigned int outCount;
        class_copyIvarList([model superclass],&outCount);
        Ivar * ivars = class_copyIvarList([model class], &outCount);
        for (int i = 0; i < outCount; i ++) {
            Ivar ivar = ivars[i];
            NSString * key = [NSString stringWithUTF8String:ivar_getName(ivar)] ;
            if([[key substringToIndex:1] isEqualToString:@"_"]){
                key = [key stringByReplacingCharactersInRange:NSMakeRange(0, 1) withString:@""];
            }
            id value = [model valueForKey:key];
            if (i == 0) {
                [sql appendFormat:@"%@ = %@",key,([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]] || [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]]) ? [NSString stringWithFormat:@"'%@'",value] : value];
            }
            else{
                [sql appendFormat:@",%@ = %@",key,([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]] || [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]]) ? [NSString stringWithFormat:@"'%@'",value] : value];
            }
        }
        
        [sql appendFormat:@" WHERE FLDBID = '%@';",FLDBID];
        success = [db executeUpdate:sql];
        if (autoCloseDB) {
            [db close];
        }
        return success;
    }
    else{
        return NO;
    }
}

/**
 *  @author gitKong
 *
 *  删除
 */
- (BOOL)fl_drop:(FMDatabase *)db table:(Class)modelClass{
    if ([db open]) {
        // 此时如果添加判断，那么下面的删除表就会执行失败，原因不明
//        BOOL success = [self fl_isExit:db table:modelClass autoCloseDB:NO];
//        if (!success) {
//            return NO;
//        }
        // 删
        NSMutableString *sql = [NSMutableString stringWithFormat:@"DROP TABLE %@;",modelClass];
        BOOL success = [db executeUpdate:sql];
        [db close];
        return success;
    }
    else{
        return NO;
    }
}

- (BOOL)fl_delete:(FMDatabase *)db model:(Class)modelClass byId:(NSString *)FLDBID{
    if ([db open]) {
        // 删除数据
        BOOL success = [self fl_isExit:db table:modelClass autoCloseDB:NO];
        if (!success) {
            return NO;
        }
        
        NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@ WHERE  FLDBID = '%@';",modelClass,FLDBID];
        success = [db executeUpdate:sql];
        [db close];
        return success;
    }
    else{
        return NO;
    }
}

- (BOOL)fl_delete:(FMDatabase *)db allModel:(Class)modelClass{
    if ([db open]) {
        // 删除数据
//        FL_ISEXITTABLE(db,modelClass);
        BOOL success = [self fl_isExit:db table:modelClass autoCloseDB:NO];
        if (!success) {
            return NO;
        }
        NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@;",modelClass];
        success = [db executeUpdate:sql];
        [db close];
        return success;
    }
    else{
        return NO;
    }
}
@end
