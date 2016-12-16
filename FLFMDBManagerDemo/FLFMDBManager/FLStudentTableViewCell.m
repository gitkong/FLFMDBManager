//
//  FLStudentTableViewCell.m
//  FLFMDBManager
//
//  Created by clarence on 16/11/21.
//  Copyright © 2016年 clarence. All rights reserved.
//

#import "FLStudentTableViewCell.h"
#import "FLStudentModel.h"
@interface FLStudentTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ageLabel;
@property (weak, nonatomic) IBOutlet UILabel *DBIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *msgInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *scroceArrMLabel;

@end

@implementation FLStudentTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setModel:(FLStudentModel *)model{
    _model = model;
    self.nameLabel.text = [NSString stringWithFormat:@"名字：%@",model.name_gitKong];
    self.ageLabel.text = [NSString stringWithFormat:@"年龄：%zd",model.age];
    self.DBIDLabel.text = [NSString stringWithFormat:@"FLDBID：%@",model.FLDBID];
    self.msgInfoLabel.text = [NSString stringWithFormat:@"msgInfo：%@",model.msgInfo];
    self.scroceArrMLabel.text = [NSString stringWithFormat:@"scroceArrM：%@",model.scroceArrM];
}

@end
