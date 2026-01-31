<template>
	<view>
		<view class="Rboy-box">
			<view class="Rboy-obverse">
				<image class="obverseimg" :src="obverseUrl ? obverseUrl : obverse" @click="obverse_btn" mode="">
				</image>
				<image class="del_btn" :src="del" mode="" v-if="obverseUrl" @click="del_btn('obverse')"></image>
				<view class="bottom">
					<text>请上传头像面</text>
				</view>
			</view>
			<view class="Rboy-reverse">
				<image class="reverseimg" :src="reverseUrl ? reverseUrl : reverse" @click="reverse_btn" mode="">
				</image>
				<image class="del_btn" :src="del" mode="" v-if="reverseUrl" @click="del_btn('reverse')"></image>
				<view class="bottom">
					<text>请上传国徽面</text>
				</view>
			</view>
		</view>
	</view>
</template>

<script>
  import file from './file'
	export default {
		name: "Rboy-upload-sfz",
		props: {
			// 正面
			obverseUrl: {
				type: String,
				default: ""
			},
			// 反面
			reverseUrl: {
				type: String,
				default: ""
			},
			// album 从相册选图，camera 使用相机，默认二者都有。如需直接开相机或直接选相册，请只使用一个选项
			sourceType: {
				type: Array || Object,
				default: () => {
					return ['album', 'camera']
				}
			}
		},
		data() {
			return {
				obverse: "/static/sfz-shenhe/zheng.png",
				reverse: "/static/sfz-shenhe/fan.png",
				del: file.del,
			}
		},
		created() {

		},
		methods: {
			obverse_btn() {
				if (this.obverseUrl) {
					// 预览
					this.previewImage(this.obverseUrl)
				} else {
					// 上传
					this.uploadpic("obverse")
				}
			},
			reverse_btn() {
				if (this.reverseUrl) {
					// 预览
					this.previewImage(this.reverseUrl)
				} else {
					// 上传
					this.uploadpic("reverse")
				}
			},
			// // 上传
			// select_change(name) {
			// 	uni.chooseImage({
			// 		count: 1, //默认9
			// 		sizeType: ['original', 'compressed'], // 可以指定是原图还是压缩图，默认二者都有
			// 		sourceType: this.sourceType, // 从相册选择
			// 		success: (res) => {
      //       console.log(res)
			// 			this.$emit("selectChange", {
			// 				msg: `${name}Image:ok`,
			// 				name,
			// 				tempFilePath: res.tempFilePaths[0],
			// 				tempFile: res.tempFiles[0]
			// 			})
			// 		}
			// 	});
			// },
			// 预览
			previewImage(current = 0) {
				uni.previewImage({
					current,
					urls: [this.obverseUrl, this.reverseUrl],
				});
			},
			// 删除
			del_btn(name) {
				console.log(name)
				this.$emit("del", {
					name,
				})
			},
      /**
       * 上传文件
       *
       */
      uploadpic(name) {
        let that = this;
        this.canvasStatus = true
        that.$util.uploadImageChange('upload/image', (res) => {
          this.$emit("selectChange", {
            msg: `${name}Image:ok`,
            name,
            tempFilePath: res.data.url
          })
        }, (res) => {
          this.canvasStatus = false
        }, (res) => {
          this.canvasWidth = res.w
          this.canvasHeight = res.h
        });
      },
		}
	}
</script>

<style scoped lang="less">
	@imgWidth: 327rpx;
	@imgheight: 203rpx;
	@boxheight: 280rpx;

	.Rboy-box {
		display: flex;
		justify-content: space-between;
		// align-items: center;

		.Rboy-obverse {
			border-radius: 10rpx;
			width: @imgWidth;
			height: @boxheight;
			overflow: hidden;
			display: flex;
			flex-direction: column;
			position: relative;
      margin-right: 30rpx;

			.obverseimg {
				width: @imgWidth;
				height: @imgheight;
			}

			.bottom {
				text-align: center;
				height: calc(@boxheight - @imgheight);
				display: flex;
				align-items: center;
        font-weight: 500;
        font-size: 22rpx;
        color: #555555;
				justify-content: center;
			}

			.del_btn {
				position: absolute;
				top: 5rpx;
				right: 5rpx;
				width: 50rpx;
				height: 50rpx;
				border-radius: 50%;
				z-index: 20;
			}
		}

		.Rboy-reverse {
			border-radius: 10rpx;
			width: @imgWidth;
			height: @boxheight;
			overflow: hidden;
			display: flex;
			flex-direction: column;
			position: relative;

			.reverseimg {
				width: @imgWidth;
				height: @imgheight;
			}

			.bottom {
				text-align: center;
				height: calc(@boxheight - @imgheight);
        font-weight: 500;
        font-size: 22rpx;
        color: #555555;
				display: flex;
				align-items: center;
				justify-content: center;
			}

			.del_btn {
				position: absolute;
				top: 5rpx;
				right: 5rpx;
				width: 50rpx;
				height: 50rpx;
				border-radius: 50%;
				z-index: 20;
			}
		}
	}
</style>
