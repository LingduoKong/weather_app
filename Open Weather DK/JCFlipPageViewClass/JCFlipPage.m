//
//  JCFlipPage.m
//  JCFlipPageView
//
//  Created by ThreegeneDev on 14-8-8.
//  Copyright (c) 2014年 JimpleChen. All rights reserved.
//

#import "JCFlipPage.h"

@implementation JCFlipPage
@synthesize reuseIdentifier = _reuseIdentifier;

- (void)dealloc
{
}

- (void)prepareForReuse
{
    
}

- (id)initWithFrame:(CGRect)frame reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _reuseIdentifier = reuseIdentifier;
        self.backgroundColor = [UIColor clearColor];
        
        // layout
        CGRect headerFrame = CGRectMake(0, self.bounds.size.height*2, self.bounds.size.width, self.bounds.size.height*0.8);
        
        CGFloat inset = 20;
        
        CGFloat temperatureHeight = 110;
        CGFloat hiloHeight = 40;
        CGFloat iconHeight = 30;
        
        CGRect timeFrame = CGRectMake(inset,
                                      iconHeight
                                      , self.bounds.size.width-inset,
                                      iconHeight);
        
        CGRect hiloFrame = CGRectMake(inset,
                                      headerFrame.size.height - hiloHeight,
                                      headerFrame.size.width - (2 * inset),
                                      hiloHeight);
        
        CGRect temperatureFrame = CGRectMake(inset,
                                             headerFrame.size.height - (temperatureHeight + hiloHeight),
                                             headerFrame.size.width - (2 * inset),
                                             temperatureHeight);
        
        CGRect iconFrame = CGRectMake(inset,
                                      temperatureFrame.origin.y - iconHeight,
                                      iconHeight,
                                      iconHeight);
        
        CGRect conditionsFrame = iconFrame;
        conditionsFrame.size.width = self.bounds.size.width - (((2 * inset) + iconHeight) + 10);
        conditionsFrame.origin.x = iconFrame.origin.x + (iconHeight + 10);
        
        CGRect humidityFrame = CGRectMake(0,
                                          iconFrame.origin.y
                                          , self.bounds.size.width-inset
                                          , iconHeight*2);
        
        CGRect windSpeedFrame = CGRectMake(0,
                                           humidityFrame.origin.y+iconHeight*2
                                           , self.bounds.size.width-inset,
                                           iconHeight*2);
        
        CGRect pressureFrame = CGRectMake(0, windSpeedFrame.origin.y+iconHeight*2
                                          , self.bounds.size.width-inset
                                          , iconHeight*2);
        
        
        _header = [[UIView alloc] initWithFrame:headerFrame];
        //header.backgroundColor = [UIColor clearColor];
        
        self.backgroudImage = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, self.bounds.size.width, self.bounds.size.height)];
        [self addSubview:self.backgroudImage];
        
        _timeLabel = [[UILabel alloc]initWithFrame:timeFrame];
        _timeLabel.textAlignment = NSTextAlignmentCenter;
        _timeLabel.backgroundColor = [UIColor clearColor];
        _timeLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        _timeLabel.textColor = [UIColor whiteColor];
        [self addSubview:_timeLabel];
        
        _windSpeedLabel = [[UILabel alloc]initWithFrame:windSpeedFrame];
        _windSpeedLabel.backgroundColor = [UIColor clearColor];
        _windSpeedLabel.textAlignment = NSTextAlignmentRight;
        _windSpeedLabel.textColor = [UIColor whiteColor];
        _windSpeedLabel.numberOfLines = 2;
        _windSpeedLabel.text = @"Wind\n:";
        _windSpeedLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        [self addSubview:_windSpeedLabel];
        
        _humidityLabel = [[UILabel alloc]initWithFrame:humidityFrame];
        _humidityLabel.textAlignment = NSTextAlignmentRight;
        _humidityLabel.backgroundColor = [UIColor clearColor];
        _humidityLabel.textColor = [UIColor whiteColor];
        _humidityLabel.numberOfLines = 2;
        _humidityLabel.text = @"Humidity\n:";
        _humidityLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        [self addSubview:_humidityLabel];
        
        _pressureLabel = [[UILabel alloc]initWithFrame:pressureFrame];
        _pressureLabel.textAlignment = NSTextAlignmentRight;
        _pressureLabel.backgroundColor = [UIColor clearColor];
        _pressureLabel.textColor = [UIColor whiteColor];
        _pressureLabel.numberOfLines = 2;
        _pressureLabel.text = @"Presure\n:";
        _pressureLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        [self addSubview:_pressureLabel];
        
        // bottom left
        _temperatureLabel = [[UILabel alloc] initWithFrame:temperatureFrame];
        _temperatureLabel.backgroundColor = [UIColor clearColor];
        _temperatureLabel.textColor = [UIColor whiteColor];
        _temperatureLabel.text = @"0°";
        _temperatureLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:120];
        [self addSubview:_temperatureLabel];
        
        // bottom left
        _hiloLabel = [[UILabel alloc] initWithFrame:hiloFrame];
        _hiloLabel.backgroundColor = [UIColor clearColor];
        _hiloLabel.textColor = [UIColor whiteColor];
        _hiloLabel.text = @"0° / 0°";
        _hiloLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:28];
        [self addSubview:_hiloLabel];
        
        _conditionsLabel = [[UILabel alloc] initWithFrame:conditionsFrame];
        _conditionsLabel.backgroundColor = [UIColor clearColor];
        _conditionsLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:18];
        _conditionsLabel.textColor = [UIColor whiteColor];
        [self addSubview:_conditionsLabel];
        
        _iconView = [[UIImageView alloc] initWithFrame:iconFrame];
        _iconView.contentMode = UIViewContentModeScaleAspectFit;
        _iconView.backgroundColor = [UIColor clearColor];
        [self addSubview:_iconView];
        
        [self addSubview:_header];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
