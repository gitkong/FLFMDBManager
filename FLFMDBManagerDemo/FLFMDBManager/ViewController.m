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
#import "FLStudentTableViewCell.h"
#import "FLFMDBQueueManager.h"
#import "TestViewController.h"
#import "FLPenModel.h"
#import "FLBookModel.h"
@interface ViewController ()
@property (nonatomic,strong)NSMutableArray *modelArrM;
@end

@implementation ViewController{
    NSInteger _index;
}

- (void)writeDbOne{
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSInteger index = 0; index < 500; index ++) {
        
        FLStudentModel *model = [[FLStudentModel alloc] init];
//        model.name_gitKong = @"clarence";
        model.age = 24;
        model.FLDBID = [NSString stringWithFormat:@"clarence_%zd",index];
        model.msgInfo = @{@"name" : @"gitKong" ,@"age" : @24};
        model.scroceArrM = [NSMutableArray arrayWithObjects:@"100",@"90",@"80", nil];
        [arrM addObject:model];
//        _index = index + 1;
        
        /**
         *  @author gitKong
         *
         *  dataBase
         */
        
//        BOOL success = [FLFMDBMANAGER fl_insertModel:model];
//        if (success) {
//            NSLog(@"插入成功");
//            
//        }
//        else {
//            NSLog(@"插入失败");
//        }
        
        
        /**
         *  @author gitKong
         *
         *  dataBaseQueue
         */
        [FLFMDBQUEUEMANAGER fl_insertModel:model complete:^(FLFMDBQueueManager *manager, BOOL flag) {
            if (flag) {
                NSLog(@"插入成功");
            }
            else {
                NSLog(@"插入失败");
            }
        }];
    }
}

- (void)writeDbTwo{
    NSMutableArray *arrM = [NSMutableArray array];
    for (NSInteger index = 500; index < 1000; index ++) {
        
        FLStudentModel *model = [[FLStudentModel alloc] init];
        model.name_gitKong = @"clarence";
        model.age = 24;
        model.FLDBID = [NSString stringWithFormat:@"clarence_%zd",index];
        model.msgInfo = @{@"name" : @"gitKong" ,@"age" : @24};
        model.scroceArrM = [NSMutableArray arrayWithObjects:@"100",@"90",@"80", nil];
        [arrM addObject:model];
//        _index = index + 1;
        
//        BOOL success = [FLFMDBMANAGER fl_insertModel:model];
//        if (success) {
//            NSLog(@"插入成功");
//            
//        }
//        else {
//            NSLog(@"插入失败");
//        }
        
        [FLFMDBQUEUEMANAGER fl_insertModel:model complete:^(FLFMDBQueueManager *manager, BOOL flag) {
            if (flag) {
                NSLog(@"插入成功");
            }
            else {
                NSLog(@"插入失败");
            }
        }];
    }
}

- (void)readDb{
    
//    NSArray *modelArr = [FLFMDBMANAGER fl_searchModelArr:[FLStudentModel class]];
    
    [FLFMDBQUEUEMANAGER fl_searchModelArr:[FLStudentModel class] complete:^(FLFMDBQueueManager *manager, NSArray *modelArr) {
        
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    
    /**
     *  @author gitKong
     *
     *  全部操作默认开启子线程，回调会在主线程，解决多线程操作大量数据文件读写问题、以及嵌套使用问题
     */
//    NSMutableArray *arrM = [NSMutableArray array];
//    for (NSInteger index = 0; index < 100; index ++) {
//        
//        FLStudentModel *model = [[FLStudentModel alloc] init];
//        model.name_gitKong = @"clarence";
//        model.age = 24;
//        model.FLDBID = [NSString stringWithFormat:@"clarence_%zd",index];
//        model.msgInfo = @{@"name" : @"gitKong" ,@"age" : @24};
//        model.scroceArrM = [NSMutableArray arrayWithObjects:@"100",@"90",@"80", nil];
//        [arrM addObject:model];
//    }
//    
//    [FLFMDBQUEUEMANAGERX(@"clarence") fl_createTable:[FLStudentModel class] complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//        [FLFMDBQUEUEMANAGERX(@"clarence") fl_searchModelArr:[FLStudentModel class] complete:^(FLFMDBQueueManager *manager, NSArray *modelArr) {
//            NSLog(@"%@",modelArr);
//            [FLFMDBQUEUEMANAGERX(@"clarence") fl_insertModel:arrM complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//                NSLog(@"%zd",flag);
//                [FLFMDBQUEUEMANAGERX(@"clarence") fl_searchModelArr:[FLStudentModel class] complete:^(FLFMDBQueueManager *manager, NSArray *modelArr) {
//                    NSLog(@"%@",modelArr);
//                }];
//            }];
//        }];
//    }];
    
    
    /**
     *  @author gitKong
     *
     *  支持多个数据库
     */
//    FLFMDBQUEUEMANAGERX(@"dd");
//
//    [FLFMDBQUEUEMANAGERX(@"dd") fl_dropDB];
    
    
    /**
     *  @author gitKong
     *
     *  多线程测试
     */
    [NSThread detachNewThreadSelector:@selector(writeDbOne) toTarget:self withObject:nil];

    [NSThread detachNewThreadSelector:@selector(readDb) toTarget:self withObject:nil];
    
    [NSThread detachNewThreadSelector:@selector(writeDbTwo) toTarget:self withObject:nil];
    
    
    FLPenModel *penModel = [[FLPenModel alloc] init];
    penModel.name = @"My Pen";
    penModel.FLDBID = @"1";
    penModel.dict = @{
                      @"name":@"gitKong",
                      @"age":@23
                      };
    penModel.arr = @[@{
                         @"name":@"gitKong",
                         @"age":@23
                         },
                     
                     @{
                         @"name":@"gitKong",
                         @"age":@23
                         }
                     ];
    
    FLPenModel *penModel1 = [[FLPenModel alloc] init];
    penModel1.name = @"My Pen";
    penModel1.FLDBID = @"2";
    penModel1.dict = @{
                       @"name":@"gitKong",
                       @"age":@23
                       };
    
    FLBookModel *bookModel = [[FLBookModel alloc] init];
    bookModel.name = @"My Book";
    bookModel.FLDBID = NSStringFromClass([FLBookModel class]);
    
    FLStudentModel *studentModel = [[FLStudentModel alloc] init];
    studentModel.name_gitKong = @"惺惺xxxxx惺惺想";
    studentModel.age = 24;
    studentModel.FLDBID = @"xxx";
    // 记录嵌套模型的id
//    studentModel.penModelID = penModel.FLDBID;
//    studentModel.bookModelID = bookModel.FLDBID;
    
    
    /**
     *  @author gitKong
     *
     *  解决死锁问题，通过insert创建就可以查到对应表
     */
//    [FLFMDBQUEUEMANAGER fl_insertModel:studentModel complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//        if (flag) {
//            NSLog(@"success------");
//            [FLFMDBQUEUEMANAGER fl_isExitTable:[FLStudentModel class] complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//                NSLog(@"flag = %zd",flag);
//            }];
//        }
//    }];
    
    
    /**
     *  @author gitKong
     *
     *  创建表格，回调是成功创建，但一直找不到表格，通过insert创建就没问题，已解决！
     */
//    [FLFMDBQUEUEMANAGER fl_createTable:[FLStudentModel class] complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//        if (flag) {
//            NSLog(@"创建成功");
//            
//            [FLFMDBQUEUEMANAGER fl_isExitTable:[FLStudentModel class] complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//                NSLog(@"flag = %zd",flag);
//            }];
//        }
//    }];
     /**/
    
    
    /**
     *  @author gitKong
     *
     *  db处理，多数据库操作正常
     */
    
    BOOL flag = [FLFMDBMANAGER fl_createTable:[FLStudentModel class]];
    if (flag) {
        NSLog(@"创建成功");
        flag = [FLFMDBMANAGER fl_isExitTable:[FLStudentModel class]];
        if (flag) {
            NSLog(@"[FLStudentModel class] is exit");
        }
    }
    
    flag = [FLFMDBMANAGERX(@"hello world") fl_createTable:[FLStudentModel class]];
    if (flag) {
        NSLog(@"hello world 创建成功");
    }
    
    flag = [FLFMDBMANAGERX(@"clarence") fl_createTable:[FLStudentModel class]];
    if (flag) {
        NSLog(@"clarence 创建成功");
    }

    /**
     *  @author gitKong
     *
     *  解决多表创建出现表格查询不到问题
     */
//    [FLFMDBQUEUEMANAGER fl_insertModel:penModel complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//        if (flag) {
//            NSLog(@"insert penModel successfully");
//            
//        }
//    }];
//
//    [FLFMDBQUEUEMANAGER fl_insertModel:studentModel complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//        if (flag) {
//            NSLog(@"insert studentModel successfully");
//            
//        }
//    }];
    
    
//    [FLFMDBQUEUEMANAGER fl_insertModel:penModel complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//        if (flag) {
//            
//        }
//    }];
//    
//    [FLFMDBQUEUEMANAGER fl_insertModel:penModel1 complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//        if (flag) {
//            
//        }
//    }];
//    
//    [FLFMDBQUEUEMANAGER fl_searchModelArr:[FLPenModel class] complete:^(FLFMDBQueueManager *manager, NSArray *modelArr) {
//        
//    }];
    
    
    
    /**
     *  @author gitKong
     *
     *  多个数据库，测试
     */
//    BOOL success = NO;
//    success = [FLFMDBMANAGERX(@"clarence") fl_insertModel:studentModel];
//    if (success) {
//        success = [FLFMDBMANAGERX(@"clarence") fl_insertModel:penModel];
//        if (success) {
//            FLStudentModel *studentModel = [FLFMDBMANAGERX(@"clarence") fl_searchModel:[FLStudentModel class] byID:@"0"];
//            if (studentModel.penModelID) {
//                FLPenModel *penModel = [FLFMDBMANAGERX(@"clarence") fl_searchModel:[FLPenModel class] byID:studentModel.penModelID];
//                [self showTip:penModel.name];
//                [NSThread sleepForTimeInterval:2.0];
//                FLPenModel *penNewModel = [[FLPenModel alloc] init];
//                penNewModel.name = @"hello world";
//                penNewModel.FLDBID = NSStringFromClass([FLPenModel class]);
//                success = [FLFMDBMANAGERX(@"clarence") fl_modifyModel:penNewModel byID:NSStringFromClass([FLPenModel class])];
//                if (success) {
//                    FLPenModel *model = [FLFMDBMANAGERX(@"clarence") fl_searchModel:[FLPenModel class] byID:penNewModel.FLDBID];
//                    [self showTip:model.name];
//                }
//            }
//        }
//    }
    
    /**
     *  @author gitKong
     *
     *  操作同一个数据库回调没问题，但同时操作多个数据库，回调只会执行最先调用的方法的，下面的方法回调不执行，正在解决。。。
     */
//    [FLFMDBQUEUEMANAGERX(@"hello world") fl_createTable:[FLBookModel class] complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//        NSLog(@"FLBookModel = %zd",flag);
//    }];
//    
//    [FLFMDBQUEUEMANAGERX(@"hello") fl_createTable:[FLPenModel class] complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//        
//        [FLFMDBQUEUEMANAGERX(@"hello world") fl_insertModel:penModel complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//            NSLog(@"FLPenModel = %zd",flag);
//            if (flag) {
//                [FLFMDBQUEUEMANAGERX(@"hello world") fl_searchModel:[FLPenModel class] byID:@"1" complete:^(FLFMDBQueueManager *manager, id model) {
//                    NSLog(@"FLPenModel = %@",model);
//                }];
//            }
//        }];
//    }];
//    
//    [FLFMDBQUEUEMANAGERX(@"hello world") fl_searchModelArr:[FLBookModel class] complete:^(FLFMDBQueueManager *manager, NSArray *modelArr) {
//        NSLog(@"modelArr = %@",modelArr);
//    }];
    
//    [FLFMDBQUEUEMANAGER fl_createTable:[FLStudentModel class] complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//        NSLog(@"%ld",(long)flag);
//        if (flag) {
//            
//        }
//    }];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FLStudentTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.estimatedRowHeight = 100;
    
//    [self.navigationController pushViewController:[[TestViewController alloc] init] animated:YES];
}

- (IBAction)searchAllData:(id)sender {
    __weak typeof(self) weakSelf = self;
    
    
//    [FLFMDBQUEUEMANAGER fl_searchModel:[FLStudentModel class] byID:@"0" complete:^(FLFMDBQueueManager *manager, id model) {
//        FLStudentModel *studentModel = (FLStudentModel *)model;
//        
//        // 再根据绑定的FLDBID 查询 嵌套的表格
//        [FLFMDBQUEUEMANAGER fl_searchModel:[FLPenModel class] byID:studentModel.penModelID complete:^(FLFMDBQueueManager *manager, id model) {
//            FLPenModel *penModel = (FLPenModel *)model;
//            [weakSelf showTip:penModel.name];
//        }];
//    }];
    
//    FLStudentModel *studentModel = [FLFMDBMANAGER fl_searchModel:[FLStudentModel class] byID:@"0"];
//    FLPenModel *penModel = [FLFMDBMANAGER fl_searchModel:[FLPenModel class] byID:studentModel.penModelID];
//    [weakSelf showTip:penModel.name];
    
    
    /**
     *  @author gitKong
     *
     *  查询所有信息
     */
    [FLFMDBQUEUEMANAGER fl_searchModelArr:[FLStudentModel class] complete:^(FLFMDBQueueManager *manager, NSArray *modelArr) {
        __weak typeof(self) strongSelf = weakSelf;
        dispatch_async(dispatch_get_main_queue(), ^{
            [strongSelf.modelArrM removeAllObjects];
            FLStudentModel *model = modelArr.firstObject;
//            for (NSString *str in model.scroceArrM) {
//                NSLog(@"----xxxxxxxxxxxxxxxxxxxxxxxx---%@",str);
//            }
            [strongSelf.modelArrM addObjectsFromArray:modelArr];
            [strongSelf.tableView reloadData];
        });
    }];
    
}

- (IBAction)deleteTable:(id)sender {
//    NSString *str = @"";
//    if ([FLFMDBMANAGER fl_dropTable:[FLStudentModel class]]) {
//        str = @"删表成功";
//        [self.modelArrM removeAllObjects];
//        [self.tableView reloadData];
//    }
//    else{
//        str = @"删表失败";
//    }
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:str message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [alertView show];
    
    __weak typeof(self) weakSelf = self;
    [FLFMDBQUEUEMANAGER fl_dropTable:[FLStudentModel class] complete:^(FLFMDBQueueManager *manager, BOOL flag) {
        __strong typeof(weakSelf) strongSelf = weakSelf;
        NSString *str = @"";
        if (flag) {
            [strongSelf.modelArrM removeAllObjects];
        
            [strongSelf.tableView reloadData];
            str = @"删表成功";
            
        }
        else{
            str = @"删表失败";
        }
        [strongSelf showTip:str];
    }];
    
//    [FLFMDBQUEUEMANAGER fl_deleteAllModel:[FLStudentModel class] complete:^(FLFMDBQueueManager *manager, BOOL flag) {
//        NSString *str = @"";
//        if (flag) {
//            str = @"删成功";
//            
//        }
//        else{
//            str = @"删失败";
//        }
//        [weakSelf showTip:str];
//    }];
    
}

- (void)showTip:(NSString *)tip{
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:tip message:nil delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alertView show];
}

- (IBAction)searchData:(id)sender {
    
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"输入FLDBID" message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(vc) weakVc = vc;
    __weak typeof(self) weakSelf = self;
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"text = %@",textField.text);
            
//            FLStudentModel *model = [FLFMDBMANAGER fl_searchModel:[FLStudentModel class] byID:textField.text];
//            if (model.FLDBID) {
//                [weakSelf.modelArrM removeAllObjects];
//                [weakSelf.modelArrM addObject:model];
//                [weakSelf.tableView reloadData];
//            }
//            else{
//                NSLog(@"找不到这个模型");
//            }
            
            [FLFMDBQUEUEMANAGER fl_searchModel:[FLStudentModel class] byID:textField.text complete:^(FLFMDBQueueManager *manager,id model) {
                __strong typeof(weakSelf) strongSelf = weakSelf;
                FLStudentModel *studentModel = (FLStudentModel *)model;
                
                if (studentModel.FLDBID) {
                    [strongSelf.modelArrM removeAllObjects];
                    [strongSelf.modelArrM addObject:studentModel];
                    [strongSelf.tableView reloadData];
                }
                else{
                    NSLog(@"找不到这个模型");
                    [strongSelf showTip:@"找不到这个模型"];
                }
            }];
        }];
        [weakVc addAction:action];
    }];
    
    [self presentViewController:weakVc animated:YES completion:nil];
}

- (IBAction)insertData:(id)sender {
    
    FLStudentModel *model = [[FLStudentModel alloc] init];
    model.name_gitKong = @"gitKong";
    model.age = 24;
    model.FLDBID = [NSString stringWithFormat:@"gitKong_%zd",_index ++];
    model.msgInfo = @{@"name" : @"gitKong" ,@"age" : @24,@"sex" : @"male"};
    model.scroceArrM = [NSMutableArray arrayWithObjects:@"100",@"99",@"97", nil];
    
//    if ([FLFMDBMANAGER fl_insertModel:model]) {
//        NSLog(@"插入数据成功");
//        [self.modelArrM addObject:model];
//        [self.tableView reloadData];
//    }
//    else{
//        NSLog(@"插入数据失败");
//    }
    
    __weak typeof(self) weakSelf = self;
    [FLFMDBQUEUEMANAGER fl_insertModel:model complete:^(FLFMDBQueueManager *manager, BOOL flag) {
        __weak typeof(self) strongSelf = weakSelf;
        if (flag) {
            [strongSelf.modelArrM addObject:model];
            [strongSelf.tableView reloadData];
            NSLog(@"插入数据成功");
            [strongSelf showTip:@"插入数据成功"];
        }
        else{
            NSLog(@"插入数据失败");
            [strongSelf showTip:@"插入数据失败"];
        }
    }];
}

#pragma mark - Table view data source & delegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return self.modelArrM.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    FLStudentTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    
    cell.model = self.modelArrM[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    FLStudentModel *model = self.modelArrM[indexPath.row];
    UIAlertController *vc = [UIAlertController alertControllerWithTitle:@"修改名字" message:nil preferredStyle:UIAlertControllerStyleAlert];
    __weak typeof(vc) weakVc = vc;
    __weak typeof(self) weakSelf = self;
    [vc addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            NSLog(@"text = %@",textField.text);
            model.name_gitKong = textField.text;
//            if ([[FLFMDBManager shareManager] fl_modifyModel:model byID:model.FLDBID]) {
//                [weakSelf.tableView reloadData];
//            }
//            else{
//                NSLog(@"修改名字失败");
//            }
            
            [FLFMDBQUEUEMANAGER fl_modifyModel:model byID:model.FLDBID complete:^(FLFMDBQueueManager *manager, BOOL flag) {
                __weak typeof(self) strongSelf = weakSelf;
                if (flag) {
                    [FLFMDBQUEUEMANAGER fl_searchModel:[model class] byID:model.FLDBID complete:^(FLFMDBQueueManager *manager, id model) {
                        FLStudentModel *modifiedModel = (FLStudentModel *)model;
                        [strongSelf showTip:[NSString stringWithFormat:@"修改名字成功 - %@",modifiedModel.name_gitKong]];
                        [strongSelf.tableView reloadData];
                    }];
                    
                }
                else{
                    [strongSelf showTip:@"修改名字失败"];
                    NSLog(@"修改名字失败");
                }
            }];
        }];
        [weakVc addAction:action];
    }];
    
    [self presentViewController:weakVc animated:YES completion:nil];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    return YES;
}

- (NSArray<UITableViewRowAction *> *)tableView:(UITableView *)tableView editActionsForRowAtIndexPath:(NSIndexPath *)indexPath{
    __weak typeof(self) weakSelf = self;
    UITableViewRowAction *action = [UITableViewRowAction rowActionWithStyle:UITableViewRowActionStyleNormal title:@"删除" handler:^(UITableViewRowAction * _Nonnull action, NSIndexPath * _Nonnull indexPath) {
        FLStudentModel *model = self.modelArrM[indexPath.row];
        // 删除数据库指定
//        if ([FLFMDBMANAGER fl_deleteModel:[FLStudentModel class] byId:model.FLDBID]) {
//            [weakSelf.modelArrM removeObject:model];
//            [weakSelf.tableView reloadData];
//        }
//        else{
//            NSLog(@"删除数据失败");
//        }
        
        [FLFMDBQUEUEMANAGER fl_deleteModel:[FLStudentModel class] byId:model.FLDBID complete:^(FLFMDBQueueManager *manager, BOOL flag) {
            __weak typeof(self) strongSelf = weakSelf;
            if (flag) {
                
                [strongSelf.modelArrM removeObject:model];
                [strongSelf.tableView reloadData];
                NSLog(@"删除数据成功");
                [strongSelf showTip:@"删除数据成功"];
            }
            else{
                NSLog(@"删除数据失败");
                [strongSelf showTip:@"删除数据失败"];
            }
        }];
    }];
    return @[action];
}


#pragma mark -- Setter & Getter

- (NSMutableArray *)modelArrM{
    if (_modelArrM == nil) {
        _modelArrM = [NSMutableArray array];
    }
    return _modelArrM;
}


@end
