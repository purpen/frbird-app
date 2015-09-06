//
//  THNYuShouViewController.m
//  store
//
//  Created by XiaobinJia on 14-12-15.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNYuShouViewController.h"
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
#import "HVTableView.h"
#import "THNOrderViewController.h"
#import "NSMutableDictionary+AddSign.h"
#import "UIBarButtonItem+Badge.h"

@interface THNYuShouViewController ()<JYComHttpRequestDelegate, HVTableViewDelegate, HVTableViewDataSource>
{
    JYComHttpRequest    *_request;
    THNProduct          *_product;
    IBOutlet UIButton   *_buyButton;
    IBOutlet UILabel    *_buyPriceLabel;
    UILabel             *_countlabel;
    THNSku              *_selectSKU;
    
    BOOL                _detailBeenRequested;//记录商品详情是否被请求
    int                 _currentSKUID;
}
@property (weak, nonatomic) IBOutlet HVTableView *tableview;
@property (nonatomic, retain) THNSku *selectSKU;

@property (assign)BOOL isOpen;
@end

@implementation THNYuShouViewController
@synthesize coverImage = _coverImage, selectSKU = _selectSKU, isPush = _isPush;

- (id)initWithProduct:(THNProductBrief *)product coverImage:(UIImage *)ci
{
    if (self = [super init]) {
        _request = [[JYComHttpRequest alloc] init];
        _product = [[THNProduct alloc] init];
        _product.brief = product;
        _coverImage = ci;
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
    self.tableview.HVTableViewDataSource = self;
    self.tableview.HVTableViewDelegate = self;
    _buyPriceLabel.text = @"￥0";
    _detailBeenRequested = NO;
    
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
    _buyButton.layer.borderWidth = .5;
    _buyButton.layer.borderColor = [[UIColor colorWithRed:3/255.0 green:3/255.0 blue:3/255.0 alpha:1.0] CGColor];
    [_buyButton.layer setMasksToBounds:YES];
    [_buyButton.layer setCornerRadius:4.0];
    
    [self requestForDetail];
    
    //设置购物车数量显示
    int count = [[THNCartDB sharedTHNCartDB] allCount];
    self.navigationItem.rightBarButtonItem.badgeValue = [NSString stringWithFormat:@"%d",count];
    self.navigationItem.rightBarButtonItem.badgeBGColor = [UIColor SecondColor];
    
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

- (void)requestForDetail
{
    if (!_product) {
        return;
    }
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [[THNUserManager sharedTHNUserManager] userid], @"current_user_id",
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
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiProductDetail]];
    [self showLoadingWithAni:YES];
}

#pragma mark - ASI Delegate
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    _detailBeenRequested = YES;
    if ([jyRequest.requestUrl hasSuffix:kTHNApiProductDetail]) {
        // 解析数据
        
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSDictionary *dict = result;
            
            int stage = [dict intValueForKey:@"stage"];
            _product.brief.productStage = (stage==5)?kTHNProductStagePre:kTHNProductStageSelling;
            
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
            
            NSArray *arr = [dict objectForKey:@"skus"];
            NSMutableArray *skus = [[NSMutableArray alloc] initWithCapacity:0];
            for (NSDictionary *dict in arr) {
                THNSku *sku = [[THNSku alloc] init];
                sku.skuID = [dict intValueForKey:@"_id"];
                sku.skuMode = [dict stringValueForKey:@"mode"];
                sku.skuName = [dict stringValueForKey:@"name"];
                sku.skuPrice = [dict stringValueForKey:@"price"];
                sku.skuSummary = [dict stringValueForKey:@"summary"];
                sku.skuLimmitedCount = [dict intValueForKey:@"limited_count"];
                sku.skuSyncCount  = [dict intValueForKey:@"sync_count"];
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
            [self.tableview reloadData];
            [self hideLoading];
        });
        if (_product.userStore) {
            [self.FavButton setImage:[UIImage imageNamed:@"detail_collect_n"] forState:UIControlStateNormal];
        }
        if (_product.userZan) {
            [self.likeButton setImage:[UIImage imageNamed:@"detail_like_n"] forState:UIControlStateNormal];
        }
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
                pItem.itemProductCount = @"1";
                if (!pItem.itemProductCount) {
                    [self alertWithInfo:@"请选择购买数量"];
                    return;
                }
                pItem.itemProductSKUID = _currentSKUID;
                pItem.itemProductPrice = _selectSKU.skuPrice;
                pItem.itemProductSKUTitle = _selectSKU.skuMode;
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
- (IBAction)buy:(UIButton *)sender
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
    if (!_selectSKU) {
        //请选择预购版本
        [self alertWithInfo:@"请选择预购版本！"];
        return;
    }
    if (!_product) {
        return;
    }
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [THNUserManager sharedTHNUserManager].userid,  @"current_user_id",
                                     [NSString stringWithFormat:@"%d",_selectSKU.skuID],       @"sku",
                                     @"1",                                         @"n",
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

- (void)skuBuyButtonClicked:(UIButton *)sender
{
    int order = (int)((UIView *)sender.superview).tag-6010;
    THNSku *sku = [_product.skus objectAtIndex:order];
    _currentSKUID = sku.skuID;
    self.selectSKU = sku;
}

#pragma mark - Back
- (void)doBack:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.isPush) {
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    }
}

#pragma mark - 扩展函数
//perform your expand stuff (may include animation) for cell here. It will be called when the user touches a cell
-(void)tableView:(UITableView *)tableView expandCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return;
    }else if(indexPath.row==[self tableView:self.tableview numberOfRowsInSection:1]-2){
        return;
    }else if(indexPath.row==[self tableView:self.tableview numberOfRowsInSection:1]-1){
        return;
    }
    for (int i=308; i<316; i++) {
        [cell.contentView viewWithTag:i].hidden = NO;
    }
    /*
    [UIView animateWithDuration:.5 animations:^{
        detailLabel.text = @"Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua.";
        purchaseButton.alpha = 1;
        [cell.contentView viewWithTag:7].transform = CGAffineTransformMakeRotation(3.14);
    }];*/
}

//perform your collapse stuff (may include animation) for cell here. It will be called when the user touches an expanded cell so it gets collapsed or the table is in the expandOnlyOneCell satate and the user touches another item, So the last expanded item has to collapse
-(void)tableView:(UITableView *)tableView collapseCell:(UITableViewCell *)cell withIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row==0) {
        return;
    }else if(indexPath.row==[self tableView:self.tableview numberOfRowsInSection:1]-2){
        return;
    }else if(indexPath.row==[self tableView:self.tableview numberOfRowsInSection:1]-1){
        return;
    }
    for (int i=308; i<316; i++) {
        [cell.contentView viewWithTag:i].hidden = YES;
    }
    /*
    [UIView animateWithDuration:.5 animations:^{
        detailLabel.text = @"Lorem ipsum dolor sit amet";
        purchaseButton.alpha = 0;
        [cell.contentView viewWithTag:7].transform = CGAffineTransformMakeRotation(-3.14);
    } completion:^(BOOL finished) {
        purchaseButton.hidden = YES;
    }];*/
}

#pragma mark table view data source
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    
    return 202.0f;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 0.0000001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)sectio
{
    RKAdBanner *ad = [[RKAdBanner alloc] initWithFrameRect:CGRectMake(0, 0, SCREEN_WIDTH, 202) ImageArray:_product.productAdImages TitleArray:nil];
    ad.retBlock = ^(int order){
        JYLog(@"&&&&&&&&&**********%d",order);
    };
    return ad;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath isExpanded:(BOOL)isexpanded
{
    NSString *str = _product.brief.productTitle;
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
    NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18], NSParagraphStyleAttributeName:paragraphStyle.copy};
    
    CGSize labelSize = [str boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-30, 999)
                                         options:NSStringDrawingUsesLineFragmentOrigin
                                      attributes:attributes
                                         context:nil].size;
    if (indexPath.row==0) {
        CGFloat h = labelSize.height+85;
        return h;
    }else if(indexPath.row==[self tableView:self.tableview numberOfRowsInSection:1]-2){
        return 85;
    }else if(indexPath.row==[self tableView:self.tableview numberOfRowsInSection:1]-1){
        return 65;
    }else{
        //if (isexpanded)
        //{
            THNSku *sku = [_product.skus objectAtIndex:indexPath.row-1];
            NSString *nameLabelStr = sku.skuName;
            NSMutableParagraphStyle *nameLabelStyle = [[NSMutableParagraphStyle alloc]init];
            nameLabelStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary *nameLabelAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:nameLabelStyle.copy};
            
            CGSize nameLabelSize = [nameLabelStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-30, 999)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:nameLabelAttributes
                                                              context:nil].size;
            
            NSString *summLabelStr = sku.skuSummary;
            NSMutableParagraphStyle *summLabelStyle = [[NSMutableParagraphStyle alloc]init];
            summLabelStyle.lineBreakMode = NSLineBreakByWordWrapping;
            NSDictionary *summLabelAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:13], NSParagraphStyleAttributeName:summLabelStyle.copy};
            CGSize summLabelSize = [summLabelStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-30, 999)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:summLabelAttributes
                                                              context:nil].size;
            CGFloat height = nameLabelSize.height+summLabelSize.height+70+45;
            return height;
        //}
        
        
        //return 35;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath isExpanded:(BOOL)isExpanded
{
    UITableViewCell *cell = nil;
    if (indexPath.row == 0) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        [cell setSeparatorInset:UIEdgeInsetsZero];
        cell.backgroundColor = UIColorFromRGB(0xF8F8F8);
        CGFloat baseHeight = 10;
        NSString *str = _product.brief.productTitle;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
        paragraphStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *attributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18], NSParagraphStyleAttributeName:paragraphStyle.copy};
        
        CGSize labelSize = [str boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-30, 999)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:attributes
                                             context:nil].size;
        
        UILabel* titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, baseHeight, SCREEN_WIDTH-15*2, labelSize.height)];
        titleLabel.tag = 1102;
        titleLabel.numberOfLines = MAXFLOAT;
        titleLabel.text = _product.brief.productTitle;
        titleLabel.textColor = [UIColor BlackTextColor];
        titleLabel.font = [UIFont systemFontOfSize:18];
        [cell.contentView addSubview:titleLabel];
        
        //预售总金额
        baseHeight = baseHeight+titleLabel.frame.size.height+6;
        NSString *detailLabelStr = [NSString stringWithFormat:@"￥%@",_product.brief.productPreSaleMoney];
        NSMutableParagraphStyle *detailLabelStyle = [[NSMutableParagraphStyle alloc]init];
        detailLabelStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *detailLabelAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18], NSParagraphStyleAttributeName:detailLabelStyle.copy};
        
        CGSize detailLabelSize = [detailLabelStr boundingRectWithSize:CGSizeMake(999, 999)
                                                              options:NSStringDrawingUsesLineFragmentOrigin
                                                           attributes:detailLabelAttributes
                                                              context:nil].size;
        UILabel* detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(15 ,baseHeight, detailLabelSize.width, detailLabelSize.height)];
        detailLabel.tag = 1103;
        detailLabel.text = detailLabelStr;
        detailLabel.textColor = [UIColor SecondColor];
        detailLabel.font = [UIFont systemFontOfSize:17];
        [cell.contentView addSubview:detailLabel];
        
        //总金额提示信息
        UILabel *detailTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(15+detailLabelSize.width,baseHeight+3, 100, 18)];
        detailTipLabel.text = @"预售金额";
        detailTipLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
        detailTipLabel.font = [UIFont systemFontOfSize:15];
        [cell.contentView addSubview:detailTipLabel];
        
        //进度条
        baseHeight = baseHeight+detailLabel.frame.size.height;
        UIView *progressBg = [[UIView alloc] initWithFrame:CGRectMake(15, baseHeight+5, SCREEN_WIDTH-30, 6)];
        progressBg.backgroundColor = [UIColor colorWithRed:238/255.0 green:238/255.0 blue:238/255.0 alpha:1.0];
        CGFloat presagePercent =[_product.brief.productPresagePercent intValue]/100;
        if (presagePercent>1) {
            presagePercent=1;
        }
        UIView *progress = [[UIView alloc] initWithFrame:CGRectMake(0, 0, progressBg.frame.size.width*presagePercent, 6)];
        progress.backgroundColor = [UIColor SecondColor];
        [progressBg addSubview:progress];
        [cell.contentView addSubview:progressBg];
        
        //支持人数
        baseHeight = baseHeight + 6 + 10;
        NSString *peopleNumLabelStr = [NSString stringWithFormat:@"%@",_product.brief.productPresagePeople];
        NSMutableParagraphStyle *peopleNumLabelStyle = [[NSMutableParagraphStyle alloc]init];
        peopleNumLabelStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *peopleNumLabelAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18], NSParagraphStyleAttributeName:peopleNumLabelStyle.copy};
        
        CGSize peopleNumLabelSize = [peopleNumLabelStr boundingRectWithSize:CGSizeMake(999, 999)
                                                                    options:NSStringDrawingUsesLineFragmentOrigin
                                                                 attributes:peopleNumLabelAttributes
                                                                    context:nil].size;
        UILabel *peopleNumLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, baseHeight, peopleNumLabelSize.width, peopleNumLabelSize.height)];
        peopleNumLabel.textColor = [UIColor BlackTextColor];
        peopleNumLabel.text = peopleNumLabelStr;
        [cell.contentView addSubview:peopleNumLabel];
        UILabel *peopleTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(peopleNumLabelSize.width+15+2, baseHeight+2, 60, 18)];
        peopleTipLabel.text = @"支持人数";
        peopleTipLabel.font = [UIFont systemFontOfSize:15];
        peopleTipLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
        [cell.contentView addSubview:peopleTipLabel];
        
        //剩余时间
        int start = [[NSDate date] timeIntervalSince1970];
        int finished = [_product.brief.productPresageFinishedTime intValue];
        int surplus = finished - start;//单位是s
        int dayNum = surplus/(60*60*24);
        if (dayNum<0) {
            dayNum = 0;
        }
        NSString *timeLabelStr = [NSString stringWithFormat:@"%d天",dayNum];
        NSMutableParagraphStyle *timeLabelStyle = [[NSMutableParagraphStyle alloc]init];
        timeLabelStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *timeLabelAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:18], NSParagraphStyleAttributeName:peopleNumLabelStyle.copy};
        
        CGSize timeLabelSize = [timeLabelStr boundingRectWithSize:CGSizeMake(999, 999)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:timeLabelAttributes
                                                          context:nil].size;
        UILabel *timeLabel = [[UILabel alloc] initWithFrame:CGRectMake(SCREEN_WIDTH-15-60-timeLabelSize.width, baseHeight, timeLabelSize.width, timeLabelSize.height)];
        timeLabel.text = timeLabelStr;
        timeLabel.textColor = [UIColor BlackTextColor];
        [cell.contentView addSubview:timeLabel];
        UILabel *timeTipLabel = [[UILabel alloc] initWithFrame:CGRectMake(timeLabel.frame.origin.x+timeLabelSize.width, baseHeight+2, 60, 18)];
        timeTipLabel.text = @"剩余时间";
        timeTipLabel.font = [UIFont systemFontOfSize:15];
        timeTipLabel.textColor = [UIColor colorWithRed:149/255.0 green:149/255.0 blue:149/255.0 alpha:1.0];
        [cell.contentView addSubview:timeTipLabel];
    }else if (indexPath.row<=_product.skusCount){
        //sku
        THNSku *sku = [_product.skus objectAtIndex:indexPath.row-1];
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, 200, 35)];
        label.text = [NSString stringWithFormat:@"￥%@",sku.skuPrice];
        label.textColor = [UIColor SecondColor];
        [cell.contentView addSubview:label];
        //name
        NSString *nameLabelStr = sku.skuName;
        NSMutableParagraphStyle *nameLabelStyle = [[NSMutableParagraphStyle alloc]init];
        nameLabelStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *nameLabelAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:16], NSParagraphStyleAttributeName:nameLabelStyle.copy};
        
        CGSize nameLabelSize = [nameLabelStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-30, 999)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:nameLabelAttributes
                                                          context:nil].size;
        UILabel *nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 35, SCREEN_WIDTH-30, nameLabelSize.height)];
        nameLabel.numberOfLines = MAXFLOAT;
        nameLabel.font = [UIFont boldSystemFontOfSize:16];
        nameLabel.textColor = [UIColor BlackTextColor];
        nameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        nameLabel.text = nameLabelStr;
        //summary
        NSString *summLabelStr = sku.skuSummary;
        NSMutableParagraphStyle *summLabelStyle = [[NSMutableParagraphStyle alloc]init];
        summLabelStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *summLabelAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:13], NSParagraphStyleAttributeName:summLabelStyle.copy};
        CGSize summLabelSize = [summLabelStr boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-30, 999)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:summLabelAttributes
                                                          context:nil].size;
        UILabel *summLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 35+nameLabelSize.height+5, SCREEN_WIDTH-30, summLabelSize.height)];
        summLabel.text = summLabelStr;
        summLabel.textColor = [UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0];
        summLabel.numberOfLines = MAXFLOAT;
        summLabel.lineBreakMode = NSLineBreakByWordWrapping;
        summLabel.font = [UIFont systemFontOfSize:13];

        //预定按钮
        UIButton *buyButton = [UIButton buttonWithType:UIButtonTypeCustom];
        buyButton.frame = CGRectMake(15, summLabel.frame.origin.y+summLabelSize.height+12, 68, 25);
        [buyButton.titleLabel setFont:[UIFont systemFontOfSize:13]];
        [buyButton setTitleColor:[UIColor SecondColor] forState:UIControlStateNormal];
        [buyButton setTitle:@"现在预定" forState:UIControlStateNormal];
        [buyButton addTarget:self action:@selector(skuBuyButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
        buyButton.layer.cornerRadius = 4;
        buyButton.layer.masksToBounds = YES;
        [buyButton.layer setBorderWidth:.5]; //边框宽度
        CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
        CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 254/255.0, 52/255.0, 102/255.0, 1 });
        [buyButton.layer setBorderColor:colorref];//边框颜色
        if (!(sku.skuLimmitedCount > sku.skuSyncCount)) {
            CGColorRef colorref = CGColorCreate(colorSpace,(CGFloat[]){ 112/255.0, 112/255.0, 112/255.0, 1 });
            [buyButton.layer setBorderColor:colorref];
            
            [buyButton setTitleColor:[UIColor colorWithRed:112/255.0 green:112/255.0 blue:112/255.0 alpha:1.0] forState:UIControlStateNormal];
            [buyButton setTitle:@"已抢完" forState:UIControlStateNormal];
            buyButton.userInteractionEnabled = NO;
        }
        
        //限量多少
        CGFloat baseH = buyButton.frame.origin.y+37;
        UILabel *limitLabel1 = [[UILabel alloc] initWithFrame:CGRectMake(15, baseH, 28, 16)];
        limitLabel1.text = @"限量";
        limitLabel1.font = [UIFont systemFontOfSize:13];
        
        NSString *ltr2 = [NSString stringWithFormat:@"%d",sku.skuLimmitedCount];
        NSMutableParagraphStyle *ltrStyle = [[NSMutableParagraphStyle alloc]init];
        ltrStyle.lineBreakMode = NSLineBreakByWordWrapping;
        NSDictionary *ltrAttributes = @{NSFontAttributeName:[UIFont systemFontOfSize:13], NSParagraphStyleAttributeName:ltrStyle.copy};
        CGSize ltrSize2 = [ltr2 boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-30, 999)
                                                          options:NSStringDrawingUsesLineFragmentOrigin
                                                       attributes:ltrAttributes
                                                          context:nil].size;
        UILabel *limitLabel2 = [[UILabel alloc] initWithFrame:CGRectMake(15+28, baseH, ltrSize2.width, ltrSize2.height)];
        limitLabel2.text = ltr2;
        limitLabel2.font = [UIFont systemFontOfSize:13];
        
        UILabel *limitLabel3 = [[UILabel alloc] initWithFrame:CGRectMake(15+28+ltrSize2.width, baseH, 40, 16)];
        limitLabel3.text = @",  已有";
        limitLabel3.font = [UIFont systemFontOfSize:13];
        
        NSString *ltr4 = [NSString stringWithFormat:@"%d",sku.skuSyncCount];
        CGSize ltrSize4 = [ltr2 boundingRectWithSize:CGSizeMake(SCREEN_WIDTH-30, 18)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:ltrAttributes
                                             context:nil].size;
        UILabel *limitLabel4 = [[UILabel alloc] initWithFrame:CGRectMake(15+28+ltrSize2.width+39, baseH, ltrSize4.width, ltrSize4.height)];
        limitLabel4.text = ltr4;
        limitLabel4.font = [UIFont systemFontOfSize:13];
        
        UILabel *limitLabel5 = [[UILabel alloc] initWithFrame:CGRectMake(15+28+ltrSize2.width+39+ltrSize4.width, baseH, 100, 16)];
        limitLabel5.text = @"位预订者";
        limitLabel5.font = [UIFont systemFontOfSize:13];
        
        nameLabel.tag = 308;
        summLabel.tag = 309;
        buyButton.tag = 310;
        limitLabel1.tag = 311;
        limitLabel2.tag = 312;
        limitLabel3.tag = 313;
        limitLabel4.tag = 314;
        limitLabel5.tag = 315;
        limitLabel2.textColor = [UIColor SecondColor];
        limitLabel4.textColor = [UIColor SecondColor];
        [cell.contentView addSubview:buyButton];
        [cell.contentView addSubview:nameLabel];
        [cell.contentView addSubview:summLabel];
        [cell.contentView addSubview:limitLabel1];
        [cell.contentView addSubview:limitLabel2];
        [cell.contentView addSubview:limitLabel3];
        [cell.contentView addSubview:limitLabel4];
        [cell.contentView addSubview:limitLabel5];
        //用于预定按钮点击判断
        cell.contentView.tag = 6010+indexPath.row-1;
        
        for (int i=308; i<316; i++) {
            [cell.contentView viewWithTag:i].hidden = YES;
        }
        if (isExpanded) {
            for (int i=308; i<316; i++) {
                [cell.contentView viewWithTag:i].hidden = NO;
            }
        }
    }else{
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
        [cell setSeparatorInset:UIEdgeInsetsZero];
        cell.backgroundColor = UIColorFromRGB(0xF8F8F8);
        if (indexPath.row-_product.skusCount==1) {
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
        }else{
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:nil];
            [cell setSeparatorInset:UIEdgeInsetsZero];
            cell.backgroundColor = UIColorFromRGB(0xF8F8F8);
            UIButton *detailButton = [UIButton buttonWithType:UIButtonTypeCustom];
            detailButton.frame = CGRectMake(0, 0, SCREEN_WIDTH/2+100, 40);
            detailButton.center = CGPointMake(SCREEN_WIDTH/2, 15+15);
            [detailButton setTitleColor:[UIColor BlackTextColor] forState:UIControlStateNormal];
            detailButton.titleLabel.font = [UIFont systemFontOfSize:15];
            [detailButton.layer setMasksToBounds:YES];
            [detailButton.layer setCornerRadius:4.0];
            detailButton.layer.borderWidth = .5;
            detailButton.layer.borderColor = [[UIColor colorWithRed:204/255.0 green:204/255.0 blue:204/255.0 alpha:1.0] CGColor];
            detailButton.backgroundColor = [UIColor whiteColor];
            [detailButton setTitle:@"查看产品详情" forState:UIControlStateNormal];
            [detailButton addTarget:self action:@selector(detailButtonClicked) forControlEvents:UIControlEventTouchUpInside];
            [cell.contentView addSubview:detailButton];
            cell.accessoryType = UITableViewCellAccessoryNone;
        }
    }
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

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
- (NSInteger)tableView:(UITableView *)aTableView numberOfRowsInSection:(NSInteger)section
{
    return _detailBeenRequested?(3+_product.skusCount):0;
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

#pragma mark - set函数
- (THNSku *)selectSKU
{
    return _selectSKU;
}
- (void)setSelectSKU:(THNSku *)selectSKU
{
    if (_selectSKU != selectSKU) {
        _selectSKU = selectSKU;
    }
    _buyPriceLabel.text = [NSString stringWithFormat:@"￥%@",_selectSKU.skuPrice];
}
@end
