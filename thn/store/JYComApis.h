//
//  JYComApis.h
//  xiuxiuNote
//
//  Created by XiaobinJia on 14-10-27.
//  Copyright (c) 2014年 金源互动. All rights reserved.
//

#ifndef xiuxiuNote_JYComApis_h
#define xiuxiuNote_JYComApis_h

/*****************
 *
 * 服务端Api接口
 *
 *****************/
//测试环境
#define kTHNApiBaseUrl              @"http://t.taihuoniao.com/app/api"
#define kTHNPageBaseUrl             @"http://t.taihuoniao.com/app/wap"
//正式环境
//#define kTHNPageBaseUrl           @"http://m.taihuoniao.com"
//#define kTHNApiBaseUrl            @"http://api.taihuoniao.com"

#define kTHNApiLogin                @"/auth/login"
#define kTHNApiRegister             @"/auth/register"
#define kTHNApiPhoneCode            @"/auth/verify_code"
#define kTHNApiForget               @"/auth/find_pwd"


//Tab
//首页
#define kTHNApiMainSlide            @"/gateway/slide"
#define kTHNApiList                 @"/product/getlist"

//商店
#define kTHNApiStoreCategory        @"/product/category"

//社区
#define kTHNApiPartyCategory        @"/topic/category"
#define kTHNApiPartyList            @"/topic/getlist"
#define kTHNApiPartyDetail          @"/topic/view"
#define kTHNApiPartyReplys          @"/topic/replis"

//Detail
//商品
#define kTHNApiProductDetail        @"/product/view"
#define kTHNApiProductStore         @"/product/ajax_favorite"//收藏
#define kTHNApiProductUnStore       @"/product/ajax_cancel_favorite"
#define kTHNApiProductZan           @"/product/ajax_love"//赞
#define kTHNApiProductUnZan         @"/product/ajax_cancel_love"
#define kTHNApiProductComment       @"/product/ajax_comment"//评论
#define kTHNApiProductCommentsList  @"/product/comments"//评论列表
#define kTHNApiProductRelation      @"/product/fetch_relation_product"


//立即购买
#define kTHNApiProductNowBuy        @"/shopping/now_buy"
//购物车下单
#define kTHNApiProductCartBuy       @"/shopping/checkout"
//立即下单
#define kTHNApiProductConfirm       @"/shopping/confirm"
#define kTHNApiProductPay           @"/shopping/payed"
//取消订单
#define kTHNApiProductCancelOrder   @"/my/cancel_order"
//主题
#define kTHNApiTopicDetail          @"/topic/view"
#define kTHNApiTopicStore           @"/topic/ajax_favorite"//收藏
#define kTHNApiTopicUnStore         @"/topic/ajax_cancel_favorite"
#define kTHNApiTopicZan             @"/topic/ajax_love"//赞
#define kTHNApiTopicUnZan           @"/topic/ajax_cancel_love"
#define kTHNApiTopicComment         @"/topic/ajax_comment"//评论
#define kTHNApiTopicCommentsList    @"/topic/comments"//评论列表
#define kTHNApiTopicUpload          @"/topic/submit"

//账户
//获取某用户收货地址
#define kTHNApiAccountUserAddress   @"/shopping/address"
//http://t.taihuoniao.com/app/api/shopping/ajax_provinces

//新增用户收货地址
#define kTHNApiAccountAddAddress    @"/shopping/ajax_address"
//删除某收货地址
#define kTHNApiAccountDeleteAddress @"/shopping/remove_address"
//默认收货地址
#define kTHNApiAccountDefaultAddress @"/shopping/set_default_address"
//省份列表
#define kTHNApiProvinces   @"/shopping/ajax_provinces"
//市区列表
#define kTHNApiDistricts   @"/shopping/ajax_districts"
//我的收藏
#define kTHNApiAccountFavorite      @"/my/favorite"
//用户信息
#define kTHNApiAccountUserInfo      @"/auth/user"
//修改用户信息
#define kTHNApiAccountEditUserInfo  @"/my/update_profile"
//修改用户头像
#define kTHNApiAccountAvatar        @"/my/upload_token"
//意见反馈
#define kTHNApiSetFeedback          @"/gateway/feedback"
//我的订单
#define kTHNApiMyOrder              @"/shopping/orders"


//页面
#define kTHNPageClause              @"/guide/law"
#define kTHNPageAbout               @"/guide/about"


#endif
