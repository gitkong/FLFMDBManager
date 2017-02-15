//
//  TestViewController.m
//  FLFMDBManager
//
//  Created by 孔凡列 on 2017/1/15.
//  Copyright © 2017年 clarence. All rights reserved.
//

#import "TestViewController.h"
#import "FLFMDBQueueManager.h"
#import "FLStudentModel.h"
@interface TestViewController ()
@property(nonatomic,copy)NSString *name;
@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
//    [FLFMDBQUEUEMANAGER fl_createTable:[FLStudentModel class] complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//        self.name = @"hello world";
//        [self testCircleRef];
//    }];
}

- (void)testCircleRef{
    NSLog(@"%@",self.name);
}

- (void)dealloc {
    NSLog(@"%s",__func__);
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
