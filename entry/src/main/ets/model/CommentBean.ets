/**
 * 评论
 * 对应 Android 项目中的 CommentBean.java
 */
export interface CommentBean {
  rate: number;
  imgUrls: string[] | null;
  comment: string;
  time: string;
  userName: string;
  type: number;
}
