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

@interface FLFMDBManager ()
@property (nonatomic,strong)FMDatabase *dataBase;
@property (nonatomic,strong)FMDatabaseQueue *queue;
@end

@implementation FLFMDBManager

+ (instancetype)shareManager{
    static FLFMDBManager *instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).lastObject;
        NSString *sqlFilePath = [path stringByAppendingPathComponent:@"clarence.sqlite"];
        // 通过路径创建数据库
        instance.dataBase = [FMDatabase databaseWithPath:sqlFilePath];
    });
    return instance;
}


- (BOOL)fl_createTable:(Class)modelClass{
    return [self fl_createTable:modelClass autoCloseDB:YES];
}


- (BOOL)fl_insertModel:(id)model{
    return [self fl_insertModel:model autoCloseDB:YES];
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
    [self.dataBase close];
    // 全部插入成功才返回YES
    return flag;
}

- (id)fl_searchModel:(Class)modelClass byID:(NSString *)DBID{
    if ([self.dataBase open]) {
        // 查询数据
        FMResultSet *rs = [self.dataBase executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@ WHERE DBID = '%@';",modelClass,DBID]];
        // 创建对象
        id object = [[modelClass class] new];
        // 遍历结果集
        while ([rs next]) {
            
            unsigned int outCount;
            Ivar * ivars = class_copyIvarList(modelClass, &outCount);
            for (int i = 0; i < outCount; i ++) {
                Ivar ivar = ivars[i];
                NSString * key = [[NSString stringWithUTF8String:ivar_getName(ivar)] stringByReplacingOccurrencesOfString:@"_" withString:@""];
                
                id value = [rs objectForColumnName:key];
                [object setValue:value forKey:key];
            }
        }
        [self.dataBase close];
        return object;
    }
    else{
        NSLog(@"数据库没开启");
        return nil;
    }
}

- (NSArray *)fl_searchModelArr:(Class)modelClass{
    if ([self.dataBase open]) {
        // 查询数据
        FMResultSet *rs = [self.dataBase executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",modelClass]];
        NSMutableArray *modelArrM = [NSMutableArray array];
        // 遍历结果集
        while ([rs next]) {
            
            // 创建对象
            id object = [[modelClass class] new];
            
            unsigned int outCount;
            Ivar * ivars = class_copyIvarList(modelClass, &outCount);
            for (int i = 0; i < outCount; i ++) {
                Ivar ivar = ivars[i];
                NSString * key = [[NSString stringWithUTF8String:ivar_getName(ivar)] stringByReplacingOccurrencesOfString:@"_" withString:@""];
                
                id value = [rs objectForColumnName:key];
                [object setValue:value forKey:key];
            }
            
            // 添加
            [modelArrM addObject:object];
        }
        [self.dataBase close];
        return modelArrM.copy;
    }
    else{
        NSLog(@"数据库没开启");
        return nil;
    }
}


- (BOOL)fl_modifyModel:(id)model byID:(NSString *)DBID{
    if ([self.dataBase open]) {
        // 修改数据@"UPDATE t_student SET name = 'liwx' WHERE age > 12 AND age < 15;"
        NSMutableString *sql = [NSMutableString stringWithFormat:@"UPDATE %@ SET ",[model class]];
        unsigned int outCount;
        Ivar * ivars = class_copyIvarList([model class], &outCount);
        for (int i = 0; i < outCount; i ++) {
            Ivar ivar = ivars[i];
            NSString * key = [[NSString stringWithUTF8String:ivar_getName(ivar)] stringByReplacingOccurrencesOfString:@"_" withString:@""];
            id value = [model valueForKey:key];
            if (i == 0) {
                [sql appendFormat:@"%@ = %@",key,[value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'",value] : value];
            }
            else{
                [sql appendFormat:@",%@ = %@",key,[value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'",value] : value];
            }
        }
        
        [sql appendFormat:@" WHERE DBID = '%@';",DBID];
        NSLog(@"modify sql = %@",sql);
        BOOL success = [self.dataBase executeUpdate:sql];
        [self.dataBase close];
        return success;
    }
    else{
        NSLog(@"数据库没开启");
        return NO;
    }
}

- (BOOL)fl_dropTable:(Class)modelClass{
    if ([self.dataBase open]) {
        // 删除数据
        NSMutableString *sql = [NSMutableString stringWithFormat:@"DROP TABLE %@;",modelClass];
        NSLog(@"fl_dropModel sql = %@",sql);
        BOOL success = [self.dataBase executeUpdate:sql];
        if (success) {
            NSLog(@"删表成功");
        }
        [self.dataBase close];
        return success;
    }
    else{
        NSLog(@"数据库没开启");
        return NO;
    }
}

- (BOOL)fl_deleteAllModel:(Class)modelClass{
    if ([self.dataBase open]) {
        // 删除数据
        NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@;",modelClass];
        NSLog(@"fl_deleteAllModel sql = %@",sql);
        BOOL success = [self.dataBase executeUpdate:sql];
        [self.dataBase close];
        return success;
    }
    else{
        NSLog(@"数据库没开启");
        return NO;
    }
}

- (BOOL)fl_deleteModel:(Class)modelClass byId:(NSString *)DBID{
    if ([self.dataBase open]) {
        // 删除数据
        NSMutableString *sql = [NSMutableString stringWithFormat:@"DELETE FROM %@ WHERE  DBID = '%@';",modelClass,DBID];
        NSLog(@"fl_deleteModel sql = %@",sql);
        BOOL success = [self.dataBase executeUpdate:sql];
        [self.dataBase close];
        return success;
    }
    else{
        NSLog(@"数据库没开启");
        return NO;
    }
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
        NSString * key = [[NSString stringWithUTF8String:ivar_getName(ivar)] stringByReplacingOccurrencesOfString:@"_" withString:@""];
        [sqlPropertyM appendFormat:@", %@",key];
    }
    [sqlPropertyM appendString:@")"];
    
    NSLog(@"propertySql = %@",sqlPropertyM);
    return sqlPropertyM;
}

/**
 *  @author Clarence
 *
 *  创建插入表的SQL语句
 */
- (NSString *)createInsertSQL:(id)model{
    NSMutableString *sqlValueM = [NSMutableString stringWithFormat:@"INSERT INTO %@ (",[model class]];
    unsigned int outCount;
    Ivar * ivars = class_copyIvarList([model class], &outCount);
    for (int i = 0; i < outCount; i ++) {
        Ivar ivar = ivars[i];
        NSString * key = [[NSString stringWithUTF8String:ivar_getName(ivar)] stringByReplacingOccurrencesOfString:@"_" withString:@""];
        
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
        NSString * key = [[NSString stringWithUTF8String:ivar_getName(ivar)] stringByReplacingOccurrencesOfString:@"_" withString:@""];
        
        id value = [model valueForKey:key];
        
        if (i == 0) {
            // sql 语句中字符串需要单引号或者双引号括起来
            [sqlValueM appendFormat:@"%@",[value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'",value] : value];
        }
        else{
            [sqlValueM appendFormat:@", %@",[value isKindOfClass:[NSString class]] ? [NSString stringWithFormat:@"'%@'",value] : value];
        }
    }
    [sqlValueM appendString:@");"];
    
    NSLog(@"valueSql = %@",sqlValueM);
    return sqlValueM;
}

/**
 *  @author Clarence
 *
 *  指定的表是否存在
 */
- (BOOL)isExitTable:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB{
    BOOL success = [self.dataBase executeQuery:[NSString stringWithFormat:@"SELECT * FROM %@",modelClass]];
    // 操作完毕是否需要关闭
    if (autoCloseDB) {
        [self.dataBase close];
    }
    return success;
}

- (BOOL)fl_createTable:(Class)modelClass autoCloseDB:(BOOL)autoCloseDB{
    if ([self.dataBase open]) {
        NSLog(@"数据库打开成功");
        // 创表
        BOOL success = [self.dataBase executeUpdate:[self createTableSQL:modelClass]];
        // 关闭数据库
        if (autoCloseDB) {
            [self.dataBase close];
        }
        return success;
    }
    else{
        NSLog(@"数据库打开失败");
        return NO;
    }
}

- (BOOL)fl_insertModel:(id)model autoCloseDB:(BOOL)autoCloseDB{
    if ([self.dataBase open]) {
        // 没有表的时候，先创建再插入
        
        // 此时有三步操作，第一步处理完不关闭数据库
        if (![self isExitTable:[model class] autoCloseDB:NO]) {
            // 第二步处理完不关闭数据库
            BOOL success = [self fl_createTable:[model class] autoCloseDB:NO];
            if (success) {
                NSLog(@"创建表成功");
                BOOL insertSuccess = [self.dataBase executeUpdate:[self createInsertSQL:model]];
                // 最后一步操作完毕，询问是否需要关闭
                if (autoCloseDB) {
                    [self.dataBase close];
                }
                return insertSuccess;
            }
            else {
                NSLog(@"创建表失败");
                // 第二步操作失败，询问是否需要关闭
                if (autoCloseDB) {
                    [self.dataBase close];
                }
                return NO;
            }
        }
        // 已经创建有对应的表，直接插入
        else{
            BOOL insertSuccess = [self.dataBase executeUpdate:[self createInsertSQL:model]];
            // 最后一步操作完毕，询问是否需要关闭
            if (autoCloseDB) {
                [self.dataBase close];
            }
            
            return insertSuccess;
        }
    }
    else{
        NSLog(@"数据库还没打开");
        return NO;
    }
}
@end
