//
//  MTTSmallVideoView.swift
//  MyTwitter
//
//  Created by LiuChuanan on 2018/2/12.
//  Copyright © 2018年 waitWalker. All rights reserved.
//

/********
 小视频视图 
 ********/

import UIKit
import RxCocoa
import RxSwift
import AVFoundation

class MTTSmallVideoView: MTTView {

    let disposeBag = DisposeBag()
    
    
    // 灰色背景容器
    var containerView:UIView!
    
    // 视频相关容器 
    var videoContainerView:UIView!
    
    // 视频顶部bar
    var videoTopBarView:UIView!
    var videoBarImageView:UIImageView!
    var videoRecordingHintImageView:UIImageView!
    
    // 视频录制
    var videoRecordView:UIView!
    
    // 下部容器
    var videoBottomContainerView:MTTSmallVideoBottomView!
    
    // 眼睛视图 
    var eyeView:MTTEyeView!
    var focusView:MTTFocusView!
    
    // 上滑取消 
    var moveUpCancelLabel:UILabel!
    
    // 松手取消 
    var loseCancelLabel:UILabel!
    
    // 是否正在录制 
    var isRecording:Bool!
    
    
    // 录制相关 
    var captureSession:AVCaptureSession! //捕获会话 
    var captureVideoPreviewLayer:AVCaptureVideoPreviewLayer!
    var captureVideoDevice:AVCaptureDevice!
    
    var captureVideoDataOutput:AVCaptureVideoDataOutput!
    var captureAudioDataOutput:AVCaptureAudioDataOutput!
    
    var assetWriter:AVAssetWriter!
    var assetWriterInputPixelBufferAdaptor:AVAssetWriterInputPixelBufferAdaptor!
    var assetWriterVideoInput:AVAssetWriterInput!
    var assetWriterAudioInput:AVAssetWriterInput!
    
    var currentSampleTime:CMTime!
    
    
    
    var videoQueue:DispatchQueue!
    
    var recordSECTimer:Timer!
    
    
    
    
    override init(frame: CGRect) 
    {
        super.init(frame: frame)
        
        setupEvent()
    }
    
    override func setupSubview() 
    {
        // 背景大容器
        containerView = UIView(frame: self.bounds)
        containerView.backgroundColor = UIColor.gray.withAlphaComponent(0.7)
        self.addSubview(containerView)
        
        // 视频相关容器 
        videoContainerView = UIView(frame: CGRect(x: 0, y: kScreenHeight, width: kScreenWidth, height: kScreenHeight - 260))
        videoContainerView.backgroundColor = UIColor.black
        containerView.addSubview(videoContainerView)
        
        // 视频录制视图
        videoRecordView = UIView(frame: CGRect(x: 0, y: 20, width: kScreenWidth, height: 260))
        videoRecordView.backgroundColor = kMainBlueColor()
        videoContainerView.addSubview(videoRecordView)
        
        // 录制视频上部bar
        videoTopBarView = UIView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: 20))
        videoTopBarView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        videoContainerView.addSubview(videoTopBarView)
        
        videoBarImageView = UIImageView(frame: CGRect(x: (videoTopBarView.width - 20)/2, y: 2, width: 20, height: 16))
        videoBarImageView.isUserInteractionEnabled = true
        videoBarImageView.image = UIImage.imageNamed(name: "small_video_bar")
        videoTopBarView.addSubview(videoBarImageView)
        
        videoRecordingHintImageView = UIImageView(frame: CGRect(x: (videoTopBarView.width - 10)/2, y: 5, width: 10, height: 10))
        videoRecordingHintImageView.layer.cornerRadius = 5.0
        videoRecordingHintImageView.clipsToBounds = true
        videoRecordingHintImageView.image = UIImage.imageNamed(name: "small_video_dot")
        videoRecordingHintImageView.isUserInteractionEnabled = true
        videoRecordingHintImageView.isHidden = true
        videoTopBarView.addSubview(videoRecordingHintImageView)
        
        
        // 下部视图 
        videoBottomContainerView = MTTSmallVideoBottomView(frame: CGRect(x: 0, y: self.videoRecordView.frame.maxY, width: kScreenWidth, height: videoContainerView.height - 20 - 260))
        videoBottomContainerView.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        videoBottomContainerView.delegate = self
        videoContainerView.addSubview(videoBottomContainerView)
        
        // 设置视频录制
        self.setupVideoRecordCapture()
        
        videoContainerView.sendSubview(toBack: videoTopBarView)
        
        // 眼睛视图
        eyeView = MTTEyeView(frame:self.videoRecordView.bounds)
        self.videoRecordView.addSubview(eyeView)
        print(eyeView)
        
        // 聚焦视图  
        focusView = MTTFocusView(frame: CGRect(x: 0, y: 0, width: 60, height: 60))
        focusView.backgroundColor = UIColor.clear
        
        
        UIView.animate(withDuration: 0.3, 
                       delay: 0.0, 
                       options: UIViewAnimationOptions.curveEaseIn, 
                       animations: { 
            self.videoContainerView.y = 260
        }) { completed in
            self.setupEyeAnimationView()
        }

        
        let timeInterval:TimeInterval = 2.0
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeInterval) { 
            
        }
        
        // 设置手势 
        setupGesture()
        
        // 上滑取消 
        moveUpCancelLabel = UILabel()
        moveUpCancelLabel.frame = CGRect(x: 0, y: self.videoRecordView.height - 20 - 5, width: self.videoRecordView.width, height: 20)
        moveUpCancelLabel.font = UIFont.boldSystemFont(ofSize: 12)
        moveUpCancelLabel.text = "↑上移取消"
        moveUpCancelLabel.textAlignment = NSTextAlignment.center
        moveUpCancelLabel.textColor = kMainBlueColor()
        moveUpCancelLabel.isHidden = true
        self.videoRecordView.addSubview(moveUpCancelLabel)
        
        // 松手取消 
        loseCancelLabel = UILabel()
        loseCancelLabel.frame = CGRect(x: 0, y: (self.videoRecordView.height - 20) / 2.0, width: self.videoRecordView.width, height: 20)
        loseCancelLabel.font = UIFont.boldSystemFont(ofSize: 12)
        loseCancelLabel.text = "松手取消"
        loseCancelLabel.textAlignment = NSTextAlignment.center
        loseCancelLabel.textColor = kMainBlueColor()
        loseCancelLabel.isHidden = true
        self.videoRecordView.addSubview(loseCancelLabel)
        
    }
    
    // MARK: - 设置相关手势 
    func setupGesture() -> Void 
    {
        let singleTapGesture = UITapGestureRecognizer(
            target: self, 
            action: #selector(focusAction(gesture:)))
        singleTapGesture.delaysTouchesBegan = true
        self.videoRecordView.addGestureRecognizer(singleTapGesture)
        
        let doubleTapGesture = UITapGestureRecognizer(
            target: self, 
            action: #selector(zoomAction(gesture:)))
        doubleTapGesture.numberOfTapsRequired = 2
        doubleTapGesture.numberOfTouchesRequired = 1
        doubleTapGesture.delaysTouchesBegan = true
        self.videoRecordView.addGestureRecognizer(doubleTapGesture)
        // 双击失败了才会触发单击 
        singleTapGesture.require(toFail: doubleTapGesture)
        
    }
    // 单击聚焦事件 
    @objc private func focusAction(gesture:UITapGestureRecognizer) -> Void 
    {
        let date = Date(timeIntervalSinceNow: 0)
        print("录制单击聚焦\(self),时间:\(date)")
        
        let tPoint = gesture.location(in: self.videoRecordView)
        
        self.focusInPoint(point: tPoint)
        
    }
    
    private func focusInPoint(point:CGPoint) -> Void 
    {
        let cameraPoint = captureVideoPreviewLayer.captureDevicePointOfInterest(for: point)
        
        focusView.center = point
        self.videoRecordView.addSubview(focusView)
        self.videoRecordView.bringSubview(toFront: focusView)
        focusView.focusing()
        
        if (try? captureVideoDevice.lockForConfiguration()) != nil {
            
            if captureVideoDevice.isFocusPointOfInterestSupported
            {
                captureVideoDevice.focusPointOfInterest = cameraPoint
            }
            
            // 自动聚焦
            if captureVideoDevice.isFocusModeSupported(AVCaptureFocusMode.autoFocus)
            {
                captureVideoDevice.focusMode = AVCaptureFocusMode.autoFocus
            }
            
            // 自动调节曝光 
            if captureVideoDevice.isExposureModeSupported(AVCaptureExposureMode.autoExpose)
            {
                captureVideoDevice.exposureMode = AVCaptureExposureMode.autoExpose
            }
            
            // 白平衡 
            if captureVideoDevice.isWhiteBalanceModeSupported(AVCaptureWhiteBalanceMode.autoWhiteBalance)
            {
                captureVideoDevice.whiteBalanceMode = AVCaptureWhiteBalanceMode.autoWhiteBalance
            }
            
            captureVideoDevice.unlockForConfiguration()
        }
        
        
        let timeInterval:TimeInterval = 2.0
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + timeInterval, 
            execute: { 
            self.focusView.removeFromSuperview()
        })
    }
    
    // 双击缩放事件 
    @objc private func zoomAction(gesture:UITapGestureRecognizer) -> Void 
    {
        if ((try? captureVideoDevice.lockForConfiguration()) != nil) 
        {
            let zoomFactor:CGFloat = captureVideoDevice.videoZoomFactor == 2.0 ? 1.0:2.0
            captureVideoDevice.videoZoomFactor = zoomFactor
            captureVideoDevice.unlockForConfiguration()
            
        }
    }
    
    // MARK: - 设置睁眼动画 
    func setupEyeAnimationView() -> Void 
    {
        let eyeCopyView = eyeView.snapshotView(afterScreenUpdates: false)
        
        let eyeCopyViewWidth:CGFloat = self.videoRecordView.width
        let eyeCopyViewHeight:CGFloat = self.videoRecordView.height
        
        eyeView.alpha = 0.0
        
        let topView = eyeCopyView?.resizableSnapshotView(from: CGRect(x: 0, y: 0, width: eyeCopyViewWidth, height: eyeCopyViewHeight / 2.0), afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero)
        
        let bottomFrame = CGRect(x: 0, y: 130, width: eyeCopyViewWidth, height: eyeCopyViewHeight / 2.0)
        
        
        let bottomView = eyeCopyView?.resizableSnapshotView(from: bottomFrame, afterScreenUpdates: false, withCapInsets: UIEdgeInsets.zero)
        bottomView?.frame = bottomFrame
        print(topView as Any,"\n",bottomView as Any)
        self.videoRecordView.addSubview(topView!)
        self.videoRecordView.addSubview(bottomView!)
        
        UIView.animate(
            withDuration: 0.3, 
            delay: 0.0, 
            options: UIViewAnimationOptions.curveEaseIn, 
            animations: { 
                topView?.transform = CGAffineTransform(translationX: 0.0, y: -20)
                bottomView?.transform = CGAffineTransform(translationX: 0.0, y: 260)
                topView?.alpha = 0.3
                bottomView?.alpha = 0.3
        }) { completed in
            topView?.removeFromSuperview()
            bottomView?.removeFromSuperview()
            self.eyeView.removeFromSuperview()
            self.eyeView = nil
            self.focusInPoint(point: self.videoRecordView.center)
        }
        
        // 双击放大label 
        self.setupDoubleTapLabel()
        
    }
    
    // MARK: - 设置双击放大 label 
    func setupDoubleTapLabel() -> Void 
    {
        let doubleTapLabel = UILabel()
        doubleTapLabel.text = "双击当大"
        doubleTapLabel.font = UIFont.systemFont(ofSize: 14)
        doubleTapLabel.frame = CGRect(x: 0, y: 0, width: 200, height: 20)
        doubleTapLabel.center = CGPoint(x: self.videoRecordView.center.x, y: self.videoRecordView.frame.maxY - 50)
        doubleTapLabel.textColor = UIColor.white
        doubleTapLabel.textAlignment = NSTextAlignment.center  //int 类型的枚举 
        self.videoRecordView.addSubview(doubleTapLabel)
        self.videoRecordView.bringSubview(toFront: doubleTapLabel)
        
        let timeInterval:TimeInterval = 1.5
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeInterval) { 
            doubleTapLabel.removeFromSuperview()
        }
    }
    
    // MARK: - 设置录制SEC红色提示
    func setupRecordHintSECView() -> Void 
    {
        self.videoRecordingHintImageView.isHidden = false
        self.videoBarImageView.isHidden = true
        if recordSECTimer == nil 
        {
            recordSECTimer = Timer(
                timeInterval: 0.3, 
                target: self, 
                selector: #selector(setupSECAction), 
                userInfo: nil, 
                repeats: true)
            RunLoop.current.add(recordSECTimer, forMode: RunLoopMode.defaultRunLoopMode)
        }
        recordSECTimer.fire()
        
    }
    
    @objc private func setupSECAction() -> Void 
    {
        let timeInterval:TimeInterval = 0.3
        if self.videoRecordingHintImageView.isHidden 
        {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeInterval, execute: { 
                
                if self.isRecording
                {
                    self.videoRecordingHintImageView.isHidden = false
                } else
                {
                    self.stopRecordHintSECView()
                }
                
            })
            
        } else
        {
            DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeInterval, execute: { 
                self.videoRecordingHintImageView.isHidden = true
            })
        }
        
        
    }
    
    func stopRecordHintSECView() -> Void 
    {
        self.videoRecordingHintImageView.isHidden = true
        self.videoBarImageView.isHidden = false
        if recordSECTimer != nil 
        {
            recordSECTimer.invalidate()
            recordSECTimer = nil
        }
    }
    
    // MARK: - 监听相关事件 
    func setupEvent() -> Void 
    {
        
    }
    
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

}

// MARK: - ************************ extension ***********************
// MARK: - 底部视图delegate 回调  
extension MTTSmallVideoView:MTTSmallVideoBottomViewDelegate
{
    
    // 底部视图移除关闭按钮delegate 回调 
    func tappedRemoveButton(bottomView: MTTSmallVideoBottomView) 
    {
        self.videoRemoveButtonAction()
    }
    
    // 视频开始录制delegate 回调 
    func recordCircleViewDidStartRecord(bottomView: MTTSmallVideoBottomView) 
    {
        // 录制 上 中 相关控件状态做好准备 
        self.isRecording = true
        
        self.setupRecordHintSECView()
        
        self.moveUpCancelLabel.isHidden = false
        
        let timeInterval:TimeInterval = 0.5
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeInterval) { 
            
            self.moveUpCancelLabel.isHidden = true
        }
        
        self.setupVideoAssetWritter()
    }
    
    // 视频录制上滑即将取消录制delegate 回调 
    func recordCircleViewMoveUpWillCancel(bottomView: MTTSmallVideoBottomView) 
    {
        self.loseCancelLabel.isHidden = false
        let timeInterval:TimeInterval = 0.5
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + timeInterval) { 
            
            self.loseCancelLabel.isHidden = true
        }
    }
    
    // 视频录制正常结束delegate 回调 
    func recordCircleViewDidEnd(bottomView: MTTSmallVideoBottomView) 
    {
        self.isRecording = false
        
        print("视频录制正常结束delegate")
        self.stopRecordHintSECView()
    }
    
    // 视频录制因为某种原因结束delegate 回调 
    func recordCircleViewDidEndWithType(bottomView: MTTSmallVideoBottomView, type: MTTSmallVideoDidEndType) 
    {
        self.isRecording = false
        
        print("视频录制因为某种原因结束delegate:\(type)")
        self.stopRecordHintSECView()
    }
    
}

// MARK: - ************************ extension ***********************
// MARK: - 按钮的相关事件 
extension MTTSmallVideoView
{
    // 移除按钮相关事件回调 
    func videoRemoveButtonAction() -> Void 
    {
        UIView.animate(withDuration: 0.3, animations: { 
            self.videoContainerView.y = kScreenHeight
            self.containerView.backgroundColor = UIColor.gray.withAlphaComponent(0)
        }) { completed in
            self.removeFromSuperview()
        }
    }
}

// MARK: - ************************ extension ***********************
// MARK: - 拓展小视频相关录制方法 
extension MTTSmallVideoView
{
    func setupVideoRecordCapture() -> Void 
    {
        // 视频录制队列 
        self.videoQueue = DispatchQueue(label: "video_queue", qos: DispatchQoS.default, attributes: DispatchQueue.Attributes.concurrent, autoreleaseFrequency: DispatchQueue.AutoreleaseFrequency.never, target: nil)
        
        // 1.创建捕捉会话 
        self.captureSession = AVCaptureSession()
        // 1.1 设置分辨率 
        if self.captureSession.canSetSessionPreset(AVCaptureSessionPreset640x480)
        {
            self.captureSession.sessionPreset = AVCaptureSessionPreset640x480
        }
        
        // 2.视频的输入 
        self.captureVideoDevice = self.getCameraDeviceWithPosition(position: AVCaptureDevicePosition.back)
        
        // 2.1视频HDR(高动态范围图像)
        //self.captureVideoDevice.isVideoHDREnabled = true
        
        // 2.2 视频最大,最小帧速率 
        //self.captureVideoDevice.activeVideoMinFrameDuration = CMTime(value: 1, timescale: 60)
        
        // 2.3 视频输入源 
        let captureVideoDeviceInput = try! AVCaptureDeviceInput(device: self.captureVideoDevice)
        
        // 2.4 将视频输入源添加到会话 
        if self.captureSession.canAddInput(captureVideoDeviceInput) 
        {
            self.captureSession.addInput(captureVideoDeviceInput)
        }
        
        // 2.5 视频输出
        self.captureVideoDataOutput = AVCaptureVideoDataOutput()
        
        // 2.6 立即丢弃旧帧,节省内存 
        self.captureVideoDataOutput.alwaysDiscardsLateVideoFrames = true
        self.captureVideoDataOutput.setSampleBufferDelegate(self, queue: self.videoQueue)
        if self.captureSession.canAddOutput(self.captureVideoDataOutput) 
        {
            self.captureSession.addOutput(self.captureVideoDataOutput)
        }
        
        // 3.获取音频设备 
        let captureAudioDevice = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInMicrophone], mediaType: AVMediaTypeAudio, position: AVCaptureDevicePosition.unspecified).devices.first
        
        
        // 3.1 创建音频输入源
        let captureAudioDeviceInput = try! AVCaptureDeviceInput(device: captureAudioDevice)
        
        // 3.2 将音频输入源添加到会话 
        if self.captureSession.canAddInput(captureAudioDeviceInput)
        {
            self.captureSession.addInput(captureAudioDeviceInput)
        }
        
        // 3.3 设置音频的输出 
        self.captureAudioDataOutput = AVCaptureAudioDataOutput()
        self.captureAudioDataOutput.setSampleBufferDelegate(self, queue: self.videoQueue)
        if self.captureSession.canAddOutput(self.captureAudioDataOutput) 
        {
            self.captureSession.addOutput(self.captureAudioDataOutput)
        }
        
        // 4. 设置视频预览层
        self.captureVideoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession)
        self.captureVideoPreviewLayer.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 260)
        self.captureVideoPreviewLayer.position = CGPoint(x: kScreenWidth / 2, y: 130)
        self.captureVideoPreviewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.videoRecordView.layer.addSublayer(self.captureVideoPreviewLayer)
        
        // 5. 开始采集
        self.captureSession.startRunning()
        
    }
    
    // 获取设备 
    func getCameraDeviceWithPosition(position:AVCaptureDevicePosition) -> AVCaptureDevice 
    {
        let captureDeviceDiscoverySession = AVCaptureDeviceDiscoverySession(deviceTypes: [AVCaptureDeviceType.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: position)
        
        let deviceArray = captureDeviceDiscoverySession?.devices
        for device in deviceArray! {
            if device.position == position
            {
                return device
            }
        }
        return (deviceArray?.first)!
    }
    
    // 视频输出相关参数设置 
    func setupVideoAssetWritter() -> Void 
    {
        // 视频文件名称
        videoSharedInstance.currentVideoFileName = String(format: "/video-%.0f.MOV", Date().timeIntervalSince1970)
        
        // 视频缩略图名称 
        videoSharedInstance.currentVideoThumbnailFileName = String(format: "/video-picture-%.0f.JPG", Date().timeIntervalSince1970)
        
        // 组合视频文件路径
        videoSharedInstance.currentVideoPath = videoSharedInstance.getRecorderFilePath() + videoSharedInstance.currentVideoFileName
        
        // 组合视频缩略图路径 
        videoSharedInstance.currentVideoThumbnailPath = videoSharedInstance.getRecorderFilePath() + videoSharedInstance.currentVideoThumbnailFileName
        
        print("文件输出路径和名称:\(videoSharedInstance.currentVideoFileName),\(videoSharedInstance.currentVideoPath)")
        
        // 输入视频路径URL
        let outputURL = URL(fileURLWithPath: videoSharedInstance.currentVideoPath)
        
        assetWriter = try! AVAssetWriter(url: outputURL, fileType: AVFileTypeQuickTimeMovie)
        let outputSettings:[String:Any] = [AVVideoCodecKey:AVVideoCodecH264,
                              AVVideoWidthKey:kScreenWidth,
                              AVVideoHeightKey:260,
                              AVVideoScalingModeKey:AVVideoScalingModeResizeAspectFill
        ]
        assetWriterVideoInput = AVAssetWriterInput(mediaType: AVMediaTypeVideo, outputSettings: outputSettings)
        assetWriterVideoInput.expectsMediaDataInRealTime = true
        assetWriterVideoInput.transform = CGAffineTransform(rotationAngle: CGFloat(Double.pi / 2.0))
        
        let audioOutputSettings:[String:Any] = [
            AVFormatIDKey:kAudioFormatMPEG4AAC,
            AVEncoderBitRateKey:6400,
            AVSampleRateKey:44100,
            AVNumberOfChannelsKey:1
        ]
        
        assetWriterAudioInput = AVAssetWriterInput(mediaType: AVMediaTypeAudio, outputSettings: audioOutputSettings)
        assetWriterAudioInput.expectsMediaDataInRealTime = true
        
        let SPBDict:[String:Any] = [
            kCVPixelBufferPixelFormatTypeKey as String:kCVPixelFormatType_32BGRA,
            kCVPixelBufferWidthKey as String:kScreenWidth,
            kCVPixelBufferHeightKey as String:260,
            kCVPixelFormatOpenGLESCompatibility as String:kCFBooleanTrue
        ]
        
        assetWriterInputPixelBufferAdaptor = AVAssetWriterInputPixelBufferAdaptor(assetWriterInput: assetWriterVideoInput, sourcePixelBufferAttributes: SPBDict)
        
        if assetWriter.canAdd(assetWriterVideoInput) 
        {
            assetWriter.add(assetWriterVideoInput)
        } else
        {
            print("不能添加视频writer的input \(assetWriterVideoInput)")
        }
        
        if assetWriter.canAdd(assetWriterAudioInput) 
        {
            assetWriter.add(assetWriterAudioInput)
        } else
        {
            print("不能添加音频writer的input \(assetWriterAudioInput)")
        }
        
    }
}

// MARK: - ************************ extension ***********************
// MARK: - AVCaptureVideoDataOutputSampleBufferDelegate协议方法
extension MTTSmallVideoView:AVCaptureVideoDataOutputSampleBufferDelegate,AVCaptureAudioDataOutputSampleBufferDelegate
{
    // 输出 AVCaptureVideoDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput!, didOutputSampleBuffer sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) 
    {
        if self.isRecording != nil && !self.isRecording 
        {
            return
        }
        
        autoreleasepool { () -> () in
            
            currentSampleTime = CMSampleBufferGetOutputPresentationTimeStamp(sampleBuffer)
            
            if assetWriter != nil && assetWriter.status != AVAssetWriterStatus.writing
            {
                assetWriter.startWriting()
                assetWriter.startSession(atSourceTime: currentSampleTime)
            }
            
            print("当前output:\(output)")
            
            if output == captureVideoDataOutput
            {
                if assetWriterInputPixelBufferAdaptor != nil && assetWriterInputPixelBufferAdaptor.assetWriterInput.isReadyForMoreMediaData
                {
                    let pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer)
                    let isSuccess = assetWriterInputPixelBufferAdaptor.append(pixelBuffer!, withPresentationTime: currentSampleTime)
                    if !isSuccess
                    {
                        print("Pixel Buffer 没有 append 成功 ")
                    }
                    
                }
            }
            
            if output == captureAudioDataOutput
            {
                if assetWriterAudioInput == nil
                {
                    return
                }
                assetWriterAudioInput.append(sampleBuffer)
            }
            
        }
        
    }
    
    // 丢弃 AVCaptureVideoDataOutputSampleBufferDelegate  AVCaptureAudioDataOutputSampleBufferDelegate
    func captureOutput(_ output: AVCaptureOutput!, didDrop sampleBuffer: CMSampleBuffer!, from connection: AVCaptureConnection!) 
    {
        // 判断AVCaptureOutput 
    }
}

// MARK: - ************************ class ***********************
// MARK: - 眼睛视图 
class MTTEyeView: MTTView 
{
    override init(frame: CGRect) 
    {
        super.init(frame: frame)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setupSubview() -> Void 
    {
        self.backgroundColor = UIColor(red: (21.0 / 255.0), green: (21.0 / 255.0), blue: (21.0 / 255.0), alpha: 1.0)
        let eyeImageView = UIImageView(frame: CGRect(x: (self.bounds.size.width - 100) / 2.0, y: (self.bounds.size.height - 70) / 2.0, width: 100, height: 70))
        eyeImageView.image = UIImage.imageNamed(name: "small_video_eye")
        self.addSubview(eyeImageView)
        
        
        // 容器 
        let containerView = UIView(frame: self.bounds)
        containerView.backgroundColor = UIColor.clear
        //self.addSubview(containerView)
        
        // 绘制path
        let selfCenter = CGPoint(x: self.bounds.size.width / 2.0, y: self.bounds.size.height / 2.0)
        let eyeWidth:CGFloat = 64.0
        let eyeHeight:CGFloat = 40.0
        let curveCtrlHeitht:CGFloat = 44.0
        
        let transform = CGAffineTransform(scaleX: 1.0, y: 1.0)
        let strokePath = CGMutablePath()
        strokePath.move(to: CGPoint(x:selfCenter.x - eyeWidth / 2.0,y:selfCenter.y), transform: transform)
        
        strokePath.addQuadCurve(to: CGPoint(x:selfCenter.x,y:selfCenter.y - curveCtrlHeitht), control: CGPoint(x:selfCenter.x + eyeWidth / 2.0,y:selfCenter.y), transform: transform)
        strokePath.addQuadCurve(to: CGPoint(x:selfCenter.x,y:selfCenter.y + curveCtrlHeitht), control: CGPoint(x:selfCenter.x - eyeWidth / 2.0,y:selfCenter.y), transform: transform)
        let arcRadius:CGFloat = eyeHeight / 2.0 - 1.0;
        
        strokePath.move(to: CGPoint(x:selfCenter.x + arcRadius,y:selfCenter.y), transform: transform)
        strokePath.addArc(center: CGPoint(x:selfCenter.x, y:selfCenter.y), radius: arcRadius, startAngle: 0, endAngle: CGFloat(CGFloat(Double.pi) * 2.0), clockwise: false, transform: transform)
        
        let startAngle:CGFloat = 110.0
        let angle_one:CGFloat = startAngle + 30.0
        let angle_two:CGFloat = angle_one + 20.0
        let angle_three:CGFloat = angle_two + 10.0
        
        let arcRadius_two:CGFloat = arcRadius - 4.0
        let arcRadius_three:CGFloat = arcRadius_two - 7.0
        
        let fillPath = createPath(with: selfCenter, startAngle: changeAngleToRadius(with: startAngle), endAngle: changeAngleToRadius(with: angle_one), bigRadius: arcRadius_two, smallRadius: arcRadius_three, transform: transform)
        
        let fillPath_two = createPath(with: selfCenter, startAngle: changeAngleToRadius(with: angle_two), endAngle: changeAngleToRadius(with: angle_three), bigRadius: arcRadius_two, smallRadius: arcRadius_three, transform: transform)
        
        fillPath.addPath(fillPath_two, transform: transform)
        
        // 创建图层 
        let color = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.9)
        
        let shape_one = CAShapeLayer()
        shape_one.frame = self.bounds
        shape_one.strokeColor = color.cgColor
        shape_one.fillColor = UIColor.clear.cgColor
        shape_one.opacity = 1.0
        shape_one.lineCap = kCALineCapRound
        shape_one.lineWidth = 1.0
        shape_one.path = strokePath
        containerView.layer.addSublayer(shape_one)
        
        let shape_two = CAShapeLayer()
        shape_two.frame = self.bounds
        shape_two.strokeColor = color.cgColor
        shape_two.fillColor = color.cgColor
        shape_two.opacity = 1.0
        shape_two.lineCap = kCALineCapRound
        shape_two.lineWidth = 1.0
        shape_two.path = fillPath
        containerView.layer.addSublayer(shape_two)
        
    }
    
    // 创建所需路径 
    func createPath(with center:CGPoint, startAngle:CGFloat,endAngle:CGFloat,bigRadius:CGFloat,smallRadius:CGFloat,transform:CGAffineTransform) -> CGMutablePath 
    {
        let arcStartAngle:CGFloat = CGFloat(Double.pi) * 2.0 - startAngle
        let arcEndAngle:CGFloat = CGFloat(Double.pi) * 2.0 - endAngle
        
        let path = CGMutablePath()
        
        
        path.move(to: CGPoint(x:center.x + bigRadius * cos(startAngle), y: center.y - bigRadius * sin(startAngle)), transform: transform)
        
        path.addArc(center: center, radius: bigRadius, startAngle: arcStartAngle, endAngle: arcEndAngle, clockwise: true)
        
        path.addLine(to: CGPoint(x: center.x + smallRadius * cos(endAngle), y: center.y - smallRadius * sin(endAngle)), transform: transform)
        
        path.addArc(center: center, radius: smallRadius, startAngle: arcEndAngle, endAngle: arcStartAngle, clockwise: false)
        
        path.addLine(to: CGPoint(x: center.x + bigRadius * cos(startAngle), y: center.y - bigRadius * sin(startAngle)), transform: transform)
        
        return path
    }
    
    // 角度转换 
    func changeAngleToRadius(with angle:CGFloat) -> CGFloat 
    {
        let tmp:CGFloat = angle / 180.0 * CGFloat(Double.pi)
        print(tmp)
        return tmp
    }
}

// MARK: - ************************ class ***********************
// MARK: - 聚焦视图 
class MTTFocusView: MTTView {
    
    var originalWidthHeight:CGFloat!
    
    
    override init(frame: CGRect) 
    {
        super.init(frame: frame)
        originalWidthHeight = frame.size.height
    }
    
    override func draw(_ rect: CGRect) 
    {
        super.draw(rect)
        
        // 画一个矩形 
        let context = UIGraphicsGetCurrentContext()
        context?.setStrokeColor(kMainBlueColor().cgColor)
        context?.setLineWidth(1.0)
        
        let len:CGFloat = 4.0
        context?.move(to: CGPoint(x: 0, y: 0))
        context?.addRect(self.bounds)
        
        context?.move(to: CGPoint(x: 0, y: originalWidthHeight / 2.0))
        context?.addLine(to: CGPoint(x: len, y: originalWidthHeight / 2.0))
        context?.move(to: CGPoint(x: originalWidthHeight / 2.0, y: originalWidthHeight))
        context?.addLine(to: CGPoint(x: originalWidthHeight / 2.0, y: originalWidthHeight - len))
        
        context?.move(to: CGPoint(x: originalWidthHeight, y: originalWidthHeight / 2.0))
        context?.addLine(to: CGPoint(x: originalWidthHeight - len, y: originalWidthHeight / 2.0))
        context?.move(to: CGPoint(x: originalWidthHeight / 2.0, y: 0))
        context?.addLine(to: CGPoint(x: originalWidthHeight / 2.0, y: len))
        context?.drawPath(using: CGPathDrawingMode.stroke)
        
        
    }
    
    // 聚焦 
    func focusing() -> Void 
    {
        let oTransform = CGAffineTransform.identity
        
        UIView.animate(withDuration: 0.5, animations: { 
            self.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
            
        }) { completed in
            self.transform = oTransform
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

// MARK: - ************************ class ***********************
// MARK: - 小视频底部容器视图
class MTTSmallVideoBottomView: MTTView 
{
    let disposeBag = DisposeBag()
    var delegate:MTTSmallVideoBottomViewDelegate!
    
    var recordCircleView:UIView!
    var videoListButton:UIButton!
    var videoRemoveButton:UIButton!
    var recordProgressView:UIView!
    
    
    let kRecordTotalTime:Int = 5
    var recordSurplusTime:Int!
    
    
    var longPressGesture:UILongPressGestureRecognizer!
    var recordTimer:Timer!
    
    
    override init(frame: CGRect) 
    {
        super.init(frame: frame)
        
        setupEvent()
    }
    
    override func setupSubview() 
    {
        // 右边移除按钮  
        videoRemoveButton = UIButton(frame: CGRect(x: kScreenWidth - 30 - 24, y: (self.height - 24) / 2 - 10, width: 24, height: 24))
        videoRemoveButton.setImage(UIImage.imageNamed(name: "small_video_remove"), for: UIControlState.normal)
        self.addSubview(videoRemoveButton)
        
        // 中间圆圈录制控件
        self.setupRecordCircleView()
        
        // 录制进度条 
        recordProgressView = UIView(frame: CGRect(x: 0, y: 0, width: self.bounds.size.width, height: 2))
        recordProgressView.backgroundColor = kMainBlueColor()
        recordProgressView.isHidden = true
        self.addSubview(recordProgressView)
        
        // 视频列表按钮 
        videoListButton = UIButton(frame: CGRect(x: 20, y: (self.height - 45) / 2 - 10, width: 60, height: 45))
        videoListButton.setImage(UIImage.imageNamed(name: "samll_video_list"), for: UIControlState.normal)
        self.addSubview(videoListButton)
    }
    
    private func setupRecordCircleView() -> Void
    {
        // 录制视图控件 中间那个圆圈 
        recordCircleView = UIView(frame: CGRect(x: (self.bounds.width - 80) / 2.0, y: (self.bounds.height - 80) / 2.0 - 10, width: 80, height: 80))
        recordCircleView.backgroundColor = UIColor.clear
        self.addSubview(recordCircleView)
        
        let path = UIBezierPath(roundedRect: recordCircleView.bounds, cornerRadius: 40)
        let trackLayer = CAShapeLayer()
        trackLayer.frame = recordCircleView.bounds
        trackLayer.strokeColor = kMainBlueColor().cgColor
        trackLayer.fillColor = UIColor.clear.cgColor
        trackLayer.opacity = 1.0
        trackLayer.lineCap = kCALineCapRound
        trackLayer.lineWidth = 2.0
        trackLayer.path = path.cgPath
        recordCircleView.layer.addSublayer(trackLayer)
        recordCircleView.layer.cornerRadius = 40
        recordCircleView.layer.masksToBounds = true
        
        // 设置渐变色 
        let gradientLayer = CAGradientLayer()
        gradientLayer.frame = recordCircleView.bounds
        gradientLayer.colors = [kMainBlueColor().cgColor,UIColor.purple.cgColor]
        recordCircleView.layer.addSublayer(gradientLayer)
        gradientLayer.mask = trackLayer
        
        // 长按手势 
        longPressGesture = UILongPressGestureRecognizer(
            target: self, action: #selector(longPressAction(gesture:)))
        longPressGesture.minimumPressDuration = 0.01
        longPressGesture.delegate = self
        recordCircleView.addGestureRecognizer(longPressGesture)
    }
    
    // MARK: - 长按录制视频事件回调 
    @objc private func longPressAction(gesture:UILongPressGestureRecognizer) -> Void 
    {
        let touchPoint = gesture.location(in: recordCircleView)
        let isTouchInsided = touchPoint.y >= 0
        print("录制长按是否在圆圈内:\(isTouchInsided)")
        
        switch gesture.state {
        case UIGestureRecognizerState.began:
            self.longPressBeganAction()
            self.delegate.recordCircleViewDidStartRecord(bottomView: self)
        
        case UIGestureRecognizerState.changed:
            
            if isTouchInsided
            {
                self.recordProgressView.backgroundColor = kMainBlueColor()
            } else
            {
                self.recordProgressView.backgroundColor = kMainRedColor()
                self.delegate.recordCircleViewMoveUpWillCancel(bottomView: self)
            }
            
        case UIGestureRecognizerState.ended:
            self.setupRecordOriginalData()
            if !isTouchInsided || kRecordTotalTime - recordSurplusTime <= 1
            {
                var reason:MTTSmallVideoDidEndType = MTTSmallVideoDidEndType.MTTSmallVideoDidEndTypeShortTime
                
                if !isTouchInsided
                {
                    reason = MTTSmallVideoDidEndType.MTTSmallVideoDidEndTypeDefault
                }
                self.delegate.recordCircleViewDidEndWithType(bottomView: self, type: reason)
            } else
            {
                self.delegate.recordCircleViewDidEnd(bottomView: self)
            }
            
        default: break
            
        }
        
        
    }
    
    // 开始长按回调 
    private func longPressBeganAction() -> Void 
    {
        recordCircleView.alpha = 1.0
        
        recordProgressView.frame = CGRect(x: 0, y: 0, width: self.bounds.size.width, height: 2)
        recordProgressView.isHidden = false
        
        recordSurplusTime = kRecordTotalTime
        
        if recordTimer == nil 
        {
            recordTimer = Timer(
                timeInterval: 1.0, 
                target: self, 
                selector: #selector(recordProgressTimerAction), 
                userInfo: nil, 
                repeats: true)
            RunLoop.current.add(recordTimer, forMode: RunLoopMode.defaultRunLoopMode)
        }
        recordTimer.fire()
        
        
        let oTransform = CGAffineTransform.identity
        UIView.animate(withDuration: 0.5, animations: { 
            self.recordCircleView.alpha = 0.0
            self.recordCircleView.transform = CGAffineTransform(scaleX: 2.0, y: 2.0)
        }) { completed in
            self.recordCircleView.transform = oTransform
        }
        
        
    }
    
    // 录制初始数据
    private func setupRecordOriginalData() -> Void 
    {
        self.recordProgressView.isHidden = true
        
        if self.recordTimer != nil 
        {
            self.recordTimer.invalidate()
            self.recordTimer = nil
        }
        
        self.recordCircleView.alpha = 1.0
    }
    
    // 录制进度回调 
    @objc private func recordProgressTimerAction() -> Void 
    {
        let reduceLength:CGFloat = self.bounds.size.width / CGFloat(recordSurplusTime)
        let oldProgressViewLength = self.recordProgressView.width
        let oldProgressViewFrame = self.recordProgressView.frame
        
        UIView.animate(withDuration: 1.0, delay: 0.0, options: UIViewAnimationOptions.curveLinear, animations: { 
            self.recordProgressView.frame = CGRect(x: oldProgressViewFrame.origin.x, y: oldProgressViewFrame.origin.y, width: oldProgressViewLength - reduceLength, height: oldProgressViewFrame.size.height)
            self.recordProgressView.center = CGPoint(x: self.bounds.size.width / 2.0, y: self.recordProgressView.bounds.size.height / 2.0)
        }) { completed in
            self.recordSurplusTime = self.recordSurplusTime - 1
            print("录制剩余时间:\(self.recordSurplusTime)")
            if self.recordSurplusTime == 1
            {
                print("录制剩余时间:\(self.recordSurplusTime)")
                self.setupRecordOriginalData()
            }
        }
        
        
        
    }
    
    
    // MARK: - 监听相关事件 
    func setupEvent() -> Void 
    {
        videoRemoveButton.rx.tap
            .subscribe(onNext:{ _ in
                self.delegate.tappedRemoveButton(bottomView: self)
            }).disposed(by: disposeBag)
        
        videoListButton.rx.tap
            .subscribe(onNext:{ element in
                print("视频列表事件触发")
            })
            .disposed(by: disposeBag)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}

// MARK: - ************************ extension ***********************
// MARK: - 长按手势delegate 回调
extension MTTSmallVideoBottomView:UIGestureRecognizerDelegate
{
    override func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool 
    {
        
        return true
    }
}
