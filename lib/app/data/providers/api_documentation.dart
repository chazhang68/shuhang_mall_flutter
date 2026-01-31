// API 接口文档
// 该文件汇总了从WIKI中提取的所有API接口定义
// 对应原项目中的 api/api.js、api/admin.js、api/order.js、api/store.js、api/public.js、api/points_mall.js

/*
 * ==========================================
 * 数航商道 API 接口文档
 * ==========================================
 * 
 * 说明：此文件为API接口文档，列出了所有可用的API端点及其功能
 * 原始API文件位置：/api/
 * 
 * ==========================================
 * 用户相关接口 (user.js)
 * ==========================================
 */

// 用户登录
// POST /api/login/mobile - 手机号+验证码登录
// POST /api/register - 用户注册
// GET /api/user - 获取用户信息
// GET /api/user/info - 获取用户详细信息
// GET /api/logout - 退出登录

// 用户签到
// POST /api/sign/user - 签到用户信息
// GET /api/sign/config - 获取签到配置
// GET /api/sign/list - 获取签到列表
// POST /api/sign/integral - 用户签到
// GET /api/sign/month - 签到列表(年月)

// 用户资产
// GET /api/spread/commission/:type - 获取资金明细
// GET /api/fudou/list - 获取福豆列表
// GET /api/fubao/list - 获取福宝列表
// GET /api/gxz/list - 获取贡献值列表
// GET /api/ryz/list - 获取荣誉值列表
// GET /api/integral/list - 获取积分列表

// 分销推广
// GET /api/spread/banner - 获取分销海报
// POST /api/spread/people - 获取推广用户
// GET /api/spread/count/:type - 推广佣金/提现总和
// GET /api/commission - 推广数据
// POST /api/spread/order - 推广订单
// POST /api/division/order - 分销订单
// GET /api/rank - 获取推广人排行
// GET /api/brokerage_rank - 获取佣金排名

// 用户设置
// POST /api/user/edit - 修改用户信息
// POST /api/v2/user/user_update - 更新用户信息 v2
// POST /api/user/share - 设置用户分享

// 地址管理
// GET /api/address/list - 获取地址列表
// POST /api/address/default/set - 设置默认地址
// POST /api/address/edit - 添加/编辑地址
// POST /api/address/del - 删除地址
// GET /api/address/detail/:id - 获取地址详情
// GET /api/address/default - 获取默认地址

// 发票管理
// GET /api/v2/invoice - 发票列表
// POST /api/v2/invoice/save - 添加/修改发票
// GET /api/v2/invoice/del/:id - 删除发票
// GET /api/v2/invoice/get_default/:type - 获取默认发票
// GET /api/v2/invoice/detail/:id - 发票详情

/*
 * ==========================================
 * 商品相关接口 (store.js)
 * ==========================================
 */

// 商品信息
// GET /api/product/detail/:id - 获取产品详情
// GET /api/product/code/:id - 产品分享二维码
// GET /api/products - 获取产品列表
// GET /api/category - 获取分类列表
// GET /api/product/hot - 获取推荐产品

// 收藏功能
// POST /api/collect/add - 添加收藏
// POST /api/collect/del - 删除收藏产品
// GET /api/collect/user - 获取收藏列表
// POST /api/collect/all - 批量收藏

// 购物车功能
// POST /api/cart/add - 购车添加
// GET /api/cart/list - 获取购物车列表
// POST /api/v2/reset_cart - 修改购物车
// POST /api/cart/num - 修改购物车数量
// POST /api/v2/set_cart_num - 购车添加、减少、修改
// POST /api/cart/del - 清除购物车

// 评论功能
// GET /api/reply/list/:id - 获取产品评论
// GET /api/reply/config/:id - 产品评价数量和好评度

// 搜索功能
// GET /api/search/keyword - 获取搜索关键字
// GET /api/v2/user/search_list - 个人搜索历史
// GET /api/v2/user/clean_search - 删除搜索历史

// 特殊商品类型
// GET /api/store_discounts/list/:id - 套餐列表
// GET /api/advance/detail/:id - 预售详情

/*
 * ==========================================
 * 订单相关接口 (order.js)
 * ==========================================
 */

// 订单操作
// GET /api/order/list - 订单列表
// POST /api/order/product - 订单产品信息
// POST /api/order/comment - 订单评价
// POST /api/order/pay - 订单支付
// GET /api/order/data - 订单统计数据
// POST /api/order/cancel - 订单取消
// POST /api/order/del - 删除已完成订单
// GET /api/order/detail/:uni - 订单详情
// POST /api/order/again - 再次下单
// POST /api/order/take - 订单收货

// 退款相关
// GET /api/order/refund/del/:uni - 删除已退款和拒绝退款的订单
// GET /api/order/refund_detail/:uni - 退款订单详情
// GET /api/order/refund/reason - 获取退款理由
// POST /api/order/refund/verify - 订单退款审核
// POST /api/order/refund/apply/:id - 退款商品提交
// POST /api/order/refund/express - 退货物流单号提交

// 订单确认
// POST /api/order/confirm - 订单确认获取订单详细信息
// POST /api/order/check_shipping - 获取确认订单页面是否展示快递配送和到店自提
// GET /api/coupons/order/:price - 获取当前金额能使用的优惠卷
// POST /api/order/create/:key - 订单创建
// POST /api/order/computed/:key - 计算订单金额
// POST /api/v2/order/product_coupon/:orderId - 订单优惠券

// 物流相关
// GET /api/order/express/:uni - 订单查询物流信息
// GET /api/admin/order/express/:uni - 管理员订单查询物流信息

// 线下支付
// POST /api/order/offline/check/price - 计算会员线下付款金额
// POST /api/order/offline/create - 线下扫码付款
// GET /api/order/offline/pay/type - 支付方式开关

// 开票相关
// GET /api/v2/order/invoice_list - 开票记录
// GET /api/v2/order/invoice_detail/:id - 开票订单详情

/*
 * ==========================================
 * 管理员相关接口 (admin.js)
 * ==========================================
 */

// 数据统计
// GET /api/admin/order/statistics - 统计数据
// GET /api/admin/order/data - 订单月统计
// GET /api/admin/order/time - 订单统计图

// 订单管理
// GET /api/admin/order/list - 管理员订单列表
// POST /api/admin/order/price - 订单改价
// POST /api/admin/order/remark - 订单备注
// GET /api/admin/order/detail/:orderId - 订单详情
// GET /api/admin/refund_order/detail/:orderId - 退款订单详情

// 发货管理
// GET /api/admin/order/delivery/gain/:orderId - 订单发货信息获取
// POST /api/admin/order/delivery/keep/:id - 订单发货保存
// GET /api/admin/order/delivery_info - 获取订单打印默认配置
// GET /api/admin/order/delivery - 配送员列表

// 退款管理
// GET /api/admin/refund_order/list - 退款列表
// POST /api/admin/refund_order/remark - 订单备注（退款）
// POST /api/admin/order/agreeExpress - 订单同意退货
// POST /api/admin/order/refund - 订单确认退款

// 其他管理
// GET /api/logistics - 获取快递公司
// POST /api/order/order_verific - 订单核销
// GET /api/admin/order/export_temp - 获取物流公司模板
// POST /api/admin/order/offline - 线下付款订单确认付款

/*
 * ==========================================
 * 公共接口 (public.js)
 * ==========================================
 */

// 微信相关
// GET /api/wechat/config - 获取微信sdk配置
// GET /api/wechat/auth - 微信授权
// GET /api/wechat/get_logo - 获取登录授权logo
// POST /api/wechat/mp_auth - 小程序用户登录
// GET /api/v2/wechat/silence_auth - 静默授权
// GET /api/share - 分享
// GET /api/wechat/follow - 获取关注海报
// GET /api/v2/wechat/silence_auth_login - code生成用户

// 系统配置
// GET /api/site_config - 获取网站基础配置
// GET /api/v2/bind_status - 获取商城是否强制绑定手机号
// POST /api/v2/auth_bindind_phone - 小程序绑定手机号
// GET /api/v2/wechat/routine_auth - 小程序用户登录
// GET /api/v2/wechat/auth - 微信授权 V2
// GET /api/navigation - 获取组件底部菜单
// GET /api/subscribe - 获取订阅消息
// GET /api/get_new_app/:type - 获取版本信息

// 其他公共功能
// POST /api/image_base64 - 获取图片base64
// GET /api/copy_words - 自动复制口令功能
// GET /api/version - 后台版本信息
// GET /api/v2/diy/get_version/:name - 获取首页DIY数据版本号
// GET /api/category_version - 获取商品分类版本号
// GET /api/basic_config - 配置信息
// GET /api/get_index/:type - 获取首页数据
// GET /api/get_products/:type - 获取商品数据

/*
 * ==========================================
 * 文章相关接口 (api.js)
 * ==========================================
 */

// 文章功能
// GET /api/article/hot/list - 文章热门列表
// GET /api/article/banner/list - 文章轮播列表
// GET /api/article/details/:id - 文章详情

/*
 * ==========================================
 * 积分商城相关接口 (points_mall.js)
 * ==========================================
 */

// 积分商城
// GET /api/store_integral/index - 消费券商城

/*
 * ==========================================
 * 验证码相关接口 (api.js, store.js)
 * ==========================================
 */

// 验证码功能
// GET /api/verify_code - 获取短信KEY
// POST /api/register/verify - 验证码发送
// POST /api/register/easy_verify - 发送验证码

/*
 * ==========================================
 * 使用说明
 * ==========================================
 * 
 * 以上接口可以直接在Flutter项目中使用，例如：
 * 
 * // 创建Dio实例
 * Dio dio = Dio();
 * 
 * // 设置基础配置
 * dio.options.baseUrl = 'https://your-api-domain.com/api/';
 * dio.options.headers = {
 *   'Content-Type': 'application/json',
 *   'Authorization': 'Bearer your-token',
 * };
 * 
 * // 调用接口示例
 * Response response = await dio.get('/user');
 * var userData = response.data;
 * 
 * // 或者结合Flutter的http客户端使用
 * 
 * 此文档基于原始uni-app项目的API接口整理而成，保留了原有的功能和参数结构。
 */
