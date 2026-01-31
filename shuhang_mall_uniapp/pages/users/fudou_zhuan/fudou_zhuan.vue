<template>
	<view :style="colorStyle">
		<view class="box">
			<view class="item flex">
				<view>当前可用福豆：</view>
				<view style="padding-left:20px">{{userInfo.fudou}}</view>
			
			</view>
			<view class="item flex">
				<view>转赠用户：</view>
				<input type="number" v-model="zuid" placeholder="请输入转让用户UID">
			</view>
			<view class="item flex">
				<view>数量：</view>
				<input type="number" v-model="num" placeholder="请输入转出数量">
				<text @click="allnum">全部</text>
			</view>
			<view class="item flex">
				<view>消耗福豆：</view>
				<input type="number" v-model="fd_sxf" disabled="true">
			</view>
			<view class="item flex">
				<view>消耗贡献值：</view>
				<input type="number" v-model="gxz" disabled="true">
			</view>
			<view class="item flex" v-if="xfq_bl > 0">
				<view>消耗消费券：</view>
				<input type="number" v-model="xfq_sxf" disabled="true">
			</view>
			<view class="flex" style="padding: 10px;">
				<radio-group @change="radioChange">
					<label class="uni-list-cell uni-list-cell-pd flex" style="margin: 10px 0px;" v-for="(item, indexs) in items" :key="indexs" >
						<view v-if="indexs == 1" class="flex">
							<view>
								<radio :value="String(indexs)" :checked="indexs == index" />
							</view>
							<view>{{item.name}}</view>
						</view>
					</label>
				</radio-group>
			</view>
			<view style="padding: 20rpx;color: red;font-size: 13px;" v-if="index==0">
				{{bz}}
			</view>
			<view class="okb" @click="okzhuan">
				确认转出
			</view>
		</view>
	</view>
</template>

<script>
	import colors from '@/mixins/color.js';
	import {getUserInfo,fudouzhuan,getSxf} from '@/api/user.js'
	export default {
		data() {
			return {
				userInfo:{},
				is_loading:true,
				num:'',
				zuid:'',
				fd_sxf:'',
				xfq_sxf:'',
				fd_bl:'',
				xfq_bl:'',
				gxz:'',
				items: [],
				index: 1,
				bz:''
			}
		},
		mixins: [colors],
		onShow() {
			this.getUserInfo(),
			this.getSxf()
		},
		watch: {
		
			num:{
				handler:function(newV,old){
					if(newV == ''){
						this.fd_sxf = 0
						this.xfq_sxf = 0
						this.gxz = 0
					}else{
						this.fd_sxf = (newV*this.fd_bl/100).toFixed(3)
						this.xfq_sxf = (newV*this.xfq_bl/100).toFixed(3)
						this.gxz = this.num
					}
				}
			}
		},
		methods: {
			 radioChange: function(evt) {
			         let index = evt.detail.value
					
						this.index = index
					this.fd_bl = this.items[index].sxf
					this.xfq_bl = this.items[index].xfq
					this.fd_sxf = (this.num*this.fd_bl/100).toFixed(3)
					this.xfq_sxf = (this.num*this.xfq_bl/100).toFixed(3)
			        },
			getSxf(){
				getSxf().then(res=>{
					this.items = res.data.sxf
					this.fd_bl = res.data.sxf[this.index].sxf
					this.xfq_bl = res.data.sxf[this.index].xfq
					this.bz = res.data.bz
				})
			},
			okzhuan(){
				let that = this;
				if(!Number(that.zuid)){
					uni.showToast({
						title:"请输入转赠用户ID",
						icon:"none"
					})
					return false;
				}
				
				if(Number(that.userInfo.fudou)-Number(that.num) <10){
					uni.showToast({
						title:"账户必须留存10个福豆",
						icon:"none"
					})
					return false;
				}
				if(Number(that.userInfo.fudou) <= 10){
					uni.showToast({
						title:"福豆余额要大于10个才支持转增",
						icon:"none"
					})
					return false;
				}
				if(Number(that.userInfo.gxz) < Number(that.num)){
					uni.showToast({
						title:"贡献值余额不足",
						icon:"none"
					})
					return false;
				}
				if(that.xfq_bl > 0){
					if(Number(that.userInfo.integral) < Number(that.xfq_sxf)){
						uni.showToast({
							title:"消费券余额不足",
							icon:"none"
						})
						return false;
					}
				}
				if(Number(that.num) < 1){
					uni.showToast({
						title:"请输出转出数量",
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
				if(Number(that.num) > Number(that.userInfo.fudou)){
					uni.showToast({
						title:"福豆数量不足",
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
								fudouzhuan({number:that.num,zuid:that.zuid,type:that.index}).then(res=>{
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
				this.num = this.userInfo.fudou-10
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
