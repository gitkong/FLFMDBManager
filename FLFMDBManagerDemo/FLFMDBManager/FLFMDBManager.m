//
//  FLFMDBManager.m
//  FLFMDBManager
//
//  Created by clarence on 16/11/17.
//  Copyright © 2016年 clarence. All rights reserved.
//

#import "FLFMDBManager.h"
#import "FMDB.h"
#import <objc/runtime.h>
#import <UIKit/UIKit.h>
//#define FL_ISEXITTABLE(modelClass) \
//{NSString *classNameTip = [NSString stringWithFormat:@"%@ 表不存在，请先创建",modelClass]; \
//NSAssert([self isExitTable:modelClass autoCloseDB:NO], classNameTip);\
//}


#define FLCURRENTDB (FMDatabase *)self.dataBaseDictM[self.dbName]

@interface FLFMDBManager ()
@property (nonatomic,copy)NSString *dbName;
@property (nonatomic,strong)NSMutableDictionary *dataBaseDictM;
@end

@implementation FLFMDBManager

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
    
    
    static FLFMDBManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        instance.dataBaseDictM = [NSMutableDictionary dictionary];
        if (tag) {
            FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlFilePath];
            [instance.dataBaseDictM setValue:dataBase forKey:tempDBName];
        }
    });
    
    if (!tag) {
        [manager createDirectoryAtPath:path withIntermediateDirectories:YES attributes:nil error:NULL];
        // 通过路径创建数据库
        FMDatabase *dataBase = [FMDatabase databaseWithPath:sqlFilePath];
        [instance.dataBaseDictM setValue:dataBase forKey:tempDBName];
    }
    
    instance.dbName = tempDBName;
    
    return instance;
}

- (BOOL)fl_createTable:(Class)modelClass{
    
    return [self fl_createTable:modelClass autoCloseDB:YES];
}


- (BOOL)fl_insertModel:(id)model{
    if ([model isKindOfClass:[NSArray class]] || [model isKindOfClass:[NSMutableArray class]]) {
        NSArray *modelArr = (NSArray *)model;
        return [self fl_insertModelArr:modelArr];
    }
    else{
        return [self fl_insertModel:model autoCloseDB:YES];
    }
}


- (id)fl_searchModel:(Class)modelClass byID:(NSString *)FLDBID{
    return [self fl_searchModel:modelClass byID:FLDBID autoCloseDB:YES];
}

- (NSArray *)fl_searchModelArr:(Class)modelClass{
    return  [self fl_searchModelArr:modelClass autoCloseDB:YES];
}




- (BOOL)fl_modifyModel:(id)model byID:(NSString *)FLDBID{
    return [self fl_modifyModel:model byID:FLDBID autoCloseDB:YES];
}

- (BOOL)fl_dropTable:(Class)modelClass{
    if ([FLCURRENTDB open]) {
//        FL_ISEXITTABLE(modelClass);
        if(![self isExitTable:modelClass autoCloseDB:NO])return NO;
        // 删除数据
        NSMutableString *sql = [NSMutableString stringWithFormat:@"DROP TABLE %@;",modelClass];
        BOOL success = [FLCURRENTDB executeUpdate:sql];
        [FLCURRENTDB close];
        return success;
    }
    else{
        return NO;
    }
}

- (BOOL)fl_dropDB{
    NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
    NSString *sqlFilePath = [path stringByAppendingPathComponent:[self.dbName stringByAppendingString:@".sqlite"]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:sqlFilePath error:NULL];
}

- (BOOL)fl_deleteAllModel:(Class)modelClass{
    if ([FLCURRENTDB open]) {
//        FL_ISEXITTABLE(modelClass);
        if(![self isExitTable:modelClass autoCloseDB:NO])return NO;
        NSArray *modelArr = [self fl_searchModelArr:modelClass autoCloseDB:NO];
        if (modelArr && modelArr.count) {
            // 删除数据
            NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@;",modelClass];
            BOOL success = [FLCURRENTDB executeUpdate:sql];
            [FLCURRENTDB close];
            return success;
        }
        return NO;
    }
    else{
        return NO;
    }
}

- (BOOL)fl_deleteModel:(Class)modelClass byId:(NSString *)FLDBID{
    if ([FLCURRENTDB open]) {
//        FL_ISEXITTABLE(modelClass);
        if(![self isExitTable:modelClass autoCloseDB:NO])return NO;
        if ([self fl_searchModel:modelClass byID:FLDBID autoCloseDB:NO]) {
            // 删除数据
            NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@ WHERE  FLDBID = '%@';",modelClass,FLDBID];
            BOOL success = [FLCURRENTDB executeUpdate:sql];
            [FLCURRENTDB close];
            return success;
        }
        return NO;
    }
    else{
        return NO;
    }
}

- (BOOL)fl_isExitTable:(Class)modelClass{
    return [self isExitTable:modelClass autoCloseDB:YES];
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
 *  @author Clarence
 *
 *  指定的表是否存在
 */
- (BOOL)isExitTable:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB{
    if ([FLCURRENTDB open]){
//        BOOL success = [FLCURRENTDB executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",modelClass]];
//        // 操作完毕是否需要关闭
//        if (autoCloseDB) {
//            [FLCURRENTDB close];
//        }
//        return success;
        FMResultSet *rs = [FLCURRENTDB executeQuery:@"select count(*) as 'count' from sqlite_master where type ='table' and name = ?", modelClass];
        while ([rs next]){
            NSInteger count = [rs intForColumn:@"count"];
            
            if (0 == count){
                // 操作完毕是否需要关闭
                if (autoCloseDB) {
                    [FLCURRENTDB close];
                }
                return NO;
            }
            else{
                // 操作完毕是否需要关闭
                if (autoCloseDB) {
                    [FLCURRENTDB close];
                }
                return YES;
            }
        }
        // 操作完毕是否需要关闭
        if (autoCloseDB) {
            [FLCURRENTDB close];
        }
        return NO;
    }
    else{
        return NO;
    }
}

- (BOOL)fl_createTable:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB{
    if ([FLCURRENTDB open]) {
        // 创表,判断是否已经存在
        if ([self isExitTable:modelClass autoCloseDB:NO]) {
            if (autoCloseDB) {
                [FLCURRENTDB close];
            }
            return YES;
        }
        else{
            BOOL success = [FLCURRENTDB executeUpdate:[self createTableSQL:modelClass]];
            // 关闭数据库
            if (autoCloseDB) {
                [FLCURRENTDB close];
            }
            return success;
        }
    }
    else{
        return NO;
    }
}

- (BOOL)fl_insertModel:(id)model autoCloseDB:(BOOL)autoCloseDB{
    NSAssert(![model isKindOfClass:[UIResponder class]], @"必须保证模型是NSObject或者NSObject的子类,同时不响应事件");
    if ([FLCURRENTDB open]) {
        // 没有表的时候，先创建再插入
        
        // 此时有三步操作，第一步处理完不关闭数据库
        if (![self isExitTable:[model class] autoCloseDB:NO]) {
            // 第二步处理完不关闭数据库
            BOOL success = [self fl_createTable:[model class] autoCloseDB:NO];
            if (success) {
                NSString *fl_dbid = [model valueForKey:@"FLDBID"];
                id judgeModle = [self fl_searchModel:[model class] byID:fl_dbid autoCloseDB:NO];
                
                if ([[judgeModle valueForKey:@"FLDBID"] isEqualToString:fl_dbid]) {
                    BOOL updataSuccess = [self fl_modifyModel:model byID:fl_dbid autoCloseDB:NO];
                    if (autoCloseDB) {
                        [FLCURRENTDB close];
                    }
                    return updataSuccess;
                }
                else{
                    BOOL insertSuccess = [FLCURRENTDB executeUpdate:[self createInsertSQL:model]];
                    // 最后一步操作完毕，询问是否需要关闭
                    if (autoCloseDB) {
                        [FLCURRENTDB close];
                    }
                    return insertSuccess;
                }
                
            }
            else {
                // 第二步操作失败，询问是否需要关闭,可能是创表失败，或者是已经有表
                if (autoCloseDB) {
                    [FLCURRENTDB close];
                }
                return NO;
            }
        }
        // 已经创建有对应的表，直接插入
        else{
            NSString *fl_dbid = [model valueForKey:@"FLDBID"];
            id judgeModle = [self fl_searchModel:[model class] byID:fl_dbid autoCloseDB:NO];
            
            if ([[judgeModle valueForKey:@"FLDBID"] isEqualToString:fl_dbid]) {
                BOOL updataSuccess = [self fl_modifyModel:model byID:fl_dbid autoCloseDB:NO];
                if (autoCloseDB) {
                    [FLCURRENTDB close];
                }
                return updataSuccess;
            }
            else{
                BOOL insertSuccess = [FLCURRENTDB executeUpdate:[self createInsertSQL:model]];
                // 最后一步操作完毕，询问是否需要关闭
                if (autoCloseDB) {
                    [FLCURRENTDB close];
                }
                return insertSuccess;
            }
        }
    }
    else{
        return NO;
    }
}

- (BOOL)fl_insertModelArr:(NSArray *)modelArr{
    BOOL flag = YES;
    for (id model in modelArr) {
        // 处理过程中不关闭数据库
        if (![self fl_insertModel:model autoCloseDB:NO]) {
            flag = NO;
        }
    }
    // 处理完毕关闭数据库
    [FLCURRENTDB close];
    // 全部插入成功才返回YES
    return flag;
}

- (NSArray *)fl_searchModelArr:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB{
    if ([FLCURRENTDB open]) {
//        FL_ISEXITTABLE(modelClass);
        if(![self isExitTable:modelClass autoCloseDB:NO])return nil;
        // 查询数据
        FMResultSet *rs = [FLCURRENTDB executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",modelClass]];
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
        if (autoCloseDB) {
            [FLCURRENTDB close];
        }
        return modelArrM;
    }
    else{
        return nil;
    }
}

- (id)fl_searchModel:(Class)modelClass byID:(NSString *)FLDBID autoCloseDB:(BOOL)autoCloseDB{
    if ([FLCURRENTDB open]) {
//        FL_ISEXITTABLE(modelClass);
        if(![self isExitTable:modelClass autoCloseDB:NO]){
            if (autoCloseDB) {
                [FLCURRENTDB close];
            }
            return nil;
        }
        // 查询数据
        FMResultSet *rs = [FLCURRENTDB executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE FLDBID = '%@';",modelClass,FLDBID]];
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
            [FLCURRENTDB close];
        }
        return object;
    }
    else{
        if (autoCloseDB) {
            [FLCURRENTDB close];
        }
        return nil;
    }
    
}

- (BOOL)fl_modifyModel:(id)model byID:(NSString *)FLDBID autoCloseDB:(BOOL)autoCloseDB{
    if ([FLCURRENTDB open]) {
//        FL_ISEXITTABLE([model class]);
        if(![self isExitTable:[model class] autoCloseDB:NO]){
            if (autoCloseDB) {
                [FLCURRENTDB close];
            }
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
            /**
             *  @author gitKong
             *
             *  防止属性没赋值
             */
            if (value == [NSNull null]) {
                value = @"";
            }
            if (i == 0) {
                [sql appendFormat:@"%@ = %@",key,([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]] || [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]]) ? [NSString stringWithFormat:@"'%@'",value] : value];
            }
            else{
                [sql appendFormat:@",%@ = %@",key,([value isKindOfClass:[NSString class]] || [value isKindOfClass:[NSDictionary class]] || [value isKindOfClass:[NSMutableDictionary class]] || [value isKindOfClass:[NSArray class]] || [value isKindOfClass:[NSMutableArray class]]) ? [NSString stringWithFormat:@"'%@'",value] : value];
            }
        }
        
        [sql appendFormat:@" WHERE FLDBID = '%@';",FLDBID];
        BOOL success = [FLCURRENTDB executeUpdate:sql];
        if (autoCloseDB) {
            [FLCURRENTDB close];
        }
        return success;
    }
    else{
        if (autoCloseDB) {
            [FLCURRENTDB close];
        }
        return NO;
    }
    
}

#pragma mark -- Setter & Getter
//- (NSMutableDictionary *)dataBaseDictM{
//    if (_dataBaseDictM == nil) {
//        _dataBaseDictM = [NSMutableDictionary dictionary];
//    }
//    return _dataBaseDictM;
//}

@end
