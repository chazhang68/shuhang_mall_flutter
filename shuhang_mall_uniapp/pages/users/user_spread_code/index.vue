<template>
	<view>
		<swiper :style="{height:sysHeight}"  :interval="1000" :duration="100">
			<swiper-item  style="width: 100%;height: 100%;" v-for="(item,index) in list">
				<image :src="item.wap_poster" @click='savePosterPathMp(list[index])'  style="width: 100%;height: 100%;" mode=""></image>

			</swiper-item>
		</swiper>
	</view>
</template>

<script>
	import {getBanner } from "../../../api/api.js"
	let sysHeight = uni.getSystemInfoSync().screenHeight + 'px';
	export default {
		data() {
			return {
				list:[],
				sysHeight:sysHeight
			}
		},
		onLoad() {
			
			this.getBanner()
		},
		methods: {
			// #ifdef APP-PLUS
			savePosterPathMp(url) {
				let that = this;
				uni.showModal({
					title: '提示',
					content: '需要获取相册的读取权限保存推广图片',
					success: function (res) {
						if (res.confirm) {
							uni.saveImageToPhotosAlbum({
								filePath: url.wap_poster,
								success: function(res) {
									uni.showToast({
										title: '保存成功',
										icon: 'success'
									});
								},
								fail: function(res) {
									uni.showToast({
										title: '保存失败',
										icon: 'error'
									});
								}
							});
						} else if (res.cancel) {
							
						}
					}
				});
			
			},
			// #endif

			getBanner(){
				uni.showLoading({
					title:'海报生成中'
				})
				getBanner().then(res=>{
					uni.hideLoading()
					this.list = res.data
				}).catch(e=>{
					uni.hideLoading()
					uni.showToast({
						title:'生成失败',
						icon:'none'
					})
				})
			}
		}
	}
</script>

<style>

</style>
