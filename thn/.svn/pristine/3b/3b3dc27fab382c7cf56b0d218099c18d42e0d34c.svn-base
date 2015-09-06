//
//  RKFootFreshView.m
//  pictureFlow
//
//  Created by Robinkey on 12/28/12.
//  Copyright (c) 2012 Robinkey. All rights reserved.
//

#import "RKFootFreshView.h"

@interface RKFootFreshView()
@property(nonatomic, strong) UILabel * textLabel;
@property(nonatomic, strong) UILabel * endLabel;
@property(nonatomic, strong) UIActivityIndicatorView * activityView;
@property(nonatomic, readwrite, assign) CGRect savedFrame;
@end

@implementation RKFootFreshView
@synthesize textLabel = _textLabel, endLabel = _endLabel;
@synthesize activityView = _activityView;
@synthesize showActivityIndicator = _showActivityIndicator;
@synthesize refreshing = _refreshing;
@synthesize enabled = _enabled;
@synthesize savedFrame = _savedFrame;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.showActivityIndicator = NO;
        self.enabled = YES;
        self.refreshing = NO;
        
        self.textLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, frame.size.width, frame.size.height)] ;
        self.textLabel.textAlignment = NSTextAlignmentCenter;
        self.textLabel.text = NSLocalizedString(@"", @"");
        self.textLabel.textColor = [UIColor darkGrayColor];
        [self addSubview:self.textLabel];
        
        self.endLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, frame.size.width, frame.size.height)];
        self.endLabel.textAlignment = NSTextAlignmentCenter;
        self.endLabel.font = [UIFont systemFontOfSize:14];
        self.endLabel.text = NSLocalizedString(@"已加载全部", @"All load");
        self.endLabel.textColor = UIColorFromRGB(0xd7d7d7);
        self.endLabel.hidden = YES;
        [self addSubview:self.endLabel];
        
        self.textLabel.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void) setFrame:(CGRect)frame {
    self.savedFrame = frame;
    [super setFrame:frame];
}

- (void) setTextAlignment:(NSTextAlignment)textAlignment {
    self.textLabel.textAlignment = textAlignment;
}

- (NSTextAlignment) textAlignment {
    return self.textAlignment;
}

- (void) setShowActivityIndicator:(BOOL)showActivityIndicator {
    _showActivityIndicator = showActivityIndicator;
    if (showActivityIndicator && !self.activityView) {
        self.activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityView.center = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
        [self addSubview:self.activityView];
        [self.activityView startAnimating];
        self.textLabel.text = NSLocalizedString(@"", @"");
    }
    else if (!showActivityIndicator) {
        [self.activityView stopAnimating];
        [self.activityView removeFromSuperview];
        self.activityView = nil;
        self.textLabel.text = NSLocalizedString(@"", @"");
    }
    
}

- (void) setEnabled:(BOOL)enabled {
    _enabled = enabled;
    if (enabled) {
        //[super setFrame:self.savedFrame];
        //self.hidden = NO;
        self.endLabel.hidden = YES;
    }
    else {
        //[super setFrame:CGRectZero];
        //self.hidden = YES;
        self.endLabel.hidden = NO;
    }
}
@end
