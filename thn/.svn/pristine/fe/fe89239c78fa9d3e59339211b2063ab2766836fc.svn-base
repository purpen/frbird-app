//
//  HZAreaPickerView.m
//  areapicker
//
//  Created by Cloud Dai on 12-9-9.
//  Copyright (c) 2012年 clouddai.com. All rights reserved.
//

#import "HZAreaPickerView.h"
#import <QuartzCore/QuartzCore.h>

#define kDuration 0.3

@interface HZAreaPickerView ()
{
    NSArray *provinces, *cities, *areas;
}

@end

@implementation HZAreaPickerView

@synthesize delegate=_delegate;
@synthesize locate=_locate;
@synthesize locatePicker = _locatePicker;

- (void)dealloc
{
    [_locate release];
    [_locatePicker release];
    [provinces release];
    [super dealloc];
}

-(HZLocation *)locate
{
    if (_locate == nil) {
        _locate = [[HZLocation alloc] init];
    }
    
    return _locate;
}

- (id)initWithDelegate:(id<HZAreaPickerDelegate>)delegate
{
    
    self = [[[[NSBundle mainBundle] loadNibNamed:@"HZAreaPickerView" owner:self options:nil] objectAtIndex:0] retain];
    if (self) {
        self.delegate = delegate;
        self.locatePicker.dataSource = self;
        self.locatePicker.delegate = self;
        {
            provinces = [[NSArray alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:@"taihuoniao_area.plist" ofType:nil]];
            cities = [[provinces objectAtIndex:0] objectForKey:@"cities"];
            self.locate.state = [[provinces objectAtIndex:0] objectForKey:@"city"];
            self.locate.stateID = [[[provinces objectAtIndex:0] objectForKey:@"_id"] intValue];
            self.locate.city = [[cities objectAtIndex:0] objectForKey:@"city"];
            self.locate.cityID = [[[cities objectAtIndex:0] objectForKey:@"_id"] intValue];
        }
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.frame = CGRectMake(SCREEN_WIDTH-54, 0, 54, 44);
        button.backgroundColor = [UIColor clearColor];
        [button setImage:[UIImage imageNamed:@"DownAccessory"] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(cancel) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:button];
    }
    return self;
    
}
- (void)cancel
{
    [self.delegate cancelLocatePicker];
}


#pragma mark - PickerView lifecycle

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [provinces count];
            break;
        case 1:
            return [cities count];
            break;
        case 2:
            return 0;
            break;
        default:
            return 0;
            break;
    }
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            return [[provinces objectAtIndex:row] objectForKey:@"city"];
            break;
        case 1:
            return [[cities objectAtIndex:row] objectForKey:@"city"];
            break;
        default:
            return @"";
            break;
    }
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    switch (component) {
        case 0:
            cities = [[provinces objectAtIndex:row] objectForKey:@"cities"];
            [self.locatePicker selectRow:0 inComponent:1 animated:YES];
            [self.locatePicker reloadComponent:1];
            
            self.locate.state = [[provinces objectAtIndex:row] objectForKey:@"city"];
            self.locate.stateID = [[[provinces objectAtIndex:row] objectForKey:@"_id"] intValue];
            self.locate.city = [[cities objectAtIndex:0] objectForKey:@"city"];
            self.locate.cityID = [[[cities objectAtIndex:0] objectForKey:@"_id"] intValue];
            break;
        case 1:
            self.locate.city = [[cities objectAtIndex:row] objectForKey:@"city"];
            self.locate.cityID = [[[cities objectAtIndex:row] objectForKey:@"_id"] intValue];
            break;
        default:
            break;
    }
    
    if([self.delegate respondsToSelector:@selector(pickerDidChaneStatus:)]) {
        [self.delegate pickerDidChaneStatus:self];
    }

}


#pragma mark - animation

- (void)showInView:(UIView *) view
{
    self.frame = CGRectMake(0, view.frame.size.height, self.frame.size.width, self.frame.size.height);
    [view addSubview:self];
    
    [UIView animateWithDuration:0.3 animations:^{
        self.frame = CGRectMake(0, view.frame.size.height - self.frame.size.height, self.frame.size.width, self.frame.size.height);
    }];
    
}

- (void)cancelPicker
{
    
    [UIView animateWithDuration:0.3
                     animations:^{
                         self.frame = CGRectMake(0, self.frame.origin.y+self.frame.size.height, self.frame.size.width, self.frame.size.height);
                     }
                     completion:^(BOOL finished){
                         [self removeFromSuperview];
                         
                     }];
    
}

@end
