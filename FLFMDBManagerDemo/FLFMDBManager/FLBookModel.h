//
//  FLBookModel.h
//  FLFMDBManager
//
//  Created by clarence on 17/2/10.
//  Copyright © 2017年 clarence. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FLBookModel : NSObject
/**
 *  @author Clarence
 *
 *  数据库中绑定指定模型的DBID（一般对应后台返回模型数据中的唯一id）
 *  属性名称必须是FLDBID,适应框架
 */
@property (nonatomic,copy)NSString *FLDBID;

@property (nonatomic,copy)NSString *name;
@end
