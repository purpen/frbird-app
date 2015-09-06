//
//  RKAdBanner.h
//  icoiniPad
//
//  Created by Ethan on 12-11-24.
//
//

#import <UIKit/UIKit.h>

typedef void (^AdRetBlock)(int);

@interface RKAdBanner : UIView<UIScrollViewDelegate> {
    
	CGRect _viewSize;
	UIScrollView *_scrollView;
	NSArray *_imageArray;
    NSArray *_titleArray;
    UIPageControl *_pageControl;
    int _currentPageIndex;
    UILabel *_noteTitle;
    
    NSTimer *_timer;
}
@property (nonatomic, copy) AdRetBlock retBlock;
-(id)initWithFrameRect:(CGRect)rect ImageArray:(NSArray *)imgArr TitleArray:(NSArray *)titArr;
@end
