//
//  RKAdBanner.m
//  icoiniPad
//
//  Created by Ethan on 12-11-24.
//
//

#import "RKAdBanner.h"
#import <UIButton+WebCache.h>
@implementation RKAdBanner
@synthesize retBlock = _retBlock;

- (void)dealloc {
    _retBlock = nil;
    [_timer release],_timer = nil;
    [_scrollView release], _scrollView = nil;
    [_noteTitle release], _noteTitle = nil;
    [_pageControl release],_pageControl = nil;
    [_imageArray release],_imageArray = nil;
    [super dealloc];
}
-(id)initWithFrameRect:(CGRect)rect ImageArray:(NSArray *)imgArr TitleArray:(NSArray *)titArr
{
    
	if ((self=[super initWithFrame:rect])) {
        self.userInteractionEnabled=YES;
        self.imageArray = imgArr;
	}
	return self;
}
- (void)setImageArray:(NSArray *)imageArray
{
    if (_imageArray != imageArray) {
        [_imageArray release],_imageArray = nil;
        _imageArray = [imageArray retain];
    }
    NSMutableArray *tempArray=[NSMutableArray arrayWithArray:imageArray];
    if ([imageArray count]) {
        [tempArray insertObject:[imageArray objectAtIndex:([imageArray count]-1)] atIndex:0];
        [tempArray addObject:[imageArray objectAtIndex:0]];
    }
    _imageArray=[[NSArray arrayWithArray:tempArray] retain];
    NSUInteger pageCount=[_imageArray count];
    _scrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, kTHNAdBannerHeight)];
    _scrollView.pagingEnabled = YES;
    _scrollView.contentSize = CGSizeMake(SCREEN_WIDTH * pageCount, kTHNAdBannerHeight);
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.delegate = self;
    self.backgroundColor  = [UIColor clearColor];
    for (int i=0; i<pageCount; i++) {
        NSString *imgURL=[_imageArray objectAtIndex:i];
        UIButton *imgView=[[UIButton alloc] init];
        if ([imgURL hasPrefix:@"http://"]) {
            //网络图片 请使用ego异步图片库
            [imgView sd_setImageWithURL:[NSURL URLWithString:imgURL] forState:UIControlStateNormal];
        }
        else
        {
            UIImage *img=[UIImage imageNamed:[_imageArray objectAtIndex:i]];
            [imgView setImage:img forState:UIControlStateNormal];
        }
        
        [imgView setFrame:CGRectMake(SCREEN_WIDTH*i, 0, SCREEN_WIDTH, kTHNAdBannerHeight)];
        imgView.tag=i;
        [imgView addTarget:self action:@selector(imagePressed:) forControlEvents:UIControlEventTouchUpInside];
        [_scrollView addSubview:imgView];
        [imgView release];
    }
    [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0)];
    [self addSubview:_scrollView];
    
    //说明文字层
    UIView *noteView=[[UIView alloc] initWithFrame:CGRectMake(0, self.bounds.size.height-33,self.bounds.size.width,33)];
    [noteView setBackgroundColor:[UIColor colorWithRed:0.0 green:0.0 blue:0.8 alpha:.0]];
    
    float pageControlWidth = (pageCount - 2) * 10.0f + 40.f;
    float pagecontrolHeight = 8.0f;
    _pageControl=[[UIPageControl alloc]initWithFrame:CGRectMake((self.frame.size.width-pageControlWidth)/2, 17, pageControlWidth, pagecontrolHeight)];
    _pageControl.backgroundColor = [UIColor clearColor];
    _pageControl.currentPage=0;
    _pageControl.numberOfPages=(pageCount-2);
    _pageControl.pageIndicatorTintColor = [UIColor colorWithRed:204/255.0 green:204/255.0  blue:204/255.0  alpha:.45];
    _pageControl.currentPageIndicatorTintColor = [UIColor colorWithRed:6/255.0 green:6/255.0 blue:6/255.0 alpha:1.0];
    [noteView addSubview:_pageControl];
    [self addSubview:noteView];
    [noteView release];
    
    [self adStart];
}
- (void)adStart
{
    _timer = [[NSTimer scheduledTimerWithTimeInterval:10 target: self selector: @selector(handleTimer)  userInfo:nil  repeats: YES] retain];
}
- (void)handleTimer
{
    int page = _currentPageIndex + 1;
    NSUInteger pageCount=[_imageArray count];
    _currentPageIndex=page;
    if (page == pageCount) {
        page = 0;
    }
    [UIView animateWithDuration:.5 animations:^{
        [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH*_currentPageIndex, 0)];
    } completion:^(BOOL finished){
        [self resetBannerState];
    }];
   
}
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView
{
    if (_timer.valid) {
        [_timer invalidate];
        [_timer release],_timer = nil;
    }
}
- (void)scrollViewDidScroll:(UIScrollView *)sender
{
    CGFloat pageWidth = _scrollView.frame.size.width;
    int page = floor((_scrollView.contentOffset.x - pageWidth / 2) / pageWidth) + 1;
    _currentPageIndex=page;
       
    _pageControl.currentPage=(page-1);
}
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    if (!_timer.valid) {
        _timer = [[NSTimer scheduledTimerWithTimeInterval:3 target: self selector: @selector(handleTimer)  userInfo:nil  repeats: YES] retain];
    }
    [self resetBannerState];
}
/*
 * 划到最后一页或第一页的时候重置scrollView的偏移量
 */
- (void)resetBannerState
{
    if (_currentPageIndex==0) {
        
        [_scrollView setContentOffset:CGPointMake(([_imageArray count]-2) * SCREEN_WIDTH, 0)];
    }
    if (_currentPageIndex==([_imageArray count]-1)) {
        
        [_scrollView setContentOffset:CGPointMake(SCREEN_WIDTH, 0)];
        
    }
}
- (void)imagePressed:(UIButton *)sender
{
    if (sender.tag==0) {
        self.retBlock([_imageArray count]-1);
    }else if(sender.tag==[_imageArray count]+1){
        self.retBlock(1);
    }else{
        self.retBlock(sender.tag-1);
    }
}

@end
