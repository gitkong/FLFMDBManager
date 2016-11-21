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
 *  属性名称必须是FLDBID,适应框架
 */
@property (nonatomic,copy)NSString *FLDBID;


@property (nonatomic,copy)NSString *name;

@property (nonatomic,assign)NSInteger age;

@property (nonatomic,strong)NSDictionary *msgInfo;

@property (nonatomic,strong)NSMutableArray *scroceArrM;

// 嵌套的模型一般创建多一张表，一张表不好处理
//@property (nonatomic,strong)NSArray *otherModelArr;

@end
