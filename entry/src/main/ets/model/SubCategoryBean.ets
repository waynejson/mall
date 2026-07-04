import { ThirdCategoryBean } from './ThirdCategoryBean';

/**
 * 二级分类
 * 对应 Android 项目中的 SubCategoryBean.java
 */
export interface SubCategoryBean {
  id: number;
  name: string;
  thirdCategory: ThirdCategoryBean[] | null;
}
