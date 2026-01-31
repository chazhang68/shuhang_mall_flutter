require('./common/vendor.js');(global["webpackJsonp"] = global["webpackJsonp"] || []).push([["pages/points_mall/integral_order"],{

/***/ 1102:
/*!*********************************************************************************************!*\
  !*** D:/practice-project/中臻电商/中臻电商/main.js?{"page":"pages%2Fpoints_mall%2Fintegral_order"} ***!
  \*********************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(wx, createPage) {

var _interopRequireDefault = __webpack_require__(/*! @babel/runtime/helpers/interopRequireDefault */ 4);
__webpack_require__(/*! uni-pages */ 26);
var _vue = _interopRequireDefault(__webpack_require__(/*! vue */ 25));
var _integral_order = _interopRequireDefault(__webpack_require__(/*! ./pages/points_mall/integral_order.vue */ 1103));
// @ts-ignore
wx.__webpack_require_UNI_MP_PLUGIN__ = __webpack_require__;
createPage(_integral_order.default);
/* WEBPACK VAR INJECTION */}.call(this, __webpack_require__(/*! ./node_modules/@dcloudio/uni-mp-weixin/dist/wx.js */ 1)["default"], __webpack_require__(/*! ./node_modules/@dcloudio/uni-mp-weixin/dist/index.js */ 2)["createPage"]))

/***/ }),

/***/ 1103:
/*!**************************************************************************!*\
  !*** D:/practice-project/中臻电商/中臻电商/pages/points_mall/integral_order.vue ***!
  \**************************************************************************/
/*! no static exports found */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _integral_order_vue_vue_type_template_id_fe1f759a_scoped_true___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./integral_order.vue?vue&type=template&id=fe1f759a&scoped=true& */ 1104);
/* harmony import */ var _integral_order_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./integral_order.vue?vue&type=script&lang=js& */ 1106);
/* harmony reexport (unknown) */ for(var __WEBPACK_IMPORT_KEY__ in _integral_order_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_1__) if(["default"].indexOf(__WEBPACK_IMPORT_KEY__) < 0) (function(key) { __webpack_require__.d(__webpack_exports__, key, function() { return _integral_order_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_1__[key]; }) }(__WEBPACK_IMPORT_KEY__));
/* harmony import */ var _integral_order_vue_vue_type_style_index_0_id_fe1f759a_lang_scss_scoped_true___WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./integral_order.vue?vue&type=style&index=0&id=fe1f759a&lang=scss&scoped=true& */ 1108);
/* harmony import */ var _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_runtime_componentNormalizer_js__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib/runtime/componentNormalizer.js */ 58);

var renderjs





/* normalize component */

var component = Object(_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_runtime_componentNormalizer_js__WEBPACK_IMPORTED_MODULE_3__["default"])(
  _integral_order_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_1__["default"],
  _integral_order_vue_vue_type_template_id_fe1f759a_scoped_true___WEBPACK_IMPORTED_MODULE_0__["render"],
  _integral_order_vue_vue_type_template_id_fe1f759a_scoped_true___WEBPACK_IMPORTED_MODULE_0__["staticRenderFns"],
  false,
  null,
  "fe1f759a",
  null,
  false,
  _integral_order_vue_vue_type_template_id_fe1f759a_scoped_true___WEBPACK_IMPORTED_MODULE_0__["components"],
  renderjs
)

component.options.__file = "pages/points_mall/integral_order.vue"
/* harmony default export */ __webpack_exports__["default"] = (component.exports);

/***/ }),

/***/ 1104:
/*!*********************************************************************************************************************!*\
  !*** D:/practice-project/中臻电商/中臻电商/pages/points_mall/integral_order.vue?vue&type=template&id=fe1f759a&scoped=true& ***!
  \*********************************************************************************************************************/
/*! exports provided: render, staticRenderFns, recyclableRender, components */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_17_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_template_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_uni_app_loader_page_meta_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_template_id_fe1f759a_scoped_true___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! -!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib/loaders/templateLoader.js??vue-loader-options!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--17-0!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/webpack-uni-mp-loader/lib/template.js!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-uni-app-loader/page-meta.js!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib??vue-loader-options!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/webpack-uni-mp-loader/lib/style.js!./integral_order.vue?vue&type=template&id=fe1f759a&scoped=true& */ 1105);
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "render", function() { return _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_17_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_template_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_uni_app_loader_page_meta_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_template_id_fe1f759a_scoped_true___WEBPACK_IMPORTED_MODULE_0__["render"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "staticRenderFns", function() { return _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_17_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_template_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_uni_app_loader_page_meta_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_template_id_fe1f759a_scoped_true___WEBPACK_IMPORTED_MODULE_0__["staticRenderFns"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "recyclableRender", function() { return _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_17_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_template_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_uni_app_loader_page_meta_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_template_id_fe1f759a_scoped_true___WEBPACK_IMPORTED_MODULE_0__["recyclableRender"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "components", function() { return _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_17_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_template_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_uni_app_loader_page_meta_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_template_id_fe1f759a_scoped_true___WEBPACK_IMPORTED_MODULE_0__["components"]; });



/***/ }),

/***/ 1105:
/*!*********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************!*\
  !*** ./node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib/loaders/templateLoader.js??vue-loader-options!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--17-0!./node_modules/@dcloudio/webpack-uni-mp-loader/lib/template.js!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-uni-app-loader/page-meta.js!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib??vue-loader-options!./node_modules/@dcloudio/webpack-uni-mp-loader/lib/style.js!D:/practice-project/中臻电商/中臻电商/pages/points_mall/integral_order.vue?vue&type=template&id=fe1f759a&scoped=true& ***!
  \*********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************/
/*! exports provided: render, staticRenderFns, recyclableRender, components */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "render", function() { return render; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "staticRenderFns", function() { return staticRenderFns; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "recyclableRender", function() { return recyclableRender; });
/* harmony export (binding) */ __webpack_require__.d(__webpack_exports__, "components", function() { return components; });
var components
var render = function () {
  var _vm = this
  var _h = _vm.$createElement
  var _c = _vm._self._c || _h
  var m0 =
    _vm.shippingType == 0 &&
    _vm.addressInfo.real_name &&
    _vm.addressInfo.is_default
      ? _vm.$t("[默认]")
      : null
  var m1 =
    _vm.shippingType == 0 && !_vm.addressInfo.real_name
      ? _vm.$t("设置收货地址")
      : null
  var m2 = _vm.$t("共")
  var m3 = _vm.$t("件商品")
  var m4 = _vm.$t("消费券")
  var m5 = _vm.$t("可用消费券")
  var m6 = _vm.$t("快递费用")
  var m7 = _vm.$t("免运费")
  var m8 = _vm.textareaStatus ? _vm.$t("备注信息") : null
  var m9 = _vm.textareaStatus ? _vm.$t("请添加备注（150字以内）") : null
  var m10 = _vm.$t("合计")
  var m11 = _vm.$t("消费券")
  var m12 = _vm.$t("立即兑换")
  _vm.$mp.data = Object.assign(
    {},
    {
      $root: {
        m0: m0,
        m1: m1,
        m2: m2,
        m3: m3,
        m4: m4,
        m5: m5,
        m6: m6,
        m7: m7,
        m8: m8,
        m9: m9,
        m10: m10,
        m11: m11,
        m12: m12,
      },
    }
  )
}
var recyclableRender = false
var staticRenderFns = []
render._withStripped = true



/***/ }),

/***/ 1106:
/*!***************************************************************************************************!*\
  !*** D:/practice-project/中臻电商/中臻电商/pages/points_mall/integral_order.vue?vue&type=script&lang=js& ***!
  \***************************************************************************************************/
/*! no static exports found */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_babel_loader_lib_index_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_13_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_script_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! -!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/babel-loader/lib!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--13-1!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/webpack-uni-mp-loader/lib/script.js!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib??vue-loader-options!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/webpack-uni-mp-loader/lib/style.js!./integral_order.vue?vue&type=script&lang=js& */ 1107);
/* harmony import */ var _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_babel_loader_lib_index_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_13_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_script_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_babel_loader_lib_index_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_13_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_script_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0__);
/* harmony reexport (unknown) */ for(var __WEBPACK_IMPORT_KEY__ in _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_babel_loader_lib_index_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_13_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_script_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0__) if(["default"].indexOf(__WEBPACK_IMPORT_KEY__) < 0) (function(key) { __webpack_require__.d(__webpack_exports__, key, function() { return _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_babel_loader_lib_index_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_13_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_script_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0__[key]; }) }(__WEBPACK_IMPORT_KEY__));
 /* harmony default export */ __webpack_exports__["default"] = (_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_babel_loader_lib_index_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_13_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_script_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0___default.a); 

/***/ }),

/***/ 1107:
/*!**********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************!*\
  !*** ./node_modules/babel-loader/lib!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--13-1!./node_modules/@dcloudio/webpack-uni-mp-loader/lib/script.js!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib??vue-loader-options!./node_modules/@dcloudio/webpack-uni-mp-loader/lib/style.js!D:/practice-project/中臻电商/中臻电商/pages/points_mall/integral_order.vue?vue&type=script&lang=js& ***!
  \**********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(uni) {

var _interopRequireDefault = __webpack_require__(/*! @babel/runtime/helpers/interopRequireDefault */ 4);
Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var _activity = __webpack_require__(/*! @/api/activity.js */ 819);
var _user = __webpack_require__(/*! @/api/user.js */ 38);
var _store = __webpack_require__(/*! @/api/store.js */ 92);
var _cache = __webpack_require__(/*! @/config/cache.js */ 44);
var _login = __webpack_require__(/*! @/libs/login.js */ 33);
var _vuex = __webpack_require__(/*! vuex */ 35);
var _color = _interopRequireDefault(__webpack_require__(/*! @/mixins/color */ 55));
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
//
var couponListWindow = function couponListWindow() {
  Promise.all(/*! require.ensure | components/couponListWindow/index */[__webpack_require__.e("common/vendor"), __webpack_require__.e("components/couponListWindow/index")]).then((function () {
    return resolve(__webpack_require__(/*! @/components/couponListWindow */ 1426));
  }).bind(null, __webpack_require__)).catch(__webpack_require__.oe);
};
var addressWindow = function addressWindow() {
  __webpack_require__.e(/*! require.ensure | components/addressWindow/index */ "components/addressWindow/index").then((function () {
    return resolve(__webpack_require__(/*! @/components/addressWindow */ 1433));
  }).bind(null, __webpack_require__)).catch(__webpack_require__.oe);
};
var orderGoods = function orderGoods() {
  __webpack_require__.e(/*! require.ensure | components/orderGoods/index */ "components/orderGoods/index").then((function () {
    return resolve(__webpack_require__(/*! @/components/orderGoods */ 1440));
  }).bind(null, __webpack_require__)).catch(__webpack_require__.oe);
};
var home = function home() {
  Promise.all(/*! require.ensure | components/home/index */[__webpack_require__.e("common/vendor"), __webpack_require__.e("components/home/index")]).then((function () {
    return resolve(__webpack_require__(/*! @/components/home */ 1334));
  }).bind(null, __webpack_require__)).catch(__webpack_require__.oe);
};
var authorize = function authorize() {
  __webpack_require__.e(/*! require.ensure | components/Authorize */ "components/Authorize").then((function () {
    return resolve(__webpack_require__(/*! @/components/Authorize */ 1206));
  }).bind(null, __webpack_require__)).catch(__webpack_require__.oe);
};
var _default = {
  components: {
    couponListWindow: couponListWindow,
    addressWindow: addressWindow,
    orderGoods: orderGoods,
    home: home,
    authorize: authorize
  },
  mixins: [_color.default],
  data: function data() {
    return {
      textFocus: false,
      textareaStatus: true,
      //支付方式
      cartArr: [{
        "name": this.$t("\u5FAE\u4FE1\u652F\u4ED8"),
        "icon": "icon-weixin2",
        value: 'weixin',
        title: this.$t("\u4F7F\u7528\u5FAE\u4FE1\u5FEB\u6377\u652F\u4ED8"),
        payStatus: 1
      }, {
        "name": this.$t("\u652F\u4ED8\u5B9D\u652F\u4ED8"),
        "icon": "icon-zhifubao",
        value: 'alipay',
        title: this.$t("\u4F7F\u7528\u7EBF\u4E0A\u652F\u4ED8\u5B9D\u652F\u4ED8"),
        payStatus: 1
      }, {
        "name": this.$t("\u4F59\u989D\u652F\u4ED8"),
        "icon": "icon-yuezhifu",
        value: 'yue',
        title: this.$t("\u53EF\u7528\u4F59\u989D:"),
        payStatus: 1
      }, {
        "name": this.$t("\u7EBF\u4E0B\u652F\u4ED8"),
        "icon": "icon-yuezhifu1",
        value: 'offline',
        title: this.$t("\u9009\u62E9\u7EBF\u4E0B\u4ED8\u6B3E\u65B9\u5F0F"),
        payStatus: 2
      }],
      formContent: '',
      payType: 'weixin',
      //支付方式
      openType: 1,
      //优惠券打开方式 1=使用
      active: 0,
      //支付方式切换
      coupon: {
        coupon: false,
        list: [],
        statusTile: this.$t("\u7ACB\u5373\u4F7F\u7528")
      },
      //优惠券组件
      address: {
        address: false
      },
      //地址组件
      addressInfo: {},
      //地址信息
      pinkId: 0,
      //拼团id
      addressId: 0,
      //地址id
      couponId: 0,
      //优惠券id
      cartId: '',
      //购物车id
      BargainId: 0,
      combinationId: 0,
      seckillId: 0,
      userInfo: {},
      //用户信息
      coupon_price: 0,
      //优惠券抵扣金额
      useIntegral: false,
      //是否使用消费券
      integral_price: 0,
      //消费券抵扣金额
      integral: 0,
      ChangePrice: 0,
      //使用消费券抵扣变动后的金额
      formIds: [],
      //收集formid
      status: 0,
      is_address: false,
      toPay: false,
      //修复进入支付时页面隐藏从新刷新页面
      shippingType: 0,
      system_store: {},
      storePostage: 0,
      contacts: '',
      contactsTel: '',
      mydata: {},
      storeList: [],
      store_self_mention: 0,
      cartInfo: {},
      priceGroup: {},
      animated: false,
      totalPrice: 0,
      integralRatio: "0",
      pagesUrl: "",
      orderKey: "",
      // usableCoupon: {},
      offlinePostage: "",
      isAuto: false,
      //没有授权的不会自动授权
      isShowAuth: false,
      //是否隐藏授权
      from: '',
      news: 1,
      invTitle: this.$t("\u4E0D\u5F00\u53D1\u7968"),
      special_invoice: false,
      invoice_func: false,
      header_type: '',
      invShow: false,
      invList: [],
      invChecked: '',
      urlQuery: '',
      pay_close: false,
      resData: {},
      mark: ''
    };
  },
  computed: (0, _vuex.mapGetters)(['isLogin']),
  onLoad: function onLoad(options) {
    this.from = 'routine';
    if (!options.unique) return this.$util.Tips({
      title: this.$t("\u8BF7\u9009\u62E9\u8981\u8D2D\u4E70\u7684\u5546\u54C1")
    }, {
      tab: 3,
      url: 1
    });
    this.unique = options.unique;
    this.num = options.num;
    this.couponId = options.couponId || 0;
    this.pinkId = options.pinkId ? parseInt(options.pinkId) : 0;
    this.addressId = options.addressId || 0;
    this.cartId = options.cartId;
    this.is_address = options.is_address ? true : false;
    this.news = !options.new || options.new === '0' ? 0 : 1;
    this.invChecked = options.invoice_id || '';
    this.header_type = options.header_type || '1';
    this.couponTitle = options.couponTitle || this.$t("\u8BF7\u9009\u62E9");
    this.textareaStatus = true;
    if (this.isLogin && this.toPay == false) {
      this.getaddressInfo();
      this.getConfirm();
      this.$nextTick(function () {
        this.$refs.addressWindow.getAddressList();
      });
    } else {
      (0, _login.toLogin)();
    }
  },
  /**
   * 生命周期函数--监听页面显示
   */
  onShow: function onShow() {
    var _this = this;
    uni.$on("handClick", function (res) {
      if (res) {
        _this.system_store = res.address;
      }
      // 清除监听
      uni.$off('handClick');
    });
  },
  methods: {
    getInvoiceList: function getInvoiceList() {
      var _this2 = this;
      uni.showLoading({
        title: this.$t("\u6B63\u5728\u52A0\u8F7D\u2026")
      });
      (0, _user.invoiceList)().then(function (res) {
        uni.hideLoading();
        _this2.invList = res.data.map(function (item) {
          item.id = item.id.toString();
          return item;
        });
        var result = _this2.invList.find(function (item) {
          return item.id == _this2.invChecked;
        });
        if (result) {
          var name = '';
          name += result.header_type === 1 ? _this2.$t("\u4E2A\u4EBA") : _this2.$t("\u4F01\u4E1A");
          name += result.type === 1 ? _this2.$t("\u666E\u901A") : _this2.$t("\u4E13\u7528");
          name += _this2.$t("\u53D1\u7968");
          _this2.invTitle = name;
        }
      }).catch(function (err) {
        uni.showToast({
          title: err,
          icon: 'none'
        });
      });
    },
    /**
     * 事件回调
     *
     */
    onChangeFun: function onChangeFun(e) {
      var opt = e;
      var action = opt.action || null;
      var value = opt.value != undefined ? opt.value : null;
      action && this[action] && this[action](value);
    },
    payClose: function payClose() {
      this.pay_close = false;
    },
    goPay: function goPay() {
      var that = this;
      if (!that.addressId) {
        return that.$util.Tips({
          title: that.$t("\u8BF7\u9009\u62E9\u6536\u8D27\u5730\u5740")
        });
      }
      if (parseFloat(that.resData.integral) < parseFloat(that.cartInfo.price)) return that.$util.Tips({
        title: that.$t("\u53EF\u7528\u6D88\u8D39\u5238\u4E0D\u8DB3\uFF01")
      });
      var data = {
        addressId: that.addressId,
        mark: that.mark,
        unique: this.cartInfo.unique,
        num: this.resData.num
      };
      (0, _activity.integralOrderCreate)(data).then(function (res) {
        uni.redirectTo({
          url: "/pages/points_mall/integral_order_status?order_id=".concat(res.data.result.orderId)
        });
      }).catch(function (err) {
        uni.hideLoading();
        return that.$util.Tips({
          title: err
        });
      });
    },
    // 关闭地址弹窗；
    changeClose: function changeClose() {
      this.$set(this.address, 'address', false);
    },
    computedPrice: function computedPrice() {
      var _this3 = this;
      var shippingType = this.shippingType;
      postOrderComputed(this.orderKey, {
        addressId: this.addressId,
        useIntegral: this.useIntegral ? 1 : 0,
        couponId: this.couponId,
        shipping_type: parseInt(shippingType) + 1,
        payType: this.payType
      }).then(function (res) {
        var result = res.data.result;
        if (result) {
          _this3.totalPrice = result.pay_price;
          _this3.integral_price = result.deduction_price;
          _this3.coupon_price = result.coupon_price;
          _this3.integral = _this3.useIntegral ? result.SurplusIntegral : _this3.userInfo.integral;
          _this3.$set(_this3.priceGroup, 'storePostage', shippingType == 1 ? 0 : result.pay_postage);
          _this3.$set(_this3.priceGroup, 'storePostageDiscount', result.storePostageDiscount);
        }
      });
    },
    ChangCouponsClone: function ChangCouponsClone() {
      this.$set(this.coupon, 'coupon', false);
    },
    changeTextareaStatus: function changeTextareaStatus() {
      for (var i = 0, len = this.coupon.list.length; i < len; i++) {
        this.coupon.list[i].use_title = '';
        this.coupon.list[i].is_use = 0;
      }
      this.textareaStatus = true;
      this.status = 0;
      this.$set(this.coupon, 'list', this.coupon.list);
    },
    /**
     * 选择地址后改变事件
     * @param object e
     */
    OnChangeAddress: function OnChangeAddress(e) {
      this.textareaStatus = true;
      this.addressId = e;
      this.address.address = false;
      this.getaddressInfo();
    },
    bindHideKeyboard: function bindHideKeyboard(e) {
      this.mark = e.detail.value;
    },
    /**
     * 获取当前订单详细信息
     * 
     */
    getConfirm: function getConfirm() {
      var _this4 = this;
      var that = this;
      // return;
      (0, _activity.integralOrderConfirm)({
        unique: this.unique,
        num: this.num
      }).then(function (res) {
        that.$set(that, 'resData', res.data);
        that.$set(that, 'cartInfo', res.data.productInfo);
      }).catch(function (err) {
        return _this4.$util.Tips({
          title: err
        });
      });
    },
    /*
     * 提取砍价和拼团id
     */
    getBargainId: function getBargainId() {
      var that = this;
      var cartINfo = that.cartInfo;
      var BargainId = 0;
      var combinationId = 0;
      cartINfo.forEach(function (value, index, cartINfo) {
        BargainId = cartINfo[index].bargain_id, combinationId = cartINfo[index].combination_id;
      });
      that.$set(that, 'BargainId', parseInt(BargainId));
      that.$set(that, 'combinationId', parseInt(combinationId));
      if (that.cartArr.length == 3 && (BargainId || combinationId || that.seckillId)) {
        that.cartArr[2].payStatus = 0;
        that.$set(that, 'cartArr', that.cartArr);
      }
    },
    /*
     * 获取默认收货地址或者获取某条地址信息
     */
    getaddressInfo: function getaddressInfo() {
      var that = this;
      if (that.addressId) {
        (0, _user.getAddressDetail)(that.addressId).then(function (res) {
          res.data.is_default = parseInt(res.data.is_default);
          that.addressInfo = res.data || {};
          that.addressId = res.data.id || 0;
          that.address.addressId = res.data.id || 0;
        });
      } else {
        (0, _user.getAddressDefault)().then(function (res) {
          res.data.is_default = parseInt(res.data.is_default);
          that.addressInfo = res.data || {};
          that.addressId = res.data.id || 0;
          that.address.addressId = res.data.id || 0;
        });
      }
    },
    couponTap: function couponTap() {
      var _this5 = this;
      this.coupon.coupon = true;
      this.coupon.list.forEach(function (item, index) {
        if (item.id == _this5.couponId) {
          item.is_use = 1;
        } else {
          item.is_use = 0;
        }
      });
      this.$set(this.coupon, 'list', this.coupon.list);
    },
    car: function car() {
      var that = this;
      that.animated = false;
    },
    onAddress: function onAddress() {
      var that = this;
      that.textareaStatus = false;
      that.address.address = true;
      that.pagesUrl = "/pages/points_mall/user_address?unique=".concat(this.unique, "&num=").concat(this.num);
    },
    clickTextArea: function clickTextArea() {
      this.textFocus = true;
      // this.$nextTick(() => {
      // 	this.$refs.getFocus.focus()
      // })
    }
  }
};
exports.default = _default;
/* WEBPACK VAR INJECTION */}.call(this, __webpack_require__(/*! ./node_modules/@dcloudio/uni-mp-weixin/dist/index.js */ 2)["default"]))

/***/ }),

/***/ 1108:
/*!************************************************************************************************************************************!*\
  !*** D:/practice-project/中臻电商/中臻电商/pages/points_mall/integral_order.vue?vue&type=style&index=0&id=fe1f759a&lang=scss&scoped=true& ***!
  \************************************************************************************************************************************/
/*! no static exports found */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_mini_css_extract_plugin_dist_loader_js_ref_8_oneOf_1_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_css_loader_dist_cjs_js_ref_8_oneOf_1_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_stylePostLoader_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_2_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_postcss_loader_src_index_js_ref_8_oneOf_1_3_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_sass_loader_dist_cjs_js_ref_8_oneOf_1_4_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_5_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_style_index_0_id_fe1f759a_lang_scss_scoped_true___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! -!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/mini-css-extract-plugin/dist/loader.js??ref--8-oneOf-1-0!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/css-loader/dist/cjs.js??ref--8-oneOf-1-1!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib/loaders/stylePostLoader.js!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--8-oneOf-1-2!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/postcss-loader/src??ref--8-oneOf-1-3!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/sass-loader/dist/cjs.js??ref--8-oneOf-1-4!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--8-oneOf-1-5!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib??vue-loader-options!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/webpack-uni-mp-loader/lib/style.js!./integral_order.vue?vue&type=style&index=0&id=fe1f759a&lang=scss&scoped=true& */ 1109);
/* harmony import */ var _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_mini_css_extract_plugin_dist_loader_js_ref_8_oneOf_1_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_css_loader_dist_cjs_js_ref_8_oneOf_1_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_stylePostLoader_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_2_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_postcss_loader_src_index_js_ref_8_oneOf_1_3_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_sass_loader_dist_cjs_js_ref_8_oneOf_1_4_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_5_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_style_index_0_id_fe1f759a_lang_scss_scoped_true___WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_mini_css_extract_plugin_dist_loader_js_ref_8_oneOf_1_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_css_loader_dist_cjs_js_ref_8_oneOf_1_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_stylePostLoader_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_2_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_postcss_loader_src_index_js_ref_8_oneOf_1_3_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_sass_loader_dist_cjs_js_ref_8_oneOf_1_4_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_5_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_style_index_0_id_fe1f759a_lang_scss_scoped_true___WEBPACK_IMPORTED_MODULE_0__);
/* harmony reexport (unknown) */ for(var __WEBPACK_IMPORT_KEY__ in _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_mini_css_extract_plugin_dist_loader_js_ref_8_oneOf_1_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_css_loader_dist_cjs_js_ref_8_oneOf_1_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_stylePostLoader_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_2_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_postcss_loader_src_index_js_ref_8_oneOf_1_3_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_sass_loader_dist_cjs_js_ref_8_oneOf_1_4_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_5_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_style_index_0_id_fe1f759a_lang_scss_scoped_true___WEBPACK_IMPORTED_MODULE_0__) if(["default"].indexOf(__WEBPACK_IMPORT_KEY__) < 0) (function(key) { __webpack_require__.d(__webpack_exports__, key, function() { return _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_mini_css_extract_plugin_dist_loader_js_ref_8_oneOf_1_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_css_loader_dist_cjs_js_ref_8_oneOf_1_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_stylePostLoader_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_2_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_postcss_loader_src_index_js_ref_8_oneOf_1_3_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_sass_loader_dist_cjs_js_ref_8_oneOf_1_4_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_5_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_style_index_0_id_fe1f759a_lang_scss_scoped_true___WEBPACK_IMPORTED_MODULE_0__[key]; }) }(__WEBPACK_IMPORT_KEY__));
 /* harmony default export */ __webpack_exports__["default"] = (_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_mini_css_extract_plugin_dist_loader_js_ref_8_oneOf_1_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_css_loader_dist_cjs_js_ref_8_oneOf_1_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_stylePostLoader_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_2_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_postcss_loader_src_index_js_ref_8_oneOf_1_3_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_sass_loader_dist_cjs_js_ref_8_oneOf_1_4_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_5_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_integral_order_vue_vue_type_style_index_0_id_fe1f759a_lang_scss_scoped_true___WEBPACK_IMPORTED_MODULE_0___default.a); 

/***/ }),

/***/ 1109:
/*!****************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************!*\
  !*** ./node_modules/mini-css-extract-plugin/dist/loader.js??ref--8-oneOf-1-0!./node_modules/css-loader/dist/cjs.js??ref--8-oneOf-1-1!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib/loaders/stylePostLoader.js!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--8-oneOf-1-2!./node_modules/postcss-loader/src??ref--8-oneOf-1-3!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/sass-loader/dist/cjs.js??ref--8-oneOf-1-4!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--8-oneOf-1-5!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib??vue-loader-options!./node_modules/@dcloudio/webpack-uni-mp-loader/lib/style.js!D:/practice-project/中臻电商/中臻电商/pages/points_mall/integral_order.vue?vue&type=style&index=0&id=fe1f759a&lang=scss&scoped=true& ***!
  \****************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

// extracted by mini-css-extract-plugin
    if(false) { var cssReload; }
  

/***/ })

},[[1102,"common/runtime","common/vendor"]]]);
//# sourceMappingURL=../../../.sourcemap/mp-weixin/pages/points_mall/integral_order.js.map