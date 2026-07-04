import { HttpUtil } from '../common/HttpUtil';
import { Constants } from '../common/Constants';
import { RResult } from '../model/RResult';
import { resultToString } from '../model/RResult';
import { ProductBean } from '../model/ProductBean';
import { ProductInfoBean } from '../model/ProductInfoBean';
import { SearchProductParamBean } from '../model/SearchProductParamBean';

interface SearchResult {
  rows: ProductBean[];
}

interface ProductInfoRaw {
  typeList?: string[];
  type_list?: string[];
  types?: string[];
}

/**
 * 商品服务
 * 对应 Android 项目中的 ProductController.java
 */
export class ProductService {
  /**
   * 搜索商品
   */
  static async searchProduct(params: SearchProductParamBean): Promise<ProductBean[]> {
    const formParams: Record<string, string> = {};
    if (params.keyword) formParams['keyword'] = params.keyword;
    if (params.categoryId) formParams['categoryId'] = String(params.categoryId);
    if (params.filterType) formParams['filterType'] = params.filterType;
    if (params.sortType) formParams['sortType'] = params.sortType;
    if (params.deliverChoose) formParams['deliverChoose'] = params.deliverChoose;
    if (params.minPrice) formParams['minPrice'] = String(params.minPrice);
    if (params.maxPrice) formParams['maxPrice'] = String(params.maxPrice);
    if (params.brandId) formParams['brandId'] = String(params.brandId);

    const response = await HttpUtil.doPost(Constants.SEARCH_PRODUCT, formParams);
    const parsed: RResult = JSON.parse(response) as RResult;
    if (!parsed || !parsed.result) {
      return [];
    }
    const resultObj: SearchResult = JSON.parse(resultToString(parsed.result)) as SearchResult;
    if (!resultObj || !resultObj.rows) {
      return [];
    }
    return resultObj.rows;
  }

  /**
   * 获取商品详情
   */
  static async getProductInfo(id: number): Promise<ProductInfoBean> {
    const url = Constants.PRODUCT_INFO + id;
    const response = await HttpUtil.doGet(url);
    const rResult: RResult = JSON.parse(response) as RResult;
    const info: ProductInfoBean = JSON.parse(resultToString(rResult.result)) as ProductInfoBean;
    // 兼容不同字段名
    if (info && (!info.typeList || info.typeList.length === 0)) {
      const jo: ProductInfoRaw = JSON.parse(resultToString(rResult.result)) as ProductInfoRaw;
      if (jo) {
        let arr: string[] | undefined = jo.typeList;
        if (!arr) arr = jo.type_list;
        if (!arr) arr = jo.types;
        if (arr && arr.length > 0) {
          info.typeList = arr;
        }
      }
    }
    return info;
  }

  /**
   * 按好评率排序
   */
  static async sortByFavComRate(keyword: string): Promise<ProductBean[]> {
    const params: SearchProductParamBean = {
      keyword: keyword,
      categoryId: null,
      filterType: '',
      sortType: '',
      deliverChoose: '',
      minPrice: null,
      maxPrice: null,
      brandId: null,
      brandIds: ''
    };
    const products: ProductBean[] = await ProductService.searchProduct(params);
    return products.sort((a: ProductBean, b: ProductBean) => b.favcomRate - a.favcomRate);
  }

  /**
   * 按评论数排序
   */
  static async sortByCommentCount(keyword: string): Promise<ProductBean[]> {
    const params: SearchProductParamBean = {
      keyword: keyword,
      categoryId: null,
      filterType: '',
      sortType: '',
      deliverChoose: '',
      minPrice: null,
      maxPrice: null,
      brandId: null,
      brandIds: ''
    };
    const products: ProductBean[] = await ProductService.searchProduct(params);
    return products.sort((a: ProductBean, b: ProductBean) => b.commentCount - a.commentCount);
  }

  /**
   * 按价格升序
   */
  static async sortByPriceUp(keyword: string): Promise<ProductBean[]> {
    const params: SearchProductParamBean = {
      keyword: keyword,
      categoryId: null,
      filterType: '',
      sortType: '',
      deliverChoose: '',
      minPrice: null,
      maxPrice: null,
      brandId: null,
      brandIds: ''
    };
    const products: ProductBean[] = await ProductService.searchProduct(params);
    return products.sort((a: ProductBean, b: ProductBean) => a.price - b.price);
  }

  /**
   * 按价格降序
   */
  static async sortByPriceDown(keyword: string): Promise<ProductBean[]> {
    const params: SearchProductParamBean = {
      keyword: keyword,
      categoryId: null,
      filterType: '',
      sortType: '',
      deliverChoose: '',
      minPrice: null,
      maxPrice: null,
      brandId: null,
      brandIds: ''
    };
    const products: ProductBean[] = await ProductService.searchProduct(params);
    return products.sort((a: ProductBean, b: ProductBean) => b.price - a.price);
  }
}
