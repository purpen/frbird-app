//
//  THNOrder.m
//  store
//
//  Created by XiaobinJia on 14/12/27.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import "THNOrder.h"

@implementation THNOrder
@dynamic orderStatusInfo;

- (NSString *)orderStatusInfo
{
    NSString *info = nil;
    switch (self.orderStatus) {
        case kTHNOrderStateOutDate:
            info = @"订单已过期";
            break;
        case kTHNOrderStateCancel:
            info = @"订单已取消";
            break;
        case kTHNOrderStateWaitForPay:
            info = @"等待付款";
            break;
        case kTHNOrderStateWaitForVerify:
            info = @"等待审核";
            break;
        case kTHNOrderStatePayFail:
            info = @"支付失败";
            break;
        case kTHNOrderStateWaitForSend:
            info = @"正在配货";
            break;
        case kTHNOrderStateRefund:
            info = @"退款中";
            break;
        case kTHNOrderStateRefundSuccess:
            info = @"退款成功";
            break;
        case kTHNOrderStateHaveSend:
            info = @"已发货";
            break;
        case kTHNOrderStateSendComplete:
            info = @"购买完成";
            break;
        default:
            break;
    }
    return info;
}
@end
