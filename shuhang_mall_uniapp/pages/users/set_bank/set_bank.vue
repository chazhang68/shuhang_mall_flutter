<template>
  <view class="mt-5 mx-2 rounded">
    <form @submit="editPwd">
		<content-list class="p-3" :is-icon="false">
		  <template v-slot:leftTitle>
		    <view style="width: 25%">
		      <text class="font-weight-nn">
		        真实姓名
		      </text>
		    </view>
		  </template>
		  <template v-slot:center>
		    <view class="input-pwd">
		      <uni-easyinput :placeholderStyle="inputStyle" :clearable="false" type="text" :input-border="false" v-model="real_name" placeholder="请输真实姓名"></uni-easyinput>
		    </view>
		  </template>
		</content-list>
		<content-list class="p-3" :is-icon="false">
		  <template v-slot:leftTitle>
		    <view style="width: 25%">
		      <text class="font-weight-nn">
		        身份证
		      </text>
		    </view>
		  </template>
		  <template v-slot:center>
		    <view class="input-pwd">
		      <uni-easyinput :placeholderStyle="inputStyle" :clearable="false" type="text" :input-border="false" v-model="idcard" placeholder="请输身份证号码"></uni-easyinput>
		    </view>
		  </template>
		</content-list>
      <content-list class="p-3" :is-icon="false">
        <template v-slot:leftTitle>
          <view style="width: 25%">
            <text class="font-weight-nn">
              银行名称
            </text>
          </view>
        </template>
        <template v-slot:center>
          <view class="input-pwd">
             <uni-data-select style="font-size: 15px;"
                  v-model="value"
                  :localdata="range"
				  placeholder="请选择银行"

                ></uni-data-select>
          </view>
        </template>
      </content-list>
      <content-list class="p-3" :is-icon="false">
        <template v-slot:leftTitle>
          <view style="width: 25%">
            <text class="font-weight-nn">
              银行卡号
            </text>
          </view>
        </template>
        <template v-slot:center>
          <view class="input-pwd">
            <uni-easyinput :placeholderStyle="inputStyle" :clearable="false" type="number" :input-border="false" v-model="bank_num" placeholder="请输银行卡号"></uni-easyinput>
          </view>
        </template>
      </content-list>

      <content-list  class="p-3" :is-icon="false">
        <template v-slot:leftTitle>
          <view style="width: 25%">
            <text class="font-weight-nn">
              手机号
            </text>
          </view>
        </template>
        <template v-slot:center>
          <view class="input-pwd">
            <uni-easyinput :placeholderStyle="inputStyle" :clearable="false" type="number" :input-border="false" v-model="bank_phone" placeholder="请输入银行预留手机号"></uni-easyinput>
          </view>
        </template>
      </content-list>

      <content-list class="p-3" :is-icon="false">
        <template v-slot:leftTitle>
          <view style="width: 25%">
            <text class="font-weight-nn">
              动态密码
            </text>
          </view>
        </template>
        <template v-slot:center>
          <view style="width: 53%" class="input-pwd">
            <input type="number" maxlength="6" placeholder="请输入动态密码" v-model="code">
          </view>
        </template>
        <template v-slot:rightTitle>
          <view class="font-weight-nn font" style="color: #e44340;width: 90px;" @click="getCode">{{text}}</view>
        </template>
      </content-list>
      <button form-type="submit" style="padding: 13px;margin-top: 75rpx" type="warn">保存</button>
    </form>

  </view>
</template>

<script>

import {
  getUserInfo,qianyue,okQianYue
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

import contentList from "../../../components/contentList/index.vue";

export default {
  mixins: [colors],
  components: {
    contentList,
    // #ifdef MP
    authorize,
    // #endif

  },
  data() {
    return {
	 text:"获取动态密码",
      phone: '',
      userInfo: {},
      // old_password: '',
      enter_password: '',
      captcha: '',
      new_password: '',
      isAuto: false, //没有授权的不会自动授权
      isShowAuth: false, //是否隐藏授权
      key: '',
      showPassword: true,
      inputStyle: 'fontSize: 30rpx; color: grey',
	  codeTime: '0',
	  value: 'a',
	  bank_num:"",
	  bank_phone:'',
	  idcard:"",
	  real_name:'',
	  order_id:'',
	  code:'',
		range: [
		  { value: 0, text: "中国银行" },
		  { value: 1, text: "中国工商银行" },
		  { value: 2, text: "中国建设银行" },
		  { value: 3, text: "光大银行" },
		  { value: 4, text: "华夏银行" },
		{ value: 5, text: "中信银行" },
		{ value: 6, text: "平安银行" },
		{ value: 7, text: "民生银行" },
		{ value: 8, text: "中国邮政储蓄银行" },
		{ value: 9, text: "北京银行" },
		{ value: 10, text: "交通银行" },
		{ value: 11, text: "广发银行" },
		{ value: 12, text: "浦东发展银行" },
		{ value: 13, text: "上海银行" },
		{ value: 14, text: "渤海银行" },
		{ value: 15, text: "其他银行" },
		],
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
    } else {
      toLogin()
    }
  },
  methods: {
	  daojishi() {
	    this.codeTime = 60
	    let timer = setInterval(() => {
	      this.codeTime--;
	      this.text = this.codeTime + "秒后获取"
	      if (this.codeTime < 1) {
	        clearInterval(timer);
	        this.codeTime = 0,
	            this.text = "获取验证码"
	      }
	    }, 1000)
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
	getCode() {
      let that = this;
	  if (this.codeTime > 0) {
	    uni.showToast({
	      title: '请勿重复获取',
	      icon: "none"
	    });
	    return;
	  }
	  if(!that.real_name){
		  return uni.showToast({
		  	title:"请填写姓名",
			icon:'none'
		  })
	  }
	  if(!that.idcard){
		  return uni.showToast({
			title:"请填写身份证号码",
			icon:'none'
		  })
	  }
	  if(!that.bank_num){
		  return uni.showToast({
			title:"请填写银行卡号",
			icon:'none'
		  })
	  }
	  if(!that.bank_phone){
		  return uni.showToast({
			title:"请填写手机号",
			icon:'none'
		  })
	  }
	  qianyue({real_name:that.real_name,idcard:that.idcard,bank_num:that.bank_num,bank_phone:that.bank_phone}).then(res=>{
		  
		  uni.showToast({
		  	title:'发送成功',
			icon:'success'
		  })
		  that.order_id = res.data.order_id
		  that.daojishi()
	  }).catch(e=>{
		  
		  uni.showToast({
		  	title:e,
			icon:'none'
		  })
	  })
		
       
    },

    /**
     * H5登录 修改密码
     *
     */
    editPwd: function (e) {
      let that = this,
	  bank_num = this.bank_num,
	  bank_name = this.range[that.value].text,
	  real_name = this.real_name,
	  idcard = this.idcard,
	  code = this.code,
	  bank_phone = this.bank_phone;
	  if (!real_name) return that.$util.Tips({
	    title: that.$t(`请填写姓名`)
	  });
	  if (!idcard) return that.$util.Tips({
        title: that.$t(`请填写身份证号码`)
      });
		if(that.value =='a')return that.$util.Tips({
        title: that.$t(`请选择银行`)
      });
      if (!bank_num) return that.$util.Tips({
        title: that.$t(`请填写银行卡号`)
      });
	  if (!bank_phone) return that.$util.Tips({
	    title: that.$t(`请填写银行预留手机号`)
	  });
      if (!code) return that.$util.Tips({
        title: that.$t(`请输入动态密码`)
      });
		uni.showLoading({
			title:'绑定提交中'
		})
		okQianYue({real_name:real_name,idcard:idcard,bank_name:bank_name,bank_num:bank_num,bank_num:bank_num,bank_phone,code:code,order_id:that.order_id}).then(res=>{
			uni.hideLoading()
			uni.showToast({
				title:"添加成功"
			})
			setTimeout(()=>{
				uni.navigateBack()
			},1000)
		}).catch(e=>{
			uni.hideLoading()
			uni.showToast({
				title:e,
				icon:'none'
			})
		})
    }
  }
}

</script>
<style scoped lang="scss">
	/deep/.uni-select__input-placeholder{
		font-size: 15px!important;
		color: grey!important;
	}
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
  margin-left: 70rpx;
}
.on {
  color: #e44340 !important;
}
</style>
