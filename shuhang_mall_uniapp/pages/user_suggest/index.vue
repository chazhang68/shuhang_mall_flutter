<template>
  <view class="m-2">
    <!-- 基础用法，不包含校验规则 -->
    <uni-easyinput primary-color="#de561b" class="position-relative" maxlength="150" v-model="textarea" type="textarea"
                   placeholder="请输入你遇到的问题或建议(150字以内)">
      <template v-slot:right>
        <view class="number position-absolute right-0">
          <text class="number-red">{{ impose }}</text>
          /150
        </view>
      </template>
    </uni-easyinput>
    <uni-easyinput primary-color="#de561b" class="mt-2" maxlength="20" v-model="phone" type="text" placeholder="请输入联系方式">
      <template v-slot:left>
        <view class="ml-2 lianxi">
          联系方式
        </view>
      </template>
    </uni-easyinput>
    <view class="btn flex align-center justify-center mt-5" @click="save">
      <text class="font-weight-bold p-2">保存</text>
    </view>
  </view>
</template>

<script>
import {suggest} from "@/api/user";

export default {
  data() {
    return {
      textarea: '',
      phone: '',
	  load:false
    }
  },
  computed: {
    impose() {
      return this.textarea.length
    }
  },
  methods: {
    save() {
      let {textarea, phone} = this
	  if(this.load)return;
	  this.load = true;
      if (!textarea) {
        
        this.$util.Tips({
          title: this.$t(`请填写问题或建议`)
        });
      }
      if (!phone) {
        return this.$util.Tips({
          title: this.$t('请填写联系方式')
        });
      }
	  uni.showLoading({
	  	title:'提交中'
	  })
	  
      suggest({ text:textarea, phone:phone }).then(res=>{
		  uni.hideLoading()
		  uni.showToast({
		  	title:'提交成功'
		  })
		  this.load = false
		  setTimeout(()=>{
			  uni.navigateBack()
		  },1000)
        
      }).catch(err=>{
		uni.hideLoading()
		this.load = false
		uni.showToast({
			title:err,
			icon:'none'
		})
      })
    }
  }
}
</script>

<style lang="scss" scoped>
::v-deep .uni-easyinput__content-textarea {
  line-height: 1.5;
  font-size: 28rpx;
  height: 200px;
  min-height: 60px;
}

.number {
  margin-right: 10px;
  margin-bottom: -160px;

  & .number-red {
    color: #de561b;
  }
}

.btn {
  width: 100%;
  background: linear-gradient(to right, #FF5A5A, #FF5A5A);
  border-radius: 10rpx;
	height: 50px;
  & text {
    color: #FFFFFF;
  }
}
</style>
