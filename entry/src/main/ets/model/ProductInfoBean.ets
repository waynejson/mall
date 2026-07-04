/**
 * 商品详情
 * 对应 Android 项目中的 ProductInfoBean.java
 */
export interface ProductInfoBean {
  favcomRate: number | null;
  typeList: string[] | null;
  ifSaleOneself: boolean | null;
  imgUrls: string[] | null;
  price: number | null;
  name: string;
  id: number | null;
  recomProductId: number | null;
  recomProduct: string;
  timeLeft: number | null;
  stockCount: number | null;
  commentCount: number | null;
}
