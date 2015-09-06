//
//  JYComHttpRequest.h
//  JYGameHelper
//
//  Created by Xiaobin Jia on 9/12/13.
//  Copyright (c) 2013 Jinyuan. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ASIHTTPRequest.h"
#import "ASIFormDataRequest.h"
#import "ASIDownloadCache.h"

@class JYComHttpRequest;

@protocol JYComHttpRequestDelegate <NSObject>

@required
- (void)jyRequest:(JYComHttpRequest *)jyRequest didFinishLoading:(id)result;
- (void)jyRequest:(id)jyRequest didFailLoading:(NSError *)error;
@end

@interface JYComHttpRequest : NSObject<ASIHTTPRequestDelegate>
{
    ASIHTTPRequest                      *_httpRequest;
    ASIFormDataRequest                  *_formDataRequest;
    id<JYComHttpRequestDelegate>        _delegate;
    NSString                            *_requestUrl;
}
@property (nonatomic, copy)     NSString *requestUrl;
@property (nonatomic, assign)   id<JYComHttpRequestDelegate> delegate;
- (void)clearDelegatesAndCancel;
- (void)getInfoWithParas:(NSDictionary *)paras andUrl:(NSString *)urlStr;
- (void)postInfoWithParas:(NSDictionary *)paras andUrl:(NSString *)urlStr;
- (void)postFileWithParas:(NSDictionary *)paras andUrl:(NSString *)urlStr;
@end
