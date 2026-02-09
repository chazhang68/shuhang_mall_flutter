<template>
	<view style="width: 100%;height: 100vh;">
		<web-view ref="webView" :src="url"></web-view>
	</view>
</template>

<script>
	export default {
		data() {
			return {
				url:''
			}
		},
		onLoad(options) {
			const base64 = decodeURIComponent(options.url)
			console.log(base64)
			this.url = atob(`${base64}`) 
			if (this.url.indexOf('?') > -1) {
				this.url += '&token=' + this.$store.state.app.token
			} else {
				this.url += '?token=' + this.$store.state.app.token
			}
			// this.url = 'http://localhost:5173/#/pages/merchant/apply?token=' + this.$store.state.app.token
			// `/pages/webview/webview?url=http%3A%2F%2Flocalhost%3A5173%2F%23%2Fpages%2Fmerchant%2Fapply`
		},
		methods: {
			
		}
	}
</script>

<style>

</style>
