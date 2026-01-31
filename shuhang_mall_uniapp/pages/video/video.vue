<template>
	<view>
		<video style="width: 100%;" :style="{height:h}" :controls="false"  src="https://xifu-1320565916.cos.ap-chengdu.myqcloud.com/gg.mp4" autoplay="true"></video>
	</view>
</template>

<script>
	import {getUserInfo,watchTv} from '@/api/user.js'
	export default {
		data() {
			return {
				h:0,
				i:0,
				time:60,
				timer:''
			}
		},
		onLoad() {
			
			this.h = uni.getSystemInfoSync().screenHeight+'px'
		},
		onShow() {
			
				
			this.daojishi()
				
		},
		onHide() {
			clearInterval(this.timer);
		},
		
		onUnload(){
			clearInterval(this.timer);
		},
		methods: {
			daojishi() {
				this.codeTime = 30
				this.timer = setInterval(() => {
					this.codeTime--;
					console.log(this.codeTime)
					if (this.codeTime < 5) {
						clearInterval(this.timer);
						watchTv().then(res=>{
							uni.showToast({
								title:"当前任务已完成"
							})
							
						})
						this.codeTime = 0
						
					}
				}, 1000)
			}
		}
	}
</script>

<style>

</style>
