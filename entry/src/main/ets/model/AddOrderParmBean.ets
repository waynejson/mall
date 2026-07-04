/**
 * 下单商品参数
 * 对应 Android 项目中的 AddOrderParmBean.java
 */
export interface AddOrderParmBean {
  buyCount: number;
  type: string; // 商品版本
  pid: number; // 商品id
}
