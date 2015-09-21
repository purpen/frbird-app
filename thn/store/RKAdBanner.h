//
//  RKAdBanner.h
//  icoiniPad
//
//  Created by Ethan on 12-11-24.
//
//

#import <UIKit/UIKit.h>

typedef void (^AdRetBlock)(int);

@interface RKAdBanner : UICollectionReusableView<UIScrollViewDelegate> {
	UIScrollView *_scrollView;
	NSArray *_imageArray;
    UIPageControl *_pageControl;
    int _currentPageIndex;
    UILabel *_noteTitle;
    
    NSTimer *_timer;
}
@property (nonatomic, copy) AdRetBlock retBlock;
@property (nonatomic, retain) NSArray *imageArray;
-(id)initWithFrameRect:(CGRect)rect ImageArray:(NSArray *)imgArr TitleArray:(NSArray *)titArr;
@end
