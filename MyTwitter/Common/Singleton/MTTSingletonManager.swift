//
//  MTTSingletonManager.swift
//  MyTwitter
//
//  Created by LiuChuanan on 2017/9/18.
//  Copyright © 2017年 waitWalker. All rights reserved.
//

import UIKit
import Foundation
import Photos
import AssetsLibrary
import AVFoundation
import MBProgressHUD

class MTTSingletonManager: NSObject 
{
    var user_name:String     = ""
    var email:String         = ""
    var phone_num:String     = ""
    var password:String      = ""
    var tappedImageIndex:Int = 0
    var isSimulator          = MTTPlatform.isSimulator


    // 录音相关 
    var recorder:AVAudioRecorder!
    var currentRecorderPath:String!
    var currentRecorderFileName:String!
    
    var recorderTimer:Timer!
    var recorderContainerView:UIView!
    var recordingAnimationImageView:UIImageView!
    var recordingMicroImageView:UIImageView!
    var recordCancelImageView:UIImageView!
    var recordShotTimeImageView:UIImageView!
    var recordHintTextLabel:UILabel!
    dynamic var recorderButtonEnabled:Bool = true
    var recorderTotalTime:Int = 0
    
    // 播放相关 
    var player:AVAudioPlayer!
    var autoStopPlaying:Bool = true
    
    

    static let sharedInstance = MTTSingletonManager()
    
    private override init
    () {
        super.init()
    }
    
    // MARK: - AppDelegate 相关
    func getAppDelegate() -> AppDelegate
    {
        return UIApplication.shared.delegate as! AppDelegate
    }
    
    func getKeyWindow() -> UIWindow
    {
        return getAppDelegate().window!
    }
    
    func getRootViewController() -> UIViewController
    {
        return getKeyWindow().rootViewController!
    }
    
    // MARK: - 全局设置状态栏 导航栏背景色透明 
    /*
     全局设置状态栏颜色:我在这里提供几种方法，大家可以根据需求使用（如有不正确的地方，请留言）
     1.全工程的颜色都是白色（从app启动就是白色）。
     第一步：在Info.plist中设置UIViewControllerBasedStatusBarAppearance 为NO
     第二步：在info.plist中添加：
     <key>UIStatusBarStyle</key>
     <string>UIStatusBarStyleLightContent</string>
     这样就可以把默认的黑色改为白色，注意从启动的时候就是白色。
     2.全工程的颜色都是白色（启动的时候是默认的颜色黑色）
     第一步：在Info.plist中设置UIViewControllerBasedStatusBarAppearance 为NO
     第二步：在viewWillAppear中添加代码
     oc：[[UIApplication sharedApplication]setStatusBarStyle:UIStatusBarStyleLightContent];//状态栏内容颜色
     swift：UIApplication.shared.statusBarStyle = .lightContent
     这样就可以把默认的黑色改为白色，注意启动的时候是默认的颜色黑色。
     3.只是部分控制器需要修改状态栏文字的颜色
     只需要把上面第二步的白色改成黑色，即lightContent或UIStatusBarStyleLightContent改成.default或UIStatusBarStyleDefault
     */
    func setupClearNavigationBar(controller:MTTViewController) -> Void 
    {
        controller.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        controller.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    func removeClearNavigationBarSetting(controller:MTTViewController) -> Void 
    {
        controller.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        controller.navigationController?.navigationBar.shadowImage = nil
    }
    
    // MARK: - 隐藏 显示 tabBar
    func hideTabbar() -> Void
    {
        let rootVC = getRootViewController()
        
        if (rootVC.isKind(of: UITabBarController.self))
        {
            let tabBarVC = rootVC as! UITabBarController
            tabBarVC.tabBar.isHidden = true
        } else
        {
            rootVC.tabBarController?.tabBar.isHidden = true
        }
        
    }
    
    func showTabbar() -> Void
    {
        let rootVC = getRootViewController()
        
        if (rootVC.isKind(of: UITabBarController.self))
        {
            let tabBarVC = rootVC as! UITabBarController
            tabBarVC.tabBar.isHidden = false
        } else
        {
            rootVC.tabBarController?.tabBar.isHidden = false
        }
    }
    
    // MARK: - 获取相机相册权限状态
    func getCameraAuthorizationStatus() -> Bool
    {
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeVideo)
        
        if authStatus != AVAuthorizationStatus.denied
        {
            return true
        }
        return false
    }
    
    func getPhotoLibraryAuthorizationStatus() -> Bool
    {
        if PHPhotoLibrary.authorizationStatus() != PHAuthorizationStatus.denied
        {
            return true
        }
        return false
    }
    
    // MARK: - 授权失败弹框
    func showAlter(with message: String) -> Void
    {
        let alertController = UIAlertController(title: "提示", message: message, preferredStyle: UIAlertControllerStyle.alert)
        let confirmAction = UIAlertAction(title: "确定", style: UIAlertActionStyle.default) { action in
            UIApplication.shared.open(URL(string: "App-Prefs:root=Privacy")!, options: ["" : ""], completionHandler: { completed in
                
            })
        }
        
        let cancelAction = UIAlertAction(title: "取消", style: UIAlertActionStyle.cancel) { action in
            
        }
        
        alertController.addAction(cancelAction)
        alertController.addAction(confirmAction)
        
        getRootViewController().present(alertController, animated: true) {
            
        }
    }
    
    
    
    
    
    /***************************************/
    // MARK: - recorder 相关 
    func startRecorder() -> Void 
    {
        DispatchQueue.main.async {
            self.setupSubview()
        }
        
        setupRecorder()
    }
    
    func cancelRecorder() -> Void 
    {
        if recorder != nil
        {
            stopRecorder()
        }
    }
    
    func finishRecorder() -> Void 
    {
        if recorder != nil
        {
            if recorder.currentTime < 1.0
            {
                recorderButtonEnabled = false
                showShotTimeView()
                return
            }
            stopRecorder()
        }
        
    }
    
    func readyToCancelRecorder() -> Void 
    {
        recordingAnimationImageView.isHidden = true
        recordingMicroImageView.isHidden     = true
        recordCancelImageView.isHidden       = false
        recordShotTimeImageView.isHidden     = true
        recordHintTextLabel.text = "手指松开，取消发送"
    }
    
    func readyToResumeRecorder() -> Void 
    {
        recordingAnimationImageView.isHidden = false
        recordingMicroImageView.isHidden     = false
        recordCancelImageView.isHidden       = true
        recordShotTimeImageView.isHidden     = true
        recordHintTextLabel.text = "手指松开，取消发送"
    }
    
    func stopRecorder() -> Void 
    {
        recorderButtonEnabled = true
        if recorderTimer != nil
        {
            recorderTimer.invalidate()
            recorderTimer = nil
        }
        
        if recorderContainerView != nil
        {
            recorderContainerView.removeFromSuperview()
            recorderContainerView = nil
        }
        
        recorder.stop()
        
    }
    
    private func setupRecorder() -> Void 
    {
        //初始化录音器
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        //设置录音类型
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        //设置支持后台
        try! session.setActive(true)
        
        // 文件名称
        currentRecorderFileName = String(format: "/voice-%.0f.m4a", Date().timeIntervalSince1970)
        
        //组合录音文件路径
        currentRecorderPath = getRecorderFilePath() + currentRecorderFileName
        
        //初始化字典并添加设置参数
        let recorderSeetingsDic = setupSettings()
        
        //初始化录音器
        recorder = try! AVAudioRecorder(url: URL(string: currentRecorderPath)!, settings: recorderSeetingsDic)
        
        if recorder != nil 
        {
            //开启仪表计数功能
            recorder!.isMeteringEnabled = true
            //准备录音
            recorder!.prepareToRecord()
            //开始录音
            recorder!.record()
            
            recorder.delegate = self
            
            //启动定时器，定时更新录音音量
            recorderTimer = Timer.scheduledTimer(timeInterval: 0.01, 
                                                 target: self,
                                                 selector: #selector(recorderTimerAction),
                                                 userInfo: nil, 
                                                 repeats: true)
        }
    }
    
    @objc func recorderTimerAction() -> Void 
    {
        recorder!.updateMeters() // 刷新音量数据
        var averageV:Float = recorder!.averagePower(forChannel: 0) //获取音量的平均值
        print("声波:\(averageV)")
        averageV = averageV + 75.0
        
        if averageV > 0.0 && averageV <= 10.0 
        {
            recordingAnimationImageView.image = UIImage.imageNamed(name: "twitter_record_vol_1")
        } else if averageV > 10.0 && averageV <= 20.0
        {
            recordingAnimationImageView.image = UIImage.imageNamed(name: "twitter_record_vol_2")
        } else if averageV > 20.0 && averageV <= 30.0
        {
            recordingAnimationImageView.image = UIImage.imageNamed(name: "twitter_record_vol_3")
        } else if averageV > 30.0 && averageV <= 40.0
        {
            recordingAnimationImageView.image = UIImage.imageNamed(name: "twitter_record_vol_4")
        } else if averageV > 40.0 && averageV <= 50.0
        {
            recordingAnimationImageView.image = UIImage.imageNamed(name: "twitter_record_vol_5")
        } else if averageV > 50.0 && averageV <= 60.0
        {
            recordingAnimationImageView.image = UIImage.imageNamed(name: "twitter_record_vol_6")
        } else if averageV > 60.0 && averageV <= 70.0
        {
            recordingAnimationImageView.image = UIImage.imageNamed(name: "twitter_record_vol_7")
        }  else
        {
            recordingAnimationImageView.image = UIImage.imageNamed(name: "twitter_record_vol_7")
        }
        
    }
    
    public func setupSettings() -> [String:Any]
    {
        let setting = 
            [
                AVFormatIDKey: NSNumber(value: kAudioFormatMPEG4AAC),
                AVNumberOfChannelsKey: 1, //录音的声道数，立体声为双声道
                AVEncoderAudioQualityKey : AVAudioQuality.max.rawValue,
                //AVEncoderBitRateKey : 320000,
                AVSampleRateKey : 44100.0 //录音器每秒采集的录音样本数
            ] as [String : Any]
        
        return setting
        
    }
    
    // 录音缓存路径 
    func getRecorderFilePath() -> String 
    {
        /*
         let docDir = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
         let fileURL = docDir.appendingPathComponent("Audio").appendingPathExtension("m4a")
         do {
         audioRecorder = try AVAudioRecorder(url: fileURL, settings: recordSetting)
         } catch {
         print(error)
         }
         */
        
        let filePath = getDocumentPath() + "/recorderFile"
        if FileManager.default.fileExists(atPath: filePath)
        {
            return filePath
        }
        
        do {
            try FileManager.default.createDirectory(atPath: filePath, withIntermediateDirectories: true, attributes: nil)
            return filePath
        } catch
        {
            return getDocumentPath()
        }
    }
    
    
    func setupSubview() -> Void 
    {
        if recorderContainerView == nil 
        {
            recorderContainerView = UIView(frame: CGRect(x: (kScreenWidth - 160) / 2, y: (kScreenHeight - 140) / 2, width: 160, height: 140))
            recorderContainerView.layer.cornerRadius = 15
            recorderContainerView.clipsToBounds = true
            recorderContainerView.backgroundColor = kMainBlueColor().withAlphaComponent(0.5)
            self.getKeyWindow().addSubview(recorderContainerView)
            
            recordingMicroImageView = UIImageView(frame: CGRect(x: 40, y: 25, width: 37, height: 70))
            recordingMicroImageView.image = UIImage.imageNamed(name: "twitter_record_micro")
            recorderContainerView.addSubview(recordingMicroImageView)
            
            recordingAnimationImageView = UIImageView(frame: CGRect(x: recordingMicroImageView.frame.maxX + 16, y: 30, width: 29, height: 64))
            recordingAnimationImageView.image = UIImage.imageNamed(name: "twitter_record_vol_5")
            recorderContainerView.addSubview(recordingAnimationImageView)
            
            recordHintTextLabel = UILabel()
            recordHintTextLabel.frame = CGRect(x: 0, y: recordingAnimationImageView.frame.maxY + 10, width: recorderContainerView.frame.size.width, height: 20)
            recordHintTextLabel.backgroundColor = UIColor.clear
            recordHintTextLabel.textColor = UIColor.white
            recordHintTextLabel.textAlignment = NSTextAlignment.center
            recordHintTextLabel.font = UIFont.systemFont(ofSize: 14.0)
            recordHintTextLabel.text = "手指上滑,取消发送"
            recorderContainerView.addSubview(recordHintTextLabel)
            
            recordCancelImageView = UIImageView(frame: CGRect(x: 45, y: 20, width: 60, height: 75))
            recordCancelImageView.image = UIImage.imageNamed(name: "twitter_record_cancel")
            recorderContainerView.addSubview(recordCancelImageView)
            
            recordShotTimeImageView = UIImageView(frame: CGRect(x: 70, y: 20, width: 20, height: 75))
            recordShotTimeImageView.image = UIImage.imageNamed(name: "twitter_record_shot_time")
            recorderContainerView.addSubview(recordShotTimeImageView)
        }
        
        recordingAnimationImageView.isHidden = false
        recordingMicroImageView.isHidden     = false
        recordCancelImageView.isHidden       = true
        recordShotTimeImageView.isHidden     = true
    }
    
    func showShotTimeView() -> Void 
    {
        recordingAnimationImageView.isHidden = true
        recordingMicroImageView.isHidden     = true
        recordCancelImageView.isHidden       = true
        recordShotTimeImageView.isHidden     = false
        recordHintTextLabel.text             = "说话时间太短"
        
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1.5) { 
            self.stopRecorder()
        }
    }
    
    /***********************************************************/
    
    /***********************************************************/
    // MARK: - 播放相关 
    func playerVoice(with fileString:String) -> Void 
    {
        setupPlayer(fileString: fileString)
    }
    
    private func setupPlayer(fileString:String) -> Void 
    {
        //初始化录音器
        let session:AVAudioSession = AVAudioSession.sharedInstance()
        
        //设置录音类型
        try! session.setCategory(AVAudioSessionCategoryPlayback)
        
        player = try! AVAudioPlayer(contentsOf: URL(fileURLWithPath: fileString))
        
        if player.isPlaying 
        {
            player.stop()
        }
        
        UIDevice.current.isProximityMonitoringEnabled = true
        NotificationCenter.default.addObserver(self, selector: #selector(proximityMonitoringAction), name: NSNotification.Name.UIDeviceProximityStateDidChange, object: nil)
        
        player.volume = 1.0
        player.delegate = self
        player.prepareToPlay()
        player.play()
        self.autoStopPlaying = true
    }
    
    func freePlayer() -> Void 
    {
        if player != nil 
        {
            player.stop()
            player.delegate = nil
            player = nil
        }
    }
    
    @objc func proximityMonitoringAction() -> Void 
    {
        if UIDevice.current.proximityState 
        {
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayAndRecord)
        } else
        {
            try! AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
        }
    }
    
    
    /***********************************************************/
    
    /**工具相关**/
    func getDocumentPath() -> String 
    {
        let path = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true).first
        return path!
    }
}

// MARK: - recorderDelegate
extension MTTSingletonManager:
AVAudioRecorderDelegate
{
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) 
    {
        print("finish recorder \(self)")
    }
    
    
    func audioRecorderEncodeErrorDidOccur(_ recorder: AVAudioRecorder, error: Error?) 
    {
        
    }
}

// MARK: - playerDelegate
extension MTTSingletonManager:
AVAudioPlayerDelegate
{
    func audioPlayerDidFinishPlaying(_ player: AVAudioPlayer, successfully flag: Bool) 
    {
        self.freePlayer()
        
        if self.autoStopPlaying
        {
            NotificationCenter.default.post(name: NSNotification.Name(rawValue: kRecorderPlayFinishNotificationString), object: nil)
        }
    }
}

// MARK: - 判断是否是模拟器 
struct MTTPlatform 
{
    static let isSimulator:Bool = {
        var isSim = false
        #if arch(i386) || arch(x86_64)
            isSim = true
        #endif 
        return isSim
    }()
}

// MARK: - 获取录音授权状态 
extension MTTSingletonManager
{
    func getAudioAuthrizationStatus() -> Bool 
    {
        let authStatus = AVCaptureDevice.authorizationStatus(forMediaType: AVMediaTypeAudio)
        if authStatus == AVAuthorizationStatus.restricted || authStatus == AVAuthorizationStatus.denied 
        {
            return false
        }
        return true
    }
    
}
