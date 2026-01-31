<template>
	<view class="m-2">
		<view class="bg-white rounded p-3">
			<view class="font-md font-weight-nn text-hh">兑换数量</view>
			<view class="flex border-bottom py-3 mt-3">
				<input type="number" maxlength="7" class="w-100 font-md" v-model="jfnum" placeholder="请输入兑换数量" placeholder-class="text-muted font" />
				
			</view>
			
			<view class="mt-2 flex align-center justify-between py-1">
				<view class="font">可用SWP数量{{userInfo.now_money}}个</view>
				<view class="font" style="color: #FF5A5A;" @click="allJIfen">全部兑换</view>
			</view>
		</view>
		<!-- <view class="mt-2 bg-white flex align-center font p-3 rounded">
			<view class="flex align-center w-30">
				<view class="mr-3">手续费</view>
				<view style="color: #FF5A5A;">{{userInfo.xfq_sxf}}%</view>
			</view>
			<view class="flex align-center flex-1 pl-2 justify-end">
				<view class="mr-3">损耗数量</view>
				<view style="color: #FF5A5A;">{{xfqsxfnum}}个</view>
			</view>
		</view> -->
		<view class="mt-2 bg-white flex align-center justify-between font p-3 rounded">
			<view>实际到账数量</view>
			<view style="color: #FF5A5A;">{{jfnum}}个</view>
		</view>
		
		<view class="rounded-circle flex align-center justify-center text-white py-2" style="background: #FF5A5A;margin-top: 50px;" @click="xfqZhuan">兑换</view>
	</view>
</template>

<script>
	import {
		newUserInfo,swpDui
	} from '@/api/user.js';
	export default {
		data() {
			return {
				userInfo:[],
				xfqsxfnum:0,
				jfnum:'',
				dznum:0,
				loading:false
			}
		},
		onShow() {
			this.getUserInfo()
		},
	// 	watch: {
	
	// 		jfnum:{
	// 			handler:function(newV,old){
	// 				const regex = /^[0-9]*$/;
	// 				// 如果输入的值不是整数，则将其设置为上一个值
	// 				if (!regex.test(newV) && newV !== '') {
	// 					newV = Math.floor(newV)
	// 					this.jfnum = newV
	// 				}
	// 				if(newV == ''){
	// 					this.xfqsxfnum = 0
	// 				}else{
	// 					this.xfqsxfnum = (newV*this.userInfo.xfq_sxf/100).toFixed(2)
	// 				}
	// 				this.dznum = (newV - this.xfqsxfnum).toFixed(2)
	// 			}
	// 		},
		
	// 	},
		
		methods: {
			xfqZhuan(){
				let that = this;
				if(!that.jfnum){
					return uni.showToast({
						title:"请输入兑换数量",
						icon:'none'
					})
				}
				if(Number(that.jfnum) < 1){
					return uni.showToast({
						title:"兑换数量最少1个",
						icon:'none'
					})
				}
				if(Number(that.jfnum) > Number(that.userInfo.now_money)){
					return uni.showToast({
						title:"可用SWP不足",
						icon:'none'
					})
				}
				if(that.loading)return;
				that.loading = true;
				uni.showLoading({
					title:"积分兑换中"
				})
				swpDui({number:that.jfnum},true).then(res=>{
					uni.hideLoading()
					uni.showToast({
						title:'兑换成功'		
					})
					that.getUserInfo()
					that.jfnum= ''
					that.xfqsxfnum = 0
					
					that.loading = false;
				}).catch(e=>{
					uni.hideLoading()
					uni.showToast({
						title:e,
						icon:"none"
					})
					that.loading = false;
				})
			},
			
			allJIfen(){
				let jifen = Math.floor(this.userInfo.now_money);
				this.jfnum = jifen
			},
			getUserInfo(){
				newUserInfo().then(res=>{
					this.userInfo = res.data
				})
			}
		}
	}
</script>

<style>
	page{
		background: #f5f5f5;
	}

</style>