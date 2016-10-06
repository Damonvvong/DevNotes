# 仿微信小视屏   iOS 技术路线实践笔记[录制篇]


> 一周之前拿到这个需求时，我当时是懵逼的，因为自己对 **视频** 这一块几乎可以说是一无所知。在断断续续一周的研究过程之后，准备写点笔记记录一下。

## 需求分析

- 对于一个类似微信小视屏的功能，大致需要完成的功能无非就是两块:

    - 视频录制
    - 视频播放

---

## 先讲讲视频录制 - 技术路线

> （因为自己对视频是个小白，只能借助谷歌来搜索一些相关技术，一定有什么不对的地方）

- 在 iOS 中与视频录制相关的技术大概有三种：

    - **UIImagePickerController**：这是系统相机的控制器，使用很简单，但是可定制程度几乎为零。
    - **AVFoundation**:是一个可以用来使用和创建基于时间的视听媒体的框架，它提供了一个能使用基于时间的视听数据的接口。
    - **ffmpeg**:一套可以用来记录、转换数字音频、视频，并能将其转化为流的开源计算机程序。

>  看上去很懵逼是不是，其实我也是懵逼的。更甚至于AVFoundation 和 ffmpeg 两者关系我最开始都摸不透。如果你和我一样懵逼可以看一下。我写的[AVFoundation](https://github.com/Damonvvong/iOSDevNotes/blob/master/Notes/videorecoder.md#AVFoundation)和视频捕捉相关的总结。ffmpeg 则 需要去看[雷神](http://blog.csdn.net/leixiaohua1020/article/details/47071547)的博客了,很详细,也很入门。

- 对于以上三种，首先**UIImagePickerController**肯定不在考虑范围之内了，可定制化太低。
- 对于利用相机录取视频只能用 **AVFoundation** 的  **AVCaptureSession** 来捕捉。
- **ffmpeg** 技术更注重于**后期**处理技术。关于后期处理，**ffmpeg** 应该是目前最强大的视频处理技术了，利用CPU做视频的编码和解码，俗称为软编软解，目前很火的直播技术应该都是用的**ffmpeg**。
- 此外，对于**AVFoundation** 而言，因为是苹果自己提供的视频处理库，也可以用于视频后期处理而且还支持硬件编码。

---

## 废话不多说，上代码。

> 对于 AVFoundation 捕捉只是还不是很清楚的可以点击[这里](https://github.com/Damonvvong/iOSDevNotes/blob/master/Notes/videorecoder.md#AVFoundation1)查看。
> - [Demo1](https://github.com/Damonvvong/iOSDevNotes/tree/master/Demo/VideoRecoderDemo)下载链接

### 录制前的准备工作

- 第(1/5)步，你得有一个 **AVCaptureSession**[?](https://github.com/Damonvvong/iOSDevNotes/blob/master/Notes/videorecoder.md#AVCaptureSession) 对象，作为 输入、输出的 **中间件**。

```objc
@property (nonatomic, strong) AVCaptureSession *captureSession;/**< 捕捉会话 */
self.captureSession = ({
    // 分辨率设置
  AVCaptureSession *session = [[AVCaptureSession alloc] init];
    if ([session canSetSessionPreset:AVCaptureSessionPresetHigh]) {
        [session setSessionPreset:AVCaptureSessionPresetHigh];
    }
    session;	
});	
```

- 第(2/5)步,你得有将 **摄像头** 和 **话筒** 两个**AVCaptureDevice**[?](#AVCaptureDevice)添加到 **AVCaptureSession** 的 **AVCaptureDeviceInput** [?](#AVCaptureDeviceInput)中。

```objc
/// 初始化 捕捉输入
- (BOOL)setupSessionInputs:(NSError **)error {
	
	// 添加 摄像头
	AVCaptureDeviceInput *videoInput = [AVCaptureDeviceInput deviceInputWithDevice:({
		
		[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
		
	}) error:error];
	
	if (!videoInput) { return NO; }
	
	if ([self.captureSession canAddInput:videoInput]) {
		[self.captureSession addInput:videoInput];
	}else{
		return NO;
	}
	
	// 添加 话筒
	AVCaptureDeviceInput *audioInput = [AVCaptureDeviceInput deviceInputWithDevice:({
		
		[AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeAudio];
		
	}) error:error];
	
	if (!audioInput)  { return NO; }
	
	if ([self.captureSession canAddInput:audioInput]) {
		[self.captureSession addInput:audioInput];
	}else{
		return NO;
	}
	
	return YES;
}
```

- 第(3/5)步，你需要有一个视频输出 **AVCaptureMovieFileOutput** [?](#AVCaptureOutput)用于从**AVCaptureDevice**获得的数据输出到文件中。

```objc
    //初始化设备输出对象，用于获得输出数据
	self.captureMovieFileOutput = ({
		AVCaptureMovieFileOutput *output = [[AVCaptureMovieFileOutput alloc]init];
		// 设置录制模式
		AVCaptureConnection *captureConnection=[output connectionWithMediaType:AVMediaTypeVideo];
		if ([captureConnection isVideoStabilizationSupported ]) {
			captureConnection.preferredVideoStabilizationMode = AVCaptureVideoStabilizationModeAuto;
		}
		//将设备输出添加到会话中
		if ([self.captureSession canAddOutput:output]) {
			[self.captureSession addOutput:output];
		}
		output;
	});
```

- 第(4/5)步，你得有一个 **AVCaptureVideoPreviewLayer** [?](#AVCaptureVideoPreviewLayer)的视图，用于预览 **AVCaptureDevice** 拿到的界面。

```objc
@property (nonatomic, strong) AVCaptureVideoPreviewLayer *captureVideoPreviewLayer; /**< 相机拍摄预览图层 */
	//创建视频预览层，用于实时展示摄像头状态
	self.captureVideoPreviewLayer = ({
		AVCaptureVideoPreviewLayer *previewLayer = [[AVCaptureVideoPreviewLayer alloc]initWithSession:self.captureSession];
		previewLayer.frame=  CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
		previewLayer.videoGravity=AVLayerVideoGravityResizeAspectFill;//填充模式
		[self.view.layer addSublayer:previewLayer];
		self.view.layer.masksToBounds = YES;
		previewLayer;
		
	});
```
- 第(5/5)步,现在你调用 ` [self.captureSession startRunning]; ` 真机运行就可以看到一个录制画面了。

### 录制视频
用 AVCaptureMovieFileOutput 录制视频很简单。代码如下。

```objc

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event{
	if (![self.captureMovieFileOutput isRecording]) {
		AVCaptureConnection *captureConnection=[self.captureMovieFileOutput connectionWithMediaType:AVMediaTypeVideo];
		captureConnection.videoOrientation=[self.captureVideoPreviewLayer connection].videoOrientation;
		[self.captureMovieFileOutput startRecordingToOutputFileURL:({
			// 录制 缓存地址。
			NSURL *url = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"]];
			if ([[NSFileManager defaultManager] fileExistsAtPath:url.path]) {
				[[NSFileManager defaultManager] removeItemAtURL:url error:nil];
			}
			url;
		}) recordingDelegate:self];
	}else{
		[self.captureMovieFileOutput stopRecording];//停止录制
	}
}

```

### 查看录制视频

- 关于如何查看沙盒内容可以点击[这里](https://github.com/Damonvvong/iOSDevNotes/blob/master/Notes/videorecoder.md#SandBox)
- 拿到的视频大概 **8S**。**15.9 M** 左右。Excuse me ？小视屏，**15.9M**？
- 莫急，可以压缩嘛。

### 压缩视频

- 压缩大概花了不到**0.05**秒，但是视频减少了**10**倍左右,在 **1M** 以内了。

```objc
-(void)videoCompression{
	
	NSLog(@"begin");
	NSURL *tempurl = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"temp.mov"]];
	//加载视频资源
	AVAsset *asset = [AVAsset assetWithURL:tempurl];
	//创建视频资源导出会话
	AVAssetExportSession *session = [[AVAssetExportSession alloc] initWithAsset:asset presetName:AVAssetExportPresetMediumQuality];
	//创建导出视频的URL
	session.outputURL = [NSURL fileURLWithPath:[NSTemporaryDirectory() stringByAppendingPathComponent:@"tempLow.mov"]];
	//必须配置输出属性
	session.outputFileType = @"com.apple.quicktime-movie";
	//导出视频
	[session exportAsynchronouslyWithCompletionHandler:^{
                NSLog(@"end");
	}];

}
``` 

### ok！利用 AVFoundation 模仿小视屏功能就这么实现了~ 总结一下，如图

![录制视频](https://github.com/Damonvvong/iOSDevNotes/blob/master/images/videorecoder_2.png)


### 哈哈哈,那是不可能的

- 虽然说，我们已经利用摄像头，能录制视频，且压缩到1M 以下，但是还是存在以下问题：
  - 我们选择的尺寸不符合小视屏的尺寸。微信视频的尺寸比例大概是4:3。[可选预设](https://github.com/Damonvvong/iOSDevNotes/blob/master/Notes/videorecoder.md#SessionPreset)
  - 据[iOS微信小视频优化心得](http://mp.weixin.qq.com/s?__biz=MzAwNDY1ODY2OQ==&mid=207686973&idx=1&sn=1883a6c9fa0462dd5596b8890b6fccf6&3rd=MzA3MDU4NTYzMw==&scene=6#rd)说这样很耗时。所有对视频的处理都需要在录制完成之后来做。
- 总之还有更好的办法。

---

## 优化方案

- 就前一种方案存在的不足主要有几个方面:
    - 1.可选的分辨率很少，而且如果设置低分辨率的话拍摄过程中也会比较模糊。
    - 2.对于封边率问题虽然可以在 压缩过程中利用 AVMutableComposition 来实现，但是存在一个问题是只有视频录制完成以后才能处理。大概需要的步骤是 录制 -> 滤镜 -> 码率压缩。而加滤镜的过程中，还是需要取出视频再按帧处理，再存入视频。
- 完全可以设计采用一种，**AVCapture** 拿到 一帧，交给 **fiter** 处理，再利用 **writer** 根据 **setting** 写入文件。这也是[iOS微信小视频优化心得](http://mp.weixin.qq.com/s?__biz=MzAwNDY1ODY2OQ==&mid=207686973&idx=1&sn=1883a6c9fa0462dd5596b8890b6fccf6&3rd=MzA3MDU4NTYzMw==&scene=6#rd)所提供的思路。
    - 关于根据帧来操作我们可以利用**AVCaptureVideoDataOutput** 和 **AVCaptureAudioDataOutput**  来实时的处理。
    - 而 **fiter** 则可以使用 **ffmpeg** 、 **GPUImage**  、 **CoreImage** 来处理。（暂时先不处理，只提供思路）
    - 最后就设置好参数，利用**writer** 来处理。

### 总体分析

> 因为代码比较多，就不贴出来了，需要的可以在[这里]()下载

- 根据上面的分析，对于视频录制部分大致先分成三部分，一部分是读(DWVideoRecoder)、一部分是写(DWVideoWriter)、一部分是预览(DWPreviewView).如下图：

![优化版](https://github.com/Damonvvong/iOSDevNotes/blob/master/images/videorecoder_1.png)

#### DWPreviewView
- 主要是一个预览层，同时还需要处理 用户 与 Session 之间的交互

#### DWVideoRecoder
- Session 的配置与控制
- Device 的控制与配置

#### DWVideoWriter 
- 设置videoSetting 和 audioSetting 的参数，将每一帧通过帧压缩与滤镜过滤之后，写入文件中
- 视频具体的参数设置
- VideoOutputSettings

| Key |  |
| --- | --- |
| AVVideoCodecKey | 编码格式，一般选h264,硬件编码 |
| AVVideoScalingModeKey | 填充模式，AVVideoScalingModeResizeAspectFill拉伸填充 |
| AVVideoWidthKey | 视频宽度，以手机水平，home 在右边的方向 |
| AVVideoHeightKey | 视频高度，以手机水平，home 在右边的方向 |
| AVVideoCompressionPropertiesKey | 压缩参数 |

- AVVideoCompressionPropertiesKey

| Key |  |
| --- | --- |
| AVVideoAverageBitRateKey | 视频尺寸*比率 比率10.1相当于AVCaptureSessionPresetHigh数值越大越精细 |
| AVVideoMaxKeyFrameIntervalKey | 关键帧最大间隔，1为每个都是关键帧，数值越大压缩率越高  |
| AVVideoProfileLevelKey | 默认选择 AVVideoProfileLevelH264BaselineAutoLevel |
    
- 对于压缩 只需要控制比率就可以了

---

##后记
- iOS 开发真的是越来越简单了。最开始搜怎么实现的时候直接出现了好几个 SDK，大概就是直接导入照着文档写两下就能用的那种。可能自己觉得这样太 low 所以决定自己尝试一下去实现，觉得有很多收获，视频开发算是入门了吧，写下这篇总结希望能给大家一点帮助，也给自己一个技术沉淀。

---

##番外篇

<a name="AVFoundation"/> 
<a name="AVFoundation1"/> 
### 关于AVFoundation 捕捉

<a name="AVCaptureSession"/> 
 - **AVCaptureSession** 捕捉会话
    - AVCaptureSession 从捕捉设备(物理)得到数据流,比如摄像头、麦克风，输出到一个或多个目的地。
    - AVCaptureSession 可以动态配置输入输出的线路，在会话进行中按需重新配置捕捉环境。
    - AVCaptureSession 可以额外配置一个会话预设值(session preset),用来控制捕捉数据的格式和质量。会话预设值默认为AVCaptureSessionPresetHigh。

<a name="AVCaptureDevice"/> 
- **AVCaptureDevice** 捕捉设备
    - AVCaptureDevice 针对物理硬件设备定义了大量的控制方法，比如控制摄像头的对焦、曝光、白平衡和闪光灯。

<a name="AVCaptureDeviceInput"/> 
- **AVCaptureDeviceInput** 捕捉设备的输入
    - 在使用捕捉设备进行处理之前，需要将它添加到捕捉会话的输入。不过一个设备不能直接添加到AVCaptureSession 中，需要利用 AVCaptureDeviceInput 的一个实例封装起来添加。

<a name="AVCaptureOutput"/> 
- **AVCaptureOutput** 捕捉设备的输出
    - 如上文所提，AVCaptureSession 会从AVCaptureDevice拿数据流，并输出到一个或者多个目的地，这个目的地就是 AVCaptureOutput。
    - 首先 AVCaptureOutput 是一个基类，AVFoundation 为我们提供了 四个 扩展类。
        - AVCaptureStillImageOutput 捕捉静态照片（拍照）
        - AVCaptureMovieFileOutput 捕捉视频（视频 + 音频）
        - AVCaptureVideoDataOutput 视频录制数据流
	   - AVCaptureAudioDataOutput 音频录制数据流
    - AVCaptureVideoDataOutput 和 AVCaptureAudioDataOutput 可以更好的音频视频实时处理

    > 对于以上四者的关系，类似于 AVCaptureSession 是过滤器，AVCaptureDevice 是“原始”材料，AVCaptureDeviceInput 是 AVCaptureDevice 的收集器，AVCaptureOutput 就是产物了。

<a name="AVCaptureConnection"/> 
- **AVCaptureConnection** 捕捉连接
    -  那么问题来了，上面四者之间的“导管”是什么呢？那就是 AVCaptureConnection。利用AVCaptureConnection 可以很好的将这几个独立的功能件很好的连接起来。
<a name="AVCaptureVideoPreviewLayer"/> 
- **AVCaptureVideoPreviewLayer** 捕捉预览
    - 以上所有的数据处理，都是在代码中执行的，用户无法看到AVCaptureSession到底在做什么事情。所以AVFoundation 为我们提供了一个叫做 AVCaptureVideoPreviewLayer 的东西，提供实时预览。
    - AVCaptureVideoPreviewLayer 是 CoreAnimation 的 CALayer 的子类。
    - 关于预览层的填充模式有 AVLayerVideoGravityResizeAspect、AVLayerVideoGravityResizeAspectFill、AVLayerVideoGravityResize三种

<a name="SandBox"/> 
### 如何查看真机沙盒里面的文件 
- Xcode -> Window -> Devices
![](https://github.com/Damonvvong/iOSDevNotes/blob/master/images/videorecoder_3.jpg)
- 选中真机，再右边选中你要导出沙盒的项目，然后点击最下面的设置按钮，然后Download Container.
![](https://github.com/Damonvvong/iOSDevNotes/blob/master/images/videorecoder_4.jpg)

<a name="SessionPreset"/> 

### 可选预设
```objc
NSString *const  AVCaptureSessionPresetPhoto;
NSString *const  AVCaptureSessionPresetHigh;
NSString *const  AVCaptureSessionPresetMedium;
NSString *const  AVCaptureSessionPresetLow;
NSString *const  AVCaptureSessionPreset352x288;
NSString *const  AVCaptureSessionPreset640x480;
NSString *const  AVCaptureSessionPreset1280x720;
NSString *const  AVCaptureSessionPreset1920x1080;
NSString *const  AVCaptureSessionPresetiFrame960x540;
NSString *const  AVCaptureSessionPresetiFrame1280x720;
NSString *const  AVCaptureSessionPresetInputPriority;
```


