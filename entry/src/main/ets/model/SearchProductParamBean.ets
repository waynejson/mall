/**
 * 搜索商品参数
 * 对应 Android 项目中的 SearchProductParamBean.java
 */
export interface SearchProductParamBean {
  keyword: string;
  categoryId: number | null;
  filterType: string; // 1综合 2新品 3评价
  sortType: string; // 1销量 2价格高到低 3价格低到高
  deliverChoose: string;
  minPrice: number | null;
  maxPrice: number | null;
  brandId: number | null;
  brandIds: string;
}
