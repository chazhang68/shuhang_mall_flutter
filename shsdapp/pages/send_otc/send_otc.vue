<template>
	<view class="p-3">
			<uni-data-checkbox mode="tag" selectedColor="#dd524d" selectedTextColor="#fff"  v-model="type" :localdata="hobby" min="1"></uni-data-checkbox>
			<view v-if="type == 1">
				<view class="flex align-center mt-3" style="justify-content: space-between;">
					<view style="color: #666;">换入单位</view>
				</view>
				<view class="flex align-center p-2 mt-3" style="height: 80rpx;background: #f6f7fb;border-radius: 3px;margin-bottom: 30rpx;">
					<input style="width:100%;font-size:13px;text-align:center" type="float" placeholder="请输入购买单价" placeholder-style="font-size:13px;text-align:center" :disabled="true" v-model="xfq_price">
				</view>
				<view class="flex align-center mt-3" style="justify-content: space-between;">
					<view  style="color: #666;">换入数量（消费券）</view>
					<view  style="color: #a6a6a6;">最低数量1个</view>
				</view>
				<view class="flex align-center mt-3" style="height: 80rpx;;border-radius: 3px;margin-bottom: 30rpx;">
					<uni-number-box background="#f6f7fb" v-model="xfq_num" :min="1" :max="20000" color="#a6a6a6" style="flex:1;" />
				</view>
				<view class="mt-3" style="color: #666;">付款方式</view>
				<view class="mt-3">
					<uni-data-checkbox  mode="list" multiple v-model="pay_type" min="1" selectedColor="#dd524d" :localdata="cc"></uni-data-checkbox>
				</view>
			</view>
			<view v-if="type == 2">
				<view class="flex align-center mt-3" style="justify-content: space-between;">
					<view style="color: #666;">换入单位（消费券）</view>
				
				</view>
				<view class="flex align-center p-2 mt-3" style="height: 80rpx;background: #f6f7fb;border-radius: 3px;margin-bottom: 30rpx;">
					<input style="width:100%;font-size:13px;text-align:center" type="float" placeholder="请输入购买单价" placeholder-style="font-size:13px;text-align:center" v-model="fd_price">
				</view>
				<view class="flex align-center mt-3" style="justify-content: space-between;">
					<view  style="color: #666;">换入数量（福豆）</view>
					<view  style="color: #a6a6a6;">最低数量1个</view>
				</view>
				<view class="flex align-center mt-3" style="height: 80rpx;;border-radius: 3px;margin-bottom: 30rpx;">
					<uni-number-box background="#f6f7fb" v-model="fd_num" :min="1" :max="20000" color="#a6a6a6"  style="flex:1;" />
				</view>
			</view>
			
			<view style="height: 55px;"></view>
			<view class="flex align-center justify-center" style="position: fixed;bottom:0px;left: 0px; right: 0px;background: #fff;height: 55px;">
				<view class="send" @click="fabu">发布互换</view>
			</view>
			
	</view>
</template>

<script>
	import {getUserInfo,getOtcInfo,sendOtc} from '@/api/user.js'
	export default {
		
		data() {
			return {
				xfq_num:1,
				fd_num:1,
				xfq_price:'',
				fd_price:'',
				hobby: [{
						text: '互换消费券',
						value: 1
					}, {
						text: '互换福豆',
						value: 2
					}],
					type: 1,
					cc: [{
							text: '银行卡',
							value: 1
						}, {
							text: '支付宝',
							value: 2
						}, {
							text: '微信',
							value: 3
						}],
						pay_type: [],
						userInfo:{},
						otcInfo:{},
						loading:true
			}
		},
		onShow() {
			this.getUser()
			this.getOtc()
		},
		methods: {
			fabu(){
				if(this.otcInfo.pay_type >= 2){
					uni.showToast({
						title:"请完善付款方式",
						icon:"none"
					})
				}
				let data = {}
				data.type = this.type
				data.xfq_price = this.xfq_price
				data.fd_price = this.fd_price
				data.fd_num = this.fd_num
				data.xfq_num = this.xfq_num
				data.pay_type = this.pay_type
				if(data.type == 2){
					if(this.fd_price == ''){
						uni.showToast({
							title:"请填写福豆购买单价",
							icon:"none"
						})
						return;
					}
					
					if(Number(this.fd_price) > Number(this.fd_zdj)){
						uni.showToast({
							title:"今日发布最高单位（消费券）"+this.fd_zdj,
							icon:"none"
						})
						return;
					}
				}
				if(data.type == 1){
					if(this.pay_type.length == 0){
						uni.showToast({
							title:"请选择支付方式",
							icon:"none"
						})
						return;
					}
				}
				if(!this.loading)return;
				this.loading = false;
				uni.showLoading({
					title:'发布中....',
					icon:"none"
				})
				sendOtc(data).then(res=>{
					uni.hideLoading()
					uni.showToast({
						title:"发布成功"
					})
					setTimeout(function(){
						uni.navigateBack()
					},1000)
				}).catch(res=>{
					uni.hideLoading()
					uni.showToast({
						title:res,
						icon:"none"
					})
					this.loading = true
				})
			},
			getUser(){
				getUserInfo().then(res=>{
					this.userInfo = res.data
				})
			},
			getOtc(){
				getOtcInfo().then(res=>{
					this.otcInfo = res.data
					this.xfq_price = res.data.xfq_zdj
					this.fd_price = res.data.fd_zdj 
					this.fd_zdj = res.data.fd_zdj 
					if(res.data.pay_type >=2){
						uni.showToast({
							title:"请先完善自己的付款方式",
							icon:"none"
						})
						setTimeout(function(){
							uni.navigateBack()
						},500)
					}
				})
			}
		}
	}
</script>

<style>
	.send{
		display: flex;
		align-items: center;
		justify-content: center;
		width: 60%;
		height: 40px;
	
		border-radius:30px;
		background: #dd524d;
		color: #fff;
	}
page{
	background: #fff;
}
/deep/.uni-data-checklist .checklist-group .checklist-box.is--list{
	padding: 15px!important;
}
/deep/.uni-numbox{
    display: flex!important;
    flex-direction: row!important;
	align-items: center!important;
	justify-content: space-evenly!important;
}
/deep/.uni-numbox__value{
	width: 260px!important;
	height: 40px!important;
}
 /deep/.uni-data-checklist .checklist-group .checklist-box.is--tag{
	padding: 8px 10px!important;
}
/deep/.uni-numbox-btns{
	padding: 10px 12px!important;
	
}
/deep/ .uni-numbox--text{
	color: #dd524d!important;
}
</style>
