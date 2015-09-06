//
//  THNAreaMaker.m
//  store
//
//  Created by XiaobinJia on 15/1/5.
//  Copyright (c) 2015年 TaiHuoNiao. All rights reserved.
//

#import "THNAreaMaker.h"
#import "JYComHttpRequest.h"
#import "THNUserManager.h"
#import "NSMutableDictionary+AddSign.h"
/*从网络配置沙盒中的区域文件*/
@interface THNAreaMaker ()<JYComHttpRequestDelegate>

@end

@implementation THNAreaMaker
{
    JYComHttpRequest *_request;
    
    NSMutableArray *_provDataTmp;
    NSMutableArray *_provData;
    int _progress;
}
- (id)init
{
    if (self = [super init]) {
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        //获取完整路径
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString *plistPath = [documentsDirectory stringByAppendingPathComponent:@"taihuoniao_area.plist"];
        //判断是否以创建文件
        if ([[NSFileManager defaultManager] fileExistsAtPath:plistPath])
        {
            //此处可以自己写显示plist文件内容
            NSLog(@"文件已存在");
        }
        else
        {
            //如果没有plist文件就自动创建
            NSMutableDictionary *dictplist = [[NSMutableDictionary alloc ] init];
            //NSMutableDictionary *dicttxt = [[NSMutableDictionary alloc ] init];
            NSMutableArray *arrText = [[NSMutableArray alloc] init];
            [dictplist setObject:arrText forKey:@"t_area"];
            //写入文件
            [dictplist writeToFile:plistPath atomically:YES];
        }
        
        _provData = [[NSMutableArray alloc] initWithCapacity:0];
        _provDataTmp = [[NSMutableArray alloc] initWithCapacity:0];
        _progress = 0;
    }
    return self;
}
- (void)dealloc
{
    [_request clearDelegatesAndCancel];
    _request = nil;
}

- (void)refreshArea
{
    // 开始请求列表，页面进入正在加载状态
    NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                     [THNUserManager channel],                          @"channel",
                                     [THNUserManager client_id],                        @"client_id",
                                     [[THNUserManager sharedTHNUserManager] uuid],      @"uuid",
                                     [THNUserManager time],                             @"time",
                                     nil];
    [listPara addSign];
    //开始请求商品详情
    if (!_request) {
        _request = [[JYComHttpRequest alloc] init];
    }
    [_request clearDelegatesAndCancel];
    _request.delegate = self;
    [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiProvinces]];
}

- (void)requestForCity
{
    _progress ++;
    if (_progress<35) {
        // 开始请求列表，页面进入正在加载状态
        NSMutableDictionary *listPara = [NSMutableDictionary dictionaryWithObjectsAndKeys:
                                         [NSString stringWithFormat:@"%d", _progress],      @"id",
                                         [THNUserManager channel],                          @"channel",
                                         [THNUserManager client_id],                        @"client_id",
                                         [[THNUserManager sharedTHNUserManager] uuid],      @"uuid",
                                         [THNUserManager time],                             @"time",
                                         nil];
        [listPara addSign];
        //开始请求商品详情
        if (!_request) {
            _request = [[JYComHttpRequest alloc] init];
        }
        [_request clearDelegatesAndCancel];
        _request.delegate = self;
        [_request postInfoWithParas:listPara andUrl:[NSString stringWithFormat:@"%@%@", kTHNApiBaseUrl, kTHNApiDistricts]];
    }
}
#pragma mark - JYComHttp delegate
- (void)jyRequest:(id)jyRequest didFailLoading:(NSError *)error{
    
    
}

- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result{
    JYLog(@"receive result:%@",result);
    if ([jyRequest.requestUrl hasSuffix:kTHNApiProvinces]) {
        if ([result isKindOfClass:[NSArray class]]) {
            _provDataTmp = result;
            [self requestForCity];
        }
    }else if([jyRequest.requestUrl hasSuffix:kTHNApiDistricts]){\
            NSMutableDictionary *dictProvince = nil;
            for (NSDictionary *dict in _provDataTmp) {
                if ([dict intValueForKey:@"_id"] == _progress) {
                    dictProvince = [NSMutableDictionary dictionaryWithDictionary:dict];
                    if (result) {
                        [dictProvince setObject:result forKey:@"cities"];
                    }
                    [_provData addObject:dictProvince];
                }
            }
            if (_progress==34) {
                NSString *path = [[NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)objectAtIndex:0]
                                  stringByAppendingPathComponent:@"taihuoniao_area.plist"];
                
                JYLog(@"%@",path);
                NSMutableDictionary *applist = [[[NSMutableDictionary alloc]initWithContentsOfFile:path]mutableCopy];
                [applist setValue:_provData forKey:@"t_area"];
                
                //写入文件
                [applist writeToFile:path atomically:YES];
            }else{
                [self requestForCity];
            }
        }
}

@end
