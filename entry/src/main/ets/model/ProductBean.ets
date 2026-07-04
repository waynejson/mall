/**
 * 商品列表项
 * 对应 Android 项目中的 ProductBean.java
 */
export interface ProductBean {
  favcomRate: number; // 好评率
  price: number;
  name: string;
  id: number;
  iconUrl: string;
  commentCount: number; // 评论数
}
