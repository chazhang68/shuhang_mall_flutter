<template>
	<view class="p-3">
				<view class="flex align-center" v-if="data.status == 2">
					<view class="mr-2" style="color: #dd524d;">结算倒计时</view>
					<uni-countdown :font-size="13" :show-day="false" :second="Number(data.time)" color="#FFFFFF" background-color="#dd524d" />
				</view>
				<view class="flex align-center mt-3" style="justify-content: space-between;">
					<view style="color: #666;">互换人</view>
					<view class="flex align-center">
					<image :src="data.savatar" mode="" style="width: 20px;height: 20px;border-radius: 100%;"></image>
					<view class="ml-1">{{data.snickname}}</view>
					</view>
				</view>
			<view class="flex align-center p-2 mt-3" style="height: 80rpx;background: #f6f7fb;border-radius: 3px;margin-bottom: 30rpx;">
				<view style="color: #666;">互换类型：</view>
				<view style="color: #666;">{{data.type == 1?'消费券':'福豆'}}</view>
			</view>
				<view class="flex align-center p-2 mt-3" style="height: 80rpx;background: #f6f7fb;border-radius: 3px;margin-bottom: 30rpx;">
					<view style="color: #666;">换入单价：</view>
					<input style="font-size:13px;text-align:center" type="float" placeholder="请输入购买单价" placeholder-style="font-size:13px;text-align:center" v-model="data.dprice">
				</view>
				<view class="flex align-center mt-3" style="justify-content: space-between;">
					
				</view>
				<view class="flex align-center mt-3" style="height: 80rpx;background: #f6f7fb;border-radius: 3px;margin-bottom: 30rpx;">
					<view class="ml-2"  style="color: #666;">换入数量：</view>
					<input style="font-size:13px;text-align:center" type="float"  v-model="data.number">
				</view>
				<view class="flex align-center mt-3" style="justify-content: space-between;">
					
				</view>
				<view class="flex align-center mt-3" style="height: 80rpx;background: #f6f7fb;border-radius: 3px;margin-bottom: 30rpx;">
					<view class="ml-2"  style="color: #666;">总价：</view>
					<input style="font-size:13px;text-align:center" type="float"  v-model="data.all_price">
				</view>
				<view v-if="data.type == 1">
				<view class="flex align-center mt-3" style="justify-content: space-between;">
					<view  style="color: #666;">结算方式</view>
				</view>
				<view v-if="data.sbank_name" class="flex align-center mt-3" style="height: 80rpx;background: #f6f7fb;border-radius: 3px;margin-bottom: 30rpx;">
					<view class="ml-2">银行名称：</view>
					<view>{{data.sbank_name}}</view>
				</view>
				<view v-if="data.sbank_number" class="flex align-center mt-3" style="height: 80rpx;background: #f6f7fb;border-radius: 3px;margin-bottom: 30rpx;">
					<view class="ml-2">银行卡号：</view>
					<view>{{data.sbank_number}}</view>
				</view>
				<view v-if="data.salipay" class="flex align-center mt-3" style="height: 80rpx;background: #f6f7fb;border-radius: 3px;margin-bottom: 30rpx;">
					<view class="ml-2">支付宝账户：</view>
					<view>{{data.salipay}}</view>
				</view>
				<view v-if="data.swechat" class="flex align-center mt-3" style="height: 80rpx;background: #f6f7fb;border-radius: 3px;margin-bottom: 30rpx;">
					<view class="ml-2">微信账户：</view>
					<view>{{data.swechat}}</view>
				</view>
				<view  class="flex align-center mt-3 p-1" style="background: #f6f7fb;border-radius: 3px;margin-bottom: 30rpx;justify-content: space-around;">
					<view v-if="data.salipay_code" class="flex flex-column align-center">
						<view class="mb-2">支付宝收款码</view>
						<image @click="liulan(data.salipay_code)" src="/static/images/code.png" style="width: 100px;height: 100px;border-radius: 5px;">{{data.salipay_code}}</image>
					</view>
					<view v-if="data.swechat_code" class="flex flex-column align-center">
						<view class="mb-2">微信收款码</view>
						<image @click="liulan(data.swechat_code)" src="/static/images/code.png" style="width: 100px;height: 100px;border-radius: 5px;">{{data.swechat_code}}</image>
					</view>
				</view>
				<view style="color: #666;">请上传结算截图</view>
				<view class="upload">
					<view class='pictrue' style="margin-right: 20rpx;" v-for="(item,index) in images" :key="index"
						:data-index="index" @click="getPhotoClickIdx">
						<image :src='item' style="width: 60px;height: 60px;border-radius: 5px;"></image>
						<text class='iconfont icon-guanbi1' @click.stop='DelPic(index)'></text>
					</view>
					<view class='pictrue acea-row row-center-wrapper row-column' @click='uploadpic'
						v-if="images.length < 2">
						<text class='iconfont icon-icon25201'></text>
						<view>{{$t(`上传图片`)}}</view>
					</view>
				</view>
				</view>
				<view v-else class="">
					<view class="font-sm" style="color: #dd524d;">提示：福豆互换以消费券结算</view>
				</view>
			<view style="height: 55px;"></view>
			<view class="flex align-center justify-center" style="position: fixed;bottom:0px;left: 0px; right: 0px;background: #fff;height: 55px;">
				<view class="send" @click="okpay" v-if="data.status == 2 && data.type == 1">确认结算</view>
				<view class="send" @click="xfqokpay" v-if="data.status == 2 && data.type == 2">消费券结算</view>
				<view class="send" v-if="data.status == 3" @click="okShoukuan(data.id)">确认结算</view>
				<view ></view>
			</view>
			
	</view>
</template>

<script>
	import {getUserInfo,payOtc,savePayInfo,okshoukuan,xfqpay} from '@/api/user.js'
	export default {
		
		data() {
			return {
				images: [],
				userInfo:{},
				loading:true,
				data:[]
			}
		},
		onLoad(options) {
			let id = options.id;
			this.payOtc(id)
		},
		onShow() {
			this.getUser()
			
		},
		methods: {
			okShoukuan(id){
				let that = this;
				uni.showModal({
					title:"提示",
					content:"确认收款后将自动支付对应数量给买方?",
					success: function (res) {
							if (res.confirm) {
								if(!that.loading)return;
								that.loading = false;
								uni.showLoading({
									title:"数据提交中"
								})
								okshoukuan(that.data.id).then(res=>{
									uni.hideLoading()
									uni.showToast({
										title:"确认成功,等待买方确认",
										icon:"none"
									})
									setTimeout(function(){
										uni.navigateBack()
									},1000)
									that.loading = true;
								}).catch(res=>{
									uni.hideLoading()
									uni.showToast({
										title:res,
										icon:'none'
									})
									that.loading = true;
									
								})
							} else if (res.cancel) {
								uni.showToast({
									title:"取消",
									icon:"none"
								})
							}
						}
				})
			},
			xfqokpay(){
				let that = this;
					uni.showModal({
						title:"提示",
						content:"确认用消费券结算吗?",
						success: function (res) {
								if (res.confirm) {
									if(!that.loading)return;
									that.loading = false;
									uni.showLoading({
										title:"数据提交中"
									})
									xfqpay(that.data.id).then(res=>{
										uni.hideLoading()
										uni.showToast({
											title:"支付成功,等待卖方确认",
											icon:"none"
										})
										setTimeout(function(){
											uni.navigateBack()
										},1000)
										that.loading = true;
									}).catch(res=>{
										uni.hideLoading()
										uni.showToast({
											title:res,
											icon:'none'
										})
										that.loading = true;
										
									})
								} else if (res.cancel) {
									uni.showToast({
										title:"取消",
										icon:"none"
									})
								}
							}
					})
			},
			okpay(){
				if(this.images.length < 1){
					uni.showToast({
						title:"请上传支付截图",
						icon:'none'
					})
					return;
				}
				if(!this.loading)return;
				this.loading = false;
				uni.showLoading({
					title:"数据提交中..."
				})
				
				savePayInfo({id:this.data.id,pay_img:this.images}).then(res=>{
					uni.hideLoading()
					uni.showToast({
						title:'提交成功,等待卖方确认',
						icon:"none"
					})
					this.loading = true
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
			DelPic: function(index) {
				let that = this,
					pic = this.images[index];
				that.images.splice(index, 1);
				that.$set(that, 'images', that.images);
			},
			/**
			 * 上传文件
			 * 
			 */
			uploadpic: function() {
				let that = this;
				that.$util.uploadImageOne('upload/image', (res) => {
					this.images.push(res.data.url);
					that.$set(that, 'images', that.images);
				});
			
			},
			getPhotoClickIdx(e) {
				let _this = this;
				let idx = e.currentTarget.dataset.index;
				_this.imgPreview(_this.images, idx);
			},
			liulan(url){
				uni.previewImage({
					current:url,
					urls:[url]
				})
			},
			// 图片预览
			imgPreview: function(list, idx) {
				// list：图片 url 数组
				if (list && list.length > 0) {
					uni.previewImage({
						current: list[idx], //  传 Number H5端出现不兼容 
						urls: list
					});
				}
			},
			getUser(){
				getUserInfo().then(res=>{
					this.userInfo = res.data
				})
			},
			payOtc(id){
				payOtc(id).then(res=>{
					this.data = res.data
					this.images = res.data.pay_img?res.data.pay_img:[]
				}).catch(res=>{
					uni.showToast({
						title:res,
						icon:"none"
					})
					setTimeout(function(){
						uni.navigateBack()
					},1000)
				})
			}
		}
	}
</script>

<style>
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
		margin-top: 20rpx;
	}
	 .pictrue {
		width: 120rpx;
		height: 120rpx
	}
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
