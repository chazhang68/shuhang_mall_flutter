<template>
  <view v-if="status == -1 && !inloading">

    <view class="sys-head">
      <view class="sys-bar" :style="{height:sysHeight}"></view>
    </view>
    <form report-submit='true'>
      <view class='merchantsSettled'>
        <!--        导航栏-->
        <view class="mx-3 flex justify-between align-center">
          <view @click="navigateBack">
            <uni-icons type="arrow-left" size="30" color="#000000"></uni-icons>
          </view>
          <text class="my-account-title" style="color: #000000!important;">实名认证</text>
<!--          人工审核 title-->
          <view class="manually-review" @click="rengSign">
            <text></text>
          </view>
        </view>

        <view class='list'>
<!--          <view @click="openpup" class="font-weight-bold font text-center" style="font-size: 17px;">身份信息实名校验-->
<!--          </view>-->
          <view class="item">
            <view class="acea-row row-middle">
              <!-- <i class="icon iconfont icon-yonghu3"></i> -->
              <text class="item-name">{{ $t(`用户姓名`) }}</text>
              <input type="text" :placeholder="$t(`请输入姓名`)" v-model="merchantData.name"
                     @input="validateBtn" placeholder-class='placeholder'/>
            </view>
          </view>

          <view class="item">
            <view class="acea-row row-middle">
              <!-- <i class="icon iconfont icon-shoujihao"></i> -->
              <text class="item-name">{{ $t(`身份证号`) }}</text>
              <input type="idcard" :placeholder="$t(`请输入身份证号`)" v-model="merchantData.card_num"
                     @input="validateBtn" placeholder-class='placeholder'/>
            </view>
          </view>
          <view class="item">
            <view class="acea-row row-middle">
              <!-- <i class="icon iconfont icon-shoujihao"></i> -->
              <text class="item-name">{{ $t(`手机号`) }}</text>
              <input type="number" :placeholder="$t(`请输入正确的手机号`)" v-model="merchantData.phone"
                     @input="validateBtn" placeholder-class='placeholder'/>
            </view>
          </view>
          <!-- 						<view class="item no-border">
                        <view class='acea-row row-middle'>
                          <text class="item-title">{{$t(`请上传身份证图片`)}}</text>
                          <text class="item-desc">({{$t(`图片最多可上传10张,图片格式支持JPG、PNG、JPEG`)}})</text>
                          <view class="upload">
                            <view class='pictrue' v-for="(item,index) in images" :key="index"
                              :data-index="index" @click="getPhotoClickIdx">
                              <image :src='item'></image>
                              <text class='iconfont icon-guanbi1' @click.stop='DelPic(index)'></text>
                            </view>
                            <view class='pictrue acea-row row-center-wrapper row-column' @click='uploadpic'
                              v-if="images.length < 10">
                              <text class='iconfont icon-icon25201'></text>
                              <view>{{$t(`上传图片`)}}</view>
                            </view>
                          </view>
                        </view>
                      </view> -->


          <button class='submitBtn' :class="isAgree === true ? 'on':''"
                  @click="formSubmit">{{ $t(`提交认证`) }}
          </button>
<!--          <view @click="rengSign" class="text-center p-3 text-danger" style="text-decoration: underline;">人工审核-->
<!--          </view>-->
        </view>
      </view>

    </form>

    <view class='loadingicon acea-row row-center-wrapper' v-if="loading">
      <text class='loading iconfont icon-jiazai' :hidden='loading==false'></text>
    </view>
    <!-- #ifdef MP -->
    <authorize @onLoadFun="onLoadFun" :isAuto="isAuto" :isShowAuth="isShowAuth" @authColse="authColse"></authorize>
    <!-- #endif -->
    <Verify @success="success" :captchaType="'blockPuzzle'" :imgSize="{ width: '330px', height: '155px' }"
            ref="verify"></Verify>
    <view>
      <!-- 普通弹窗 -->
      <uni-popup ref="popup" background-color="#fff">
        <view class="popup-content rounded position-relative flex flex-column align-center"
              style="width: 200px;height: 165px;border-radius: 8px;">
          <image src="/static/mall/sign.png" class="position-absolute"
                 style="width: 65px;height: 65px;top: -11px;left:70px"></image>
          <view class="font-weight-bolder font text-center" style="padding-top: 60px;">实名认证成功</view>
          <view class="flex align-center justify-center rounded-circle text-white"
                style="width: 150px;height: 40px;background-color: #E93323;margin-top: 20px;" @click="gotask">去签到完成任务
          </view>
        </view>
      </uni-popup>
    </view>
  </view>


  <view class="settledSuccessMain" v-else-if='status == 0'>
    <view class="settledSuccessful">
      <image class="image" src="../../pages/annex/static/success.png" alt="">
        <view class="title">{{ $t(`您的认证申请提交成功！`) }}</view>
        <view class="goHome" hover-class="none" @click="goHome">
          {{ $t(`返回首页`) }}
        </view>
    </view>
  </view>
  <view class="settledSuccessMain" v-else-if='status == 1'>
    <view class="settledSuccessful">
      <image class="image" src="../../pages/annex/static/success.png" alt="">
        <view class="title">{{ $t(`恭喜，您已通过实名认证！`) }}</view>
        <view class="goHome" hover-class="none" @click="goHome">
          {{ $t(`返回首页`) }}
        </view>
    </view>
  </view>
  <view class="settledSuccessMain" v-else-if='status == 2'>
    <view class="settledSuccessful">
      <image class="image" src="../../pages/annex/static/error.png" alt="">
        <view class="title">{{ $t(`您的实名认证未通过！`) }}</view>
        <view class="info" v-if="refusal_reason">{{ refusal_reason }}</view>
        <view class="again" hover-class="none" @click="applyAgain">
          {{ $t(`重新申请`) }}
        </view>
        <view class="goHome" hover-class="none" @click="goHome">
          {{ $t(`返回首页`) }}
        </view>
    </view>

  </view>
</template>
<script>
import {
  toLogin
} from '@/libs/login.js';
import {
  createRealName,
  checkFaced,
  getCodeApi,
  registerVerify,
  getRealDetails,
  updateGoodsRecord,
} from '@/api/store.js';
import {
  getCaptcha
} from "@/api/user";
import {
  mapGetters
} from "vuex";
import parser from "@/components/jyf-parser/jyf-parser";
// #ifdef MP
import authorize from '@/components/Authorize';
// #endif
import colors from "@/mixins/color";
import Verify from "../../pages/annex/components/verify/verify.vue";
import sendVerifyCode from "@/mixins/SendVerifyCode";

const app = getApp();
let sysHeight = uni.getSystemInfoSync().statusBarHeight + 'px';

export default {
  components: {
    Verify,
    "jyf-parser": parser,
    // #ifdef MP
    authorize,
    // #endif
  },
  mixins: [sendVerifyCode, colors],
  data() {
    return {
      sysHeight: sysHeight,
      inloading: true,
      status: -1,
      isAuto: false, //没有授权的不会自动授权
      isShowAuth: false, //是否隐藏授权
      text: this.$t(`获取验证码`),
      codeUrl: "",
      disabled: false,
      isAgree: true,
      showProtocol: false,
      isShowCode: false,
      loading: false,
      merchantData: {
        name: "",
        phone: "",
        card_num: '',
        bank_code: ''
      },
      validate: false,
      successful: false,
      keyCode: "",
      codeVal: "",
      protocol: app.globalData.sys_intention_agree,
      timer: "",
      index: 0,
      index1: 0,
      mer_classification: "",
      mer_storeType: '',
      images: [],
      tagStyle: {
        img: 'width:100%;display:block;',
        table: 'width:100%',
        video: 'width:100%'
      },
      mer_i_id: null, // 代理商申请id
      isType: false,
      id: 0,
      sid: 0,
      refusal_reason: "",
      keyCode: '',
      type: ''
    };
  },
  beforeDestroy() {
    clearTimeout(this.timer)
  },
  computed: mapGetters(['isLogin']),
  onLoad(options) {
    // let url = 'alipays://platformapi/startapp?appId=20000067&url=https%3A%2F%2Fcustweb.alipay.com%2Fcertify%2Fopen%2Fpersonal%2Fdispatch%2F%3Falipay_exterface_invoke_assign_target%3Dinvoke_8780ed14de75f230bd6514ffb07bbdd4%26alipay_exterface_invoke_assign_sign%3D_vt_l_c_p%252F_mqq_r_sn_opd_gepj_uj_ny_u8lm_ciuzgp%252Bl_t_zko8ne_c2_dlv_lur%252F_x7w%253D%253D&closeCurrentWindow=YES&startMultApp=YES&appClearTop=false&launchKey=a34581eb-e6e4-43b2-909f-7db2b03f5b40-1712739732138&launchKey=9565dec0-5575-49a4-9726-a3fe9d3f0378-1712739839074'

    // plus.runtime.openURL(url);return;
    if (this.isLogin) {
      this.$nextTick(function () {
        this.getGoodsDetails()
      })
    } else {
      // #ifdef H5 || APP-PLUS
      toLogin();
      // #endif
      // #ifdef MP
      this.isAuto = true;
      this.$set(this, 'isShowAuth', true)
      // #endif
    }
    if (options.id) {
      this.id = id
      uni.showLoading({
        title: this.$t(`正在加载中`),
      });
    }
  },
  onShow() {
    this.$nextTick(function () {
      this.getGoodsDetails()
    })
  },
  methods: {
    navigateBack(){
      uni.navigateBack()
    },

    rengSign() {
      uni.navigateTo({
        url: "/pages/rg_sign/rg_sign"
      })
    },
    gotask() {
      uni.switchTab({
        url: '/pages/task/task'
      })
    },
    openpup() {

    },
    code() {
      let that = this
      if (!that.merchantData.phone) return that.$util.Tips({
        title: that.$t(`请填写手机号码`)
      });
      if (!/^1(3|4|5|7|8|9|6)\d{9}$/i.test(that.merchantData.phone)) return that.$util.Tips({
        title: that.$t(`请输入正确的手机号码`)
      });
      this.$refs.verify.show()
    },

    success(data) {
      this.$refs.verify.hide()
      getCodeApi()
          .then(res => {
            this.keyCode = res.data.key;
            this.getCode(data);
          })
          .catch(res => {
            this.$util.Tips({
              title: res
            });
          });
    },
    async getCode(data) {
      let that = this;
      await registerVerify({
        phone: that.merchantData.phone,
        type: that.type,
        key: that.keyCode,
        captchaType: 'blockPuzzle',
        captchaVerification: data.captchaVerification
      })
          .then(res => {
            this.sendCode()
            that.$util.Tips({
              title: res.msg
            });
          })
          .catch(res => {
            that.$util.Tips({
              title: res
            });
          });
    },
    // 获取历史提交数据详情
    getGoodsDetails() {
      getRealDetails().then(res => {
        this.status = res.data.status
        let resData = res.data
        this.sid = res.data.id
        if (res.data.status !== -1) {
          let arr = Object.keys(this.merchantData)
          arr.map(item => {
            this.merchantData[item] = resData[item]
          })
          uni.hideLoading();
        }
        if (this.status === 2) {
          this.refusal_reason = resData.refusal_reason
        }
        this.inloading = false
      })
    },

    // 图片预览
    // 获得相册 idx
    getPhotoClickIdx(e) {
      let _this = this;
      let idx = e.currentTarget.dataset.index;
      _this.imgPreview(_this.images, idx);
    },
    // 图片预览
    imgPreview: function (list, idx) {
      // list：图片 url 数组
      if (list && list.length > 0) {
        uni.previewImage({
          current: list[idx], //  传 Number H5端出现不兼容
          urls: list
        });
      }
    },
    // 授权回调
    onLoadFun: function () {
      this.isShowAuth = false;
    },
    // 授权关闭
    authColse: function (e) {
      this.isShowAuth = e
    },
    toggleTab(str) {
      this.$refs[str].show();
    },
    // 首页
    goHome() {
      uni.switchTab({
        url: '/pages/user/index'
      });
    },
    applyAgain() {
      this.status = -1
      this.merchantData = {
        name: "",
        phone: "",
        card_num: '',
        bank_code: ''
      }
    },
    /**
     * 上传文件
     *
     */
    uploadpic: function () {
      let that = this;
      that.$util.uploadImageOne('upload/image', (res) => {
        this.images.push(res.data.url);
        that.$set(that, 'images', that.images);
      });

    },
    /**
     * 删除图片
     *
     */
    DelPic: function (index) {
      let that = this,
          pic = this.images[index];
      that.images.splice(index, 1);
      that.$set(that, 'images', that.images);
    },

    getcaptcha() {
      let that = this
      getCaptcha().then(data => {
        that.codeUrl = data.data.captcha; //图片路径
        that.codeVal = data.data.code; //图片验证码
        that.codeKey = data.data.key //图片验证码key
      })
      that.isShowCode = true;
    },
    sendCode() {
      if (this.disabled) return;
      this.disabled = true;
      let n = 60;
      this.text = n + "s";
      const run = setInterval(() => {
        n = n - 1;
        if (n < 0) {
          clearInterval(run);
        }
        this.text = n + "s";
        if (this.text < 0 + "s") {
          this.disabled = false;
          this.text = this.$t(`重新获取`);
        }
      }, 1000);
    },
    onConfirm(val) {
      this.region = val.checkArr[0] + '-' + val.checkArr[1] + '-' + val.checkArr[2];
    },


    formSubmit: function (e) {
      let that = this;
      if (that.validateForm() && that.validate) {
        let requestData = {
          uid: this.$store.state.app.uid,
          phone: that.merchantData.phone,
          card_num: that.merchantData.card_num,
          name: that.merchantData.name,
          // code: that.merchantData.code,
          //images: that.images,
          id: this.sid
        }
        uni.showLoading({
          title: "数据提交中"
        })
        createRealName(requestData).then(data => {
          uni.hideLoading()
          // let url = 'alipays%3A%2F%2Fplatformapi%2Fstartapp%3FappId%3D20000067%26url%3Dhttps%253A%252F%252Fcustweb.alipay.com%252Fcertify%252Fopen%252Fpersonal%252Fdispatch%252F%253Falipay_exterface_invoke_assign_target%253Dinvoke_8780ed14de75f230bd6514ffb07bbdd4%2526alipay_exterface_invoke_assign_sign%253D_vt_l_c_p%25252F_mqq_r_sn_opd_gepj_uj_ny_u8lm_ciuzgp%25252Bl_t_zko8ne_c2_dlv_lur%25252F_x7w%25253D%25253D%26closeCurrentWindow%3DYES%26startMultApp%3DYES%26appClearTop%3Dfalse%26launchKey%3Da34581eb-e6e4-43b2-909f-7db2b03f5b40-1712739732138%26launchKey%3D9565dec0-5575-49a4-9726-a3fe9d3f0378-1712739839074'

          // plus.runtime.openURL(url);
          that.$refs.popup.open()


        }).catch(res => {
          that.$util.Tips({
            title: res
          });
        })

      }


    },
    validateBtn: function () {
      let that = this,
          value = that.merchantData;
      if (value.card_num && value.name && value.phone) {
        if (!that.isShowCode) {
          that.validate = true;
        } else {
          if (that.codeVal) {
            that.validate = true;
          } else {
            that.validate = false;
          }
        }

      }
    },

    validateForm: function () {
      let that = this,
          value = that.merchantData;

      if (!value.name) return that.$util.Tips({
        title: that.$t(`请输入姓名`)
      });
      if (!value.card_num) return that.$util.Tips({
        title: that.$t(`填写身份证号码`)
      });
      if (!value.phone) return that.$util.Tips({
        title: that.$t(`填写手机号`)
      });

      that.validate = true;
      return true;
    },
    jumpToList() {
      uni.navigateTo({
        url: "/pages/store/applicationRecord/index"
      })
    },

  }
}
</script>

<style scoped lang="scss">
/deep/ .uni-popup .uni-popup__wrapper {
  border-radius: 10px !important;
}

.manually-review {
  border-radius: 50rpx;
  padding: 10rpx;

  & text {
    font-size: 14px;
    padding-bottom: 2px;
    border-bottom: 1px solid #e93323;
    font-weight: 400;
    color: #FF5A5A;
  }
}

.uni-input-placeholder {
  color: #B2B2B2;
}

.item-name {
  width: 190rpx;
}

.uni-list-cell {
  position: relative;

  .iconfont {
    font-size: 14px;
    color: #7a7a7a;
    position: absolute;
    right: 15px;
    top: 7rpx;
  }

  .icon-guanbi2 {
    right: 35px;
  }
}

.merchantsSettled {
  //background: linear-gradient(#fd3d1d 0%, #fd151b 100%);

}

.merchantsSettled .merchantBg {
  width: 750rpx;
  width: 100%;
}

.merchantsSettled .list {
  background-color: #fff;
  border-radius: 12px;
  padding-bottom: 22px;
  margin: 15px 15px;
  //position: absolute;
  //top: 60rpx;
  // margin-top: -160px;
  width: calc(100% - 30px);
}

.application-record {
  position: absolute;
  display: flex;
  align-items: center;
  top: 240rpx;
  right: 0;
  color: #fff;
  font-size: 22rpx;
  background-color: rgba(0, 0, 0, 0.3);
  padding: 8rpx 18rpx;
  border-radius: 20px 0px 0px 20px;
}

.merchantsSettled .list .item {
  padding: 50rpx 0 20rpx;
  border-bottom: 1rpx solid #eee;
  position: relative;
  margin: 0 20px;

  &.no-border {
    border-bottom: none;
    padding-left: 0;
    padding-right: 0;
  }

  .item-title {
    color: #666666;
    font-size: 28rpx;
    display: block;
  }

  .item-desc {
    color: #B2B2B2;
    font-size: 22rpx;
    display: block;
    margin-top: 9rpx;
    line-height: 36rpx;
  }
}

.acea-row,
.upload {
  display: -webkit-box;
  display: -moz-box;
  display: -webkit-flex;
  display: -ms-flexbox;
  display: flex;
  -webkit-box-lines: multiple;
  -moz-box-lines: multiple;
  -o-box-lines: multiple;
  -webkit-flex-wrap: wrap;
  -ms-flex-wrap: wrap;
  flex-wrap: wrap;
}

.upload {
  margin-top: 20rpx;
}

.acea-row.row-middle {
  -webkit-box-align: center;
  -moz-box-align: center;
  -o-box-align: center;
  -ms-flex-align: center;
  -webkit-align-items: center;
  align-items: center;
  padding-left: 2px;
}

.acea-row.row-column {
  -webkit-box-orient: vertical;
  -moz-box-orient: vertical;
  -o-box-orient: vertical;
  -webkit-flex-direction: column;
  -ms-flex-direction: column;
  flex-direction: column;
}

.acea-row.row-center-wrapper {
  -webkit-box-align: center;
  -moz-box-align: center;
  -o-box-align: center;
  -ms-flex-align: center;
  -webkit-align-items: center;
  align-items: center;
  -webkit-box-pack: center;
  -moz-box-pack: center;
  -o-box-pack: center;
  -ms-flex-pack: center;
  -webkit-justify-content: center;
  justify-content: center;
}

.merchantsSettled .list .item .pictrue {
  width: 130rpx;
  height: 130rpx;
  margin: 24rpx 22rpx 0 0;
  position: relative;
  font-size: 11px;
  color: #bbb;

  &:nth-child(4n) {
    margin-right: 0;
  }

  &:nth-last-child(1) {
    border: 0.5px solid #ddd;
    box-sizing: border-box;
  }


  uni-image,
  image {
    width: 100%;
    height: 100%;
    border-radius: 1px;

    img {
      -webkit-touch-callout: none;
      -webkit-user-select: none;
      -moz-user-select: none;
      display: block;
      position: absolute;
      top: 0;
      left: 0;
      opacity: 0;
      width: 100%;
      height: 100%;
    }
  }

  .icon-guanbi1 {
    font-size: 33rpx;
    position: absolute;
    top: -10px;
    right: -10px;
  }
}

.uni-list-cell-db {
  position: relative;
}

.wenhao {
  width: 34rpx;
  height: 34rpx;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 28rpx;
  border-radius: 50%;
  background: #E3E3E3;
  color: #ffffff !important;
  margin-left: 4rpx;
  position: absolute;
  left: 122rpx;
}

.merchantsSettled .list .item .imageCode {
  position: absolute;
  top: 7px;
  right: 0;
}

.merchantsSettled .list .item .icon {
  font-size: 40rpx;
  color: #b4b1b4;
}

.merchantsSettled .list .item input {
  width: 400rpx;
  font-size: 30rpx;
  // margin-left: 30px;
}

.merchantsSettled .list .item .placeholder {
  color: #b2b2b2;
}

.merchantsSettled .default {
  padding: 0 30rpx;
  height: 90rpx;
  background-color: #fff;
  margin-top: 23rpx;
}

.merchantsSettled .default checkbox {
  margin-right: 15rpx;
}

.merchantsSettled .acea-row uni-image {
  width: 20px;
  height: 20px;
  display: block;
}

.merchantsSettled .list .item .codeIput {
  width: 125px;
}

.uni-input-input {
  display: block;
  height: 100%;
  background: none;
  color: inherit;
  opacity: 1;
  -webkit-text-fill-color: currentcolor;
  font: inherit;
  line-height: inherit;
  letter-spacing: inherit;
  text-align: inherit;
  text-indent: inherit;
  text-transform: inherit;
  text-shadow: inherit;
}

.merchantsSettled .list .item .code {
  position: absolute;
  width: 93px;
  line-height: 27px;
  border: 1px solid #E93323;
  border-radius: 15px;
  color: #E93323;
  text-align: center;
  bottom: 8px;
  right: 0;
  font-size: 12px;
}

.merchantsSettled .list .item .code.on {
  background-color: #bbb;
  color: #fff;
  border-color: #bbb;
}

.merchantsSettled .submitBtn {
  width: 588rpx;
  margin: 0 auto;
  height: 86rpx;
  border-radius: 25px;
  text-align: center;
  line-height: 86rpx;
  font-size: 15px;
  background: #E3E3E3;
  margin-top: 25px;
  font-weight: 400;
  color: #FFFFFF;
}

.merchantsSettled .submitBtn.on {
  background: #FF5A5A;
}

uni-checkbox-group,
.settleAgree {
  display: inline-block;
  font-size: 24rpx;
}

uni-checkbox-group {
  color: #b2b2b2;
}

.settleAgree {
  color: #E93323;
  position: relative;
  top: 2px;
  left: 8px;
}

.merchantsSettled uni-checkbox .uni-checkbox-wrapper {
  width: 30rpx;
  height: 30rpx;
  border: 2rpx solid #C3C3C3;
  border-radius: 15px;
}

.settlementAgreement {
  width: 100%;
  height: 100%;
  position: fixed;
  top: 0;
  left: 0;
  background: rgba(0, 0, 0, .5);
  z-index: 10;
}

.settlementAgreement .setAgCount {
  background: #fff;
  width: 656rpx;
  height: 458px;
  position: absolute;
  top: 50%;
  left: 50%;
  border-radius: 12rpx;
  -webkit-border-radius: 12rpx;
  padding: 52rpx;
  -webkit-transform: translate(-50%, -50%);
  -moz-transform: translate(-50%, -50%);
  transform: translate(-50%, -50%);
  overflow: hidden;

  .content {
    height: 900rpx;
    overflow-y: scroll;

    /deep/ p {
      font-size: 13px;
      line-height: 22px;
    }

    /deep/ img {
      max-width: 100%;
    }
  }
}

.settlementAgreement .setAgCount .icon {
  font-size: 42rpx;
  color: #b4b1b4;
  position: absolute;
  top: 15rpx;
  right: 15rpx;

}

.settlementAgreement .setAgCount .title {
  color: #333;
  font-size: 32rpx;
  text-align: center;
  font-weight: bold;
}

.settlementAgreement .setAgCount .content {
  margin-top: 32rpx;
  color: #333;
  font-size: 26rpx;
  line-height: 22px;
  text-align: justify;
  text-justify: distribute-all-lines;
  height: 756rpx;
  overflow-y: scroll;
}

.settledSuccessMain {
  height: 100vh;
  display: flex;
  flex-direction: column;
  background: #fff;
}

.settledSuccessful {
  flex: 1;
  width: 100%;
  padding: 0 56px;
  height: auto;
  background: #fff;
  text-align: center;
}

.settledSuccessful .image {
  width: 189px;
  height: 157px;
  margin-top: 66px;
}

.settledSuccessful .title {
  color: #333333;
  font-size: 16px;
  font-weight: bold;
  margin-top: 35px;
}

.settledSuccessful .info {
  color: #999;
  font-size: 26rpx;
  margin-top: 18rpx;
}

.settledSuccessful .goHome {
  margin: 20px auto 0;
  line-height: 43px;
  color: #282828;
  font-size: 15px;
  border: 1px solid #B4B4B4;
  border-radius: 60px;
}

.settledSuccessful .again {
  margin: 30px auto 0;
  line-height: 43px;
  color: #fff;
  font-size: 15px;
  background-color: #E93323;
  border-radius: 60px;
}

/deep/ uni-checkbox .uni-checkbox-input {
  width: 15px;
  height: 15px;
  position: relative;
}

/deep/ uni-checkbox .uni-checkbox-input.uni-checkbox-input-checked:before {
  font-size: 14px;
}

/deep/ uni-checkbox .uni-checkbox-input-checked {
  background-color: #fd151b !important;
}

.loadingicon {
  height: 100vh;
  overflow: hidden;
  position: absolute;
  top: 0;
  left: 0;
}

.icon-xiangyou {
  font-size: 22rpx;
}

// #ifdef MP
checkbox-group {
  display: inline-block;
}

// #endif
.setAgCount {
  /deep/ table {
    border: 1rpx solid #DDD;
    border-bottom: none;
    border-right: none;
  }

  /deep/ td,
  th {
    padding: 5rpx 10rpx;
    border-bottom: 1rpx solid #DDD;
    border-right: 1rpx solid #DDD;
  }
}
</style>
