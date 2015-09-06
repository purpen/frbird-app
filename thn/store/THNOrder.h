//
//  THNOrder.h
//  store
//
//  Created by XiaobinJia on 14/12/27.
//  Copyright (c) 2014年 TaiHuoNiao. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum : NSUInteger {
    kTHNOrderStateOutDate = -1,//订单过期
    kTHNOrderStateCancel = 0,//取消订单
    kTHNOrderStateWaitForPay = 1,//待付款
    kTHNOrderStateWaitForVerify = 5,//等待审核
    kTHNOrderStatePayFail = 6,//支付失败
    kTHNOrderStateWaitForSend = 10,//待发货
    kTHNOrderStateRefund = 12,//申请退款
    kTHNOrderStateRefundSuccess = 13,//退款成功
    kTHNOrderStateHaveSend = 15,//已发货
    kTHNOrderStateSendComplete = 20,//完成
} THNOrderState;

@interface THNOrder : NSObject
@property (nonatomic, copy) NSString *orderID;
@property (nonatomic, assign) float orderTotalMoney;
@property (nonatomic, copy) NSString *orderUserName;
@property (nonatomic, assign) THNOrderState orderStatus;
@property (nonatomic, readonly) NSString* orderStatusInfo;
@property (nonatomic, retain) NSArray *orderItems;
@end
