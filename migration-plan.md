# 鸿蒙迁移方案 — 已完成

## 迁移状态：✅ 已完成

## 已迁移内容

### 阶段一：基础设施（P0）✅
1. **HttpUtil 网络工具** — `common/HttpUtil.ets`（使用 @ohos.net.http）
2. **Constants 常量** — `common/Constants.ets`（API 地址 + 全局状态 Key）

### 阶段二：数据模型（P0）✅
所有 Bean 类已转为 TypeScript interface：
- `model/User.ets` — 用户模型
- `model/RResult.ets` — 通用返回结果
- `model/ProductBean.ets` — 商品列表项
- `model/ProductInfoBean.ets` — 商品详情
- `model/ShopCarInfoBean.ets` — 购物车商品
- `model/AddressBean.ets` — 收货地址
- `model/OrderDerailsBean.ets` — 订单详情（含嵌套类型）
- `model/OrderResponseBean.ets` — 下单返回
- `model/OrderByStatusBean.ets` — 订单列表项
- `model/BrandBean.ets` — 广告/品牌
- `model/SecKillBean.ets` — 秒杀商品
- `model/FavBean.ets` — 猜你喜欢
- `model/CategoryBean.ets` / `SubCategoryBean.ets` / `ThirdCategoryBean.ets` — 分类
- `model/CommentBean.ets` — 评论
- `model/BrandListBean.ets` — 品牌列表
- `model/PayInfoBean.ets` — 支付信息
- `model/BuyInfoBean.ets` — 加入购物车参数
- `model/AddOrderBean.ets` / `AddOrderParmBean.ets` — 下单参数
- `model/CityBean.ets` — 省市区
- `model/AddAddressBean.ets` — 添加地址参数
- `model/AddressRequestBean.ets` — 查询地址参数
- `model/DeleteShopCarBean.ets` — 删除购物车参数
- `model/SearchProductParamBean.ets` — 搜索参数
- `model/ProductShowBean.ets` — 订单确认页商品展示
- `model/AlipayLoginRequestBean.ets` — 支付请求参数

### 阶段三：服务层（替代 Controller）✅
- `service/UserService.ets` — 登录/注册/重置密码
- `service/HomeService.ets` — 首页广告/秒杀/推荐
- `service/ProductService.ets` — 商品搜索/排序/详情
- `service/ShopCarService.ets` — 购物车增删查
- `service/AddressService.ets` — 地址增删查/省市区
- `service/OrderService.ets` — 订单创建/详情/列表/取消/确认/支付
- `service/CategoryService.ets` — 分类/品牌/评论

### 阶段四：公共组件（P0）✅
- `components/BottomBar.ets` — 底部导航栏
- `components/TopBar.ets` — 商品详情顶部 Tab
- `components/LoadingDialog.ets` — 加载弹窗

### 阶段五：页面（P0 + P1）✅
#### P0 核心流程
1. `pages/WelcomePage.ets` — 欢迎页（2秒闪屏）
2. `pages/LoginPage.ets` — 登录页
3. `pages/MainPage.ets` — 主页（4 Tab）
   - `components/HomeComponent.ets` — 首页（轮播图/秒杀/猜你喜欢）
   - `components/CategoryComponent.ets` — 分类（三级联动）
   - `components/ShopcartComponent.ets` — 购物车（全选/结算）
   - `components/MineComponent.ets` — 我的（订单/地址/退出）
4. `pages/ProductListPage.ets` — 商品列表（搜索/排序/加入购物车）
5. `pages/ProductDetailPage.ets` — 商品详情（图片/规格/评论/加购）
6. `pages/OrderConfirmPage.ets` — 确认订单（地址/商品/支付方式/提交）
7. `pages/OrderDetailPage.ets` — 订单详情（状态/商品/金额/取消/支付）

#### P1 辅助功能
8. `pages/RegisterPage.ets` — 注册页
9. `pages/ResetPage.ets` — 重置密码页
10. `pages/OrderListPage.ets` — 订单列表（按状态筛选）
11. `pages/PayInfoPage.ets` — 支付信息页
12. `pages/AddressListPage.ets` — 地址列表（选择/删除）
13. `pages/AddressEditPage.ets` — 新增地址

## 关键映射（已实现）
| Android | 鸿蒙 |
|---------|------|
| Activity.startActivity() | router.pushUrl() / router.replaceUrl() |
| Fragment | @Component 子组件 |
| Handler/Message | async/await + @State |
| HttpURLConnection | @ohos.net.http |
| FastJSON | JSON.parse() + TS interface |
| RecyclerView | List + ListItem |
| ViewPager2 | Swiper |
| Spinner | 手动实现排序选项 |
| SharedPreferences | dataPreferences + AppStorage |
| MyApplication.getInstance() | AppStorage |

## 目录结构
```
entry/src/main/ets/
├── common/
│   ├── HttpUtil.ets          # 网络请求工具
│   └── Constants.ets         # API 地址常量
├── model/
│   ├── User.ets
│   ├── RResult.ets
│   ├── ProductBean.ets
│   ├── ProductInfoBean.ets
│   ├── ShopCarInfoBean.ets
│   ├── AddressBean.ets
│   ├── OrderDerailsBean.ets
│   └── ... (共 26 个模型文件)
├── service/
│   ├── UserService.ets
│   ├── HomeService.ets
│   ├── ProductService.ets
│   ├── ShopCarService.ets
│   ├── AddressService.ets
│   ├── OrderService.ets
│   └── CategoryService.ets
├── components/
│   ├── BottomBar.ets
│   ├── TopBar.ets
│   ├── LoadingDialog.ets
│   ├── HomeComponent.ets
│   ├── CategoryComponent.ets
│   ├── ShopcartComponent.ets
│   └── MineComponent.ets
├── pages/
│   ├── WelcomePage.ets
│   ├── LoginPage.ets
│   ├── RegisterPage.ets
│   ├── ResetPage.ets
│   ├── MainPage.ets
│   ├── ProductListPage.ets
│   ├── ProductDetailPage.ets
│   ├── OrderConfirmPage.ets
│   ├── OrderListPage.ets
│   ├── OrderDetailPage.ets
│   ├── PayInfoPage.ets
│   ├── AddressListPage.ets
│   └── AddressEditPage.ets
└── entryability/
    └── EntryAbility.ets
```
