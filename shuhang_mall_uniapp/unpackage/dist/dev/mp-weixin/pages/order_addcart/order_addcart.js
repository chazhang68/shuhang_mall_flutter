(global["webpackJsonp"] = global["webpackJsonp"] || []).push([["pages/order_addcart/order_addcart"],{

/***/ 85:
/*!**********************************************************************************************!*\
  !*** D:/practice-project/中臻电商/中臻电商/main.js?{"page":"pages%2Forder_addcart%2Forder_addcart"} ***!
  \**********************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(wx, createPage) {

var _interopRequireDefault = __webpack_require__(/*! @babel/runtime/helpers/interopRequireDefault */ 4);
__webpack_require__(/*! uni-pages */ 26);
var _vue = _interopRequireDefault(__webpack_require__(/*! vue */ 25));
var _order_addcart = _interopRequireDefault(__webpack_require__(/*! ./pages/order_addcart/order_addcart.vue */ 86));
// @ts-ignore
wx.__webpack_require_UNI_MP_PLUGIN__ = __webpack_require__;
createPage(_order_addcart.default);
/* WEBPACK VAR INJECTION */}.call(this, __webpack_require__(/*! ./node_modules/@dcloudio/uni-mp-weixin/dist/wx.js */ 1)["default"], __webpack_require__(/*! ./node_modules/@dcloudio/uni-mp-weixin/dist/index.js */ 2)["createPage"]))

/***/ }),

/***/ 86:
/*!***************************************************************************!*\
  !*** D:/practice-project/中臻电商/中臻电商/pages/order_addcart/order_addcart.vue ***!
  \***************************************************************************/
/*! no static exports found */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _order_addcart_vue_vue_type_template_id_a5aa7f30_scoped_true___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! ./order_addcart.vue?vue&type=template&id=a5aa7f30&scoped=true& */ 87);
/* harmony import */ var _order_addcart_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_1__ = __webpack_require__(/*! ./order_addcart.vue?vue&type=script&lang=js& */ 89);
/* harmony reexport (unknown) */ for(var __WEBPACK_IMPORT_KEY__ in _order_addcart_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_1__) if(["default"].indexOf(__WEBPACK_IMPORT_KEY__) < 0) (function(key) { __webpack_require__.d(__webpack_exports__, key, function() { return _order_addcart_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_1__[key]; }) }(__WEBPACK_IMPORT_KEY__));
/* harmony import */ var _order_addcart_vue_vue_type_style_index_0_id_a5aa7f30_scoped_true_lang_scss___WEBPACK_IMPORTED_MODULE_2__ = __webpack_require__(/*! ./order_addcart.vue?vue&type=style&index=0&id=a5aa7f30&scoped=true&lang=scss& */ 93);
/* harmony import */ var _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_runtime_componentNormalizer_js__WEBPACK_IMPORTED_MODULE_3__ = __webpack_require__(/*! ../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib/runtime/componentNormalizer.js */ 58);

var renderjs





/* normalize component */

var component = Object(_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_runtime_componentNormalizer_js__WEBPACK_IMPORTED_MODULE_3__["default"])(
  _order_addcart_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_1__["default"],
  _order_addcart_vue_vue_type_template_id_a5aa7f30_scoped_true___WEBPACK_IMPORTED_MODULE_0__["render"],
  _order_addcart_vue_vue_type_template_id_a5aa7f30_scoped_true___WEBPACK_IMPORTED_MODULE_0__["staticRenderFns"],
  false,
  null,
  "a5aa7f30",
  null,
  false,
  _order_addcart_vue_vue_type_template_id_a5aa7f30_scoped_true___WEBPACK_IMPORTED_MODULE_0__["components"],
  renderjs
)

component.options.__file = "pages/order_addcart/order_addcart.vue"
/* harmony default export */ __webpack_exports__["default"] = (component.exports);

/***/ }),

/***/ 87:
/*!**********************************************************************************************************************!*\
  !*** D:/practice-project/中臻电商/中臻电商/pages/order_addcart/order_addcart.vue?vue&type=template&id=a5aa7f30&scoped=true& ***!
  \**********************************************************************************************************************/
/*! exports provided: render, staticRenderFns, recyclableRender, components */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_17_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_template_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_uni_app_loader_page_meta_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_template_id_a5aa7f30_scoped_true___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! -!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib/loaders/templateLoader.js??vue-loader-options!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--17-0!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/webpack-uni-mp-loader/lib/template.js!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-uni-app-loader/page-meta.js!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib??vue-loader-options!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/webpack-uni-mp-loader/lib/style.js!./order_addcart.vue?vue&type=template&id=a5aa7f30&scoped=true& */ 88);
/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "render", function() { return _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_17_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_template_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_uni_app_loader_page_meta_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_template_id_a5aa7f30_scoped_true___WEBPACK_IMPORTED_MODULE_0__["render"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "staticRenderFns", function() { return _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_17_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_template_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_uni_app_loader_page_meta_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_template_id_a5aa7f30_scoped_true___WEBPACK_IMPORTED_MODULE_0__["staticRenderFns"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "recyclableRender", function() { return _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_17_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_template_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_uni_app_loader_page_meta_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_template_id_a5aa7f30_scoped_true___WEBPACK_IMPORTED_MODULE_0__["recyclableRender"]; });

/* harmony reexport (safe) */ __webpack_require__.d(__webpack_exports__, "components", function() { return _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_templateLoader_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_17_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_template_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_uni_app_loader_page_meta_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_template_id_a5aa7f30_scoped_true___WEBPACK_IMPORTED_MODULE_0__["components"]; });



/***/ }),

/***/ 88:
/*!**********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************!*\
  !*** ./node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib/loaders/templateLoader.js??vue-loader-options!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--17-0!./node_modules/@dcloudio/webpack-uni-mp-loader/lib/template.js!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-uni-app-loader/page-meta.js!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib??vue-loader-options!./node_modules/@dcloudio/webpack-uni-mp-loader/lib/style.js!D:/practice-project/中臻电商/中臻电商/pages/order_addcart/order_addcart.vue?vue&type=template&id=a5aa7f30&scoped=true& ***!
  \**********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************/
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
  var m0 = _vm.canShow ? _vm.$t("100%正品保证") : null
  var m1 = _vm.canShow ? _vm.$t("所有商品精挑细选") : null
  var m2 = _vm.canShow ? _vm.$t("售后无忧") : null
  var m3 = _vm.canShow ? _vm.$t("购物数量") : null
  var g0 = _vm.canShow
    ? _vm.cartList.valid.length > 0 || _vm.cartList.invalid.length > 0
    : null
  var m4 = _vm.canShow && g0 && _vm.footerswitch ? _vm.$t("管理") : null
  var m5 = _vm.canShow && g0 && !_vm.footerswitch ? _vm.$t("取消") : null
  var g1 = _vm.canShow
    ? (_vm.cartList.valid.length > 0 || _vm.cartList.invalid.length > 0) &&
      _vm.canShow
    : null
  var l0 =
    _vm.canShow && g1
      ? _vm.__map(_vm.cartList.valid, function (item, index) {
          var $orig = _vm.__get_orig(item)
          var m6 = item.productInfo.attrInfo ? _vm.$t("属性") : null
          var m7 = item.attrStatus ? _vm.$t("￥") : null
          var m8 = !item.attrStatus ? _vm.$t("请重新选择商品规格") : null
          var m9 = !item.attrStatus ? _vm.$t("重选") : null
          return {
            $orig: $orig,
            m6: m6,
            m7: m7,
            m8: m8,
            m9: m9,
          }
        })
      : null
  var g2 = _vm.canShow && g1 ? _vm.cartList.invalid.length : null
  var m10 = _vm.canShow && g1 && g2 > 0 ? _vm.$t("失效商品") : null
  var m11 = _vm.canShow && g1 && g2 > 0 ? _vm.$t("清空") : null
  var l1 =
    _vm.canShow && g1 && g2 > 0
      ? _vm.__map(_vm.cartList.invalid, function (item, index) {
          var $orig = _vm.__get_orig(item)
          var m12 = _vm.$t("失效")
          var m13 = item.productInfo.attrInfo ? _vm.$t("属性") : null
          var m14 = _vm.$t("该商品已失效")
          return {
            $orig: $orig,
            m12: m12,
            m13: m13,
            m14: m14,
          }
        })
      : null
  var g3 = _vm.canShow && g1 ? _vm.cartList.invalid.length && _vm.loadend : null
  var g4 = _vm.canShow
    ? _vm.cartList.valid.length == 0 &&
      _vm.cartList.invalid.length == 0 &&
      _vm.canShow
    : null
  var m15 = _vm.canShow && g4 ? _vm.$t("暂无商品") : null
  var g5 = _vm.canShow && g4 ? _vm.hostProduct.length : null
  var g6 = _vm.canShow ? _vm.cartList.valid.length > 0 && _vm.canShow : null
  var m16 = _vm.canShow && g6 ? _vm.$t("全选") : null
  var g7 = _vm.canShow && g6 ? _vm.selectValue.length : null
  var m17 = _vm.canShow && g6 && _vm.footerswitch == true ? _vm.$t("￥") : null
  var m18 =
    _vm.canShow && g6 && _vm.footerswitch == true ? _vm.$t("立即下单") : null
  var m19 =
    _vm.canShow && g6 && !(_vm.footerswitch == true) ? _vm.$t("收藏") : null
  var m20 =
    _vm.canShow && g6 && !(_vm.footerswitch == true) ? _vm.$t("删除") : null
  _vm.$mp.data = Object.assign(
    {},
    {
      $root: {
        m0: m0,
        m1: m1,
        m2: m2,
        m3: m3,
        g0: g0,
        m4: m4,
        m5: m5,
        g1: g1,
        l0: l0,
        g2: g2,
        m10: m10,
        m11: m11,
        l1: l1,
        g3: g3,
        g4: g4,
        m15: m15,
        g5: g5,
        g6: g6,
        m16: m16,
        g7: g7,
        m17: m17,
        m18: m18,
        m19: m19,
        m20: m20,
      },
    }
  )
}
var recyclableRender = false
var staticRenderFns = []
render._withStripped = true



/***/ }),

/***/ 89:
/*!****************************************************************************************************!*\
  !*** D:/practice-project/中臻电商/中臻电商/pages/order_addcart/order_addcart.vue?vue&type=script&lang=js& ***!
  \****************************************************************************************************/
/*! no static exports found */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_babel_loader_lib_index_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_13_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_script_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! -!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/babel-loader/lib!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--13-1!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/webpack-uni-mp-loader/lib/script.js!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib??vue-loader-options!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/webpack-uni-mp-loader/lib/style.js!./order_addcart.vue?vue&type=script&lang=js& */ 90);
/* harmony import */ var _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_babel_loader_lib_index_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_13_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_script_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_babel_loader_lib_index_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_13_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_script_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0__);
/* harmony reexport (unknown) */ for(var __WEBPACK_IMPORT_KEY__ in _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_babel_loader_lib_index_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_13_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_script_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0__) if(["default"].indexOf(__WEBPACK_IMPORT_KEY__) < 0) (function(key) { __webpack_require__.d(__webpack_exports__, key, function() { return _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_babel_loader_lib_index_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_13_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_script_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0__[key]; }) }(__WEBPACK_IMPORT_KEY__));
 /* harmony default export */ __webpack_exports__["default"] = (_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_babel_loader_lib_index_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_13_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_script_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_script_lang_js___WEBPACK_IMPORTED_MODULE_0___default.a); 

/***/ }),

/***/ 90:
/*!***********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************!*\
  !*** ./node_modules/babel-loader/lib!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--13-1!./node_modules/@dcloudio/webpack-uni-mp-loader/lib/script.js!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib??vue-loader-options!./node_modules/@dcloudio/webpack-uni-mp-loader/lib/style.js!D:/practice-project/中臻电商/中臻电商/pages/order_addcart/order_addcart.vue?vue&type=script&lang=js& ***!
  \***********************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

"use strict";
/* WEBPACK VAR INJECTION */(function(uni, wx) {

var _interopRequireDefault = __webpack_require__(/*! @babel/runtime/helpers/interopRequireDefault */ 4);
Object.defineProperty(exports, "__esModule", {
  value: true
});
exports.default = void 0;
var _regenerator = _interopRequireDefault(__webpack_require__(/*! @babel/runtime/regenerator */ 30));
var _defineProperty2 = _interopRequireDefault(__webpack_require__(/*! @babel/runtime/helpers/defineProperty */ 11));
var _asyncToGenerator2 = _interopRequireDefault(__webpack_require__(/*! @babel/runtime/helpers/asyncToGenerator */ 32));
var _order = __webpack_require__(/*! @/api/order.js */ 91);
var _store = __webpack_require__(/*! @/api/store.js */ 92);
var _login = __webpack_require__(/*! @/libs/login.js */ 33);
var _vuex = __webpack_require__(/*! vuex */ 35);
var _color = _interopRequireDefault(__webpack_require__(/*! @/mixins/color */ 55));
var _app = __webpack_require__(/*! @/config/app */ 40);
var _methods;
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

var sysHeight = 0;
var tabBar = function tabBar() {
  Promise.all(/*! require.ensure | pages/index/visualization/components/tabBar */[__webpack_require__.e("common/vendor"), __webpack_require__.e("pages/index/visualization/components/tabBar")]).then((function () {
    return resolve(__webpack_require__(/*! @/pages/index/visualization/components/tabBar.vue */ 1185));
  }).bind(null, __webpack_require__)).catch(__webpack_require__.oe);
};
var recommend = function recommend() {
  Promise.all(/*! require.ensure | components/recommend/index */[__webpack_require__.e("common/vendor"), __webpack_require__.e("components/recommend/index")]).then((function () {
    return resolve(__webpack_require__(/*! @/components/recommend */ 1192));
  }).bind(null, __webpack_require__)).catch(__webpack_require__.oe);
};
var productWindow = function productWindow() {
  __webpack_require__.e(/*! require.ensure | components/productWindow/index */ "components/productWindow/index").then((function () {
    return resolve(__webpack_require__(/*! @/components/productWindow */ 1199));
  }).bind(null, __webpack_require__)).catch(__webpack_require__.oe);
};
var authorize = function authorize() {
  __webpack_require__.e(/*! require.ensure | components/Authorize */ "components/Authorize").then((function () {
    return resolve(__webpack_require__(/*! @/components/Authorize */ 1206));
  }).bind(null, __webpack_require__)).catch(__webpack_require__.oe);
};
var _default = {
  components: {
    recommend: recommend,
    productWindow: productWindow,
    tabBar: tabBar,
    authorize: authorize
  },
  mixins: [_color.default],
  data: function data() {
    return {
      imgHost: _app.HTTP_REQUEST_URL,
      is_diy: uni.getStorageSync('is_diy'),
      canShow: false,
      cartCount: 0,
      goodsHidden: true,
      footerswitch: true,
      hostProduct: [],
      cartList: {
        valid: [],
        invalid: []
      },
      isAllSelect: false,
      //全选
      selectValue: [],
      //选中的数据
      selectCountPrice: 0.00,
      isAuto: false,
      //没有授权的不会自动授权
      isShowAuth: false,
      //是否隐藏授权
      hotScroll: false,
      hotPage: 1,
      hotLimit: 10,
      loading: false,
      loadend: false,
      loadTitle: this.$t("\u6211\u4E5F\u662F\u6709\u5E95\u7EBF\u7684"),
      //提示语
      page: 1,
      limit: 20,
      loadingInvalid: false,
      loadendInvalid: false,
      loadTitleInvalid: this.$t("\u52A0\u8F7D\u66F4\u591A"),
      //提示语
      pageInvalid: 1,
      limitInvalid: 20,
      attr: {
        cartAttr: false,
        productAttr: [],
        productSelect: {}
      },
      productValue: [],
      //系统属性
      storeInfo: {},
      attrValue: '',
      //已选属性
      attrTxt: this.$t("\u8BF7\u9009\u62E9"),
      //属性页面提示
      cartId: 0,
      product_id: 0,
      sysHeight: sysHeight,
      newData: {},
      activeRouter: '',
      is_diy_set: false,
      adding: false
    };
  },
  computed: (0, _vuex.mapGetters)(['isLogin']),
  onLoad: function onLoad(options) {
    uni.hideTabBar();
    var that = this;
    var routes = getCurrentPages(); // 获取当前打开过的页面路由数组
    var curRoute = routes[routes.length - 1].route; //获取当前页面路由
    this.activeRouter = '/' + curRoute;
  },
  onShow: function onShow() {
    if (!this.isLogin) (0, _login.toLogin)();
    this.canShow = false;
    if (this.isLogin == true) {
      this.hotPage = 1;
      this.hostProduct = [];
      this.hotScroll = false;
      this.getHostProduct();
      this.loadend = false;
      this.page = 1;
      this.cartList.valid = [];
      this.getCartList(1);
      this.loadendInvalid = false;
      this.pageInvalid = 1;
      this.cartList.invalid = [];
      this.getInvalidList();
      // this.getCartNum();
      this.goodsHidden = true;
      this.footerswitch = true;
      this.hostProduct = [];
      this.hotScroll = false;
      this.hotPage = 1;
      this.hotLimit = 10;
      this.cartList = {
        valid: [],
        invalid: []
      }, this.isAllSelect = false; //全选
      this.selectValue = []; //选中的数据
      this.selectCountPrice = 0.00;
      this.cartCount = 0;
      this.isShowAuth = false;
    }
    ;
  },
  methods: (_methods = {
    // 授权关闭
    authColse: function authColse(e) {
      this.isShowAuth = e;
    },
    // 修改购物车
    reGoCat: function reGoCat() {
      var that = this,
        productSelect = that.productValue[this.attrValue];
      //如果有属性,没有选择,提示用户选择
      if (that.attr.productAttr.length && productSelect === undefined) return that.$util.Tips({
        title: that.$t("\u4EA7\u54C1\u5E93\u5B58\u4E0D\u8DB3\uFF0C\u8BF7\u9009\u62E9\u5176\u5B83")
      });
      var q = {
        id: that.cartId,
        product_id: that.product_id,
        num: that.attr.productSelect.cart_num,
        unique: that.attr.productSelect !== undefined ? that.attr.productSelect.unique : ""
      };
      (0, _order.getResetCart)(q).then(function (res) {
        that.attr.cartAttr = false;
        that.$util.Tips({
          title: that.$t("\u6DFB\u52A0\u8D2D\u7269\u8F66\u6210\u529F"),
          success: function success() {
            that.loadend = false;
            that.page = 1;
            that.cartList.valid = [];
            that.getCartList();
            that.getCartNum();
          }
        });
      }).catch(function (res) {
        return that.$util.Tips({
          title: res.msg
        });
      });
    },
    onMyEvent: function onMyEvent() {
      this.$set(this.attr, 'cartAttr', false);
    },
    reElection: function reElection(item) {
      this.getGoodsDetails(item);
    },
    /**
     * 获取产品详情
     * 
     */
    getGoodsDetails: function getGoodsDetails(item) {
      uni.showLoading({
        title: this.$t("\u52A0\u8F7D\u4E2D"),
        mask: true
      });
      var that = this;
      that.cartId = item.id;
      that.product_id = item.product_id;
      (0, _store.getProductDetail)(item.product_id).then(function (res) {
        uni.hideLoading();
        that.attr.cartAttr = true;
        var storeInfo = res.data.storeInfo;
        that.$set(that, 'storeInfo', storeInfo);
        that.$set(that.attr, 'productAttr', res.data.productAttr);
        that.$set(that, 'productValue', res.data.productValue);
        that.DefaultSelect();
      }).catch(function (err) {
        uni.hideLoading();
      });
    },
    /**
     * 属性变动赋值
     * 
     */
    ChangeAttr: function ChangeAttr(res) {
      var productSelect = this.productValue[res];
      if (productSelect && productSelect.stock > 0) {
        this.$set(this.attr.productSelect, "image", productSelect.image);
        this.$set(this.attr.productSelect, "price", productSelect.price);
        this.$set(this.attr.productSelect, "stock", productSelect.stock);
        this.$set(this.attr.productSelect, "unique", productSelect.unique);
        this.$set(this.attr.productSelect, "cart_num", 1);
        this.$set(this, "attrValue", res);
        this.$set(this, "attrTxt", this.$t("\u5DF2\u9009\u62E9"));
      } else {
        this.$set(this.attr.productSelect, "image", this.storeInfo.image);
        this.$set(this.attr.productSelect, "price", this.storeInfo.price);
        this.$set(this.attr.productSelect, "stock", 0);
        this.$set(this.attr.productSelect, "unique", "");
        this.$set(this.attr.productSelect, "cart_num", 0);
        this.$set(this, "attrValue", "");
        this.$set(this, "attrTxt", this.$t("\u8BF7\u9009\u62E9"));
      }
    },
    /**
     * 默认选中属性
     * 
     */
    DefaultSelect: function DefaultSelect() {
      var productAttr = this.attr.productAttr;
      var value = [];
      for (var key in this.productValue) {
        if (this.productValue[key].stock > 0) {
          value = this.attr.productAttr.length ? key.split(",") : [];
          break;
        }
      }
      for (var i = 0; i < productAttr.length; i++) {
        this.$set(productAttr[i], "index", value[i]);
      }
      //sort();排序函数:数字-英文-汉字；
      var productSelect = this.productValue[value.sort().join(",")];
      if (productSelect && productAttr.length) {
        this.$set(this.attr.productSelect, "store_name", this.storeInfo.store_name);
        this.$set(this.attr.productSelect, "image", productSelect.image);
        this.$set(this.attr.productSelect, "price", productSelect.price);
        this.$set(this.attr.productSelect, "stock", productSelect.stock);
        this.$set(this.attr.productSelect, "unique", productSelect.unique);
        this.$set(this.attr.productSelect, "cart_num", 1);
        this.$set(this, "attrValue", value.sort().join(","));
        this.$set(this, "attrTxt", this.$t("\u5DF2\u9009\u62E9"));
      } else if (!productSelect && productAttr.length) {
        this.$set(this.attr.productSelect, "store_name", this.storeInfo.store_name);
        this.$set(this.attr.productSelect, "image", this.storeInfo.image);
        this.$set(this.attr.productSelect, "price", this.storeInfo.price);
        this.$set(this.attr.productSelect, "stock", 0);
        this.$set(this.attr.productSelect, "unique", "");
        this.$set(this.attr.productSelect, "cart_num", 0);
        this.$set(this, "attrValue", "");
        this.$set(this, "attrTxt", this.$t("\u8BF7\u9009\u62E9"));
      } else if (!productSelect && !productAttr.length) {
        this.$set(this.attr.productSelect, "store_name", this.storeInfo.store_name);
        this.$set(this.attr.productSelect, "image", this.storeInfo.image);
        this.$set(this.attr.productSelect, "price", this.storeInfo.price);
        this.$set(this.attr.productSelect, "stock", this.storeInfo.stock);
        this.$set(this.attr.productSelect, "unique", this.storeInfo.unique || "");
        this.$set(this.attr.productSelect, "cart_num", 1);
        this.$set(this, "attrValue", "");
        this.$set(this, "attrTxt", this.$t("\u8BF7\u9009\u62E9"));
      }
    },
    attrVal: function attrVal(val) {
      this.$set(this.attr.productAttr[val.indexw], 'index', this.attr.productAttr[val.indexw].attr_values[val.indexn]);
    },
    /**
     * 购物车数量加和数量减
     * 
     */
    ChangeCartNum: function ChangeCartNum(changeValue) {
      //changeValue:是否 加|减
      //获取当前变动属性
      var productSelect = this.productValue[this.attrValue];
      //如果没有属性,赋值给商品默认库存
      if (productSelect === undefined && !this.attr.productAttr.length) productSelect = this.attr.productSelect;
      //无属性值即库存为0；不存在加减；
      if (productSelect === undefined) return;
      var stock = productSelect.stock || 0;
      var num = this.attr.productSelect;
      if (changeValue) {
        num.cart_num++;
        if (num.cart_num > stock) {
          this.$set(this.attr.productSelect, "cart_num", stock ? stock : 1);
          this.$set(this, "cart_num", stock ? stock : 1);
        }
      } else {
        num.cart_num--;
        if (num.cart_num < 1) {
          this.$set(this.attr.productSelect, "cart_num", 1);
          this.$set(this, "cart_num", 1);
        }
      }
    },
    /**
     * 购物车手动填写
     * 
     */
    iptCartNum: function iptCartNum(e) {
      this.$set(this.attr.productSelect, 'cart_num', e);
    },
    subDel: function subDel(event) {
      var that = this,
        selectValue = that.selectValue;
      if (selectValue.length > 0) (0, _order.cartDel)(selectValue).then(function (res) {
        that.loadend = false;
        that.page = 1;
        that.cartList.valid = [];
        that.getCartList();
        that.getCartNum();
      });else return that.$util.Tips({
        title: that.$t("\u8BF7\u9009\u62E9\u4EA7\u54C1")
      });
    },
    getSelectValueProductId: function getSelectValueProductId() {
      var that = this;
      var validList = that.cartList.valid;
      var selectValue = that.selectValue;
      var productId = [];
      if (selectValue.length > 0) {
        for (var index in validList) {
          if (that.inArray(validList[index].id, selectValue)) {
            productId.push(validList[index].product_id);
          }
        }
      }
      ;
      return productId;
    },
    subCollect: function subCollect(event) {
      var that = this,
        selectValue = that.selectValue;
      if (selectValue.length > 0) {
        var selectValueProductId = that.getSelectValueProductId();
        (0, _store.collectAll)(that.getSelectValueProductId().join(',')).then(function (res) {
          return that.$util.Tips({
            title: res.msg,
            icon: 'success'
          });
        }).catch(function (err) {
          return that.$util.Tips({
            title: err
          });
        });
      } else {
        return that.$util.Tips({
          title: that.$t("\u8BF7\u9009\u62E9\u4EA7\u54C1")
        });
      }
    },
    subOrder: function subOrder(event) {
      var that = this,
        selectValue = that.selectValue;
      if (selectValue.length > 0) {
        uni.navigateTo({
          url: '/pages/goods/order_confirm/index?cartId=' + selectValue.join(',')
        });
      } else {
        return that.$util.Tips({
          title: that.$t("\u8BF7\u9009\u62E9\u4EA7\u54C1")
        });
      }
    },
    checkboxAllChange: function checkboxAllChange(event) {
      var value = event.detail.value;
      if (value.length > 0) {
        this.setAllSelectValue(1);
      } else {
        this.setAllSelectValue(0);
      }
    },
    setAllSelectValue: function setAllSelectValue(status) {
      var that = this;
      var selectValue = [];
      var valid = that.cartList.valid;
      if (valid.length > 0) {
        var newValid = valid.map(function (item) {
          if (status) {
            if (that.footerswitch) {
              if (item.attrStatus) {
                item.checked = true;
                selectValue.push(item.id);
              } else {
                item.checked = false;
              }
            } else {
              item.checked = true;
              selectValue.push(item.id);
            }
            that.isAllSelect = true;
          } else {
            item.checked = false;
            that.isAllSelect = false;
          }
          return item;
        });
        that.$set(that.cartList, 'valid', newValid);
        that.selectValue = selectValue;
        that.switchSelect();
      }
    },
    checkboxChange: function checkboxChange(event) {
      var that = this;
      var value = event.detail.value;
      var valid = that.cartList.valid;
      var arr1 = [];
      var arr2 = [];
      var arr3 = [];
      var newValid = valid.map(function (item) {
        if (that.inArray(item.id, value)) {
          if (that.footerswitch) {
            if (item.attrStatus) {
              item.checked = true;
              arr1.push(item);
            } else {
              item.checked = false;
            }
          } else {
            item.checked = true;
            arr1.push(item);
          }
        } else {
          item.checked = false;
          arr2.push(item);
        }
        return item;
      });
      if (that.footerswitch) {
        arr3 = arr2.filter(function (item) {
          return !item.attrStatus;
        });
      }
      // for (let index in valid) {
      // 	if (that.inArray(valid[index].id, value)){
      // 		if(valid[index].attrStatus){
      // 			valid[index].checked = true;
      // 		}else{
      // 			valid[index].checked = false;
      // 		}
      // 	} else {
      // 		valid[index].checked = false;
      // 	} 
      // }
      that.$set(that.cartList, 'valid', newValid);
      // let newArr = that.cartList.valid.filter(item => item.attrStatus);
      that.isAllSelect = newValid.length === arr1.length + arr3.length;
      that.selectValue = value;
      that.switchSelect();
    },
    inArray: function inArray(search, array) {
      for (var i in array) {
        if (array[i] == search) {
          return true;
        }
      }
      return false;
    },
    switchSelect: function switchSelect() {
      var that = this;
      var validList = that.cartList.valid;
      var selectValue = that.selectValue;
      var selectCountPrice = 0.00;
      if (selectValue.length < 1) {
        that.selectCountPrice = selectCountPrice;
      } else {
        for (var index in validList) {
          if (that.inArray(validList[index].id, selectValue)) {
            selectCountPrice = that.$util.$h.Add(selectCountPrice, that.$util.$h.Mul(validList[index].cart_num, validList[index].truePrice));
          }
        }
        that.selectCountPrice = selectCountPrice;
      }
    }
  }, (0, _defineProperty2.default)(_methods, "iptCartNum", function iptCartNum(index) {
    var item = this.cartList.valid[index];
    if (item.cart_num) {
      this.setCartNum(item.id, item.cart_num);
    }
    this.switchSelect();
  }), (0, _defineProperty2.default)(_methods, "blurInput", function blurInput(index) {
    var item = this.cartList.valid[index];
    if (!item.cart_num) {
      item.cart_num = 1;
      this.$set(this.cartList, 'valid', this.cartList.valid);
    }
  }), (0, _defineProperty2.default)(_methods, "subCart", function subCart(index) {
    var that = this;
    var status = false;
    var item = that.cartList.valid[index];
    item.cart_num = Number(item.cart_num) - 1;
    if (item.cart_num < 1) status = true;
    if (item.cart_num <= 1) {
      item.cart_num = 1;
      item.numSub = true;
    } else {
      item.numSub = false;
      item.numAdd = false;
    }
    if (false == status) {
      that.setCartNum(item.id, item.cart_num, function (data) {
        that.cartList.valid[index] = item;
        that.getCartNum();
        that.switchSelect();
      }, function () {
        item.cart_num = Number(item.cart_num) + 1;
      });
    }
  }), (0, _defineProperty2.default)(_methods, "addCart", function addCart(index) {
    var that = this;
    if (this.adding) return;
    var item = that.cartList.valid[index];
    item.cart_num = Number(item.cart_num) + 1;
    var productInfo = item.productInfo;
    if (productInfo.hasOwnProperty('attrInfo') && item.cart_num >= item.productInfo.attrInfo.stock) {
      item.cart_num = item.productInfo.attrInfo.stock;
      item.numAdd = true;
      item.numSub = false;
    } else {
      item.numAdd = false;
      item.numSub = false;
    }
    that.setCartNum(item.id, item.cart_num, function (data) {
      that.cartList.valid[index] = item;
      that.getCartNum();
      that.switchSelect();
    }, function () {
      item.cart_num = Number(item.cart_num) - 1;
    });
  }), (0, _defineProperty2.default)(_methods, "setCartNum", function setCartNum(cartId, cartNum, successCallback, errorCallback) {
    var that = this;
    (0, _order.changeCartNum)(cartId, cartNum).then(function (res) {
      successCallback && successCallback(res.data);
    }).catch(function (err) {
      errorCallback && errorCallback();
      return that.$util.Tips({
        title: err
      });
    });
  }), (0, _defineProperty2.default)(_methods, "getCartNum", function getCartNum() {
    var _this = this;
    var that = this;
    (0, _order.getCartCounts)().then(function (res) {
      that.cartCount = res.data.count;
      _this.adding = false;
      _this.$store.commit('indexData/setCartNum', res.data.count > 99 ? '..' : res.data.count);
      if (res.data.count > 0) {
        wx.setTabBarBadge({
          index: 2,
          text: res.data.count + ''
        });
      } else {
        wx.hideTabBarRedDot({
          index: 2
        });
      }
    });
  }), (0, _defineProperty2.default)(_methods, "getCartData", function getCartData(data) {
    var _this2 = this;
    return new Promise(function (resolve, reject) {
      (0, _order.getCartList)(data).then(function (res) {
        resolve(res.data);
      }).catch(function (err) {
        _this2.loading = false;
        _this2.canShow = true;
        _this2.$util.Tips({
          title: err
        });
      });
    });
  }), (0, _defineProperty2.default)(_methods, "getCartList", function getCartList(init) {
    var _this3 = this;
    return (0, _asyncToGenerator2.default)( /*#__PURE__*/_regenerator.default.mark(function _callee2() {
      var that, data;
      return _regenerator.default.wrap(function _callee2$(_context2) {
        while (1) {
          switch (_context2.prev = _context2.next) {
            case 0:
              uni.showLoading({
                title: _this3.$t("\u52A0\u8F7D\u4E2D"),
                mask: true
              });
              that = _this3;
              data = {
                page: that.page,
                limit: that.limit,
                status: 1
              };
              (0, _order.getCartCounts)().then( /*#__PURE__*/function () {
                var _ref = (0, _asyncToGenerator2.default)( /*#__PURE__*/_regenerator.default.mark(function _callee(c) {
                  var i, cartList, valid, validList, numSub, numAdd, selectValue, index, productInfo, newArr;
                  return _regenerator.default.wrap(function _callee$(_context) {
                    while (1) {
                      switch (_context.prev = _context.next) {
                        case 0:
                          that.cartCount = c.data.count;
                          if (init) {
                            _this3.adding = false;
                            _this3.$store.commit('indexData/setCartNum', c.data.count > 99 ? '..' : c.data.count);
                            if (c.data.count > 0) {
                              wx.setTabBarBadge({
                                index: 2,
                                text: c.data.count + ''
                              });
                            } else {
                              wx.hideTabBarRedDot({
                                index: 2
                              });
                            }
                          }
                          i = 0;
                        case 3:
                          if (!(i < Math.ceil(c.data.ids.length / that.limit))) {
                            _context.next = 21;
                            break;
                          }
                          _context.next = 6;
                          return _this3.getCartData(data);
                        case 6:
                          cartList = _context.sent;
                          valid = cartList.valid;
                          validList = that.$util.SplitArray(valid, that.cartList.valid);
                          numSub = [{
                            numSub: true
                          }, {
                            numSub: false
                          }];
                          numAdd = [{
                            numAdd: true
                          }, {
                            numAdd: false
                          }], selectValue = [];
                          if (validList.length > 0) {
                            for (index in validList) {
                              if (validList[index].cart_num == 1) {
                                validList[index].numSub = true;
                              } else {
                                validList[index].numSub = false;
                              }
                              productInfo = validList[index].productInfo;
                              if (productInfo.hasOwnProperty('attrInfo') && validList[index].cart_num == validList[index].productInfo.attrInfo.stock) {
                                validList[index].numAdd = true;
                              } else if (validList[index].cart_num == validList[index].productInfo.stock) {
                                validList[index].numAdd = true;
                              } else {
                                validList[index].numAdd = false;
                              }
                              if (validList[index].attrStatus) {
                                validList[index].checked = true;
                                selectValue.push(validList[index].id);
                              } else {
                                validList[index].checked = false;
                              }
                            }
                          }
                          that.$set(that.cartList, 'valid', validList);
                          data.page = that.page + 1;
                          // that.goodsHidden = cartList.valid.length <= 0 ? false : true;
                          that.selectValue = selectValue;
                          newArr = validList.filter(function (item) {
                            return item.attrStatus;
                          });
                          that.isAllSelect = newArr.length == selectValue.length && newArr.length;
                          that.switchSelect();
                        case 18:
                          i++;
                          _context.next = 3;
                          break;
                        case 21:
                          that.loading = false;
                          _this3.canShow = true;
                          uni.hideLoading();
                        case 24:
                        case "end":
                          return _context.stop();
                      }
                    }
                  }, _callee);
                }));
                return function (_x) {
                  return _ref.apply(this, arguments);
                };
              }());
            case 4:
            case "end":
              return _context2.stop();
          }
        }
      }, _callee2);
    }))();
  }), (0, _defineProperty2.default)(_methods, "getInvalidList", function getInvalidList() {
    var that = this;
    if (this.loadendInvalid) return false;
    if (this.loadingInvalid) return false;
    var data = {
      page: that.pageInvalid,
      limit: that.limitInvalid,
      status: 0
    };
    (0, _order.getCartList)(data).then(function (res) {
      var cartList = res.data,
        invalid = cartList.invalid,
        loadendInvalid = invalid.length < that.limitInvalid;
      var invalidList = that.$util.SplitArray(invalid, that.cartList.invalid);
      that.$set(that.cartList, 'invalid', invalidList);
      that.loadendInvalid = loadendInvalid;
      that.loadTitleInvalid = loadendInvalid ? that.$t("\u6211\u4E5F\u662F\u6709\u5E95\u7EBF\u7684") : that.$t("\u52A0\u8F7D\u66F4\u591A");
      that.pageInvalid = that.pageInvalid + 1;
      that.loadingInvalid = false;
    }).catch(function (res) {
      that.loadingInvalid = false;
      that.loadTitleInvalid = that.$t("\u52A0\u8F7D\u66F4\u591A");
    });
  }), (0, _defineProperty2.default)(_methods, "getHostProduct", function getHostProduct() {
    var that = this;
    if (that.hotScroll) return;
    (0, _store.getProductHot)(that.hotPage, that.hotLimit).then(function (res) {
      that.hotPage++;
      that.hotScroll = res.data.length < that.hotLimit;
      that.hostProduct = that.hostProduct.concat(res.data);
    });
  }), (0, _defineProperty2.default)(_methods, "goodsOpen", function goodsOpen() {
    var that = this;
    that.goodsHidden = !that.goodsHidden;
  }), (0, _defineProperty2.default)(_methods, "goRouter", function goRouter(item) {
    var pages = getCurrentPages();
    var page = pages[pages.length - 1].$page.fullPath;
    if (item.link == page) return;
    uni.switchTab({
      url: item.link,
      fail: function fail(err) {
        uni.redirectTo({
          url: item.link
        });
      }
    });
  }), (0, _defineProperty2.default)(_methods, "manage", function manage() {
    var that = this;
    that.footerswitch = !that.footerswitch;
    var arr1 = [];
    var arr2 = [];
    var newValid = that.cartList.valid.map(function (item) {
      if (that.footerswitch) {
        if (item.attrStatus) {
          if (item.checked) {
            arr1.push(item.id);
          }
        } else {
          item.checked = false;
          arr2.push(item);
        }
      } else {
        if (item.checked) {
          arr1.push(item.id);
        }
      }
      return item;
    });
    that.cartList.valid = newValid;
    if (that.footerswitch) {
      that.isAllSelect = newValid.length === arr1.length + arr2.length;
    } else {
      that.isAllSelect = newValid.length === arr1.length;
    }
    that.selectValue = arr1;
    that.switchSelect();
  }), (0, _defineProperty2.default)(_methods, "unsetCart", function unsetCart() {
    var that = this,
      ids = [];
    for (var i = 0, len = that.cartList.invalid.length; i < len; i++) {
      ids.push(that.cartList.invalid[i].id);
    }
    (0, _order.cartDel)(ids).then(function (res) {
      that.$util.Tips({
        title: that.$t("\u6E05\u9664\u6210\u529F")
      });
      that.$set(that.cartList, 'invalid', []);
      that.getCartNum();
    }).catch(function (res) {});
  }), _methods),
  onReachBottom: function onReachBottom() {
    var that = this;
    if (that.loadend) {
      that.getInvalidList();
    }
    if (that.cartList.valid.length == 0 && that.cartList.invalid.length == 0) {
      that.getHostProduct();
    }
  },
  // 滚动监听
  onPageScroll: function onPageScroll(e) {
    // 传入scrollTop值并触发所有easy-loadimage组件下的滚动监听事件
    uni.$emit('scroll');
  }
};
exports.default = _default;
/* WEBPACK VAR INJECTION */}.call(this, __webpack_require__(/*! ./node_modules/@dcloudio/uni-mp-weixin/dist/index.js */ 2)["default"], __webpack_require__(/*! ./node_modules/@dcloudio/uni-mp-weixin/dist/wx.js */ 1)["default"]))

/***/ }),

/***/ 93:
/*!*************************************************************************************************************************************!*\
  !*** D:/practice-project/中臻电商/中臻电商/pages/order_addcart/order_addcart.vue?vue&type=style&index=0&id=a5aa7f30&scoped=true&lang=scss& ***!
  \*************************************************************************************************************************************/
/*! no static exports found */
/***/ (function(module, __webpack_exports__, __webpack_require__) {

"use strict";
__webpack_require__.r(__webpack_exports__);
/* harmony import */ var _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_mini_css_extract_plugin_dist_loader_js_ref_8_oneOf_1_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_css_loader_dist_cjs_js_ref_8_oneOf_1_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_stylePostLoader_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_2_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_postcss_loader_src_index_js_ref_8_oneOf_1_3_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_sass_loader_dist_cjs_js_ref_8_oneOf_1_4_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_5_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_style_index_0_id_a5aa7f30_scoped_true_lang_scss___WEBPACK_IMPORTED_MODULE_0__ = __webpack_require__(/*! -!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/mini-css-extract-plugin/dist/loader.js??ref--8-oneOf-1-0!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/css-loader/dist/cjs.js??ref--8-oneOf-1-1!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib/loaders/stylePostLoader.js!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--8-oneOf-1-2!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/postcss-loader/src??ref--8-oneOf-1-3!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/sass-loader/dist/cjs.js??ref--8-oneOf-1-4!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--8-oneOf-1-5!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib??vue-loader-options!../../../../../HbuilderX/HBuilderX/plugins/uniapp-cli/node_modules/@dcloudio/webpack-uni-mp-loader/lib/style.js!./order_addcart.vue?vue&type=style&index=0&id=a5aa7f30&scoped=true&lang=scss& */ 94);
/* harmony import */ var _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_mini_css_extract_plugin_dist_loader_js_ref_8_oneOf_1_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_css_loader_dist_cjs_js_ref_8_oneOf_1_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_stylePostLoader_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_2_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_postcss_loader_src_index_js_ref_8_oneOf_1_3_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_sass_loader_dist_cjs_js_ref_8_oneOf_1_4_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_5_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_style_index_0_id_a5aa7f30_scoped_true_lang_scss___WEBPACK_IMPORTED_MODULE_0___default = /*#__PURE__*/__webpack_require__.n(_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_mini_css_extract_plugin_dist_loader_js_ref_8_oneOf_1_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_css_loader_dist_cjs_js_ref_8_oneOf_1_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_stylePostLoader_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_2_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_postcss_loader_src_index_js_ref_8_oneOf_1_3_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_sass_loader_dist_cjs_js_ref_8_oneOf_1_4_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_5_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_style_index_0_id_a5aa7f30_scoped_true_lang_scss___WEBPACK_IMPORTED_MODULE_0__);
/* harmony reexport (unknown) */ for(var __WEBPACK_IMPORT_KEY__ in _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_mini_css_extract_plugin_dist_loader_js_ref_8_oneOf_1_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_css_loader_dist_cjs_js_ref_8_oneOf_1_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_stylePostLoader_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_2_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_postcss_loader_src_index_js_ref_8_oneOf_1_3_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_sass_loader_dist_cjs_js_ref_8_oneOf_1_4_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_5_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_style_index_0_id_a5aa7f30_scoped_true_lang_scss___WEBPACK_IMPORTED_MODULE_0__) if(["default"].indexOf(__WEBPACK_IMPORT_KEY__) < 0) (function(key) { __webpack_require__.d(__webpack_exports__, key, function() { return _HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_mini_css_extract_plugin_dist_loader_js_ref_8_oneOf_1_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_css_loader_dist_cjs_js_ref_8_oneOf_1_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_stylePostLoader_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_2_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_postcss_loader_src_index_js_ref_8_oneOf_1_3_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_sass_loader_dist_cjs_js_ref_8_oneOf_1_4_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_5_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_style_index_0_id_a5aa7f30_scoped_true_lang_scss___WEBPACK_IMPORTED_MODULE_0__[key]; }) }(__WEBPACK_IMPORT_KEY__));
 /* harmony default export */ __webpack_exports__["default"] = (_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_mini_css_extract_plugin_dist_loader_js_ref_8_oneOf_1_0_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_css_loader_dist_cjs_js_ref_8_oneOf_1_1_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_loaders_stylePostLoader_js_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_2_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_postcss_loader_src_index_js_ref_8_oneOf_1_3_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_sass_loader_dist_cjs_js_ref_8_oneOf_1_4_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_webpack_preprocess_loader_index_js_ref_8_oneOf_1_5_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_vue_cli_plugin_uni_packages_vue_loader_lib_index_js_vue_loader_options_HbuilderX_HBuilderX_plugins_uniapp_cli_node_modules_dcloudio_webpack_uni_mp_loader_lib_style_js_order_addcart_vue_vue_type_style_index_0_id_a5aa7f30_scoped_true_lang_scss___WEBPACK_IMPORTED_MODULE_0___default.a); 

/***/ }),

/***/ 94:
/*!*****************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************!*\
  !*** ./node_modules/mini-css-extract-plugin/dist/loader.js??ref--8-oneOf-1-0!./node_modules/css-loader/dist/cjs.js??ref--8-oneOf-1-1!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib/loaders/stylePostLoader.js!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--8-oneOf-1-2!./node_modules/postcss-loader/src??ref--8-oneOf-1-3!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/sass-loader/dist/cjs.js??ref--8-oneOf-1-4!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/webpack-preprocess-loader??ref--8-oneOf-1-5!./node_modules/@dcloudio/vue-cli-plugin-uni/packages/vue-loader/lib??vue-loader-options!./node_modules/@dcloudio/webpack-uni-mp-loader/lib/style.js!D:/practice-project/中臻电商/中臻电商/pages/order_addcart/order_addcart.vue?vue&type=style&index=0&id=a5aa7f30&scoped=true&lang=scss& ***!
  \*****************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************************/
/*! no static exports found */
/***/ (function(module, exports, __webpack_require__) {

// extracted by mini-css-extract-plugin
    if(false) { var cssReload; }
  

/***/ })

},[[85,"common/runtime","common/vendor"]]]);
//# sourceMappingURL=../../../.sourcemap/mp-weixin/pages/order_addcart/order_addcart.js.map