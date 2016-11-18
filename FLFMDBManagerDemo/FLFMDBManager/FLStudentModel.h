//
//  FLStudentModel.h
//  FLFMDBManager
//
//  Created by clarence on 16/11/17.
//  Copyright © 2016年 clarence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLStudentModel : NSObject
/**
 *  @author Clarence
 *
 *  数据库中绑定指定模型的DBID（一般对应后台返回模型数据中的唯一id）
 */
@property (nonatomic,copy)NSString *DBID;

@property (nonatomic,copy)NSString *name;

@property (nonatomic,assign)NSInteger age;
// 嵌套的一般创建多一张表，一张表不好处理
//@property (nonatomic,strong)NSArray *arr;

@end
