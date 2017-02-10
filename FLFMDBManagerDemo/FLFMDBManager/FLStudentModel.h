//
//  FLStudentModel.h
//  FLFMDBManager
//
//  Created by clarence on 16/11/17.
//  Copyright © 2016年 clarence. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FLPenModel.h"
#import "FLBookModel.h"
@interface FLStudentModel : NSObject
/**
 *  @author Clarence
 *
 *  数据库中绑定指定模型的DBID（一般对应后台返回模型数据中的唯一id）
 *  属性名称必须是FLDBID,适应框架
 */
@property (nonatomic,copy)NSString *FLDBID;


@property (nonatomic,copy)NSString *name_gitKong;

@property (nonatomic,assign)NSInteger age;

@property (nonatomic,strong)NSDictionary *msgInfo;

@property (nonatomic,strong)NSMutableArray *scroceArrM;

/**
 *  @author gitKong
 *
 *  嵌套模型，多表处理
 */
@property (nonatomic,copy)NSString *penModelID;// 标记 FLPenModel 嵌套模型
//@property (nonatomic,strong)FLPenModel *penModel;
//
@property (nonatomic,copy)NSString *bookModelID;// 标记 FLBookModel 嵌套模型
//@property (nonatomic,strong)FLBookModel *bookModel;

//@property (nonatomic,copy)NSString *id;

// 嵌套的模型一般创建多一张表，一张表不好处理
//@property (nonatomic,strong)NSArray *otherModelArr;

@end
