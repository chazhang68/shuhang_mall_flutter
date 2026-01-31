<template>
	<view class="bac" :style="{height: deviceHeight}">
		<image id="img" src="/static/images/shengtai.jpg" style="width: 100%;" mode="widthFix"></image>
		<pageFoot></pageFoot>
	</view>

</template>

<script>
	import pageFoot from '@/components/pageFooter/index.vue';
	export default {
		components: {
			pageFoot
		},
		data() {
			return {
				deviceHeight: '',
			}
		},
		onLoad() {
			let info = uni.getWindowInfo()
			this.deviceHeight = `${info.screenHeight}px`
		},
		methods: {

		}
	}
</script>

<style lang="scss" scoped>
	.bac {
		width: 100%;
		//height: 100%;
		background: #fca138;
	}
</style>
