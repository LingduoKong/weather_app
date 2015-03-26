//
//  JCFlipPage.h
//  JCFlipPageView
//
//  Created by ThreegeneDev on 14-8-8.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import <UIKit/UIKit.h>

static NSString const* kJCFlipPageDefaultReusableIdentifier = @"kJCFlipPageDefaultReusableIdentifier";


@interface JCFlipPage : UIView

@property (nonatomic, readonly, copy) NSString *reuseIdentifier;

// to display
@property (nonatomic, strong) UIImageView *backgroudImage;

@property (nonatomic, strong) UILabel *timeLabel;

@property (nonatomic, strong) UILabel *windSpeedLabel;
@property (nonatomic, strong) UILabel *humidityLabel;
@property (nonatomic, strong) UILabel *pressureLabel;

@property (nonatomic, strong) UILabel *temperatureLabel;

@property (nonatomic, strong) UILabel *hiloLabel;

@property (nonatomic, strong) UILabel *conditionsLabel;

@property (nonatomic, strong) UIImageView *iconView;

@property (nonatomic, strong) UIView *header;

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier;
- (void)prepareForReuse;

@end
