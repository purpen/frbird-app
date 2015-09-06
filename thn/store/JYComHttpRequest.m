//
//  JYComHttpRequest.m
//  JYGameHelper
//
//  Created by Xiaobin Jia on 9/12/13.
//  Copyright (c) 2013 Jinyuan. All rights reserved.
//

#import "JYComHttpRequest.h"
#import "JSONKit.h"
#import "Reachability.h"

@implementation JYComHttpRequest
@synthesize delegate = _delegate, requestUrl = _requestUrl;

- (void)postInfoWithParas:(NSDictionary *)paras andUrl:(NSString *)urlStr
{
    self.requestUrl = urlStr;
    NSString *urlString = self.requestUrl;
    NSURL *url = [NSURL URLWithString:urlString];
    if (_formDataRequest) {
        [_formDataRequest clearDelegatesAndCancel];
        [_formDataRequest release],_formDataRequest = nil;
    }
    _formDataRequest = [[ASIFormDataRequest alloc] initWithURL:url];
    NSArray *paraKeys = [paras allKeys];
    for (NSString *key in paraKeys) {
        NSString *value = [paras objectForKey:key];
        [_formDataRequest setPostValue:value forKey:key];
    }
    [_formDataRequest setDelegate:self];
    [_formDataRequest startAsynchronous];
}

- (void)postFileWithParas:(NSDictionary *)paras andUrl:(NSString *)urlStr
{
    self.requestUrl = urlStr;
    NSURL *url = [NSURL URLWithString:self.requestUrl];
    if (_formDataRequest) {
        [_formDataRequest clearDelegatesAndCancel];
        [_formDataRequest release],_formDataRequest = nil;
    }
    _formDataRequest = [[ASIFormDataRequest alloc] initWithURL:url];
    NSArray *paraKeys = [paras allKeys];
    for (NSString *key in paraKeys) {
        //!!!!这里没有做一般化处理，只认为关键字是user_avatar的值才是本地文件
        if (![key isEqualToString:@"pic"]) {
            NSString *value = [paras objectForKey:key];
            [_formDataRequest setPostValue:value forKey:key];
        }else{
            UIImage *i = [paras objectForKey:key];
            //[_formDataRequest addFile:path forKey:key];
            [_formDataRequest setData:UIImageJPEGRepresentation(i, .6) withFileName:@"head.jpg" andContentType:@"image/jpeg" forKey:key];
        }
    }
    _formDataRequest.shouldAttemptPersistentConnection = NO;
    [_formDataRequest setDelegate:self];
    [_formDataRequest startAsynchronous];
}

- (void)getInfoWithParas:(NSDictionary *)paras andUrl:(NSString *)urlStr
{
    self.requestUrl = urlStr;
    //get请求--得到URL
    NSString *urlString = [[self class] serializeURL:self.requestUrl params:paras httpMethod:@"GET"];
    NSURL *url = [NSURL URLWithString:urlString];
    if (_httpRequest) {
        [_httpRequest clearDelegatesAndCancel];
        [_httpRequest release],_httpRequest = nil;
    }
    _httpRequest = [[ASIHTTPRequest alloc] initWithURL:url];
    _httpRequest.shouldAttemptPersistentConnection = NO;
    //设置缓存路径
    [_httpRequest setDownloadCache:[ASIDownloadCache sharedCache]];
    //设置缓存策略
    [_httpRequest setCachePolicy:ASIAskServerIfModifiedCachePolicy|ASIFallbackToCacheIfLoadFailsCachePolicy];
    //设置缓存存储策略
    [_httpRequest setCacheStoragePolicy:ASICachePermanentlyCacheStoragePolicy];//ASICachePermanentlyCacheStoragePolicy
    _httpRequest.delegate = self;
    [_httpRequest startAsynchronous];
}
/*
 * 构建get方式的URL
 */
+ (NSString *)serializeURL:(NSString *)baseURL params:(NSDictionary *)params httpMethod:(NSString *)httpMethod
{
    NSURL* parsedURL = [NSURL URLWithString:baseURL];
    NSString* queryPrefix = parsedURL.query ? @"&" : @"?";
    
    NSMutableArray* pairs = [NSMutableArray array];
    for (NSString* key in [params keyEnumerator])
    {
        if (([[params objectForKey:key] isKindOfClass:[UIImage class]])
            ||([[params objectForKey:key] isKindOfClass:[NSData class]]))
        {
            if ([httpMethod isEqualToString:@"GET"])
            {
                NSLog(@"can not use GET to upload a file");
            }
            continue;
        }
        
        NSString* escaped_value = (NSString *)CFURLCreateStringByAddingPercentEscapes(
                                                                                      NULL, /* allocator */
                                                                                      (CFStringRef)[params objectForKey:key],
                                                                                      NULL, /* charactersToLeaveUnescaped */
                                                                                      (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                      kCFStringEncodingUTF8);
        
        [pairs addObject:[NSString stringWithFormat:@"%@=%@", key, escaped_value]];
        [escaped_value release];
    }
    NSString* query = [pairs componentsJoinedByString:@"&"];
    
    return [NSString stringWithFormat:@"%@%@%@", baseURL, queryPrefix, query];
}
/*
 * 从返回的URL中读取参数
 *
 */
+ (NSString *)getParamValueFromUrl:(NSString*)url paramName:(NSString *)paramName
{
    if (![paramName hasSuffix:@"="])
    {
        paramName = [NSString stringWithFormat:@"%@=", paramName];
    }
    
    NSString * str = nil;
    NSRange start = [url rangeOfString:paramName];
    if (start.location != NSNotFound)
    {
        // confirm that the parameter is not a partial name match
        unichar c = '?';
        if (start.location != 0)
        {
            c = [url characterAtIndex:start.location - 1];
        }
        if (c == '?' || c == '&' || c == '#')
        {
            NSRange end = [[url substringFromIndex:start.location+start.length] rangeOfString:@"&"];
            NSUInteger offset = start.location+start.length;
            str = end.location == NSNotFound ?
            [url substringFromIndex:offset] :
            [url substringWithRange:NSMakeRange(offset, end.location)];
            str = [str stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
    }
    return str;
}
- (BOOL)judgeNetReachability
{
    Reachability* ra = [Reachability reachabilityForInternetConnection];
    if (ra.currentReachabilityStatus == NotReachable) {
        return NO;
    }
    return YES;
}
#pragma mark - json
/*
 * 处理返回数据
 */
- (void)handleResponseData:(NSString *)response
{
    NSError *error = nil;
    id ret = nil;
    id result = [self parseJSONData:response error:&error];
    if (!result) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"数据格式错误！", NSLocalizedDescriptionKey
                                  ,nil];
        error = [self errorWithCode:kJYComErrorServerError userInfo:userInfo];
        [self failedWithError:error];
    }
    if (error) {
        [self failedWithError:error];
    }else{
        NSError *error = nil;
        if ([result isKindOfClass:[NSDictionary class]]) {
            int status = [[result objectForKey:@"status"] intValue];
            if (!(status==0) && !(status==1)) {
                NSString *msg = [result objectForKey:@"message"];
                NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                          msg, NSLocalizedDescriptionKey
                                          ,nil];
                error = [self errorWithCode:kJYComErrorServerError userInfo:userInfo];
                [self failedWithError:error];
            }else{
                ret = [result objectForKey:@"data"];
                [self finishWithResult:ret];
            }
        }
    }
}
/*
 * 对数据进行Json解析
 */
- (id)parseJSONData:(NSString *)data error:(NSError **)error
{
    id ret = [data objectFromJSONString];
    if ([data length]>0 && !ret && (error!=nil)) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"数据解析出错，请稍后重试！", NSLocalizedDescriptionKey
                                  ,nil];
        *error = [self errorWithCode:kJYComErrorParseError userInfo:userInfo];
    }
    return ret;
}
- (id)errorWithCode:(NSInteger)code userInfo:(NSDictionary *)userInfo
{
    return [NSError errorWithDomain:kJYComDomain code:code userInfo:userInfo];
}
#pragma mark - ASI Delegate
- (void)requestFinished:(ASIHTTPRequest *)request
{
    NSString *response = [request responseString];
    JYLog(@"*****\n%@",request.url);
    JYLog(@"*****%@",response);
    [self handleResponseData:response];
}

- (void)requestFailed:(ASIHTTPRequest *)request
{
    NSError *error = [request error];
    JYLog(@"%@",error);
    [self failedWithError:error];
}

- (void)request:(ASIHTTPRequest *)request didReceiveResponseHeaders:(NSDictionary *)responseHeaders
{
    
}
#pragma mark - 结果处理
- (void)failedWithError:(NSError *)error
{
    if ([error code]==1) {
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"网络异常，请查看设置", NSLocalizedDescriptionKey
                                  ,nil];
        error = [self errorWithCode:kJYComErrorNetError userInfo:userInfo];
    }else if([error code]==2){
        NSDictionary *userInfo = [NSDictionary dictionaryWithObjectsAndKeys:
                                  @"请求超时，请稍后重试", NSLocalizedDescriptionKey
                                  ,nil];
        error = [self errorWithCode:kJYComErrorNetError userInfo:userInfo];
    }
    [_delegate jyRequest:self didFailLoading:error];
}
- (void)finishWithResult:(id)ret
{
    [_delegate jyRequest:self didFinishLoading:ret];
}

#pragma mark - 销毁处理
- (void)clearDelegatesAndCancel
{
    self.delegate = nil;
    [_httpRequest clearDelegatesAndCancel];
    [_httpRequest release], _httpRequest = nil;
    
    [_formDataRequest clearDelegatesAndCancel];
    [_formDataRequest release], _formDataRequest = nil;
}
- (void)dealloc
{
    [_httpRequest release], _httpRequest = nil;
    [_formDataRequest release], _formDataRequest =nil;
    self.requestUrl = nil;
    [super dealloc];
}
@end
