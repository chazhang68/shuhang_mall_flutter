<template>
	<view :style="colorStyle">
		<view class="box">
			<view class="item flex">
				<view>当前可用消费券：</view>
				<view style="padding-left:20px">{{userInfo.integral}}</view>
			
			</view>
			<view class="item flex">
				<view>转让用户</view>
				<input type="number" v-model="zuid" placeholder="请输入转让用户UID">
			</view>
			<view class="item flex">
				<view>数量</view>
				<input type="number" v-model="num" placeholder="请输入转出数量">
				<text @click="allnum">全部</text>
			</view>
		
			<view class="okb" @click="okzhuan">
				确认转出
			</view>
		</view>
	</view>
</template>

<script>
	import colors from '@/mixins/color.js';
	import {getUserInfo,zhuanzeng} from '@/api/user.js'
	export default {
		data() {
			return {
				userInfo:{},
				is_loading:true,
				num:'',
				zuid:''
			}
		},
		mixins: [colors],
		onShow() {
			this.getUserInfo()
		},
		methods: {
			okzhuan(){
				let that = this;
				if(Number(that.num) < 1){
					uni.showToast({
						title:"请输出转出数量",
						icon:"none"
					})
					return false;
				}
				if(!Number(that.zuid)){
					uni.showToast({
						title:"请输入转让用户ID",
						icon:"none"
					})
					return false;
				}
				if(Number(that.userInfo.uid) == Number(that.zuid)){
					uni.showToast({
						title:"不能转给自己哦",
						icon:"none"
					})
					return false;
				}
				if(Number(that.num) > Number(that.userInfo.integral)){
					uni.showToast({
						title:"消费券数量不足",
						icon:"none"
					})
					return false;
				}
				uni.showModal({
					title:"提示",
					content:"确认转出吗?",
					success:function(res){
						if(res.confirm){
							if(that.is_loading){
								that.is_loading = false
								uni.showLoading({
									title:"转出中..."
								})
								zhuanzeng({number:that.num,zuid:that.zuid}).then(res=>{
									uni.hideLoading()
									that.is_loading = true
									uni.showToast({
										title:"转出成功"
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
									that.is_loading = true
								})
								
							}
						}else if(res.cancel){
							uni.showToast({
								title:"取消转出",
								icon:"none"
							})
						}
					}
				})
			},
			allnum(){
				this.num = this.userInfo.integral
			},
			getUserInfo(){
				getUserInfo().then(res=>{
					this.userInfo = res.data
				})
			}
		}
	}
</script>

<style>
	.okb{
		width: 90%;
		height: 50px;
		background-color: var(--view-theme);
		display: flex;
		align-items: center;
		justify-content: center;
		color: #fff;
		margin: 10% 5%;
	
		border-radius: 5px;
	}
	page{
		background: #fff;
	}
	.box{
		background-color: #fff;
	}
	.item{
		width: 100%;
		height: 50px;
		border-bottom: 1px solid #e6e6ee;
		padding: 10px;
		align-items: center;
	}
	.item input{
		height: 100%;
		padding-left: 20px;
		font-size: 13px;
	}
	.item text{
		flex:1;
		text-align: right;
	}
</style>
