//
//  THNProductViewController.m
//  store
//
//  Created by XiaobinJia on 14-11-14.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNProductViewController.h"
#import "JYComHttpRequest.h"
#import "THNProduct.h"
#import "THNUserManager.h"
#import "THNCartDB.h"
#import "RKAdBanner.h"
#import "THNCartItem.h"
#import "THNCartViewController.h"
#import "THNProductDetailViewController.h"
#import "JYShareViewController.h"
#import <UIImageView+WebCache.h>
#import <UIViewController+AMThumblrHud.h>
#import "THNSku.h"
#import "THNOrderViewController.h"
#import "NSMutableDictionary+AddSign.h"
#import "UIBarButtonItem+Badge.h"
#import "THNTopic.h"

@interface THNProductViewController ()<JYComHttpRequestDelegate, UITableViewDelegate, UITableViewDataSource>
{
    JYComHttpRequest            *_request;
    THNProduct                  *_product;
    IBOutlet UIButton               *_cartButton;
    IBOutlet UIButton           *_buyButton;
    UILabel                     *_countlabel;
    int                         _currentSKUID;
    BOOL                        _detailBeenRequested;//记录商品详情是否被请求
    NSArray                     *_relationArray;
    NSArray                     *_commentArray;
}
@property (weak, nonatomic) IBOutlet UITableView *tableview;
@end

@implementation THNProductViewController
@synthesize coverImage = _coverImage;
@synthesize isPush = _isPush;

- (id)initWithProduct:(THNProductBrief *)product coverImage:(UIImage *)ci
{
    if (self = [super init]) {
        _request = [[JYComHttpRequest alloc] init];
        _product = [[THNProduct alloc] init];
        _product.brief = product;
        _coverImage = ci;
        _detailBeenRequested = NO;
        _isPush = NO;
    }
    return self;
}
- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"CartCountChange" object:nil];
    [_tableview setDelegate:nil];
    [_tableview setDataSource:nil];
    [_request clearDelegatesAndCancel];
    _request = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib
    self.title = @"详情";
    //记录当前要购买的类型，默认值为-1
    _currentSKUID = 0;
    
    UIButton *backBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    backBtn.frame = CGRectMake(0, 0, 44, 44);
    [backBtn setImage:[UIImage imageNamed:@"home_back.png"] forState:UIControlStateNormal];
    [backBtn setImageEdgeInsets:UIEdgeInsetsMake(10, -5, 10, 25)];
    [backBtn addTarget:self action:@selector(doBack:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];
    self.navigationItem.leftBarButtonItem = backItem;
    
    UIView *right = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 88, 44)];
    right.backgroundColor = [UIColor whiteColor];
    
    UIButton *cartButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [cartButton setTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
    [cartButton setImage:[UIImage imageNamed:@"cart"] forState:UIControlStateNormal];
    cartButton.frame = CGRectMake(15, 2, 44, 44);
    [cartButton addTarget:self action:@selector(cartButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [right addSubview:cartButton];
    
    UIButton *shareButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [shareButton setTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
    [shareButton setImage:[UIImage imageNamed:@"share"] forState:UIControlStateNormal];
    shareButton.frame = CGRectMake(44+12, 2, 44, 44);
    [shareButton addTarget:self action:@selector(shareButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [right addSubview:shareButton];
    
    UIBarButtonItem *rightItem = [[UIBarButtonItem alloc] initWithCustomView:right];
    self.navigationItem.rightBarButtonItem = rightItem;
    
    _cartButton.layer.borderWidth = .5;
    _cartButton.layer.borderColor = [[UIColor colorWithRed:255/255.0 green:74/255.0 blue:133/255.0 alpha:1.0] CGColor];
    [_cartButton.layer setMasksToBounds:YES];
    [_cartButton.layer setCornerRadius:4.0];
    
    _buyButton.layer.borderWidth = .5;
    _buyButton.layer.borderColor = [[UIColor colorWithRed:3/255.0 green:3/255.0 blue:3/255.0 alpha:1.0] CGColor];
    [_buyButton.layer setMasksToBounds:YES];
    [_buyButton.layer setCornerRadius:4.0];
    
    self.buyButton.hidden = YES;
    self.cartButton.hidden = YES;
    self.likeButton.hidden = YES;
    self.FavButton.hidden = YES;
    
    [self requestForDetail];
    //[self requestForRelation];
    
    //设置购物车数量显示
    int count = [[THNCartDB sharedTHNCartDB] allCount];
    self.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d",count];
    self.navigationItem.rightBarButtonItem.badgeBGColor = [UIColor SecondColor];
    
    //请求到图片后需要刷新RKAdBanner
    RKAdBanner *ad = [[RKAdBanner alloc] initWithFrameRect:CGRectMake(0, 0, SCREEN_WIDTH, 202) ImageArray:nil TitleArray:nil];
    ad.retBlock = ^(int order){
        JYLog(@"&&&&&&&&&**********%d",order);
    };
    self.tableview.tableHeaderView = ad;
    
    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
    UILabel *footLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
    footLabel.text = @"拖动,查看产品详情";
    footLabel.textAlignment = NSTextAlignmentCenter;
    [footView addSubview:footLabel];
    self.tableview.tableFooterView = footView;
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(cartCountChange) name:@"CartCountChange" object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)cartCountChange
{
    int count = [[THNCartDB sharedTHNCartDB] allCount];
    self.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d",count];
    self.navigationItem.rightBarButtonItem.badgeBGColor = [UIColor SecondColor];
}

- (void)requestForComment
{
    //请求商品的评论列表
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid],        @"current_user_id",
                                     _product.brief.productID,                              @"target_id",
                                     @"1",                                                  @"page",
                                     @"2",                                                  @"size",
                                     [THNUserManager channel],                              @"channel",
                                     [THNUserManager client_id],                            @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],                                 @"uuid",
                                     [THNUserManager time],                                 @"time",
                                     nil];
    [listPara addSign];
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiProductCommentsList]];
}

- (void)requestForRelation
{
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid],        @"current_user_id",
                                     _product.brief.productID,                              @"current_id",
                                     _product.productTags,                                  @"sword",
                                     [THNUserManager channel],                            @"channel",
                                     [THNUserManager client_id],                            @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],          @"uuid",
                                     [THNUserManager time],                                 @"time",
                                     nil];
    [listPara addSign];
    //开始请求商品详情
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiProductRelation]];
}

- (void)requestForDetail
{
    if (!_product) {
        return;
    }
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid],        @"current_user_id",
                                     _product.brief.productID,                                @"id",
                                     [THNUserManager channel],                              @"channel",
                                     [THNUserManager client_id],                            @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],          @"uuid",
                                     [THNUserManager time],                                 @"time",
                                     nil];
    [listPara addSign];
    //开始请求商品详情
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiProductDetail]];
    [self showLoadingWithAni:YES];
}

#pragma mark - ASI Delegate
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    if ([jyRequest.requestUrl hasSuffix:kTHNApiProductDetail]) {
        // 解析数据
        _detailBeenRequested = YES;
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = result;
            int stage = [dict intValueForKey:@"stage"];
            _product.brief.productStage = (stage==5)?kTHNProductStagePre:kTHNProductStageSelling;
            _product.brief.productIsTry = [dict boolValueForKey:@"is_try"];
            _product.brief.productIsSnatched = [dict boolValueForKey:@"snatched"];
            
            
            _product.brief.productID = [dict stringValueForKey:@"_id"];
            _product.brief.productImage = [dict stringValueForKey:@"cover_url"];
            _product.brief.productAdvantage = [dict stringValueForKey:@"advantage"];
            _product.brief.productTitle = [dict stringValueForKey:@"title"];
            
            _product.brief.productMarketPrice = [dict stringValueForKey:@"market_price"];
            _product.brief.productSalePrice = [dict stringValueForKey:@"sale_price"];
            _product.brief.productPreSaleMoney = [dict stringValueForKey:@"presale_money"];
            
            NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
            _product.brief.productPresageStartTime = timeSp;
            _product.brief.productPresageFinishedTime = [dict stringValueForKey:@"presale_finish_time"];
            _product.brief.productPresagePeople = [dict stringValueForKey:@"presale_people"];
            _product.brief.productPresagePercent = [dict stringValueForKey:@"presale_percent"];
            _product.brief.productTopicCount = [dict stringValueForKey:@"topic_count"];
            //ID不变
            _product.productSummary = [dict stringValueForKey:@"summary"];
            _product.productCommentNum = [dict stringValueForKey:@"comment_count"];
            _product.productAdImages = [dict objectForKey:@"asset"];
            _product.productContentURL = [dict stringValueForKey:@"content_view_url"];
            _product.skusCount = [dict intValueForKey:@"skus_count"];
            _product.userStore = [dict boolValueForKey:@"is_favorite"];
            _product.userZan = [dict boolValueForKey:@"is_love"];
            _product.brief.productCanSaled = [dict boolValueForKey:@"can_saled"];
            _product.productTags = [dict stringValueForKey:@"tags_s"];
            
            NSArray *arr = [dict objectForKey:@"skus"];
            NSMutableArray *skus = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *dict in arr) {
                THNSku *sku = [[THNSku alloc] init];
                sku.skuID = [dict intValueForKey:@"_id"];
                sku.skuMode = [dict stringValueForKey:@"mode"];
                sku.skuName = [dict stringValueForKey:@"name"];
                sku.skuPrice = [dict stringValueForKey:@"price"];
                int stage = [dict intValueForKey:@"stage"];
                sku.skuStage = (stage==5)?kTHNProductStagePre:kTHNProductStageSelling;
                [skus addObject:sku];
            }
            if (skus && [skus count]>0) {
                _product.skus = skus;
            }
            
            NSDictionary *designerDic = [dict objectForKey:@"designer"];
            if (designerDic && [designerDic isKindOfClass:[NSDictionary class]]) {
                _product.designer.designerID = [designerDic stringValueForKey:@"_id"];
                _product.designer.designerName = [designerDic stringValueForKey:@"screen_name"];
                _product.designer.designerAddress = [designerDic stringValueForKey:@"city"];
                NSDictionary *profile = [designerDic objectForKey:@"profile"];
                if (profile) {
                    _product.designer.designerDes = [profile stringValueForKey:@"job"];
                }
                _product.designer.designerAvatar = [designerDic stringValueForKey:@"big_avatar_url"];
            }
        }
        //刷新界面
        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, .3 * NSEC_PER_SEC);
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            if (!_product.brief.productCanSaled) {
                [self.buyButton setTitle:@"已售完" forState:UIControlStateNormal];
                self.buyButton.userInteractionEnabled = NO;
                self.cartButton.hidden = YES;
                self.buyButton.hidden = NO;
                self.likeButton.hidden = NO;
                self.FavButton.hidden = NO;
            }else{
                [self.buyButton setTitle:@"立即购买" forState:UIControlStateNormal];
                self.buyButton.userInteractionEnabled = YES;
                self.buyButton.hidden = NO;
                self.cartButton.hidden = NO;
                self.likeButton.hidden = NO;
                self.FavButton.hidden = NO;
            }
            
            [self requestForComment];
        });
        if (_product.userStore) {
            [self.FavButton setImage:[UIImage imageNamed:@"detail_collect_n"] forState:UIControlStateNormal];
        }
        if (_product.userZan) {
            [self.likeButton setImage:[UIImage imageNamed:@"detail_like_n"] forState:UIControlStateNormal];
        }
    }else if ([jyRequest.requestUrl hasSuffix:kTHNApiProductRelation]){
        //获取相关商品成功
        if ([result isKindOfClass:[NSArray class]]) {
            NSMutableArray *arrTmp = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *dict in result) {
                THNProduct *product = [[THNProduct alloc] init];
                int stage = [dict intValueForKey:@"stage"];
                product.brief.productStage = (stage==5)?kTHNProductStagePre:kTHNProductStageSelling;
                product.brief.productIsTry = [dict boolValueForKey:@"is_try"];
                product.brief.productIsSnatched = [dict boolValueForKey:@"snatched"];
                product.brief.productID = [dict stringValueForKey:@"_id"];
                product.brief.productImage = [dict stringValueForKey:@"cover_url"];
                product.brief.productAdvantage = [dict stringValueForKey:@"advantage"];
                product.brief.productTitle = [dict stringValueForKey:@"title"];
                product.brief.productMarketPrice = [dict stringValueForKey:@"market_price"];
                product.brief.productSalePrice = [dict stringValueForKey:@"sale_price"];
                product.brief.productPreSaleMoney = [dict stringValueForKey:@"presale_money"];
                
                NSString *timeSp = [NSString stringWithFormat:@"%ld", (long)[[NSDate date] timeIntervalSince1970]];
                product.brief.productPresageStartTime = timeSp;
                product.brief.productPresageFinishedTime = [dict stringValueForKey:@"presale_finish_time"];
                product.brief.productPresagePeople = [dict stringValueForKey:@"presale_people"];
                product.brief.productPresagePercent = [dict stringValueForKey:@"presale_percent"];
                product.brief.productTopicCount = [dict stringValueForKey:@"topic_count"];
                //ID不变
                product.productSummary = [dict stringValueForKey:@"summary"];
                product.productCommentNum = [dict stringValueForKey:@"comment_count"];
                product.productAdImages = [dict objectForKey:@"asset"];
                product.productContentURL = [dict stringValueForKey:@"content_view_url"];
                product.skusCount = [dict intValueForKey:@"skus_count"];
                product.userStore = [dict boolValueForKey:@"is_favorite"];
                product.userZan = [dict boolValueForKey:@"is_love"];
                product.brief.productCanSaled = [dict boolValueForKey:@"can_saled"];
                product.productTags = [dict stringValueForKey:@"tags_s"];
                
                NSArray *arr = [dict objectForKey:@"skus"];
                NSMutableArray *skus = [[NSMutableArray alloc] initWithCapacity:0];
                for (NSDictionary *dict in arr) {
                    THNSku *sku = [[THNSku alloc] init];
                    sku.skuID = [dict intValueForKey:@"_id"];
                    sku.skuMode = [dict stringValueForKey:@"mode"];
                    sku.skuName = [dict stringValueForKey:@"name"];
                    sku.skuPrice = [dict stringValueForKey:@"price"];
                    int stage = [dict intValueForKey:@"stage"];
                    sku.skuStage = (stage==5)?kTHNProductStagePre:kTHNProductStageSelling;
                    [skus addObject:sku];
                }
                if (skus && [skus count]>0) {
                    product.skus = skus;
                }
                
                NSDictionary *designerDic = [dict objectForKey:@"designer"];
                if (designerDic && [designerDic isKindOfClass:[NSDictionary class]]) {
                    product.designer.designerID = [designerDic stringValueForKey:@"_id"];
                    product.designer.designerName = [designerDic stringValueForKey:@"screen_name"];
                    product.designer.designerAddress = [designerDic stringValueForKey:@"city"];
                    NSDictionary *profile = [designerDic objectForKey:@"profile"];
                    if (profile) {
                        product.designer.designerDes = [profile stringValueForKey:@"job"];
                    }
                    product.designer.designerAvatar = [designerDic stringValueForKey:@"big_avatar_url"];
                }
                [arrTmp addObject:product];
            }
            _relationArray = arrTmp;
        }
        ((RKAdBanner *)self.tableview.tableHeaderView).imageArray = _product.productAdImages;
        [self.tableview reloadData];
        [self hideLoading];
    }else if ([jyRequest.requestUrl hasSuffix:kTHNApiProductCommentsList]){
        //加载两条评论
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSArray *rows = [result objectForKey:@"rows"];
            NSMutableArray *arrTmp = [NSMutableArray arrayWithCapacity:0];
            for (NSDictionary *dict in rows) {
                NSString *username = [((NSDictionary *)[dict objectForKey:@"user"]) objectForKey:@"nickname"];
                NSString *content = [dict objectForKey:@"content"];
                NSString *date = [dict objectForKey:@"created_on"];
                THNTopic *t = [[THNTopic alloc] init];
                t.topicTitle = content;
                t.topicUsername = username;
                t.topicDate = date;
                t.topicCommentNumber = @"0";
                [arrTmp addObject:t];
            }
            _commentArray = arrTmp;
        }
        [self requestForRelation];
    }else if ([jyRequest.requestUrl hasSuffix:kTHNApiProductStore]){
        _product.userStore = YES;
        [self.FavButton setImage:[UIImage imageNamed:@"detail_collect_n"] forState:UIControlStateNormal];
        [self hideLoadingWithCompletionMessage:@"成功加入收藏！"];
    }else if ([jyRequest.requestUrl hasSuffix:kTHNApiProductUnStore]){
        _product.userStore = NO;
        [self.FavButton setImage:[UIImage imageNamed:@"detail_collect"] forState:UIControlStateNormal];
        [self hideLoadingWithCompletionMessage:@"成功取消收藏！"];
    }else if ([jyRequest.requestUrl hasSuffix:kTHNApiProductZan]){
        _product.userZan = YES;
        [self.likeButton setImage:[UIImage imageNamed:@"detail_like_n"] forState:UIControlStateNormal];
        [self hideLoadingWithCompletionMessage:@"点赞成功！"];
    }else if ([jyRequest.requestUrl hasSuffix:kTHNApiProductUnZan]){
        _product.userZan = NO;
        [self.likeButton setImage:[UIImage imageNamed:@"detail_like"] forState:UIControlStateNormal];
        [self hideLoadingWithCompletionMessage:@"取消点赞成功！"];
    }else if([jyRequest.requestUrl hasSuffix:kTHNApiProductNowBuy]){
        //验证订单信息
        id orderInfo = [result objectForKey:@"order_info"];
        if ([orderInfo isKindOfClass:[NSDictionary class]]) {
            
            NSString *tmpOrderID = [orderInfo stringValueForKey:@"_id"];
            if (tmpOrderID) {
                THNOrderViewController *order = [[THNOrderViewController alloc] init];
                order.tmpOrderID = tmpOrderID;
                order.isNowBuy = 1;
                order.isPresale = _product.brief.productStage==kTHNProductStagePre?1:0;
                
                THNCartItem *pItem = [[THNCartItem alloc] init];
                pItem.itemProduct = _product;
                pItem.itemProductCount = _countlabel.text;
                if (!pItem.itemProductCount) {
                    [self alertWithInfo:@"请选择购买数量"];
                    return;
                }
                pItem.itemProductSKUID = _currentSKUID;
                if (_product.skusCount>0) {
                    if (_currentSKUID==0) {
                        [self alertWithInfo:@"请选择商品类型"];
                        return;
                    }
                    for (THNSku *sku in _product.skus) {
                        if (sku.skuID == _currentSKUID) {
                            pItem.itemProductPrice = sku.skuPrice;
                            pItem.itemProductSKUTitle = sku.skuMode;
                        }
                    }
                }else{
                    pItem.itemProductPrice = _product.brief.productSalePrice;
                    pItem.itemProductSKUTitle = @"无";
                }
                NSArray *arr = [NSArray arrayWithObject:pItem];
                order.productArray = arr;
                [self.navigationController pushViewController:order animated:YES];
                [self hideLoading];
            }else{
                [self hideLoadingWithCompletionMessage:@"订单创建失败！"];
            }
        }
    }
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    _detailBeenRequested = YES;
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    [self hideLoadingWithCompletionMessage:errorInfo];
}
#pragma mark - Button Clicked
- (IBAction)buy:(id)sender
{
    if (_product.brief.productIsSnatched) {
//        [JDStatusBarNotification showWithStatus:@"请到太火鸟官网参与抢购！"
//                                   dismissAfter:2.0
//                                      styleName:JDStatusBarStyleMatrix];
        [self alertWithInfo:@"请到太火鸟官网参与抢购！"];
        return;
    }
    if (_product.brief.productIsTry) {
//        [JDStatusBarNotification showWithStatus:@"该商品为试用商品!"
//                                   dismissAfter:2.0
//                                      styleName:JDStatusBarStyleMatrix];
        [self alertWithInfo:@"该商品为试用商品!"];
        return;
    }
    NSString *count = _countlabel.text;
    int skuID = 0;
    if (_product.skusCount>0) {
        if (_currentSKUID==0) {
            [self alertWithInfo:@"请选择商品类型"];
            return;
        }
        skuID = _currentSKUID;
    }else{
        skuID = [_product.brief.productID intValue];
    }
    if (!_product) {
        return;
    }
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [THNUserManager sharedTHNUserManager].userid,  @"current_user_id",
                                     [NSString stringWithFormat:@"%d",skuID],       @"sku",
                                     count,                                         @"n",
                                     [THNUserManager channel],                      @"channel",
                                     [THNUserManager client_id],                    @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],  @"uuid",
                                     [THNUserManager time],                         @"time",
                                     nil];
    [listPara addSign];
    //开始请求商品详情
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiProductNowBuy]];
    [self showLoadingWithAni:YES];
}
- (IBAction)putInCart:(id)sender
{
    if (_product.brief.productIsSnatched) {
//        [JDStatusBarNotification showWithStatus:@"请到太火鸟官网参与抢购！"
//                                   dismissAfter:2.0
//                                      styleName:JDStatusBarStyleMatrix];
        [self alertWithInfo:@"请到太火鸟官网参与抢购！"];
        return;
    }
    if (_product.brief.productIsTry) {
//        [JDStatusBarNotification showWithStatus:@"该商品为试用商品!"
//                                   dismissAfter:2.0
//                                      styleName:JDStatusBarStyleMatrix];
        [self alertWithInfo:@"该商品为试用商品!"];
        return;
    }
    if (!_product) {
        return;
    }
    //创建一个cartitem加入购物车
    THNCartItem *item = [[THNCartItem alloc] init];
    item.itemProduct = _product;
    item.itemProductCount = _countlabel.text;
    if (!item.itemProductCount) {
        [self alertWithInfo:@"请选择购买数量"];
        return;
    }
    item.itemProductSKUID = _currentSKUID;
    if (_product.skusCount>0) {
        if (_currentSKUID == 0) {
            [self alertWithInfo:@"请选择商品类型"];
            return;
        }
        for (THNSku *sku in _product.skus) {
            if (sku.skuID == _currentSKUID) {
                item.itemProductPrice = sku.skuPrice;
                item.itemProductSKUTitle = sku.skuMode;
            }
        }
    }else{
        item.itemProductPrice = _product.brief.productSalePrice;
        item.itemProductSKUTitle = @"无";
    }
    
    int ret = [[THNCartDB sharedTHNCartDB] addItem:item];
    if (ret==2) {
        [self alertWithInfo:@"购物车中已有该商品"];
        return;
    }
    ret==1?[self alertWithInfo:@"成功加入购物车"]:[self alertWithInfo:@"加入购物车失败"];
}
- (void)detailButtonClicked
{
    THNProductDetailViewController *detail = [[THNProductDetailViewController alloc] init];
    detail.product = _product;
    detail.coverImage = self.coverImage;
    [self.navigationController pushViewController:detail animated:YES];
}
- (void)cartButtonClicked:(id)sender
{
    THNCartViewController *cart = [[THNCartViewController alloc] init];
    [self.navigationController pushViewController:cart animated:YES];
}

- (void)shareButtonClicked:(id)sender
{
    JYShareViewController *shareViewController = [[JYShareViewController alloc] init];
    shareViewController.shareContent = [NSString stringWithFormat:@"太火鸟商城：%@",_product.brief.productTitle];
    shareViewController.shareUrl = [NSString stringWithFormat:@"http://m.taihuoniao.com/shop/%@.html",_product.brief.productID];
    shareViewController.shareImage = self.coverImage;
    shareViewController.shareType = shareTypeOther;
    [self presentViewController:shareViewController animated:YES completion:^{
        
    }];
}
- (IBAction)zan:(id)sender
{
    if (!_product) {
        return;
    }
        // 开始请求列表，页面进入正在加载状态
        NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [THNUserManager sharedTHNUserManager].userid, @"current_user_id",
                                         _product.brief.productID,                           @"id",
                                         [THNUserManager channel],                     @"channel",
                                         [THNUserManager client_id],                   @"client_id",
                                         [[THNUserManager sharedTHNUserManager] uuid],                        @"uuid",
                                         [THNUserManager time],                        @"time",
                                         nil];
    [listPara addSign];
        //开始请求商品详情
        if (!_request) {
            _request = [[JYComHttpRequest alloc] init];
        }
        [_request clearDelegatesAndCancel];
        _request.delegate = self;
        [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, _product.userZan?kTHNApiProductUnZan:kTHNApiProductZan]];
        [self showLoadingWithAni:YES];
}

- (IBAction)store:(id)sender
{
    if (!_product) {
        return;
    }
        // 开始请求列表，页面进入正在加载状态
        NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [THNUserManager sharedTHNUserManager].userid, @"current_user_id",
                                         _product.brief.productID,                     @"id",
                                         [THNUserManager channel],                     @"channel",
                                         [THNUserManager client_id],                   @"client_id",
                                         [[THNUserManager sharedTHNUserManager] uuid],                        @"uuid",
                                         [THNUserManager time],                        @"time",
                                         nil];
    [listPara addSign];
        //开始请求商品详情
        if (!_request) {
            _request = [[JYComHttpRequest alloc] init];
        }
        [_request clearDelegatesAndCancel];
        _request.delegate = self;
        [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, _product.userStore?kTHNApiProductUnStore:kTHNApiProductStore]];
        [self showLoadingWithAni:YES];
    
}

#pragma mark - Back
- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.isPush) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark table view data source

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 0.0000001f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.0000001f;
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectio
//{
//    RKAdBanner *ad = [[RKAdBanner alloc] initWithFrameRect:CGRectMake(0, 0, SCREEN_WIDTH, 202) ImageArray:_product.productAdImages TitleArray:nil];
//    ad.retBlock = ^(int order){
//        JYLog(@"&&&&&&&&&**********%d",order);
//    };
//    return ad;
//}
//- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section
//{
//    UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 60)];
//    UILabel *footLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 30)];
//    footLabel.text = @"拖动,查看产品详情";
//    footLabel.textAlignment = NSTextAlignmentCenter;
//    [footView addSubview:footLabel];
//    return footView;
//    
//}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSInteger heightFinal = 0;
    switch (indexPath.section) {
        case 0:
        {
            CGFloat skuHeight       = 0;
            CGFloat totalWidth      = 15;
            CGFloat baseWidth       = 15;
            CGFloat height          = 35;
            int lineCounter = 1;
            for (int i=0; i<[_product.skus count]; i++) {
                THNSku *sku = [_product.skus objectAtIndex:i];
                
                NSString *str = sku.skuMode;
                NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
                paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
                NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:27], NSParagraphStyleAttributeName:paragraphStyle.copy};
                
                CGSize buttonSize = [str boundingRectWithSize:CGSizeMake(999, 999)
                                                      options:NSStringDrawingUsesLineFragmentOrigin
                                                   attributes:attributes
                                                      context:nil].size;
                totalWidth += buttonSize.width;
                
                if (totalWidth>280) {
                    baseWidth = 15;
                    totalWidth = 15 + buttonSize.width;
                    lineCounter ++;
                    height = 35*lineCounter;
                }
            }
            skuHeight = height + 35 + 3;
            
            //特殊计算标题栏的高度
            NSString *str = _product.brief.productTitle;
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18], NSParagraphStyleAttributeName:paragraphStyle.copy};
            
            CGSize labelSize = [str boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-30, 999)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:attributes
                                                 context:nil].size;
            //特殊计算sku栏的高度
            int skusCount = _product.skusCount;
            if (skusCount==0 && indexPath.row==1) {
                skuHeight=0;
            }
            //第一个Section的高度数组
            int heightsInSectionOne[3]={
                56+labelSize.height,//标题栏
                skuHeight,//sku
                78+5,//数量
            };
            heightFinal = heightsInSectionOne[indexPath.row];
        }
            break;
        case 1:
        {
            int numberOfRow = [self tableView:tableView numberOfRowsInSection:1];
            if (indexPath.row==0) {
                heightFinal = 40;//用户评价标题
            }else if (indexPath.row==numberOfRow-1){
                heightFinal =  44;//查看更多标题
            }else{
                heightFinal = 75;//内容
            }
        }
            break;
        case 2:
        {
            CGFloat imageHeight = (SCREEN_WIDTH-30)/2;
            heightFinal = ([_relationArray count]+1)/2*(50+imageHeight)+40;//(imageHeight图片宽高度+50卡片文字高度+10间隔 40：标题高度)
        }
            break;
        default:
            break;
    }
    
    return heightFinal;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
    [cell setSeparatorInset:UIEdgeInsetsZero];
    cell.backgroundColor = UIColorFromRGB(0xF8F8F8);
    switch (indexPath.section) {
        case 0:
        {
            if (0==indexPath.row) {
                [self configTitleCell:cell];
            }else if (1==indexPath.row){
                [self configSKUCell:cell];
            }else{
                [self configProductNumberCell:cell];
            }
        }
            break;
        case 1:
        {
            int numberOfRow = [self tableView:tableView numberOfRowsInSection:1];
            if (0==indexPath.row) {
                if (_product && [_product.productCommentNum intValue]>0) {
                    cell.textLabel.text = [NSString stringWithFormat:@"用户评价(%@)",_product.productCommentNum];
                }else{
                    cell.textLabel.text = [NSString stringWithFormat:@"用户评价"];
                }

                cell.textLabel.textColor = UIColorFromRGB(0x929292);
            }else if (numberOfRow-1==indexPath.row){
                UILabel *lable = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, 44)];
                lable.text = @"查看全部用户评价";
                lable.textAlignment = NSTextAlignmentCenter;
                lable.textColor = UIColorFromRGB(0x2E3548);
                lable.font = [UIFont systemFontOfSize:14];
                lable.backgroundColor = [UIColor whiteColor];
                [cell addSubview:lable];
            }else{
                //配置评价cell
                [self configCommentCell:cell];
            }
        }
            break;
        case 2:
        {
            //配置相关商品cell
            [self configRelationCell:cell];
        }
            break;
        default:
            break;
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger number = 0;
    switch (section) {
        case 0:
        {
            number = 3;
        }
            break;
        case 1:
        {
            if (_commentArray && [_commentArray count]>0) {
                return 2+[_commentArray count];
            }else{
                return 1;//只显示一个标题
            }
        }
            break;
        case 2:
        {
            if (_relationArray && [_relationArray count]>0) {
                return 1;
            }else{
                return 0;
            }
        }
            break;
        default:
            break;
    }
    return number;
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    NSInteger number = 2;
    if (_relationArray && [_relationArray count]>0) {
        number++;
    }
    return number;
}

-(void)viewDidLayoutSubviews
{
    if ([self.tableview respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableview setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.tableview respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableview setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

-(void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
}

#pragma mark - ConfigCell

- (void)configTitleCell:(UITableViewCell *)cell
{
    NSString *str = _product.brief.productTitle;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18], NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize labelSize = [str boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-30, 999)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil].size;
    
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, SCREEN_WIDTH-15*2, labelSize.height)];
    titleLabel.tag = 1102;
    titleLabel.numberOfLines = MAXFLOAT;
    titleLabel.text = _product.brief.productTitle;
    titleLabel.textColor = [UIColor BlackTextColor];
    titleLabel.font = [UIFont systemFontOfSize:18];
    [cell.contentView addSubview:titleLabel];
    UILabel* detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 ,titleLabel.frame.origin.y+labelSize.height+12, SCREEN_WIDTH-15*2, 17)];
    detailLabel.tag = 1103;
    detailLabel.text = [NSString stringWithFormat:@"￥%@",_product.brief.productSalePrice];
    detailLabel.textColor = [UIColor SecondColor];
    detailLabel.font = [UIFont systemFontOfSize:17];
    [cell.contentView addSubview:detailLabel];
    
    titleLabel.backgroundColor = [UIColor clearColor];
    detailLabel.backgroundColor = [UIColor clearColor];
}
- (void)configSKUCell:(UITableViewCell *)cell
{
    if (_product.skusCount>0) {
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, SCREEN_WIDTH-15*2, 16)];
        titleLabel.tag = 1102;
        titleLabel.text = @"类型";
        titleLabel.textColor = UIColorFromRGB(0x929292);
        titleLabel.font = [UIFont systemFontOfSize:18];
        [cell.contentView addSubview:titleLabel];
        
        //35
        CGFloat totalWidth = 15;
        CGFloat baseWidth = 15;
        CGFloat height = 35;
        int lineCounter = 1;
        int order = -1;
        for (int i=0; i<[_product.skus count]; i++) {
            if (((THNSku *)[_product.skus objectAtIndex:i]).skuID == _currentSKUID) {
                order = i;
            }
        }
        for (int i=0; i<[_product.skus count]; i++) {
            THNSku *sku = [_product.skus objectAtIndex:i];
            
            NSString *str = sku.skuMode;
            NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
            paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:27], NSParagraphStyleAttributeName:paragraphStyle.copy};
            
            CGSize buttonSize = [str boundingRectWithSize:CGSizeMake(999, 999)
                                                  options:NSStringDrawingUsesLineFragmentOrigin
                                               attributes:attributes
                                                  context:nil].size;
            totalWidth += buttonSize.width;
            
            if (totalWidth>280) {
                baseWidth = 15;
                totalWidth = 15 + buttonSize.width;
                lineCounter ++;
                height = 35*lineCounter;
            }
            
            UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
            button.frame = CGRectMake(baseWidth, height, buttonSize.width, buttonSize.height);
            baseWidth = baseWidth + buttonSize.width+11;
            button.titleLabel.font = [UIFont systemFontOfSize:14];
            button.layer.borderWidth = .5;
            [button setBackgroundColor:[UIColor whiteColor]];
            [button setTitleColor:[UIColor BlackTextColor] forState:UIControlStateNormal];
            button.layer.borderColor = [[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0] CGColor];
            [button.layer setMasksToBounds:YES];
            [button.layer setCornerRadius:4.0];
            [button setTag:22100+i];
            [button addTarget:self action:@selector(productTypeChange:) forControlEvents:UIControlEventTouchUpInside];
            [button setTitle:sku.skuMode forState:UIControlStateNormal];
            [cell.contentView addSubview:button];
            
            if (i==order) {
                [button setBackgroundColor:[UIColor SecondColor]];
                [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
                button.layer.borderColor = [[UIColor colorWithRed:254/255.0 green:50/255.0 blue:103/255.0 alpha:1.0] CGColor];
            }
        }
    }
    
}
- (void)configProductNumberCell:(UITableViewCell *)cell
{
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, SCREEN_WIDTH-15*2, 16)];
    titleLabel.tag = 1102;
    titleLabel.text = @"数量";
    titleLabel.textColor = UIColorFromRGB(0x929292);
    titleLabel.font = [UIFont systemFontOfSize:18];
    [cell.contentView addSubview:titleLabel];
    
    //35
    UIButton *subButton = [UIButton buttonWithType:UIButtonTypeCustom];
    subButton.frame = CGRectMake(15, 37, 37+4, 32);
    subButton.layer.borderWidth = .5;
    subButton.layer.borderColor = [[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0] CGColor];
    [subButton.layer setMasksToBounds:YES];
    [subButton.layer setCornerRadius:4.0];
    [subButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    subButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [subButton setTitle:@"一" forState:UIControlStateNormal];
    [subButton setBackgroundColor:[UIColor whiteColor]];
    [subButton addTarget:self action:@selector(subCount) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:subButton];
    
    UIButton *addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    addButton.frame = CGRectMake(15+37+50-4, 37, 37+4, 32);
    addButton.layer.borderWidth = .5;
    addButton.layer.borderColor = [[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0] CGColor];
    [addButton setTitleColor:[UIColor darkTextColor] forState:UIControlStateNormal];
    [addButton.layer setMasksToBounds:YES];
    [addButton.layer setCornerRadius:4.0];
    addButton.titleLabel.font = [UIFont boldSystemFontOfSize:12];
    [addButton setTitle:@"十" forState:UIControlStateNormal];
    [addButton setBackgroundColor:[UIColor whiteColor]];
    [addButton addTarget:self action:@selector(addCount) forControlEvents:UIControlEventTouchUpInside];
    [cell.contentView addSubview:addButton];
    
    _countlabel = [[UILabel alloc] init];
    _countlabel.frame = CGRectMake(15+37, 37, 50, 32);
    _countlabel.text = @"1";
    _countlabel.font = [UIFont systemFontOfSize:15];
    _countlabel.textAlignment = NSTextAlignmentCenter;
    _countlabel.layer.borderWidth = .5;
    _countlabel.layer.borderColor = [[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0] CGColor];
    _countlabel.backgroundColor = [UIColor whiteColor];
    [cell.contentView addSubview:_countlabel];
    
}
/*V2.0去掉设计者一行*/
- (void)configDesignerCell:(UITableViewCell *)cell
{
    UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 10, SCREEN_WIDTH-15*2, 16)];
    titleLabel.tag = 1102;
    titleLabel.text = @"设计者";
    titleLabel.backgroundColor = [UIColor clearColor];
    titleLabel.textColor = UIColorFromRGB(0x929292);
    titleLabel.font = [UIFont systemFontOfSize:18];
    [cell.contentView addSubview:titleLabel];
    
    UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 35, 200, 18)];
    nameLabel.text = _product.designer.designerName;
    nameLabel.font = [UIFont systemFontOfSize:15];
    [cell.contentView addSubview:nameLabel];
    
    UILabel *placeLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 33+25, 200, 18)];
    placeLabel.text = [NSString stringWithFormat:@"%@ %@",_product.designer.designerAddress, _product.designer.designerDes];
    placeLabel.font = [UIFont systemFontOfSize:15];
    [cell.contentView addSubview:placeLabel];
    
    UIImageView *headImage = [[UIImageView alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-65, 26, 50, 50)];
    headImage.backgroundColor = [UIColor clearColor];
    [headImage sd_setImageWithURL:[NSURL URLWithString:_product.designer.designerAvatar] placeholderImage:[UIImage imageNamed:@"default_head"]];
    [cell.contentView addSubview:headImage];
    
    headImage.layer.masksToBounds=YES;
    headImage.layer.cornerRadius = 25;
}
- (void)configCommentCell:(UITableViewCell *)cell
{
    cell.backgroundColor = [UIColor RandomColor];
}
- (void)configRelationCell:(UITableViewCell *)cell
{
    cell.backgroundColor = [UIColor RandomColor];
}

#pragma mark - other

- (void)productTypeChange:(UIButton *)sender
{
    int type = 0;
    if (!sender) {
        type = -1;
    }else{
        type = (int)sender.tag - 22100;
    }
    _currentSKUID = ((THNSku *)[_product.skus objectAtIndex:type]).skuID;
    UITableViewCell *cell = [_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0]];
    for (int i=0; i<10; i++) {
        UIButton *button = (UIButton *)[cell viewWithTag:22100+i];
        if (button) {
            [button setBackgroundColor:[UIColor whiteColor]];
            [button setTitleColor:[UIColor BlackTextColor] forState:UIControlStateNormal];
            button.layer.borderColor = [[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0] CGColor];
        }
    }
    [sender setBackgroundColor:[UIColor SecondColor]];
    [sender setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    sender.layer.borderColor = [[UIColor colorWithRed:254/255.0 green:50/255.0 blue:103/255.0 alpha:1.0] CGColor];
    
    //得到价格Label
    UITableViewCell *priceCell = [_tableview cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    UILabel *priceLabel = (UILabel *)[priceCell viewWithTag:1103];
    THNSku *sku = [_product.skus objectAtIndex:type];
    priceLabel.text = [NSString stringWithFormat:@"￥%@",sku.skuPrice];
    
}

- (void)subCount
{
    int num = [[_countlabel text] intValue];
    int count = num-1;
    if (count>0) {
        _countlabel.text = [NSString stringWithFormat:@"%d",count];
    }
    
}

- (void)addCount
{
    int num = [[_countlabel text] intValue];
    int count = num+1;
    if (count<1000) {
        _countlabel.text = [NSString stringWithFormat:@"%d",count];
    }
    
}

@end
