<template>
	<view style="width: 100%;height: 100vh;">
		<web-view ref="webView" :src="url"></web-view>
	</view>
</template>

<script>
	import store from '../../store';
	export default {
		data() {
			return {
				token:'',
				url:''
			}
		},
		onLoad() {
			this.token = this.$store.getters.token
			this.url = "http://hh.sgzx131.com/#/?token="+this.token
			
		},
		methods: {
			
		}
	}
</script>

<style>

</style>
