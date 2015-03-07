//
//  CityTableViewCell.h
//  Open Weather D.K.
//
//  Created by dongjiaming on 15/2/27.
//  Copyright (c) 2015年 The University of Chicago, Department of Computer Science. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CityTableViewCell : UITableViewCell

@property (strong, nonatomic) IBOutlet UIImageView *weatherType;
@property (strong, nonatomic) IBOutlet UILabel *cityName;
@property (strong, nonatomic) IBOutlet UILabel *temperature;
@property (weak, nonatomic) IBOutlet UIImageView *mapSign;


@end
