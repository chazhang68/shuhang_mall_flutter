<template>
  <view>
    <view class="sys-head">
      <view class="sys-bar" :style="{height:sysHeight}"></view>
    </view>
    <form report-submit='true'>
      <view class='merchantsSettled'>
        <!--        导航栏-->
        <view class="position-relative flex justify-center align-center">
          <text class="my-account-title" style="color: #000000!important;">人工审核</text>
          <view class="position-absolute left-0 ml-3" @click="navigateBack">
            <uni-icons type="arrow-left" size="30" color="#000000"></uni-icons>
          </view>
        </view>
        <view class="card-title flex align-center">
          <view class="card-line"></view>
          <text class="card-txt">身份信息</text>
        </view>
        <view class='list mt-2'>
          <!--								<view @click="openpup" class="font-weight-bold font text-center" style="font-size: 17px;">人工审核身份信息</view>-->
          <view class="item">
            <view class="acea-row row-middle">
              <text class="item-name">{{ $t(`用户姓名`) }}</text>
              <input type="text" :placeholder="$t(`请输入姓名`)" v-model="merchantData.name"
                     @input="validateBtn" placeholder-class='placeholder'/>
            </view>
          </view>
          <view class="item">
            <view class="acea-row row-middle">
              <text class="item-name">{{ $t(`身份证号`) }}</text>
              <input type="idcard" :placeholder="$t(`请输入身份证号`)" v-model="merchantData.card_num"
                     @input="validateBtn" placeholder-class='placeholder'/>
            </view>
          </view>
          <view class="item">
            <view class="acea-row row-middle">
              <text class="item-name">{{ $t(`银行卡号`) }}</text>
              <input type="idcard" :placeholder="$t(`请输入银行卡号`)" v-model="merchantData.bank_code"
                     @input="validateBtn" placeholder-class='placeholder'/>
            </view>
          </view>
          <view class="item">
            <view class="acea-row row-middle">
              <text class="item-name">{{ $t(`预留手机号`) }}</text>
              <input type="number" :placeholder="$t(`请输入银行卡手机号`)" v-model="merchantData.phone"
                     @input="validateBtn" placeholder-class='placeholder'/>
            </view>
          </view>
          <view class="item no-border">
            <view class="flex align-center">
              <view class="card-line"></view>
              <text class="card-txt">上传证件材料</text>
            </view>
          </view>

        </view>
        <view class="list mt-2">
          <view class="item no-border" style="padding-top: 0!important;">
            <view class='acea-row row-middle'>
              <view class="upload">
                <Rboy-upload-sfz :obverse-url="sfz_formData.obverseUrl" :reverse-url="sfz_formData.reverseUrl"
                  @selectChange="sfz_chagne" @del="del_btn"></Rboy-upload-sfz>
                <!-- <view class='pictrue' v-for="(item,index) in images" :key="index"-->
                <!--       :data-index="index" @click="getPhotoClickIdx">-->
                <!--   <image :src='item'></image>-->
                <!--   <text class='iconfont icon-guanbi1' @click.stop='DelPic(index)'></text>-->
                <!-- </view>-->
                <!-- <view class='pictrue acea-row row-center-wrapper row-column' @click='uploadpic'-->
                <!--       v-if="images.length < 10">-->
                <!--   <text class='iconfont icon-icon25201'></text>-->
                <!--   <view>{{ $t(`上传图片`) }}</view>-->
                <!-- </view>-->
              </view>
            </view>
          </view>
          <button class='submitBtn' :class="isAgree === true ? 'on':''"
                  @click="formSubmit">{{ $t(`确认`) }}
          </button>
        </view>
      </view>


    </form>
  </view>
</template>
<script>
import {
  toLogin
} from '@/libs/login.js';
import {
  createRealName
} from '@/api/store.js';

const app = getApp();
let sysHeight = uni.getSystemInfoSync().statusBarHeight + 'px';

import RboyUploadSfz from "@/components/Rboy-upload-sfz/Rboy-upload-sfz.vue"

export default {
  components: {
    RboyUploadSfz,
  },
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
        bank_code: '',
        images: []
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
      type: '',
      // 身份证表单
      sfz_formData: {
        // 正面
        obverseUrl: "",
        // 反面
        reverseUrl: "",
      },
    };
  },


  onLoad(options) {

  },
  onShow() {

  },
  methods: {
    navigateBack() {
      uni.navigateBack()
    },
    sfz_chagne(e) {
      if (e.name == "obverse") {
        this.sfz_formData.obverseUrl = e.tempFilePath
      } else if (e.name == "reverse") {
        this.sfz_formData.reverseUrl = e.tempFilePath
      }
    },
// 删除
    del_btn(e) {
      if (e.name == "obverse") {
        this.sfz_formData.obverseUrl = ""
      } else if (e.name == "reverse") {
        this.sfz_formData.reverseUrl = ""
      }
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

    formSubmit: function (e) {
      let that = this;
      if (!that.sfz_formData.obverseUrl) {
        return that.$util.Tips({
          title: '请上传身份证正面'
        });
      }
      if (!that.sfz_formData.reverseUrl) {
        return that.$util.Tips({
          title: '请上传身份证反面'
        });
      }
      if (that.validateForm() && that.validate) {
        let requestData = {
          uid: this.$store.state.app.uid,
          phone: that.merchantData.phone,
          card_num: that.merchantData.card_num,
          name: that.merchantData.name,
          bank_code: that.merchantData.bank_code,
          // code: that.merchantData.code,
          images: that.sfz_formData,
          id: this.sid,
          type: 2
        }
        uni.showLoading({
          title: "数据提交中"
        })
        createRealName(requestData).then(data => {
          uni.hideLoading()
          uni.showToast({
            title: '提交成功',
          })
          setTimeout(() => {
            uni.navigateBack()
          }, 800)
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
      if (value.card_num && value.name && value.bank_code && value.phone) {
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
      if (!value.bank_code) return that.$util.Tips({
        title: that.$t(`填写银行卡号`)
      });
      if (!value.phone) return that.$util.Tips({
        title: that.$t(`填写银行预留手机号`)
      });

      that.validate = true;
      return true;
    },


  }
}
</script>

<style scoped lang="scss">
/deep/ .uni-popup .uni-popup__wrapper {
  border-radius: 10px !important;
}

.uni-input-placeholder {
  color: #B2B2B2;
}

.item-name {
  width: 190rpx;
}

.card-title {
  background-color: white;
  border-radius: 15px 15px 0 0;
  padding: 20px;
  height: 100rpx;
  margin-top: 50rpx;


}

.card-line {
  width: 12rpx;
  height: 32rpx;
  background: #FF5A5A;
  margin-right: 22rpx;
}

.card-txt {
  font-weight: 500;
  font-size: 30rpx;
  color: #222222;
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
  //border-radius: 12px;
  padding-bottom: 22px;
  //position: absolute;
  //top: 40rpx;
  // margin-top: -160px;
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
