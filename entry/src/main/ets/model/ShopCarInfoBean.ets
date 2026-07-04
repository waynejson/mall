/**
 * 购物车商品信息
 * 对应 Android 项目中的 ShopCarInfoBean.java
 */
export interface ShopCarInfoBean {
  id: number; // 购物车明细id
  buyCount: number; // 购买数
  storeName: string; // 商店名称
  pprice: number; // 价格
  pimageUrl: string; // 商品图片路径
  pname: string; // 商品名称
  pid: number; // 商品id
  stockCount: number; // 库存
  storeId: number; // 商店id
  pversion: string; // 商品版本
  isChecked: boolean;
}
