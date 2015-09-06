//
//  JYLoadErrorView.m
//  HaojyClient
//
//  Created by Robinkey on 14-6-11.
//  Copyright (c) 2014年 JYHD. All rights reserved.
//

#import "JYLoadErrorView.h"

@interface JYLoadErrorView()
@property (nonatomic, copy) CallbackBlock backBlock;
@end

@implementation JYLoadErrorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.userInteractionEnabled = YES;
        self.frame = CGRectMake((SCREEN_WIDTH-LoadErrorViewWidth)/2, (SCREEN_HEIGHT-LoadErrorViewHeight)/2, LoadErrorViewWidth, LoadErrorViewHeight);
        self.backgroundColor = [UIColor clearColor];
        UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(self.frame.size.width/2-82, self.frame.size.height/2-36, 163, 73)];
        imageView.image = [UIImage imageNamed:@"loadingbg"];
        [self addSubview:imageView];
        }
    return self;
}
- (id)initWithBlock:(CallbackBlock)block
{
    if (self = [self initWithFrame:CGRectZero]) {
        self.backBlock = block;
    }
    return self;
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (self.backBlock) {
        self.backBlock();
    }
    
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
