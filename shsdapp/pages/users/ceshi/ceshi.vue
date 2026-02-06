<template>
  <view class="container">
    <!-- 广告按钮 -->
    <button 
      class="ad-btn"
      :class="{
        'ad-ready': adReady,
        'ad-loading': adLoading,
        'ad-error': adErrorCount >= 3
      }"
      @tap="showAd"
      :disabled="adErrorCount >= 3"
    >
      <view class="btn-content">
        <text v-if="adLoading" class="loading-text">⏳ 加载中...</text>
        <text v-else-if="adReady" class="ready-text">🎬 观看广告领奖励</text>
        <text v-else-if="adErrorCount >= 3" class="error-text">😢 广告不可用</text>
        <text v-else class="normal-text">📺 点击看广告</text>
      </view>
    </button>
    
    <!-- 状态显示 -->
    <view class="status-box" v-if="false"> <!-- 调试时可以改为true -->
      <view class="status-title">广告状态监控：</view>
      <view 
        v-for="status in getAdStatus()" 
        :key="status.index"
        class="status-item"
        :class="{
          'status-ready': status.status === '就绪',
          'status-loading': status.status === '加载中',
          'status-error': status.status === '错误'
        }"
      >
        <text>广告位{{status.index}}: {{status.status}}</text>
        <text class="status-time">{{status.lastLoad}}</text>
      </view>
    </view>
    
    <!-- 提示信息 -->
    <view class="tips">
      <text>💡 提示：广告会自动轮换，确保最快速度展示</text>
    </view>
  </view>
</template>
<script setup>
export default {
  data() {
    return {
      adIds: [
        '1686783283',  // 广告位1
        '1438349751',  // 广告位2
        '1193095889',  // 广告位3
        '1220453411',  // 广告位4
        '1644506192',  // 广告位5
      ],
      adInstances: [],      // 广告实例数组
      currentAdIndex: 0,    // 当前使用的广告索引
      adReady: false,       // 是否有广告就绪
      adLoading: false,     // 是否正在加载
      adErrorCount: 0,      // 错误计数
    }
  },
  
  onLoad() {
    this.initAllAds();
  },
  
  onShow() {
    // 页面显示时检查广告状态
    if (!this.adReady && !this.adLoading) {
      this.preloadNextAd();
    }
  },
  
  onUnload() {
    this.destroyAllAds();
  },
  
  methods: {
    // 初始化所有广告
    initAllAds() {
      
      this.adInstances = this.adIds.map((adpid, index) => ({
        adpid,
        instance: null,
        ready: false,
        loading: false,
        error: false,
        lastLoadTime: 0,
      }));
      
      // 初始化前3个广告
      for (let i = 0; i < Math.min(3, this.adIds.length); i++) {
        this.initAd(i);
      }
    },
    
    // 初始化单个广告
    initAd(index) {
      const adInfo = this.adInstances[index];
      if (!adInfo || adInfo.instance) return;
      
      console.log(`初始化广告位${index + 1}: ${adInfo.adpid}`);
      
      try {
        adInfo.instance = uni.createRewardedVideoAd({
          adpid: adInfo.adpid
        });
        
        // 绑定事件
        adInfo.instance.onLoad(() => {
          console.log(`✅ 广告位${index + 1} 加载完成`);
          adInfo.ready = true;
          adInfo.loading = false;
          adInfo.error = false;
          adInfo.lastLoadTime = Date.now();
          this.checkAdReadyStatus();
        });
        
        adInfo.instance.onError((err) => {
          console.error(`❌ 广告位${index + 1} 加载失败:`, err);
          adInfo.ready = false;
          adInfo.loading = false;
          adInfo.error = true;
          this.adErrorCount++;
          
          // 尝试下一个广告位
          setTimeout(() => {
            this.tryNextAd(index);
          }, 3000);
        });
        
        adInfo.instance.onClose((res) => {
          console.log(`广告位${index + 1} 关闭`);
          adInfo.ready = false;
          
          if (res && res.isEnded) {
            this.giveReward();
          }
          
          // 当前广告关闭后，预加载下一个
          setTimeout(() => {
            this.preloadAd((index + 1) % this.adIds.length);
          }, 500);
        });
        
        // 初始化后立即加载
        this.preloadAd(index);
        
      } catch (err) {
        console.error(`初始化广告位${index + 1}失败:`, err);
        adInfo.error = true;
      }
    },
    
    // 预加载指定广告
    preloadAd(index) {
      const adInfo = this.adInstances[index];
      if (!adInfo || !adInfo.instance || adInfo.ready || adInfo.loading) {
        return;
      }
      
      // 检查是否最近刚加载过
      const now = Date.now();
      if (now - adInfo.lastLoadTime < 10000) { // 10秒内不重复加载
        return;
      }
      
      console.log(`⏳ 预加载广告位${index + 1}...`);
      adInfo.loading = true;
      
      adInfo.instance.load()
        .then(() => {
          // 加载成功在onLoad回调处理
        })
        .catch(err => {
          console.log(`广告位${index + 1} 加载失败:`, err);
          adInfo.loading = false;
          adInfo.error = true;
        });
    },
    
    // 预加载下一个可用广告
    preloadNextAd() {
      // 找到第一个未就绪且未加载的广告
      for (let i = 0; i < this.adInstances.length; i++) {
        const adInfo = this.adInstances[i];
        if (adInfo.instance && !adInfo.ready && !adInfo.loading && !adInfo.error) {
          this.preloadAd(i);
          break;
        }
      }
    },
    
    // 检查是否有广告就绪
    checkAdReadyStatus() {
      this.adReady = this.adInstances.some(ad => ad.ready);
      
      if (this.adReady) {
        console.log('🎉 有广告可用了！');
      }
    },
    
    // 尝试下一个广告
    tryNextAd(currentIndex) {
      const nextIndex = (currentIndex + 1) % this.adIds.length;
      console.log(`尝试下一个广告位: ${nextIndex + 1}`);
      
      if (!this.adInstances[nextIndex]?.instance) {
        this.initAd(nextIndex);
      } else {
        this.preloadAd(nextIndex);
      }
    },
    
    // 获取最优广告
    getBestAd() {
      // 1. 优先返回已就绪的广告
      for (let i = 0; i < this.adInstances.length; i++) {
        const adInfo = this.adInstances[i];
        if (adInfo.ready && adInfo.instance) {
          return { index: i, adInfo };
        }
      }
      
      // 2. 返回第一个可用的实例
      for (let i = 0; i < this.adInstances.length; i++) {
        const adInfo = this.adInstances[i];
        if (adInfo.instance && !adInfo.error) {
          return { index: i, adInfo };
        }
      }
      
      return null;
    },
    
    // 显示广告
    async showAd() {
      // 获取最优广告
      const bestAd = this.getBestAd();
      
      if (!bestAd) {
        uni.showToast({ 
          title: '暂无可用广告', 
          icon: 'none',
          duration: 2000
        });
        
        // 尝试初始化一个广告
        this.initAd(this.currentAdIndex);
        return;
      }
      
      const { index, adInfo } = bestAd;
      this.currentAdIndex = index;
      
      // 如果广告已就绪，直接显示（秒开）
      if (adInfo.ready) {
        console.log(`🚀 秒开广告位${index + 1}`);
        try {
          await adInfo.instance.show();
          adInfo.ready = false;
          return;
        } catch (err) {
          console.error(`广告位${index + 1} 展示失败:`, err);
        }
      }
      
      // 需要先加载
      console.log(`⏳ 加载广告位${index + 1}...`);
      uni.showLoading({ 
        title: '加载广告中...',
        mask: true 
      });
      
      try {
        await adInfo.instance.load();
        uni.hideLoading();
        
        await adInfo.instance.show();
        adInfo.ready = false;
      } catch (err) {
        uni.hideLoading();
        console.error('广告加载/展示失败:', err);
        
        // 标记错误，尝试下一个广告
        adInfo.error = true;
        this.adErrorCount++;
        
        if (this.adErrorCount < 3) {
          uni.showToast({ 
            title: '广告加载失败，尝试下一个...', 
            icon: 'none',
            duration: 1500
          });
          
          // 短暂延迟后自动尝试下一个广告
          setTimeout(() => {
            this.tryNextAd(index);
            this.showAd(); // 重试
          }, 1000);
        } else {
          uni.showToast({ 
            title: '广告暂时不可用，请稍后重试', 
            icon: 'none',
            duration: 2000
          });
        }
      }
    },
    
    // 批量预加载
    batchPreload(count = 2) {
      let loadedCount = 0;
      
      for (let i = 0; i < this.adInstances.length && loadedCount < count; i++) {
        const adInfo = this.adInstances[i];
        if (adInfo.instance && !adInfo.ready && !adInfo.loading) {
          this.preloadAd(i);
          loadedCount++;
        }
      }
    },
    
    // 获取广告状态
    getAdStatus() {
      return this.adInstances.map((ad, index) => ({
        index: index + 1,
        adpid: ad.adpid,
        status: ad.error ? '错误' : ad.ready ? '就绪' : ad.loading ? '加载中' : '未加载',
        lastLoad: ad.lastLoadTime ? 
          Math.floor((Date.now() - ad.lastLoadTime) / 1000) + '秒前' : 
          '从未加载'
      }));
    },
    
    // 销毁所有广告
    destroyAllAds() {
      this.adInstances.forEach(adInfo => {
        if (adInfo.instance) {
          adInfo.instance.destroy();
        }
      });
      this.adInstances = [];
    },
    
    // 发放奖励
    giveReward() {
      uni.showToast({ 
        title: '奖励已到账！',
        icon: 'success',
        duration: 2000
      });
      
      // 奖励逻辑
      console.log('发放奖励给用户');
      
      // 预加载下一个广告
      this.batchPreload(2);
    }
  }
}
</script>

<style scoped>
.container {
  padding: 30rpx;
}

.ad-btn {
  width: 100%;
  height: 120rpx;
  border-radius: 60rpx;
  border: none;
  font-size: 36rpx;
  font-weight: bold;
  transition: all 0.3s;
  margin: 40rpx 0;
}

.ad-btn.ad-ready {
  background: linear-gradient(135deg, #4CAF50, #45a049);
  color: white;
  box-shadow: 0 8rpx 20rpx rgba(76, 175, 80, 0.3);
}

.ad-btn.ad-loading {
  background: linear-gradient(135deg, #FF9800, #F57C00);
  color: white;
  opacity: 0.9;
}

.ad-btn.ad-error {
  background: linear-gradient(135deg, #9E9E9E, #757575);
  color: white;
  opacity: 0.7;
}

.ad-btn:not(.ad-ready):not(.ad-loading):not(.ad-error) {
  background: linear-gradient(135deg, #2196F3, #1976D2);
  color: white;
}

.ad-btn:active {
  transform: scale(0.98);
}

.ad-btn[disabled] {
  opacity: 0.6;
}

.btn-content {
  display: flex;
  align-items: center;
  justify-content: center;
  gap: 20rpx;
}

.status-box {
  background: #f5f5f5;
  border-radius: 20rpx;
  padding: 30rpx;
  margin-top: 40rpx;
}

.status-title {
  font-size: 30rpx;
  font-weight: bold;
  color: #333;
  margin-bottom: 20rpx;
}

.status-item {
  display: flex;
  justify-content: space-between;
  padding: 20rpx 0;
  border-bottom: 1rpx solid #eee;
  font-size: 28rpx;
}

.status-item:last-child {
  border-bottom: none;
}

.status-item.status-ready {
  color: #4CAF50;
}

.status-item.status-loading {
  color: #FF9800;
}

.status-item.status-error {
  color: #F44336;
}

.status-time {
  color: #999;
  font-size: 24rpx;
}

.tips {
  text-align: center;
  color: #666;
  font-size: 24rpx;
  margin-top: 30rpx;
  padding: 20rpx;
  background: #f8f9fa;
  border-radius: 10rpx;
}
</style>