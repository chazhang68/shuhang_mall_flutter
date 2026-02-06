<template>
	<view class="mx-2 mt-5">
	<navigator url="/pages/users/privacy/index?type=4" animation-type="fade-in" animation-duration="100" hover-class="none">
		<content-list class="p-3" left-title="用户协议"></content-list>
	</navigator>
    <navigator url="/pages/users/privacy/index?type=3" animation-type="fade-in" animation-duration="100" hover-class="none">
      <content-list class="p-3 mt-2" left-title="隐私政策"></content-list>
    </navigator>
	</view>
</template>

<script>
import contentList from "../../../components/contentList/index.vue";
	export default {
    components: {
      contentList,
    },
		data() {
			return {

			}
		},
		methods: {

		}
	}
</script>

<style>

</style>
