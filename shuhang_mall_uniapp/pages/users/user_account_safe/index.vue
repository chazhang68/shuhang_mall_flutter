<template>
	<view class="user-account-safe-bac">
    <view class="flex flex-column justify-center align-center" style="padding-top: 90rpx">
      <text class="user-phone">{{phone}}</text>
      <view class="flex align-center" style="margin-top: 49rpx">
        <image style="width: 24rpx;height: 33rpx;margin-right: 14rpx" src="/static/account_safe/shouji-4@2x.png"></image>
        <text>手机号码</text>
      </view>
    </view>
    <view class="mx-2 mt-7">
      <navigator url="/pages/users/update_login_pwd/index" animation-type="fade-in" animation-duration="100" hover-class="none">
        <content-list class="p-3"  left-title="登陆密码"></content-list>
      </navigator>
      <navigator url="/pages/users/update_payment_pwd/index" animation-type="fade-in" animation-duration="100" hover-class="none">
        <content-list class="mt-2 p-3" left-title="支付密码"></content-list>
      </navigator>
    </view>

	</view>
</template>

<script>
// import contentList from "@/components/contentList/index.vue";
	import { getUserInfo } from "../../../api/user";
import contentList from "../../../components/contentList/index.vue";

export default {
    components: {
      contentList,
    },
		data() {
			return {
				userInfo:[],
				phone:''
			}
		},
		onLoad() {
			getUserInfo().then(res=>{
				this.userInfo = res.data
				let tel = res.data.phone;
				let phone = tel.substr(0, 3) + "****" + tel.substr(7);
				this.phone = phone
			})
		},
		methods: {

		}
	}
</script>

<style lang="scss" scoped>
.user-account-safe-bac {
  background-image: url("/static/account_safe/bac_1015@2x.png");
  background-size: 100% 100%;
  background-repeat: no-repeat;
  width: 750rpx;
  height: 536rpx;

  .user-phone{
    font-family: DIN Alternate;
    font-weight: bold;
    font-size: 60rpx;
    color: #000000;
  }
}
</style>
