<template>
  <view class="info-list-center flex flex-column px-3">
    <view class="flex justify-between align-center person-info-list-text">
      <slot name="leftTitle">
        <text>{{ leftTitle }}</text>
      </slot>
      <slot name="center"></slot>
      <view class="flex align-center">
        <slot name="rightTitle">
          <text class="set-person-info-txt mr-2">{{ rightTitle }}</text>
          <uni-icons style="margin-top: 1px" :type="icon" v-show="arrows" v-if="isIcon"></uni-icons>
        </slot>
      </view>
    </view>
  </view>
</template>
<script>

/**
 * @property {String} leftTitle 左标题
 * @property {String} rightTitle 右标题
 * @property {Boolean} arrows 是否需要箭头
 * @property {String} icon 图标
 * **/
export default {
  name: "index",
  props: {
    leftTitle: {
      type: String,
      default: ''
    },
    rightTitle: {
      type: String,
      default: ''
    },
    arrows: {
      type: Boolean,
      default: true
    },
    icon: {
      type: String,
      default: "right"
    },
    isIcon: {
      type: Boolean,
      default: true
    }
  },
}
</script>


<style scoped lang="scss">

$set-card-background-color: #FFFFFF;
$set-card-font-color: #000000;
$set-card-border-radius: 0px;

.set-person-info-txt {
  font-weight: 400;
  font-size: 26rpx;
  color: $set-card-font-color;
}

.info-list-center {
  background: $set-card-background-color;
  border-radius: $set-card-border-radius;
}

.person-info-list-text text {
  font-weight: 400;
  font-size: 28rpx;
  color: $set-card-font-color;
}
</style>
