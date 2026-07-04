/**
 * API 地址常量
 * 对应 Android 项目中的 NetworkConst.java
 */
export class Constants {
  // 服务器域名
  static readonly DOMAIN: string = 'http://www.ggrchc.com/jd';

  // 用户模块
  static readonly LOGIN: string = Constants.DOMAIN + '/login';
  static readonly REGISTER: string = Constants.DOMAIN + '/regist';
  static readonly RESET_PASSWORD: string = Constants.DOMAIN + '/reset';

  // 首页模块
  static readonly BANNER_AD1: string = Constants.DOMAIN + '/banner?adKind=1';
  static readonly BANNER_AD2: string = Constants.DOMAIN + '/banner?adKind=2';
  static readonly SECKILL: string = Constants.DOMAIN + '/seckill';
  static readonly RECOMMEND_PRODUCT: string = Constants.DOMAIN + '/getYourFav';

  // 分类模块
  static readonly TOP_CATEGORY: string = Constants.DOMAIN + '/category';
  static readonly SUB_CATEGORY: string = Constants.DOMAIN + '/category?parentId=';
  static readonly BRAND_LIST: string = Constants.DOMAIN + '/brand?categoryId=';

  // 商品模块
  static readonly SEARCH_PRODUCT: string = Constants.DOMAIN + '/searchProduct';
  static readonly PRODUCT_INFO: string = Constants.DOMAIN + '/productInfo?id=';
  static readonly PRODUCT_DETAIL: string = Constants.DOMAIN + '/productDetail?productId=';

  // 评论模块
  static readonly PRODUCT_COMMENT: string = Constants.DOMAIN + '/productComment';
  static readonly COMMENT_COUNT: string = Constants.DOMAIN + '/commentCount';
  static readonly COMMENT_DETAIL: string = Constants.DOMAIN + '/commentDetail';

  // 购物车模块
  static readonly SHOP_CAR: string = Constants.DOMAIN + '/shopCar?userId=';
  static readonly ADD_TO_SHOP_CAR: string = Constants.DOMAIN + '/toShopCar';
  static readonly SHOP_CAR_NUM: string = Constants.DOMAIN + '/shopCarNum';
  static readonly DELETE_SHOP_CAR: string = Constants.DOMAIN + '/delShopCar';

  // 地址模块
  static readonly RECEIVE_ADDRESS: string = Constants.DOMAIN + '/receiveAddress';
  static readonly PROVINCE: string = Constants.DOMAIN + '/province';
  static readonly CITY: string = Constants.DOMAIN + '/city?fcode=';
  static readonly AREA: string = Constants.DOMAIN + '/area';
  static readonly ADD_ADDRESS: string = Constants.DOMAIN + '/addAddress';
  static readonly DELETE_ADDRESS: string = Constants.DOMAIN + '/delAddress';

  // 订单模块
  static readonly ADD_ORDER: string = Constants.DOMAIN + '/addOrder';
  static readonly ORDER_LIST: string = Constants.DOMAIN + '/getOrderByStatus';
  static readonly ORDER_DETAIL: string = Constants.DOMAIN + '/getOrderDetail';
  static readonly CANCEL_ORDER: string = Constants.DOMAIN + '/cancelOrder';
  static readonly CONFIRM_ORDER: string = Constants.DOMAIN + '/confirmOrder';

  // 支付模块
  static readonly PAY_INFO: string = Constants.DOMAIN + '/getPayInfo';
  static readonly PAY: string = Constants.DOMAIN + '/pay';

  // 全局状态 Key
  static readonly STORAGE_USER_ID: string = 'user_id';
  static readonly STORAGE_USER_NAME: string = 'user_name';
  static readonly STORAGE_IS_LOGGED_IN: string = 'is_logged_in';
}
