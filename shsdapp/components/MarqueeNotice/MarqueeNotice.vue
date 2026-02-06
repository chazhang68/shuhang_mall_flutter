<template>
  <div class="notice-wrapper">
    <!-- 视口：负责裁剪溢出的文字 -->
    <div class="notice-viewport">
      <!-- 滚动的内容 -->
      <div 
        class="notice-content" 
        :style="{ 'animation-duration': duration + 's' }"
      >
        <text class="text">{{ text }}</text>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'MarqueeText',
  props: {
    // 要显示的文字
    text: {
      type: String,
      default: ''
    },
    // 滚动一圈的时间，数值越小越快
    speed: {
      type: Number,
      default: 10
    }
  },
  computed: {
    // 计算动画持续时间，根据字数调整速度
    duration() {
      if (this.text.length < 16) return 0;
      return this.speed * (this.text.length / 16);
    }
  }
}
</script>

<style scoped>
.notice-wrapper {
  border-radius: 4px;
  width: 100%;
  overflow: hidden;
}

.notice-viewport {
  width: 100%;
  overflow: hidden;
  white-space: nowrap;
}

.notice-content {
  display: inline-block;
  animation: marquee linear infinite;
}
.text {
  color: #666;
  font-size: 26rpx;
}
@keyframes marquee {
  from { transform: translateX(100%); }
  to { transform: translateX(-100%); }
}
</style>