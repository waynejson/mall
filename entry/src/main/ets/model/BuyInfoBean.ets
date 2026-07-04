/**
 * 加入购物车参数
 * 对应 Android 项目中的 BuyInfoBean.java
 */
export interface BuyInfoBean {
  userId: number;
  productId: number;
  buyCount: number;
  productType: string; // 商品版本/规格
}
