<template>
  <view class="container">
    <swiper class="swiper" autoplay interval="1500" duration="2000" :circular="true" display-multiple-items="4">
      <block v-for="(group, groupIndex) in nav" :key="groupIndex">
        <swiper-item class="swiper-group">
          <view class="item">{{ group.text }}</view>
          <image :src="group.img"></image>
        </swiper-item>
      </block>
    </swiper>
  </view>
</template>

<script>
export default {
  data() {
    return {
      nav: [
        {
          text: 'Image 1',
          img: '/static/mall/img_jdms.png'
        }, {
          text: 'Image 2',
          img: '/static/mall/img_jdms.png'
        }, {
          text: 'Image 3',
          img: '/static/mall/img_jdms.png'
        }, {
          text: 'Image 4',
          img: '/static/mall/img_jdms.png'
        }, {
          text: 'Image 5',
          img: '/static/mall/img_jdms.png'
        }
        ],
    };
  },
  onLoad() {
    // this.startAutoScroll();
  },
  methods: {
    // startAutoScroll() {
    // 	setInterval(() => {
    // 		const swiper = uni.createSelectorQuery().select('.swiper');
    // 		swiper.boundingClientRect((rect) => {
    // 			if (rect) {
    // 				const scrollLeft = rect.scrollLeft + rect.width;
    // 				swiper.scrollBy({
    // 					left: scrollLeft,
    // 					behavior: 'smooth',
    // 				});
    // 			}
    // 		}).exec();
    // 	}, 1000);
    // },
  },
};
</script>

<style>
.container {
  height: 200px;
//overflow: hidden;
}

.swiper {
  white-space: nowrap;
  height: 100%;
}

.swiper-group {
  display: inline-block;
  width: 100%;
  white-space: initial;

}

.item {
  height: 100%;
  width: 80%;
  display: inline-block;
  line-height: 200px;
  text-align: center;
  background-color: #ccc;

}

.quees {


  margin-top: 20rpx;
}

/* .quee {
  width: 300rpx;
  height: 300rpx;
  overflow: hidden;
  border-radius: 12rpx;
  display: inline-block;
  margin-right: 20rpx;

  image {
    width: 300rpx;
    height: 300rpx;
  }
}
} */

/* .quees:hover {
  animation: move 7s linear infinite paused;
} */

//@keyframes move {
//
//	0% {
//		transform: translateX(0rpx);
//	}
//
//	100% {
//		//无缝重点：图片是300rpx，margin-right是20rpx，那就是需要左移 （300+20）*图片数rpx
//		transform: translateX(-960rpx);
//	}

//}
</style>
