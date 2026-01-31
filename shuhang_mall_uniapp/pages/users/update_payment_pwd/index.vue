<template>
  <view class="mt-5 mx-2">
    <form @submit="editPwd">
      <view class="phone">{{ $t(`当前手机号`) }}：{{ phone }}</view>
      <content-list class="p-3 mt-2" :is-icon="false">
        <template v-slot:leftTitle>
          <view style="width: 25%">
            <text>
              新支付密码
            </text>
          </view>
        </template>
        <template v-slot:center>
          <view class="input-pwd">
            <uni-easyinput maxlength="6" :placeholderStyle="inputStyle" :clearable="false" type="password" :input-border="false" v-model="new_password" placeholder="请输入新支付密码"></uni-easyinput>
          </view>
        </template>
      </content-list>

      <content-list style="margin-top: 1px" class="p-3" :is-icon="false">
        <template v-slot:leftTitle>
          <view style="width: 25%">
            <text>
              确认新支付密码
            </text>
          </view>
        </template>
        <template v-slot:center>
          <view class="input-pwd">
            <uni-easyinput maxlength="6" :placeholderStyle="inputStyle" :clearable="false" type="password" :input-border="false" v-model="enter_password" placeholder="请输入新支付密码"></uni-easyinput>
          </view>
        </template>
      </content-list>

      <content-list class="p-3 mt-2" :is-icon="false">
        <template v-slot:leftTitle>
          <view style="width: 25%">
            <text>
              验证码
            </text>
          </view>
        </template>
        <template v-slot:center>
          <view style="width: 53%" class="input-pwd">
            <input type="number" placeholder="请输入验证码" v-model="captcha">
          </view>
        </template>
        <template v-slot:rightTitle>
          <button style="width: 140rpx" class="code" :class="disabled === true ? 'on' : ''" :disabled='disabled'
                  @click="code">
            {{ text }}
          </button>
        </template>
      </content-list>
      <button form-type="submit" style="padding: 35rpx;margin-top: 75rpx" type="warn">保存</button>
    </form>
    <Verify @success="success" :captchaType="'blockPuzzle'" :imgSize="{ width: '330px', height: '155px' }"
            ref="verify"></Verify>
  </view>
</template>

<script>
import sendVerifyCode from "@/mixins/SendVerifyCode";
import {
  phoneRegisterReset,
  verifyCode, zhiFuRegisterReset
} from '@/api/api.js';
import {
  getUserInfo,
  registerVerify
} from '@/api/user.js';
import {
  toLogin
} from '@/libs/login.js';
import {
  mapGetters
} from "vuex";
// #ifdef MP
import authorize from '@/components/Authorize';
// #endif
import colors from '@/mixins/color.js';
import Verify from '../components/verify/index.vue';
import contentList from "../../../components/contentList/index.vue";

export default {
  mixins: [sendVerifyCode, colors],
  components: {
    contentList,
    // #ifdef MP
    authorize,
    // #endif
    Verify
  },
  data() {
    return {
      phone: '',
      userInfo: {},
      enter_password: '',
      captcha: '',
      new_password: '',
      isAuto: false, //没有授权的不会自动授权
      isShowAuth: false, //是否隐藏授权
      key: '',
      inputStyle: 'fontSize: 28rpx; color: grey'
    };
  },
  computed: mapGetters(['isLogin']),
  watch: {
    isLogin: {
      handler: function (newV, oldV) {
        if (newV) {
          this.getUserInfo();
        }
      },
      deep: true
    }
  },
  onLoad() {
    if (this.isLogin) {
      this.getUserInfo();
      verifyCode().then(res => {
        this.$set(this, 'key', res.data.key)
      });
    } else {
      toLogin()
    }
  },
  methods: {
    // 清除原密码
    clearOldPwd(){
      this.old_password = ""
    },
    /**
     * 授权回调
     */
    onLoadFun: function (e) {
      this.getUserInfo();
    },
    // 授权关闭
    authColse: function (e) {
      this.isShowAuth = e
    },
    /**
     * 获取个人用户信息
     */
    getUserInfo: function () {
      let that = this;
      getUserInfo().then(res => {
        let tel = res.data.phone;
        let phone = tel.substr(0, 3) + "****" + tel.substr(7);
        that.$set(that, 'userInfo', res.data);
        that.phone = phone;
      });
    },
    /**
     * 发送验证码
     *
     */
    async code() {
      let that = this;
      if (!that.userInfo.phone) return that.$util.Tips({
        title: that.$t(`手机号码不存在,无法发送验证码！`)
      });
      this.$refs.verify.show()

    },

    async success(data) {
      let that = this;
      this.$refs.verify.hide()
      await registerVerify({
        phone: that.userInfo.phone,
        type: 'reset',
        key: that.key,
        captchaType: 'blockPuzzle',
        captchaVerification: data.captchaVerification
      }).then(res => {
        this.sendCode()
        that.$util.Tips({
          title: res.msg
        });
      }).catch(err => {
        return that.$util.Tips({
          title: err
        });
      });
    },
    /**
     * H5登录 修改密码
     *
     */
    editPwd: function (e) {
      let that = this,
          new_password = this.new_password,
          enter_password = this.enter_password,
          captcha = this.captcha;
      if (!new_password) return that.$util.Tips({
        title: that.$t(`请输入新支付密码`)
      });
      if (!enter_password) return that.$util.Tips({
        title: that.$t(`请再次输入新支付密码`)
      });
      if (new_password != enter_password) return that.$util.Tips({
        title: that.$t(`两次输入的密码不一致！`)
      });
      if (!captcha) return that.$util.Tips({
        title: that.$t(`请输入验证码`)
      });
      zhiFuRegisterReset({
        account: that.userInfo.phone,
        captcha: captcha,
        password: new_password
      }).then(res => {
        return that.$util.Tips({
          title: res.msg
        }, {
          tab: 3,
          url: 1
        });
      }).catch(err => {
        return that.$util.Tips({
          title: err
        });
      });
    }
  }
}

</script>
<style scoped lang="scss">
.code {
  font-size: 29rpx;
  color: red;
}

.phone {
  font-size: 32rpx;
  font-weight: bold;
  text-align: center;
  margin-bottom: 55rpx;
}

.forget-pwd-text {
  font-weight: 400;
  font-size: 26rpx;
  color: #FF5A5A;
}

.input-pwd {
  width: 75%;
  margin-left: 76rpx;
}
</style>
