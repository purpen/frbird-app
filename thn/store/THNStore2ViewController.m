//
//  THNStore2ViewController.m
//  store
//
//  Created by XiaobinJia on 15/9/12.
//  Copyright (c) 2015年 TaiHuoNiao. All rights reserved.
//

#import "THNStore2ViewController.h"
#import "JYComHttpRequest.h"
#import "THNUserManager.h"
#import "NSMutableDictionary+AddSign.h"
#import "THNCategory.h"
#import "THNErrorPage.h"
#import <UIImageView+WebCache.h>
#import "THNCateDetailViewController.h"

@interface THNStore2ViewController ()<JYComHttpRequestDelegate, UICollectionViewDataSource, UICollectionViewDelegate>
@property (strong, nonatomic) NSMutableArray *cateData;
@end

@implementation THNStore2ViewController
{
    JYComHttpRequest *_cateRequest;
    NSMutableArray *_cateData;
}
@synthesize cateData = _cateData;
- (id)init
{
    if (self = [super init]) {
        _cateRequest = [[JYComHttpRequest alloc] init];
        _cateData = [[NSMutableArray alloc] init];
    }
    return self;
}
- (void)dealloc
{
    [_cateRequest clearDelegatesAndCancel];
    _cateRequest = nil;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"商店";
    [self requestForCategory];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)requestForCategory
{
    [self showLoadingWithAni:YES];
    [self.cateData removeAllObjects];
    self.cateData = [[NSMutableArray alloc] initWithCapacity:0];
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [THNUserManager channel],                      @"channel",
                                     [THNUserManager client_id],                    @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],  @"uuid",
                                     kParaTime,                                     @"time",
                                     [[THNUserManager sharedTHNUserManager] userid],@"current_user_id",
                                     nil];
    [listPara addSign];
    //开始请求分类
    if (!_cateRequest) {
        _cateRequest = [[JYComHttpRequest alloc] init];
    }
    [_cateRequest clearDelegatesAndCancel];
    _cateRequest.delegate = self;
    [_cateRequest getInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiStoreCategory]];
}

#pragma mark - ASI Delegate
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result
{
    JYLog(@"接口数据返回成功：%@",result);
    [self hideLoading];
    if ([jyRequest.requestUrl hasSuffix:kTHNApiStoreCategory]) {
        // 解析数据
        if ([result isKindOfClass:[NSDictionary class]]) {
            NSArray *rows = [result objectForKey:@"rows"];
            for (NSDictionary *dict in rows) {
                THNCategory *cate = [[THNCategory alloc] init];
                cate.cateID = [dict stringValueForKey:@"_id"];
                cate.cateName = [dict stringValueForKey:@"name"];
                cate.cateTitle = [dict stringValueForKey:@"title"];
                cate.cateCount = [dict intValueForKey:@"total_count"];
#warning 约定新的字段key
                cate.cateImage = [dict stringValueForKey:@"cateImage"];
                [self.cateData addObject:cate];
            }
        }
        [((UICollectionView *)[self.view viewWithTag:21001]) reloadData];
    }
}
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFailLoading:(NSError *)error
{
    JYLog(@"接口数据返回成功：%@",error);
    if ([jyRequest.requestUrl hasSuffix:kTHNApiList]) {
        
    }
    NSString *errorInfo = [error.userInfo objectForKey:NSLocalizedDescriptionKey];
    [self hideLoadingWithCompletionMessage:errorInfo];
    THNErrorPage *errorPage = [[THNErrorPage alloc] initWithFrame:CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-20-44-50)];
    __block THNErrorPage *weakError = errorPage;
    errorPage.callBack = ^{
        [weakError removeFromSuperview];
        [self requestForCategory];
    };
    errorPage.tag = 9328301;
    if (![self.view viewWithTag:9328301]) {
        [self.view addSubview:errorPage];
    }
}
#pragma mark - datasource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}
//每个section的item个数
-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [_cateData count];
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"StoreCateCell";
    static BOOL nibsRegistered = NO;
    if (!nibsRegistered) {
        [collectionView registerNib:[UINib nibWithNibName:@"StoreCateCell" bundle:nil] forCellWithReuseIdentifier:CellIdentifier];
        nibsRegistered = YES;
    }
    THNCategory *cate = [_cateData objectAtIndex:indexPath.row];
    UICollectionViewCell *cell = (UICollectionViewCell *)[collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier forIndexPath:indexPath];
//    [((UIImageView *)[cell viewWithTag:21001]) sd_setImageWithURL:[NSURL URLWithString:cate.cateImage] placeholderImage:nil];
    [((UIImageView *)[cell viewWithTag:21001]) sd_setImageWithURL:[NSURL URLWithString:@"http://b.hiphotos.baidu.com/baike/c0%3Dbaike60%2C5%2C5%2C60%2C20/sign=7022e219f403738dca470470d272db34/d1a20cf431adcbefbf2ae3bfaeaf2edda3cc9f69.jpg"] placeholderImage:nil];
    [(UILabel *)[cell viewWithTag:21002] setText:cate.cateTitle];
    return cell;
}
//定义每个UICollectionViewCell 的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(160, 160);
}

//每个section中不同的行之间的行间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0001;
}
//每个item之间的间距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 0.0f;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    THNCategory *cate = [_cateData objectAtIndex:indexPath.row];
    THNCateDetailViewController *detail = [[THNCateDetailViewController alloc] initWithCateModel:cate];
    detail.hidesBottomBarWhenPushed = YES;
    [self.navigationController pushViewController:detail animated:YES];
}
@end
