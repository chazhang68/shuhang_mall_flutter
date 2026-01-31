<template>
	<div id="alipay-form"></div>
</template>

<script>
	export default {
		data() {
			return {
				
			}
		},
		onLoad(options) {
			const htmlCode = decodeURIComponent(options.htmlCode); // 解码传递的HTML代码
			  document.getElementById('alipay-form').innerHTML = htmlCode; // 将HTML代码添加到页面中的div元素中
			  document.forms['alipaysubmit'].submit(); // 提交表单，实现支付宝身份验证
		},
		methods: {
			
		}
	}
</script>

<style>

</style>
