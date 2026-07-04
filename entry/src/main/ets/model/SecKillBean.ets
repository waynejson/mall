/**
 * 秒杀商品
 * 对应 Android 项目中的 SecKillBean.java
 */
export interface SecKillBean {
  allPrice: number;
  productId: number;
  iconUrl: string;
  pointPrice: number;
  type: number;
  timeLeft: number;
}
