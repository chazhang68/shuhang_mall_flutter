<template>
	<view class="m-2">
		<view class="font-sm" style="color: #627090;">您所使用的收款账户的姓名需与平台认证姓名一致，否则由此造成的损失自行承担</view>
		<view class="bb mt-3 p-2" v-if="userInfo.qy_bank">
			<image src="../../../static/bank.png" style="width: 30px;height: 30px;" mode=""></image>
			<view class="flex align-center justify-between">
				<view class=" mt-2 flex justify-start flex-column">
					<view class="font-ll" style="color: #fff;">银行卡号：</view>
					<view class="font-weight-bold mt-1" style="font-size: 19px;color: #fff;">{{userInfo.qy_bank}}</view>
				</view>
				<view  class="jb text-white font-ll mr-1" @click="jiebang">解绑</view>
			</view>
		</view>
		<view v-else style="margin-top:40px">
			<view class="flex justify-center w-100">
				<view class="fabu flex align-center justify-center" @click="shezhi">立即设置</view>
			</view>

		</view>
		<view>
					
					<uni-popup ref="alertDialog" type="dialog">
						<uni-popup-dialog type="error" cancelText="取消" confirmText="确认" title="提示" content="解绑后将不能进行快捷支付哦" @confirm="dialogConfirm"
							@close="dialogClose"></uni-popup-dialog>
					</uni-popup>
				</view>
	</view>
</template>

<script>
import { getJiebang, getUserinfo_bank } from "@/api/api";

export default {
		data() {
			return {
				userInfo:[],
        msgType: ''
			}
		},
		onShow() {
			this.getUserInfo()

		},
		methods: {
			jiebang(){
				this.msgType = 'center'
				this.$refs.alertDialog.open()
			},
			dialogConfirm(){
				let that = this;
				uni.showLoading({
					title:"解绑中..."
				})
				getJiebang().then(res=>{
					uni.showToast({
						title:'解绑成功',
					})
					that.getUserInfo()
				}).catch(e=>{
					uni.hideLoading()
					uni.showToast({
						title:e,
						icon:'none'
					})
				})
			},
			dialogClose() {

			},
			shezhi(){
				uni.navigateTo({
					url:"/pages/users/set_bank/set_bank",
					animationDuration:100,
					animationType:"fade-in"
				})
			},
			getUserInfo(){
				getUserinfo_bank().then(res=>{
					this.userInfo = res.data
				})
			}
		}
	}
</script>

<style>
	.jb{
		width: 72px;
		height: 32px;
		background: linear-gradient(180deg, #ff1f1f 0%, #df1443 100%);
		border-radius: 16px;
		backdrop-filter: blur(4px);
		display: flex;
		align-items: center;
		justify-content: center;
	}
	.bb{
		height: 115px;
		border-radius: 4px;
		background:#FF5A5A ;
		background-repeat: no-repeat;
		background-size: 100% 100%;
	}
	.fabu{
		font-size: 13px;
		color: #fff;
		width: 50%;
		height: 35px;
		background: linear-gradient(180deg, #ff1f1f 0%, #df1443 100%);
		border-radius: 20px;
	}
page{
	background: #f4f4f4;
}
</style>
