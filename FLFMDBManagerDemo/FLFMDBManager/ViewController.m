//
//  ViewController.m
//  FLFMDBManager
//
//  Created by clarence on 16/11/17.
//  Copyright © 2016年 clarence. All rights reserved.
//

#import "ViewController.h"
#import "FLFMDBManager.h"
#import "FLStudentModel.h"
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSInteger index = 0; index < 10; index ++) {
        FLStudentModel *model = [[FLStudentModel alloc] init];
        model.name = @"clarence";
        model.age = 24;
        model.DBID = [NSString stringWithFormat:@"clarence_%zd",index];
        
//        BOOL success = [[FLFMDBManager shareManager] fl_insertModel:model];
//        if (success) {
//            NSLog(@"插入成功");
//        }
//        else {
//            NSLog(@"插入失败");
//        }
        [arrM addObject:model];
    }
    
    BOOL success = [[FLFMDBManager shareManager] fl_insertModelArr:arrM];
    if (success) {
        NSLog(@"插入成功");
    }
    else {
        NSLog(@"插入失败");
    }
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    
    NSArray *modelArr = [[FLFMDBManager shareManager] fl_searchModelArr:[FLStudentModel class]];
    FLStudentModel *model1 = modelArr.firstObject;
    
    FLStudentModel *singleModel = [FLFMDBMANAGER fl_searchModel:[FLStudentModel class] byID:model1.DBID];
    NSLog(@"搜索单个模型--%@-%zd-%@",singleModel.name,singleModel.age,singleModel.DBID);
    NSLog(@"count = %zd,model1 = %@",modelArr.count,model1.name);
    
    FLStudentModel *model = [[FLStudentModel alloc] init];
    model.name = @"1111";
    model.age = 214;
    model.DBID = model1.DBID;
    
//    [[FLFMDBManager shareManager] fl_modifyModel:model atIndex:0];
    
    [[FLFMDBManager shareManager] fl_modifyModel:model byID:model1.DBID];
    
    NSArray *arr = [[FLFMDBManager shareManager] fl_searchModelArr:[FLStudentModel class]];
    FLStudentModel *model2 = arr.firstObject;
    
    
    FLStudentModel *model3 = arr.lastObject;
    [FLFMDBMANAGER fl_deleteModel:[FLStudentModel class] byId:model3.DBID];
    
    [FLFMDBMANAGER fl_deleteAllModel:[FLStudentModel class]];
    
    [FLFMDBMANAGER fl_dropTable:[FLStudentModel class]];
    NSArray *lastArr = [[FLFMDBManager shareManager] fl_searchModelArr:[FLStudentModel class]];
    NSLog(@"count = %zd,model2 = %@",lastArr.count,model2.name);
}


@end
