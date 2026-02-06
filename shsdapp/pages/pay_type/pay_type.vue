<template>
	<view>
		<uni-segmented-control :current="current" :values="items" @clickItem="onClickItem" styleType="button" activeColor="#dd524d"></uni-segmented-control>
		<view class="content" style="padding: 10px;">
		           <view class="box"  v-show="current === 0">
						<view class="item flex align-center ">
							<view style="width: 165rpx;">姓名</view>
							<view class="flex-1">{{info.name}}</view>
						</view>
						<view class="item flex align-center ">
							<view style="width: 165rpx;">银行名称</view>
							<input class="flex-1"  v-model="info.bank_name" placeholder="请填写银行名称" placeholder-style="font-size:14px" />
						</view>
						<view class="item flex align-center ">
							<view style="width: 165rpx;">银行卡号</view>
							<input class="flex-1" type="number" v-model="info.bank_number" placeholder="请填写银行卡号" placeholder-style="font-size:14px" />
						</view>
		           </view>
		           <view class="box" v-show="current === 1">
		               <view class="item flex align-center ">
		               	<view style="width: 165rpx;">姓名</view>
		               	<view class="flex-1">{{info.name}}</view>
		               </view>
		               <view class="item flex align-center ">
		               	<view style="width: 165rpx;">支付宝账号</view>
		               	<input class="flex-1" v-model="info.alipay" placeholder="请填写支付宝账号" placeholder-style="font-size:14px" />
		               </view>
					   <view class="item flex align-center" style="border-bottom: none;">
					   	<text class="item-title">{{$t(`请上传支付宝收款码`)}}</text>
					   </view>
					   <view class="item flex align-center" style="height: auto;padding: 10px;">
					   	<view class='acea-row row-middle'>
					   		<view class="upload">
					   			<view class='pictrue' v-if="info.alipay_code"
					   				 >
					   				<image :src="info.alipay_code" @click="imgPreview(info.alipay_code)"  style="width: 60px;height: 60px;border-radius: 3px;"></image>
					   				<text class='iconfont icon-guanbi1' @click.stop='DelPic(1)'></text>
					   			</view>
					   			<view class='pictrue acea-row row-center-wrapper row-column' @click='uploadpic'
					   				v-if="!info.alipay_code">
					   				<text class='iconfont icon-icon25201'></text>
					   				<view>{{$t(`上传图片`)}}</view>
					   			</view>
					   		</view>
					   	</view>
					   </view>
		           </view>
		           <view class="box" v-show="current === 2">
		               <view class="item flex align-center ">
		               	<view style="width: 165rpx;">姓名</view>
		               	<view class="flex-1">{{info.name}}</view>
		               </view>
		               <view class="item flex align-center ">
		               	<view style="width: 165rpx;">微信号</view>
		               	<input class="flex-1" v-model="info.wechat" placeholder="请填写微信号" placeholder-style="font-size:14px" />
		               </view>
					   <view class="item flex align-center" style="border-bottom: none;">
					   	<text class="item-title">{{$t(`请上传微信收款码`)}}</text>
					   </view>
					   <view class="item flex align-center" style="height: auto;padding: 10px;">
					   	<view class='acea-row row-middle'>
					   		<view class="upload">
					   			<view class='pictrue' v-if="info.wechat_code"
					   				 >
					   				<image :src="info.wechat_code" @click="imgPreview(info.wechat_code)" style="width: 60px;height: 60px;border-radius: 3px;"></image>
					   				<text class='iconfont icon-guanbi1' @click.stop='DelPic(2)'></text>
					   			</view>
					   			<view class='pictrue acea-row row-center-wrapper row-column' @click='uploadpics'
					   				v-if="!info.wechat_code">
					   				<text class='iconfont icon-icon25201'></text>
					   				<view>{{$t(`上传图片`)}}</view>
					   			</view>
					   		</view>
					   	</view>
					   </view>
		           </view>
				   <view class="tips" style="margin: 10px;padding: 10px;font-size: 12px;">
					   <text style="color:#dd524d;">温馨提示：</text>请保存与实名信息匹配的结算方式，否则造成损失由自己承担！
				   </view>
				   <view class="flex align-center justify-center text-white"  style="height: 85rpx;margin:20px 10px;background: #dd524d;border-radius: 3px;" @click="saveData">保存</view>
		       </view>
	</view>
</template>

<script>
	import {getPayType,saveData} from "@/api/user.js"
	export default {
		data() {
			return {
				items: ['银行卡', '支付宝','微信'],
				current: 0,
				info:{
					name:'',
					bank_name:'',
					bank_number:'',
					alipay:'',
					wechat:'',
					alipay_code:"",
					wechat_code:''
				},
				
				loading:true
			}
		},
		onShow() {
			this.getPayType()
		},
		methods: {
			saveData(){
				let that = this;
				
				if(this.current == 0){
					if(this.info.bank_name ==null){
						uni.showToast({
							title:"请填写银行名称",
							icon:"none"
						})
						return;
					}
					
					if(this.info.bank_number ==null){
						uni.showToast({
							title:"请填写银行卡号",
							icon:"none"
						})
						return;
					}
				}
				if(this.current == 1){
					if(this.info.alipay ==null){
						uni.showToast({
							title:"请填写支付宝账号",
							icon:"none"
						})
						return;
					}
					if(this.info.alipay_code ==null){
						uni.showToast({
							title:"请上传支付宝收款码",
							icon:"none"
						})
						return;
					}
				
				}
				if(this.current == 2){
				
					if(this.info.wechat ==null){
						uni.showToast({
							title:"请填写微信号",
							icon:"none"
						})
						return;
					}
					if(this.info.wechat_code ==null){
						uni.showToast({
							title:"请上传微信收款码",
							icon:"none"
						})
						return;
					}
				}
				if(!this.loading){
					return;
				}
				this.loading = false;
				uni.showLoading({
					title:"保存中..."
				})
				
				saveData(that.info).then(res=>{
					uni.hideLoading(),
					uni.showToast({
						title:"保存成功"
					})
					this.loading = true
					that.getPayType()
				}).catch(res=>{
					uni.showToast({
						title:res,
						icon:"none"
					})
					this.loading = true
				})
			},
			uploadpic: function() {
				let that = this;
				that.$util.uploadImageOne('upload/image', (res) => {
					this.info.alipay_code = res.data.url;
					
				});
			
			},
			uploadpics: function() {
				let that = this;
				that.$util.uploadImageOne('upload/image', (res) => {
					this.info.wechat_code = res.data.url;
				});
			
			},
			/**
			 * 删除图片
			 * 
			 */
			DelPic: function(index) {
				let that = this;
				if(index == 1){
					that.info.alipay_code = ''
				}else{
					that.info.wechat_code = ''
				}
				
			},
			getPhotoClickIdx(e) {
				let _this = this;
				let idx = e.currentTarget.dataset.index;
				_this.imgPreview(_this.images, idx);
			},
			// 图片预览
			imgPreview(url) {
				
					uni.previewImage({
						current: url, //  传 Number H5端出现不兼容 
						urls: [url]
					});
				
			},
			getPayType(){
				getPayType().then(res=>{
					this.info = res.data
					if(res.data.real_name ==''){
						uni.showToast({
							title:"请先实名认证",
							icon:"none"
						})
						setTimeout(function(){
							uni.redirectTo({
								url:"/pages/sign/sign"
							})
						},800)
					}
				})
			},
			onClickItem(e) {
			      if (this.current != e.currentIndex) {
			        this.current = e.currentIndex;
			      }
			    }
		}
	}
</script>

<style>
	.tips{
		
		border:1px solid #dd524d;
		border-radius: 3px;
		background-color: #fed6d6;
	}
	.item{
		height: 95rpx;
		border-bottom: 1px solid #e6e6e6;
	}
	.box{
		background: #fff;padding: 10px;border-radius: 3px;
	}
/deep/ .segmented-control__item--button--first{
	border-top-left-radius:0px;
	border-bottom-left-radius:0px
}
/deep/ .segmented-control__item--button--last{
	border-top-right-radius:0px;
	border-bottom-right-radius:0px
}
input{
	font-size: 14px;
}
</style>
