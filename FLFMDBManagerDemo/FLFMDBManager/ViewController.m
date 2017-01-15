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
        model.name_gitKong = @"clarence";
        model.age = 24;
        model.FLDBID = [NSString stringWithFormat:@"clarence_%zd",index];
        model.msgInfo = @{@"name" : @"gitKong" ,@"age" : @24};
        model.scroceArrM = [NSMutableArray arrayWithObjects:@"100",@"90",@"80", nil];
        [arrM addObject:model];
        _index = index + 1;
        
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
        _index = index + 1;
        
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
    
    
    if ([FLFMDBMANAGER fl_isExitTable:[FLStudentModel class]]) {
        [FLFMDBMANAGER fl_dropTable:[FLStudentModel class]];
    }
    
    
    // 多线程测试
    [NSThread detachNewThreadSelector:@selector(writeDbOne) toTarget:self withObject:nil];
    
    [NSThread detachNewThreadSelector:@selector(readDb) toTarget:self withObject:nil];
    
    [NSThread detachNewThreadSelector:@selector(writeDbTwo) toTarget:self withObject:nil];
    
    
    [self.tableView registerNib:[UINib nibWithNibName:@"FLStudentTableViewCell" bundle:nil] forCellReuseIdentifier:@"cell"];
    self.tableView.estimatedRowHeight = 100;
    
//    [self.navigationController pushViewController:[[TestViewController alloc] init] animated:YES];
}

- (IBAction)searchAllData:(id)sender {
//    NSArray *modelArr = [FLFMDBMANAGER fl_searchModelArr:[FLStudentModel class]];
//    [self.modelArrM removeAllObjects];
//    [self.modelArrM addObjectsFromArray:modelArr];
//    [self.tableView reloadData];
    
    __weak typeof(self) weakSelf = self;
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        NSLog(@"thread = %@",[NSThread currentThread]);
        [FLFMDBQUEUEMANAGER fl_searchModelArr:[FLStudentModel class] complete:^(FLFMDBQueueManager *manager, NSArray *modelArr) {
            __weak typeof(self) strongSelf = weakSelf;
            dispatch_async(dispatch_get_main_queue(), ^{
                [strongSelf.modelArrM removeAllObjects];
                [strongSelf.modelArrM addObjectsFromArray:modelArr];
                [strongSelf.tableView reloadData];
            });
        }];
    });
    
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
        [weakSelf showTip:str];
    }];
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
                    [strongSelf showTip:@"修改名字成功"];
                    [strongSelf.tableView reloadData];
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
