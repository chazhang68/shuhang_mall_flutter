<template>
	<view class="page">
		<!-- 背景图 -->
		<image class="bg-image" src="/static/bg.jpg" mode="aspectFill"></image>

		<view class="sys-head">
			<view class="sys-bar" :style="{height:sysHeight}"></view>
		</view>
							
		<!-- 顶部标题 -->
	<!-- 	<view class="header">
			<text class="title"></text>
		</view> -->

		<!-- 水壶进度条 -->
		<view class="water-progress" style="margin-top:10px">
			<!-- 水壶图标行 -->
			<view class="pots-row">
				<view class="pot-icon-item" v-for="(pot, index) in waterPots" :key="index">
					<image class="pot-icon" :src="
              index < task_done_count ? '/static/pot_progress_active.png' : '/static/pot_progress_default.png'
            "></image>
				</view>
			</view>

			<!-- 进度槽和圆球（糖葫芦效果） -->
			<view class="progress-track-wrapper">
				<!-- 灰色进度槽 -->
				<view class="progress-track"></view>
				<!-- 红色进度条 -->
				<view class="progress-bar" :style="{ width: getProgressBarWidth() }"></view>
				<!-- 圆球串在进度槽上 -->
				<view class="progress-dots">
					<view class="dot-item-wrapper" v-for="(pot, index) in waterPots" :key="index"
						:class="{ active: index < task_done_count }">
						<view class="dot-item"></view>
					</view>
				</view>
			</view>

			<!-- 状态文字行 -->
			<view class="labels-row">
				<view class="pot-label-item" v-for="(pot, index) in waterPots" :key="index">
					<text class="pot-label" :class="{ active: index < task_done_count }">{{
            index < task_done_count ? '已完成' : '未完成'
          }}</text>
				</view>
			</view>
		</view>

		<!-- 右侧功能按钮 -->
		<view class="right-buttons">
			<view class="btn-item" v-for="(btn, index) in buttons" :key="index" @click="handleButtonClick(btn.type)"
				@touchstart="btn.active = true" @touchend="btn.active = false" >
				<image :src="btn.img" mode="widthFix" style="width: 50px;"></image>
			</view>
		</view>

		<!-- 地块区域 -->
		<scroll-view class="farm-area" scroll-y>
			<view class="plot-wrapper">
				<!-- 地块组件列表 -->
				<view class="plot-item" v-for="(plot, plotIndex) in plotList" :key="'plot-' + plotIndex">
					<!-- 左上角图标 -->
					<!-- <image class="left-icon" :src="'/static/left_icon' + plot.left + '.png'" mode="widthFix"></image> -->

					<!-- 右侧指示牌 -->
					<image class="right-icon" :src="'/static/right_icon' + plot.right + '.png'" mode="widthFix"></image>

					<!-- 田块容器 -->
					<view class="field-container">
						<!-- 田块背景 -->
						<image class="field-bg" :src="'/static/' + plot.fieldType + '.png'" mode="widthFix"></image>

						<!-- 植物层 - 使用绝对定位 -->
						<view class="plants-layer">
							<view v-for="(plant, plantIndex) in plot.plants"
								:key="'plant-' + plotIndex + '-' + plantIndex" class="plant-wrapper"
								:style="getPlantPosition(plot.fieldType, plantIndex)">
								<image class="plant-icon" :src="'/static/plant' + plant.type + '.png'" mode="widthFix">
								</image>
								<!-- 进度条 -->
								<view class="plant-progress">
									<view class="flex justify-between align-center">
										<view class="progress-bg " >
											<view class="progress-fill" :style="{ width: plant.progress + '%' }"></view>
											
										</view>
										<view style="font-size: 10px;color: #333">{{plant.dk_day}}/{{plant.day}}天</view>
									</view>
									<text class="progress-text">已领取{{ plant.score }}</text>
								</view>
							</view>
						</view>
					</view>
				</view>
			</view>
		</scroll-view>

		<!-- 种子商店弹窗 -->
		<view class="popup-mask" v-if="showShopPopup" @click="closeShopPopup">
			<view class="popup-container" @click.stop>
				<!-- 关闭按钮 -->
				<view class="close-btn" @click="closeShopPopup">
					<text class="close-icon">×</text>
				</view>

				<!-- 背景图 -->
				<image class="popup-bg" src="/static/popup_bg.png" mode="widthFix"></image>

				<view class="popup-content">
					<!-- 种子列表 -->
					<view class="seed-list">
						<view class="seed-item" v-for="(seed, index) in seedList" :key="index">
							<text class="seed-name">{{ seed.name }}</text>
							<image class="seed-icon" :src="seed.image"></image>
							<view class="seed-info">
								<text class="seed-detail">预计获得{{ seed.output_num }}积分</text>
								<text class="seed-detail">活跃度：{{ seed.activity }}</text>
								<text class="seed-detail">种子数量：{{seed.count}}/{{seed.limit}}个</text>
							</view>
							<view class="seed-buy-btn" @click="buySeed(seed)">
								<text class="buy-text">{{ seed.dh_num }}积分</text>
							</view>
						</view>
					</view>
				</view>
			</view>
		</view>
		 <ad-rewarded-video ref="adRewardedVideo" adpid="1644506192"  :loadnext="true" @load="onadload" @close="onadclose" @error="onaderror"></ad-rewarded-video>
		<view style="width:100%;height:50px"></view>		
		<view>
			<!-- 普通弹窗 -->
			<uni-popup ref="popup" background-color="#fff" style="" borderRadius="10px 10px 10px 10px" >
				<view class="bg-white p-4 flex align-center flex-column" style="width: 300px;" >
					
					<input class="rounded border w-100 p-2 font" v-model="pwd" maxlength="6" style="height: 40px;" type="password" placeholder="请输入交易密码">
					<view class="font-weight-bold w-100 mt-3 text-white rounded flex align-center justify-center" style="background-color: #f06c6c;height: 40px;" @click="qurenBuy">确认购买</view>
				</view>
			</uni-popup>
		</view>		
			   
		<pageFooter></pageFooter>
	</view>
	
</template>

<script>
	let sysHeight = uni.getSystemInfoSync().statusBarHeight + 'px';
	import {

		getUserInfo,
		lingqu,
		getUserTask,
		watchTv,
		watchOver,
		exchangeTask,
		getTaskData,
		getNewMyTask
	} from '@/api/user.js'
	import pageFooter from '@/components/pageFooter/index.vue'
	export default {
		components: {
			pageFooter
		},
		data() {
			return {
				waterPots: [0, 1, 2, 3, 4, 5, 6, 7], // 8个水壶的索引
				load:false,
				show:false,
				pwd:'',
				// 弹窗显示状态
				showShopPopup: false,
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
				// 田块类型网格布局配置
				fieldLayouts: {
					1: [
						[1]
					],
					2: [
						[1, 1]
					],
					3: [
						[1, 1],
						[0, 1],
					],
					4: [
						[1, 1],
						[1, 1],
					],
					5: [
						[1, 1, 1],
						[1, 1, 0],
					],
					6: [
						[1, 1, 1],
						[1, 1, 1],
					],
					7: [
						[1, 1, 1],
						[1, 1, 1],
						[0, 1, 0],
					],
					8: [
						[1, 1, 1],
						[1, 1, 1],
						[1, 1, 0],
					],
					9: [
						[1, 1, 1],
						[1, 1, 1],
						[1, 1, 1],
					],
					10: [
						[1, 1, 1],
						[1, 1, 1],
						[1, 1, 1, 1],
					],
					11: [
						[1, 1, 1],
						[1, 1, 1],
						[1, 1, 1, 1],
						[0, 0, 1, 0],
					],
					12: [
						[1, 1, 1],
						[1, 1, 1],
						[1, 1, 1, 1],
						[0, 0, 1, 1],
					],
				},
				sysHeight: sysHeight,
				// 田块类型中心位置配置 (考虑45度透视)
				// 格式: { x: '百分比', y: '百分比' }
				fieldCenters: {
					// 田块1: 1个地块
					1: [
						[{
							x: '50%',
							y: '50%'
						}]
					],

					// 田块2: 2个地块 (横向2个)
					2: [
						[{
								x: '33%',
								y: '33%'
							}, // 第1个
							{
								x: '66%',
								y: '66%'
							}, // 第2个
						],
					],

					// 田块3: 3个地块 (第一行2个,第二行右侧1个)
					3: [
						[{
								x: '33%',
								y: '25%'
							}, // 第1行第1个
							{
								x: '66%',
								y: '50%'
							}, // 第1行第2个
						],
						[
							null, // 占位
							{
								x: '33%',
								y: '75%'
							}, // 第2行右侧
						],
					],

					// 田块4: 4个地块 (2x2)
					4: [
						[{
								x: '50%',
								y: '25%'
							}, // 第1行第1个
							{
								x: '75%',
								y: '50%'
							}, // 第1行第2个
						],
						[{
								x: '25%',
								y: '50%'
							}, // 第2行第1个
							{
								x: '50%',
								y: '75%'
							}, // 第2行第2个
						],
					],

					// 田块5: 5个地块 (第一行3个,第二行右侧2个)
					5: [
						[{
								x: '40%',
								y: '25%'
							}, // 第1行第1个
							{
								x: '60%',
								y: '50%'
							}, // 第1行第2个
							{
								x: '80%',
								y: '75%'
							}, // 第1行第3个
						],
						[{
								x: '20%',
								y: '50%'
							}, // 第2行第2个
							{
								x: '40%',
								y: '75%'
							}, // 第2行第3个
							null, // 占位
						],
					],

					// 田块6: 6个地块 (3x2)
					6: [
						[{
								x: '40%',
								y: '20%'
							}, // 第1行第1个
							{
								x: '60%',
								y: '40%'
							}, // 第1行第2个
							{
								x: '80%',
								y: '60%'
							}, // 第1行第3个
						],
						[{
								x: '20%',
								y: '40%'
							}, // 第2行第1个
							{
								x: '40%',
								y: '60%'
							}, // 第2行第2个
							{
								x: '60%',
								y: '80%'
							}, // 第2行第3个
						],
					],

					// 田块7: 7个地块 (第1-2行各3个,第3行中间1个)
					7: [
						[{
								x: '40%',
								y: '20%'
							}, // 第1行第1个
							{
								x: '60%',
								y: '40%'
							}, // 第1行第2个
							{
								x: '80%',
								y: '60%'
							}, // 第1行第3个
						],
						[{
								x: '20%',
								y: '40%'
							}, // 第2行第1个
							{
								x: '40%',
								y: '60%'
							}, // 第2行第2个
							{
								x: '60%',
								y: '80%'
							}, // 第2行第3个
						],
						[
							null, // 占位
							{
								x: '20%',
								y: '80%'
							}, // 第3行中间
							null, // 占位
						],
					],

					// 田块8: 8个地块 (第1-2行各3个,第3行左侧2个)
					8: [
						[{
								x: '50%',
								y: '20%'
							}, // 第1行第1个
							{
								x: 'calc(4 / 6 * 100%)',
								y: '40%'
							}, // 第1行第2个
							{
								x: 'calc(5 / 6 * 100%)',
								y: '60%'
							}, // 第1行第3个
						],
						[{
								x: 'calc(2 / 6 * 100%)',
								y: '40%'
							}, // 第2行第1个
							{
								x: '50%',
								y: '60%'
							}, // 第2行第2个
							{
								x: 'calc(4 / 6 * 100%)',
								y: '80%'
							}, // 第2行第3个
						],
						[{
								x: 'calc(1 / 6 * 100%)',
								y: '60%'
							}, // 第3行第1个
							{
								x: 'calc(2 / 6 * 100%)',
								y: '80%'
							}, // 第3行第2个
							null, // 占位
						],
					],

					// 田块9: 9个地块 (3x3)
					9: [
						[{
								x: '50%',
								y: 'calc(1 / 6 * 100%)'
							}, // 第1行第1个
							{
								x: 'calc(4 / 6 * 100%)',
								y: 'calc(2 / 6 * 100%)'
							}, // 第1行第2个
							{
								x: 'calc(5 / 6 * 100%)',
								y: 'calc(3 / 6 * 100%)'
							}, // 第1行第3个
						],
						[{
								x: 'calc(2 / 6 * 100%)',
								y: 'calc(2 / 6 * 100%)'
							}, // 第2行第1个
							{
								x: '50%',
								y: 'calc(3 / 6 * 100%)'
							}, // 第2行第2个
							{
								x: 'calc(4 / 6 * 100%)',
								y: 'calc(4 / 6 * 100%)'
							}, // 第2行第3个
						],
						[{
								x: 'calc(1 / 6 * 100%)',
								y: 'calc(3 / 6 * 100%)'
							}, // 第3行第1个
							{
								x: 'calc(2 / 6 * 100%)',
								y: 'calc(4 / 6 * 100%)'
							}, // 第3行第2个
							{
								x: '50%',
								y: 'calc(5 / 6 * 100%)'
							}, // 第3行第3个
						],
					],

					// 田块10: 10个地块 (第1-2行各3个,第3行4个)
					10: [
						[{
								x: '50%',
								y: 'calc(1 / 7 * 100%)'
							}, // 第1行第1个
							{
								x: 'calc(4 / 6 * 100%)',
								y: 'calc(2 / 7 * 100%)'
							}, // 第1行第2个
							{
								x: 'calc(5 / 6 * 100%)',
								y: 'calc(3 / 7 * 100%)'
							}, // 第1行第3个
						],
						[{
								x: 'calc(2 / 6 * 100%)',
								y: 'calc(2 / 7 * 100%)'
							}, // 第2行第1个
							{
								x: '50%',
								y: 'calc(3 / 7 * 100%)'
							}, // 第2行第2个
							{
								x: 'calc(4 / 6 * 100%)',
								y: 'calc(4 / 7 * 100%)'
							}, // 第2行第3个
						],
						[{
								x: 'calc(1 / 6 * 100%)',
								y: 'calc(3 / 7 * 100%)'
							}, // 第3行第1个
							{
								x: 'calc(2 / 6 * 100%)',
								y: 'calc(4 / 7 * 100%)'
							}, // 第3行第2个
							{
								x: '50%',
								y: 'calc(5 / 7 * 100%)'
							}, // 第3行第3个
							{
								x: 'calc(4 / 6 * 100%)',
								y: 'calc(6 / 7 * 100%)'
							}, // 第3行第4个
						],
					],

					// 田块11: 11个地块 (第1-2行各3个,第3行4个,第4行中间1个)
					11: [
						[{
								x: '50%',
								y: 'calc(1 / 7 * 100%)'
							}, // 第1行第1个
							{
								x: 'calc(4 / 6 * 100%)',
								y: 'calc(2 / 7 * 100%)'
							}, // 第1行第2个
							{
								x: 'calc(5 / 6 * 100%)',
								y: 'calc(3 / 7 * 100%)'
							}, // 第1行第3个
						],
						[{
								x: 'calc(2 / 6 * 100%)',
								y: 'calc(2 / 7 * 100%)'
							}, // 第2行第1个
							{
								x: '50%',
								y: 'calc(3 / 7 * 100%)'
							}, // 第2行第2个
							{
								x: 'calc(4 / 6 * 100%)',
								y: 'calc(4 / 7 * 100%)'
							}, // 第2行第3个
						],
						[{
								x: 'calc(1 / 6 * 100%)',
								y: 'calc(3 / 7 * 100%)'
							}, // 第3行第1个
							{
								x: 'calc(2 / 6 * 100%)',
								y: 'calc(4 / 7 * 100%)'
							}, // 第3行第2个
							{
								x: '50%',
								y: 'calc(5 / 7 * 100%)'
							}, // 第3行第3个
							{
								x: 'calc(4 / 6 * 100%)',
								y: 'calc(6 / 7 * 100%)'
							}, // 第3行第4个
						],
						[
							null, // 占位
							null, // 占位
							{
								x: 'calc(2 / 6 * 100%)',
								y: 'calc(6 / 7 * 100%)'
							}, // 第4行中间
							null, // 占位
						],
					],

					// 田块12: 12个地块 (第1-2行各3个,第3行4个,第4行右侧2个)
					12: [
						[{
								x: 'calc(3 / 6 * 100%)',
								y: 'calc(1 / 8 * 100%)'
							}, // 第1行第1个
							{
								x: 'calc(4 / 6 * 100%)',
								y: 'calc(2 / 8 * 100%)'
							}, // 第1行第2个
							{
								x: 'calc(5 / 6 * 100%)',
								y: 'calc(3 / 8 * 100%)'
							}, // 第1行第3个
						],
						[{
								x: 'calc(2 / 6 * 100%)',
								y: 'calc(2 / 8 * 100%)'
							}, // 第2行第1个
							{
								x: 'calc(3 / 6 * 100%)',
								y: 'calc(3 / 8 * 100%)'
							}, // 第2行第2个
							{
								x: 'calc(4 / 6 * 100%)',
								y: 'calc(4 / 8 * 100%)'
							}, // 第2行第3个
						],
						[{
								x: 'calc(1 / 6 * 100%)',
								y: 'calc(3 / 8 * 100%)'
							}, // 第3行第1个
							{
								x: 'calc(2 / 6 * 100%)',
								y: 'calc(4 / 8 * 100%)'
							}, // 第3行第2个
							{
								x: 'calc(3 / 6 * 100%)',
								y: 'calc(5 / 8 * 100%)'
							}, // 第3行第3个
							{
								x: 'calc(4 / 6 * 100%)',
								y: 'calc(6 / 8 * 100%)'
							}, // 第3行第4个
						],
						[
							null, // 占位
							null, // 占位
							{
								x: 'calc(2 / 6 * 100%)',
								y: 'calc(6 / 8 * 100%)'
							}, // 第4行第3个
							{
								x: 'calc(3 / 6 * 100%)',
								y: 'calc(7 / 8 * 100%)'
							}, // 第4行第4个
						],
					],
				},

				// 右侧按钮
				buttons: [{
						type: 'water',
						label: '浇水',
						active: false,
						img:'/static/jiaoshui.png'
					},
					{
						type: 'seed',
						label: '播种',
						active: false,
						img:'/static/bozhong.png'
					},
					{
						type: 'points',
						label: '积分',
						active: false,
						img:'/static/jifen.png'
					},
					{
						type: 'SWP',
						label: 'SWP',
						active: false,
						img:'/static/swp.png'
					},
				],

				///////////下边的变量，都是通过接口加载过来的数据。如果不符合当前数据库的设计，也可以按下边的结构和字段，拼装设置一下///////////

				// 水壶进度
				task_done_count: 0, // 完成数量 (0-8)

				// 弹窗里显示的种子列表
				seedList: [],

				// 地块列表（通过接口加载过来的数据，拼装而成。）
				// 左侧图标: /static/left_icon${left}.png
				// 右侧图标: /static/right_icon${right}.png
				// 田块背景: /static/${fieldType}.png
				// plants是当前这个田块中各个地块上种植的蔬菜
				// 植物图标: /static/plant${type}.png
				plotList: [
					
				],
				taskData: [],
				taskList: [],
				userInfo: [],
				all_jf: 0,
				all_rlz: 0,
				num: 1,
				info:[],
				click:false
			}
		},

		onLoad() {
			this.getTaskList()
			this.getUserInfo()
			this.getMyTask()
			this.initAllAds();
		},
		onShow() {
			if (!this.adReady && !this.adLoading) {
			  this.preloadNextAd();
			}
		},
		onReady() {
		
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
			  let that = this;
			  if (!that.userInfo.is_sign) {
			  	uni.showToast({
			  		title: "请先实名认证哦",
			  		icon: "none"
			  	})
			  	setTimeout(function() {
			  		uni.navigateTo({
			  			url: "/pages/sign/sign"
			  		})
			  	}, 1000)
				return;
			  } 
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
				let that = this;
			  watchOver().then(res => {
			  	
			  	setTimeout(() => {
			  		that.getUserInfo()
			  		setTimeout(()=>{
			  			if(that.task_done_count == 8){
			  				//领取奖励
			  				that.lingqu()
			  			}
			  		},1000)
			  		
			  	}, 500)
			  })
			  // 预加载下一个广告
			  this.batchPreload(2);
			},
			getMyTask(){				
				let that = this;
				getNewMyTask().then(res=>{
					that.plotList = that.SplitArray(res.data, that.myTaskList);
				 }).catch(e=>{
					uni.showToast({
						title:e,
						icon:"none"
					})
				})
			},
			SplitArray(list, sp) {
				if (typeof list != 'object') return [];
				if (sp === undefined) sp = [];
				for (var i = 0; i < list.length; i++) {
					sp.push(list[i]);
				}
				return sp;
			},
			OkDH() {
				let that = this;
				let num = that.num
				if (num == 0) {
					return uni.showToast({
						title: "最少兑换一个包",
						icon: 'none'
					})
				}
				if (Number(this.userInfo.fudou) < (Number(this.info.dh_num) * num)) {
					return uni.showToast({
						title: "积分不够哦",
						icon: 'none'
					})
				}

				if (this.click) return;
				this.click = true;
				uni.showLoading({
					title: "兑换中"
				})

				exchangeTask({
					task_id: this.info.id,
					num: num,
					pwd:that.pwd
				}, true).then(res => {
					uni.hideLoading()
					if (res.status == 200) {
						uni.showToast({
							title: '兑换成功'
						})
						that.num = 1;
						that.$refs.popup.close()
						that.pwd = ''
						setTimeout(function() {
							that.getTaskList()
							that.getUserInfo()
							that.getMyTask()
						}, 1000)
					}
					that.click = false;
				}).catch(res => {
					uni.hideLoading()
					that.$refs.popup.close()
					that.pwd = ''
					uni.showToast({
						title: res,
						icon: "none"
					})
					that.click = false
				})
			},

			getTaskList() {

				getUserTask().then(res => {
					this.seedList = res.data

				})
			},
			getTaskData() {
				getTaskData().then(res => {
					this.taskData = res.data
				})
			},
			// 获取植物的绝对定位位置(根据透视中心配置)
			getPlantPosition(fieldType, plantIndex) {
				const layout = this.fieldLayouts[fieldType]
				const centers = this.fieldCenters[fieldType]
				if (!layout || !centers) return ''

				// 遍历 layout 找到第 plantIndex 个有效地块的位置
				let count = 0
				for (let rowIndex = 0; rowIndex < layout.length; rowIndex++) {
					for (let colIndex = 0; colIndex < layout[rowIndex].length; colIndex++) {
						if (layout[rowIndex][colIndex] === 1) {
							if (count === plantIndex) {
								const center = centers[rowIndex][colIndex]
								if (center) {
									return `position: absolute; left: ${center.x}; top: ${center.y}; transform: translate(-50%, -100%);`
								}
							}
							count++
						}
					}
				}
				return ''
			},

			// 处理按钮点击
			handleButtonClick(type) {
				if (type === 'seed') {
					this.showShopPopup = true
				} else if (type === 'water') {
					if(this.task_done_count >= 8){
						this.lingqu()
					}else{
						this.showAd()
					}
				} else if (type === 'points') {
					uni.navigateTo({
						url: '/pages/users/ryz/ryz?index=1',
						animationDuration:100,
						animationType:"fade-in",
					})
				} else if (type === 'SWP') {
					uni.navigateTo({
						url: '/pages/users/ryz/ryz?index=0',
						animationDuration:100,
						animationType:"fade-in",
					})
				}
			},
			lingqu() {
				let that = this;
				if (that.load) return;
				that.load = true;
				uni.showLoading({
					title: '领取中'
				})
			
				lingqu().then(res => {
					uni.hideLoading()
					that.getUserInfo()
					uni.showToast({
						title: '今日任务已完成，请查看您的奖励！',
						icon: 'none'
					})
			
					that.load = false;
					that.getMyTask()
					that.getTaskList()
					that.getUserInfo()
					
				}).catch(e => {
					uni.hideLoading()
					uni.showToast({
						title: e,
						icon: 'none'
					})
					that.load = false;
				})
			},
			
			// 关闭商店弹窗
			closeShopPopup() {
				this.showShopPopup = false
			},

			// 购买种子
			buySeed(info) {
				this.info = info
				this.$refs.popup.open('center')
				
			},
			qurenBuy(){
				if(!this.pwd){
					return uni.showToast({
						title:'请输入交易密码',
						icon:'none'
					})
				}
				
				this.OkDH()
			},
			getUserInfo() {
				getUserInfo().then(res => {
					this.userInfo = res.data
					uni.stopPullDownRefresh()
					if (!res.data.is_sign) {
						uni.showToast({
							title: "请先实名认证哦",
							icon: "none"
						})
						if (!uni.getStorageSync('ist')) {
							uni.setStorageSync('ist', true)
							setTimeout(function() {
								uni.navigateTo({
									url: "/pages/sign/sign"
								})
							}, 1000)
							return;
						}

					}
					this.task_done_count = res.data.task
				
				})
			},

			// 计算进度条宽度
			getProgressBarWidth() {
				if (this.task_done_count <= 0) return '0rpx'

				const totalPots = this.waterPots.length
				const dotWrapperWidth = 44 // 每个圆球wrapper的宽度 (rpx)
				const dotRadius = 7 // 圆球半径 (rpx)

				const doneIndex = this.task_done_count - 1 // 0-7

				if (doneIndex === 0) {
					// 第1个圆球中心在 dotWrapperWidth/2 位置
					return `${dotWrapperWidth / 2 + dotRadius}rpx`
				} else if (doneIndex === totalPots - 1) {
					// 第8个圆球中心在 100% - dotWrapperWidth/2 位置
					return `100%`
				}

				// 进度条宽度 = 圆球中心位置 + 圆球半径
				const fraction = doneIndex / (totalPots - 1)
				return `calc(${dotWrapperWidth / 2 + dotRadius}rpx + ${fraction} * (100% - ${dotWrapperWidth}rpx))`
			},
		},
		onPullDownRefresh() {
			this.getUserInfo()
		},
	}
</script>

<style scoped>

	.uni-popup{
		z-index: 100!important;
	}
	uni-page-body{
		height: 100%;
	}
	.page {
	  width: 100vw;
	  height: 100%;
	  position: relative;
	  overflow: hidden;
	}

	.bg-image {
		position: absolute;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		z-index: 0;
	}

	/* 顶部标题 */
	.header {
		position: relative;
		z-index: 1;
		padding-top: 40rpx;
		text-align: center;
	}

	.title {
		font-size: 60rpx;
		font-weight: bold;
		color: #333;
		text-shadow: 2rpx 2rpx 4rpx rgba(255, 255, 255, 0.8);
	}

	/* 水壶进度条 */
	.water-progress {
		position: relative;
		z-index: 1;
		padding: 20rpx 24rpx 16rpx;
		margin: 20px;
		/* 右侧留空间给按钮，左侧也稍微减小 */
		background: rgba(255, 255, 255, 0.7);
		border-radius: 16rpx;
		border: 2rpx solid rgba(255, 255, 255, 0.9);
		box-shadow: 0 4rpx 16rpx rgba(0, 0, 0, 0.08);
		display: flex;
		flex-direction: column;
		align-items: center;
	}

	/* 水壶图标行 */
	.pots-row {
		display: flex;
		flex-direction: row;
		justify-content: space-between;
		align-items: center;
		width: 100%;
		padding: 0 6rpx;
	}

	.pot-icon-item {
		display: flex;
		justify-content: center;
		align-items: center;
	}

	.pot-icon {
		width: 60rpx;
		height: 60rpx;
	}

	/* 进度槽容器 - 糖葫芦效果 */
	.progress-track-wrapper {
		position: relative;
		width: 100%;
		height: 20rpx;
		margin-top: 8rpx;
		display: flex;
		align-items: center;
	}

	/* 灰色进度槽 */
	.progress-track {
		position: absolute;
		left: 0;
		right: 0;
		height: 4rpx;
		background: #d8d8d8;
		border-radius: 2rpx;
		z-index: 1;
	}

	/* 红色进度条 */
	.progress-bar {
		position: absolute;
		left: 0;
		height: 4rpx;
		background: linear-gradient(90deg, #ff6b6b 0%, #ff4757 100%);
		border-radius: 2rpx;
		z-index: 2;
		transition: width 0.3s ease;
		box-shadow: 0 2rpx 6rpx rgba(255, 71, 87, 0.3);
	}

	/* 圆球容器 */
	.progress-dots {
		position: absolute;
		left: 0;
		right: 0;
		display: flex;
		justify-content: space-between;
		align-items: center;
		z-index: 3;
	}

	.dot-item-wrapper {
		width: 44rpx;
		display: flex;
		justify-content: center;
	}

	/* 圆球 */
	.dot-item {
		width: 14rpx;
		height: 14rpx;
		border-radius: 50%;
		background: #d8d8d8;
		border: 2rpx solid #fff;
		box-shadow: 0 1rpx 4rpx rgba(0, 0, 0, 0.1);
		transition: all 0.3s ease;
	}

	.dot-item-wrapper.active .dot-item {
		background: linear-gradient(135deg, #ff6b6b 0%, #ff4757 100%);
		box-shadow: 0 2rpx 8rpx rgba(255, 71, 87, 0.5);
		transform: scale(1.2);
	}

	/* 状态文字行 */
	.labels-row {
		display: flex;
		flex-direction: row;
		justify-content: space-between;
		align-items: center;
		width: 100%;
		padding: 0 6rpx;
		margin-top: 6rpx;
	}

	.pot-label-item {
		display: flex;
		justify-content: center;
		align-items: center;
		width: 44rpx;
	}

	.pot-label {
		font-size: 11px;
		color: #999;
		transition: color 0.3s ease;
		white-space: nowrap;
	}

	.pot-label.active {
		color: #ff6b6b;
		font-weight: bold;
	}

	/* 右侧按钮 */
	.right-buttons {
		position: fixed;
		right: 20rpx;
		top: 35%;
		transform: translateY(-50%);
		z-index: 10;
		display: flex;
		flex-direction: column;
		gap: 20rpx;
	}

	.btn-item {
	
		cursor: pointer;
	}

	/* 地块区域 */
	.farm-area {
		position: relative;
		z-index: 1;
		height: calc(100vh - 300rpx);
		padding: 20rpx;
		margin-top:45px
	}

	.plot-wrapper {
		min-height: 100%;
		display: flex;
		flex-direction: column;
		gap: 30rpx;
		padding-bottom: 40rpx;
	}

	.plot-item {
		position: relative;
		width: 100%;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	/* 左上角图标 */
	.left-icon {
		position: absolute;
		left: 0;
		top: 0;
		width: 100rpx;
		height: auto;
		z-index: 3;
	}

	/* 右侧指示牌 */
	.right-icon {
		position: absolute;
		right: -20rpx;
		top: 20rpx;
		width: 120rpx;
		height: auto;
		z-index: 3;
	}

	/* 田块容器 */
	.field-container {
		position: relative;
		width: 500rpx;
		height: auto;
	}

	/* 田块背景 */
	.field-bg {
		width: 100%;
		height: auto;
		display: block;
	}

	/* 植物层 */
	.plants-layer {
		position: absolute;
		top: 0;
		left: 0;
		width: 100%;
		height: 100%;
		z-index: 2;
	}

	/* 植物包装器 */
	.plant-wrapper {
		position: absolute;
		display: flex;
		flex-direction: column;
		align-items: center;
	}

	/* 植物图标 */
	.plant-icon {
		width: 80rpx;
		height: auto;
	}

	/* 进度条容器 */
	.plant-progress {
		position: relative;
		background: rgba(255, 255, 255, 0.95);
		border-radius: 20rpx;
		padding: 6rpx 12rpx;
		box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.1);
		white-space: nowrap;
	}

	.progress-bg {
		width: 100rpx;
		height: 12rpx;
		background: #e0e0e0;
		border-radius: 6rpx;
		overflow: hidden;
		margin-bottom: 4rpx;
	}

	.progress-fill {
		height: 100%;
		background: linear-gradient(90deg, #7dd87d 0%, #4eb84e 100%);
		border-radius: 6rpx;
		transition: width 0.3s ease;
	}

	.progress-text {
		font-size: 16rpx;
		color: #666;
		line-height: 1;
		display: block;
		text-align: center;
	}

	/* 弹窗 */
	.popup-mask {
		position: fixed;
		top: 0;
		left: 0;
		right: 0;
		bottom: 0;
		background: rgba(0, 0, 0, 0.5);
		z-index: 10;
		display: flex;
		align-items: center;
		justify-content: center;
	}

	.popup-container {
		width: 600rpx;
		position: relative;
	}

	.popup-bg {
		width: 100%;
		height: auto;
		display: block;
	}

	.popup-content {
		position: absolute;
		top: 27%;
		left: 5%;
		right: 5%;
		bottom: 7%;
	}

	.close-btn {
		position: absolute;
		right: -10rpx;
		top: -10rpx;
		width: 50rpx;
		height: 50rpx;
		background: rgba(255, 255, 255, 0.95);
		border-radius: 50%;
		display: flex;
		align-items: center;
		justify-content: center;
		box-shadow: 0 2rpx 8rpx rgba(0, 0, 0, 0.2);
		z-index: 10;
	}

	.close-icon {
		font-size: 32rpx;
		color: #999;
		font-weight: normal;
		line-height: 1;
	}

	.seed-list {
		display: grid;
		grid-template-columns: repeat(2, 1fr);
		gap: 16rpx;
		overflow-y: auto;
		height: 100%;
	}

	.seed-item {
		background: linear-gradient(180deg, #fffef8 0%, #fff9e6 100%);
		border-radius: 16rpx;
		padding: 16rpx 12rpx;
		display: flex;
		flex-direction: column;
		align-items: center;
		box-shadow: 0 4rpx 12rpx rgba(0, 0, 0, 0.06);
	}

	.seed-name {
		display: block;
		font-size: 24rpx;
		font-weight: bold;
		color: #333;
		margin-bottom: 10rpx;
		text-align: center;
	}

	.seed-icon {
		width: 80rpx;
		height: 80rpx;
		margin-bottom: 12rpx;
	}

	.seed-info {
		width: 100%;
		margin-bottom: 10rpx;
	}

	.seed-detail {
		display: block;
		font-size: 20rpx;
		color: #666;
		margin-bottom: 4rpx;
		line-height: 1.3;
	}

	.seed-buy-btn {
		width: 100%;
		height: 48rpx;
		background: linear-gradient(180deg, #7dd87d 0%, #4eb84e 100%);
		border-radius: 24rpx;
		display: flex;
		align-items: center;
		justify-content: center;
		box-shadow: 0 4rpx 8rpx rgba(68, 170, 68, 0.3);
		margin-top: auto;
	}

	.buy-text {
		font-size: 22rpx;
		color: #fff;
		font-weight: bold;
	}
</style>