//
//  MTTChatMessageToolBar.swift
//  MyTwitter
//
//  Created by WangJunZi on 1017/11/28.
//  Copyright © 1017年 waitWalker. All rights reserved.
//
/**
    聊天底部工具栏 
 */

import UIKit
import RxCocoa
import RxSwift
import AVFoundation

class MTTChatMessageToolBar: UIView
{
    var disposeBag = DisposeBag()
    var delegate:MTTChatMessageToolBarDelegate?
    
    
    
    var lineView:UIView!
    
    var addButton:UIButton!
    var inputTextView:UITextView!
    var placeLabel:UILabel!
    var pictureButton:UIButton!
    var expressionButton:UIButton!
    var sendButton:UIButton!
    
    var keyboardHeight:CGFloat?
    var original_y:CGFloat?
    var textInputMaxHeight:CGFloat?
    var textInputHeight:CGFloat?
    var recorderButton:UIButton!
    
    
    
    var maxLines:NSInteger?
    {
        didSet{
            textInputMaxHeight = ceil((self.inputTextView.font?.lineHeight)! * CGFloat(maxLines! + 1) + self.inputTextView.textContainerInset.top + self.inputTextView.textContainerInset.bottom)
        }
    }
    
    
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        setupSubview()
        layoutSubview()
        setupEvent()
        setupNotification()
        self.original_y = frame.origin.y
        
        let recorder = try! AVAudioRecorder(url: URL(string: shardInstance.getDocumentPath())!, settings: shardInstance.setupSettings())
        recorder.prepareToRecord()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    func setupSubview()
    {
        // lineView
        lineView = UIView()
        lineView.backgroundColor = kMainLightGrayColor()
        self.addSubview(lineView)
        
        // 添加按钮
        addButton = UIButton()
        addButton.setImage(UIImage.imageNamed(name: "twitter_add_normal"), for: UIControlState.normal)
        self.addSubview(addButton)
        
        // 输入框
        inputTextView = UITextView()
        inputTextView.delegate = self
        inputTextView.backgroundColor = kMainChatBackgroundGrayColor()
        inputTextView.layer.cornerRadius = 10
        inputTextView.clipsToBounds = true
        inputTextView.textColor = UIColor.black
        inputTextView.isEditable = true
        inputTextView.font = UIFont.systemFont(ofSize: 18)
        inputTextView.scrollRangeToVisible(NSRange.init(location: 0, length: 0))
        self.addSubview(inputTextView)

        // 站位label
        placeLabel = UILabel()
        placeLabel.text = "开始写私信"
        placeLabel.textColor = kMainGrayColor()
        placeLabel.font = UIFont.systemFont(ofSize: 15)
        placeLabel.textAlignment = NSTextAlignment.left
        self.addSubview(placeLabel)
        
        // 图片按钮
        pictureButton = UIButton()
        pictureButton.setImage(UIImage.imageNamed(name: "twitter_pictures_normal"), for: UIControlState.normal)
        self.addSubview(pictureButton)
        
        // 表情按钮
        expressionButton = UIButton()
        expressionButton.setImage(UIImage.imageNamed(name: "twitter_expression_normal"), for: UIControlState.normal)
        self.addSubview(expressionButton)
        
        // 发送按钮
        sendButton = UIButton()
        sendButton.isHidden = true
        sendButton.setImage(UIImage.imageNamed(name: "twitter_send_normal"), for: UIControlState.normal)
        self.addSubview(sendButton)
        
        // 录音按钮 
        recorderButton = UIButton()
        recorderButton.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        recorderButton.setTitleColor(kMainBlueColor(), for: UIControlState.normal)
        recorderButton.setTitleColor(kMainBlueColor(), for: UIControlState.selected)
        recorderButton.setTitle("长按录音", for: UIControlState.normal)
        recorderButton.setTitle("松手结束", for: UIControlState.selected)
        recorderButton.setTitleColor(kMainGrayColor(), for: UIControlState.normal)
        recorderButton.setBackgroundImage(UIImage.imageNamed(name: "twitter_recorder_background_selected").resizableImage(withCapInsets: UIEdgeInsetsMake(10, 10, 10, 10)), for: UIControlState.selected)
        recorderButton.setBackgroundImage(UIImage.imageNamed(name: "twitter_recorder_background_normal").resizableImage(withCapInsets: UIEdgeInsetsMake(10, 10, 10, 10)), for: UIControlState.normal)
        recorderButton.layer.borderColor = kMainBlueColor().cgColor
        recorderButton.layer.borderWidth = 1.0
        recorderButton.cornerRadius = 5
        recorderButton.clipsToBounds = true
        recorderButton.addTarget(self, action: #selector(recorderTouchDownAction(with:)), for: UIControlEvents.touchDown)
        recorderButton.addTarget(self, action: #selector(recorderTouchUpOutsideAction(with:)), for: UIControlEvents.touchUpOutside)
        recorderButton.addTarget(self, action: #selector(recorderTouchUpInsideAction(with:)), for: UIControlEvents.touchUpInside)
        recorderButton.addTarget(self, action: #selector(recorderTouchDragExitAction(with:)), for: UIControlEvents.touchDragExit)
        recorderButton.addTarget(self, action: #selector(recorderTouchDragEnterAction(with:)), for: UIControlEvents.touchDragEnter)
        self.addSubview(recorderButton)
        
        shardInstance.addObserver(self, forKeyPath: "recorderButtonEnabled", options: NSKeyValueObservingOptions.new, context: nil)
    }
    
    // 开始录音
    @objc func recorderTouchDownAction(with button:UIButton) -> Void
    {
        button.setTitle("松手结束", for: UIControlState.normal)
        AVAudioSession.sharedInstance().requestRecordPermission { isPerssion in
            
            if isPerssion
            {
                shardInstance.startRecorder()
            } else
            {
                shardInstance.showAlter(with: "还没有授权麦克风,是否现在授权?")
            }
        }
        
    }
    
    // 取消录音
    @objc func recorderTouchUpOutsideAction(with button:UIButton) -> Void
    {
        shardInstance.cancelRecorder()
    }
    
    // 录音成功 发送录音 按钮恢复状态
    @objc func recorderTouchUpInsideAction(with button:UIButton) -> Void
    {
        if shardInstance.recorder != nil
        {
            if shardInstance.recorder.currentTime < 1.0
            {
                shardInstance.recorderButtonEnabled = false
                shardInstance.showShotTimeView()
                return
            }
            
            shardInstance.recorderTotalTime = Int(shardInstance.recorder.currentTime)
            
            shardInstance.stopRecorder()
            
            // 发送录音
            self.delegate?.finishRecordVoice()
            
            recorderButton.isHidden   = false
        }
        
    }
    
    // 移除范围 准备取消录音
    @objc func recorderTouchDragExitAction(with button:UIButton) -> Void
    {
        shardInstance.readyToCancelRecorder()
    }
    
    // 移入范围 准备继续录音
    @objc func recorderTouchDragEnterAction(with button:UIButton) -> Void
    {
        shardInstance.readyToResumeRecorder()
    }
    
    
    func layoutSubview()
    {
        lineView.frame            = CGRect(x: 0, y: 0, width: kScreenWidth, height: 1)
        addButton.frame           = CGRect(x: 10, y: 13, width: 24, height: 24)
        placeLabel.frame          = CGRect(x: 48, y: 5, width: 180, height: 40)
        inputTextView.frame       = CGRect(x: 44, y: 5, width: kScreenWidth - 44 - 78, height: 40)
        pictureButton.frame       = CGRect(x: inputTextView.frame.maxX + 10, y: 13, width: 24, height: 24)
        expressionButton.frame    = CGRect(x: pictureButton.frame.maxX + 10, y: 13, width: 24, height: 24)
        sendButton.frame          = CGRect(x: kScreenWidth - 24 - 10, y: 13, width: 24, height: 24)
        recorderButton.frame      = CGRect(x: 44, y: 5, width: kScreenWidth - 44 - 78, height: 40)
        
        sendButton.isHidden       = true

        pictureButton.isHidden    = false

        expressionButton.isHidden = false

        addButton.isHidden        = false
        
        recorderButton.isHidden   = true
    }
    
    func setupNotification() -> Void
    {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShowAction(notify:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHideAction(notify:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    @objc func keyboardWillShowAction(notify:Notification) -> Void
    {
        if self.pictureButton.isSelected
        {
            self.pictureButton.sendActions(for: UIControlEvents.touchUpInside)
        }
        
        if self.addButton.isSelected
        {
            self.addButton.sendActions(for: UIControlEvents.touchUpInside)
        }
        
        let keyboardFrame = notify.userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
        
        keyboardHeight = keyboardFrame.size.height
        
        let duration = notify.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! CGFloat
        
        UIView.beginAnimations(nil, context: nil)
        UIView.setAnimationBeginsFromCurrentState(true)
        UIView.setAnimationDuration(TimeInterval(duration))
        UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: 7)!)
        self.y = keyboardFrame.origin.y - self.height
        UIView.commitAnimations()
        
    }
    
    @objc func keyboardWillHideAction(notify:Notification) -> Void
    {
        let duration = notify.userInfo![UIKeyboardAnimationDurationUserInfoKey] as! TimeInterval
        UIView.animate(withDuration: duration) {
            self.y = self.original_y!
        }
        
    }
    
    public func setupEvent() -> Void
    {
        let inputTextViewSequence = (inputTextView.rx.text)
            .orEmpty
            .map{ $0.count > 0}
            .share(replay: 1)
        
        let inputTextViewSequenceNegate = (inputTextView.rx.text)
            .orEmpty
            .map{ $0.count <= 0}
            .share(replay: 1)
        
        inputTextViewSequence
            .bind(to: placeLabel.rx.isHidden)
            .disposed(by: disposeBag)
        
        inputTextViewSequence
            .bind(to: expressionButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        inputTextViewSequence
            .bind(to: pictureButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        inputTextViewSequenceNegate
            .bind(to: sendButton.rx.isHidden)
            .disposed(by: disposeBag)
        
        (pictureButton.rx.tap)
            .subscribe(onNext:{[unowned self] in
                self.delegate?.tappedPictureButton(button: self.pictureButton)
            }).disposed(by: disposeBag)
        
        (addButton.rx.tap)
            .subscribe(onNext:{[unowned self] in
                self.delegate?.tappedAddVideoButton(button: self.addButton)
            }).disposed(by: disposeBag)
        
        sendButton.rx.tap
            .subscribe(onNext:{[unowned self] in
                if self.inputTextView.text.count > 0
                {
                    self.delegate?.tappedSendButton(text: self.inputTextView.text)
                }
            }).disposed(by: disposeBag)
        
    }
    
    // MARK: - KVO 键值观察 监听属性
    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?)
    {
        if keyPath == "recorderButtonEnabled"
        {
            recorderButton.isEnabled = (change![NSKeyValueChangeKey.newKey] as! Bool)
            print(change![NSKeyValueChangeKey.newKey] as Any) 
        }
        
    }
    
    deinit
    {
        shardInstance.removeObserver(self, forKeyPath: "recorderButtonEnabled")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}

extension MTTChatMessageToolBar:UITextViewDelegate
{
    func textViewDidChange(_ textView: UITextView)
    {
        
        if textView.text.count > 0 {
            self.inputTextView.width = kScreenWidth - 44 - 44
        } else
        {
            self.inputTextView.width = kScreenWidth - 44 - 78
        }
        
        self.textInputHeight = ceil(self.inputTextView.sizeThatFits(CGSize(width: self.inputTextView.width, height: CGFloat(MAXFLOAT))).height)
        
        self.inputTextView.isScrollEnabled = (textInputHeight! > textInputMaxHeight!) && textInputMaxHeight! > CGFloat(0)
        
        if self.inputTextView.isScrollEnabled
        {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(0.3)
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: 7)!)
            
            self.inputTextView.height = 5 + textInputMaxHeight!
            self.y                    = kScreenHeight - keyboardHeight! - self.inputTextView.height - 10
            self.height               = self.inputTextView.height + 10
            self.sendButton.y         = self.height - 24 - 13
            self.addButton.y          = self.sendButton.y
            UIView.commitAnimations()
        } else
        {
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationBeginsFromCurrentState(true)
            UIView.setAnimationDuration(0.3)
            UIView.setAnimationCurve(UIViewAnimationCurve(rawValue: 7)!)
            self.inputTextView.height = textInputHeight!

            self.y                    = kScreenHeight - keyboardHeight! - self.inputTextView.height - 10
            self.height               = self.inputTextView.height + 10
            self.sendButton.y         = self.height - 24 - 13
            self.addButton.y          = self.sendButton.y
            UIView.commitAnimations()
        }
        lineView.frame = CGRect(x: 0, y: 0, width: kScreenWidth, height: 1)
    }
    
    
    func changeFrame(height:CGFloat) -> Void
    {
        var origianlFrame = self.frame
        var textViewContainerViewFrame = self.inputTextView.frame
        var textViewFrame = self.inputTextView.frame
        
        origianlFrame.size.height = height + 10
        origianlFrame.origin.y = kScreenHeight - height - 20 - 44;
        
        textViewContainerViewFrame.size.width = origianlFrame.size.width - 44 - 44
        textViewContainerViewFrame.size.height = origianlFrame.size.height - 10
        
        textViewFrame.size.width = textViewContainerViewFrame.size.width - 10
        textViewFrame.size.height = textViewContainerViewFrame.size.height
        UIView.animate(withDuration: 0.3) {
            self.frame = origianlFrame
            self.inputTextView.frame = textViewContainerViewFrame
            self.inputTextView.frame = textViewFrame
        }
        
    }
    
}

