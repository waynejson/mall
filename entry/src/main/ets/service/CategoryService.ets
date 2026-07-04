import { HttpUtil } from '../common/HttpUtil';
import { Constants } from '../common/Constants';
import { RResult } from '../model/RResult';
import { resultToString } from '../model/RResult';
import { CategoryBean } from '../model/CategoryBean';
import { SubCategoryBean } from '../model/SubCategoryBean';
import { BrandListBean } from '../model/BrandListBean';
import { CommentBean } from '../model/CommentBean';

/**
 * 分类与详情服务
 * 对应 Android 项目中的 CategoryController.java 和 DtailsController.java
 */
export class CategoryService {
  /**
   * 获取一级分类
   */
  static async getTopCategory(): Promise<CategoryBean[]> {
    const response = await HttpUtil.doGet(Constants.TOP_CATEGORY);
    const rResult = JSON.parse(response) as RResult;
    return JSON.parse(resultToString(rResult.result)) as CategoryBean[];
  }

  /**
   * 获取二级分类
   */
  static async getSubCategory(parentId: number): Promise<SubCategoryBean[]> {
    const response = await HttpUtil.doGet(Constants.SUB_CATEGORY + parentId);
    const rResult = JSON.parse(response) as RResult;
    return JSON.parse(resultToString(rResult.result)) as SubCategoryBean[];
  }

  /**
   * 获取品牌列表
   */
  static async getBrandList(categoryId: number): Promise<BrandListBean[]> {
    const response = await HttpUtil.doGet(Constants.BRAND_LIST + categoryId);
    const rResult = JSON.parse(response) as RResult;
    return JSON.parse(resultToString(rResult.result)) as BrandListBean[];
  }

  /**
   * 获取商品推荐评论
   */
  static async getProductComments(productId: number): Promise<CommentBean[]> {
    const params: Record<string, string> = { 'productId': String(productId) };
    const response = await HttpUtil.doPost(Constants.PRODUCT_COMMENT, params);
    const rResult = JSON.parse(response) as RResult;
    return JSON.parse(resultToString(rResult.result)) as CommentBean[];
  }
}
