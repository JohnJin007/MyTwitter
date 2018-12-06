//
//  MTTRegisterNameViewController.swift
//  MyTwitter
//
//  Created by LiuChuanan on 2017/9/6.
//  Copyright © 2017年 waitWalker. All rights reserved.
//

import UIKit

class MTTRegisterNameViewController: MTTViewController {

    let kRegisterNameMargin:CGFloat = 20
    
    var cancelButton:UIButton?
    var logoImageView:UIImageView?
    var nameLabel:UILabel?
    var nameTextField:UITextField?
    var verifyImageView:UIImageView?
    var errorHintLabel:UILabel?
    var firstLine:UIView?
    var contentView:UIView?
    var nextButton:UIButton?
    var secondLine:UIView?
    var leftButton:UIButton?
    var nameUserInfo:[String:String]?
    
    
    override func viewWillAppear(_ animated: Bool) 
    {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
    }
    
    override func viewDidLoad() 
    {
        super.viewDidLoad()
        self.addNotificationObserver()
        self.setupSubview()
        self.layoutSubview()
        self.setupEvent()
        
    }
    
    
    // MARK: - 初始化控件
    func setupSubview() -> Void 
    {
        //cancelButton
        cancelButton                              = UIButton()
        cancelButton?.setTitle("取消", for: UIControlState.normal)
        cancelButton?.setTitleColor(kMainBlueColor(), for: UIControlState.normal)
        cancelButton?.titleLabel?.font            = UIFont.systemFont(ofSize: 15.0)
        cancelButton?.isHidden                    = true
        self.view.addSubview(cancelButton!)

        //logo
        logoImageView                             = UIImageView()
        logoImageView?.image                      = UIImage.init(named: "twitter_logo")
        logoImageView?.isUserInteractionEnabled   = true
        self.view.addSubview(logoImageView!)

        //nameLabel
        nameLabel                                 = UILabel()
        nameLabel?.font                           = UIFont.boldSystemFont(ofSize: 20)
        nameLabel?.text                           = "你好,请问你的姓名是什么?"
        nameLabel?.textColor                      = UIColor.black
        self.view.addSubview(nameLabel!)

        //nameTextField
        nameTextField                             = UITextField()
        nameTextField?.placeholder                = "全名"
        nameTextField?.textColor                  = kMainBlueColor()
        nameTextField?.font                       = UIFont.systemFont(ofSize: 18)

        //milliseconds毫秒 microseconds微秒
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + DispatchTimeInterval.milliseconds(100)) {
            self.nameTextField?.becomeFirstResponder()
        }
        self.view.addSubview(nameTextField!)

        //verifyImageView
        verifyImageView                           = UIImageView()
        verifyImageView?.isUserInteractionEnabled = true
        verifyImageView?.layer.borderWidth        = 2
        verifyImageView?.layer.cornerRadius       = 12.5
        verifyImageView?.clipsToBounds            = true
        verifyImageView?.isHidden                 = true
        self.view.addSubview(verifyImageView!)

        //firstLine
        firstLine                                 = UIView()
        firstLine?.backgroundColor                = kMainGrayColor()
        self.view.addSubview(firstLine!)

        //errorHintLabel
        errorHintLabel                            = UILabel()
        errorHintLabel?.textColor                 = kMainWhiteColor()
        errorHintLabel?.text                      = "    你的全名不能多于20个字符."
        errorHintLabel?.backgroundColor           = kMainRedColor()
        errorHintLabel?.textAlignment             = NSTextAlignment.left
        errorHintLabel?.font                      = UIFont.systemFont(ofSize: 15)
        errorHintLabel?.isHidden                  = true
        self.view.addSubview(errorHintLabel!)

        //contentView
        contentView                               = UIView()
        self.view.addSubview(contentView!)

        //secondLine
        secondLine                                = UIView()
        secondLine?.backgroundColor               = kMainGrayColor()
        contentView?.addSubview(secondLine!)

        //nextButton
        nextButton                                = UIButton()
        nextButton?.setTitle("下一步", for: UIControlState.normal)
        nextButton?.setTitleColor(kMainGrayColor(), for: UIControlState.normal)
        nextButton?.titleLabel?.font              = UIFont.systemFont(ofSize: 15)
        nextButton?.backgroundColor               = kMainBlueColor()
        nextButton?.layer.cornerRadius            = 17.5
        nextButton?.clipsToBounds                 = true
        contentView?.addSubview(nextButton!)

        //左边返回
        leftButton                                = UIButton()
        leftButton?.frame                         = CGRect(x: -20, y: 0, width: 50, height: 44)
        leftButton?.titleEdgeInsets               = UIEdgeInsetsMake(10, 0, 10, 15)
        leftButton?.setTitle("取消", for: UIControlState.normal)
        leftButton?.setTitleColor(kMainBlueColor(), for: UIControlState.normal)
        leftButton?.titleLabel?.font              = UIFont.systemFont(ofSize: 15.0)
        self.navigationItem.leftBarButtonItem     = UIBarButtonItem.init(customView: leftButton!)
    }
    
    // MARK: - 布局控件
    func layoutSubview() -> Void 
    {
        //cancel
        cancelButton?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view).offset(kRegisterNameMargin)
            make.top.equalTo(self.view).offset(30)
            make.height.equalTo(25)
            make.width.equalTo(35)
        })
        
        //logo
        logoImageView?.snp.makeConstraints({ (make) in
            make.height.width.equalTo(30)
            make.centerX.equalTo(self.view)
            make.centerY.equalTo(self.cancelButton!)
        })
        
        //nameLabel
        nameLabel?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view).offset(kRegisterNameMargin)
            make.right.equalTo(self.view).offset(-kRegisterNameMargin)
            make.top.equalTo(self.view).offset(80 + 64)
            make.height.equalTo(40)
        })
        
        //nameTextField
        nameTextField?.snp.makeConstraints({ (make) in
            make.top.equalTo((self.nameLabel?.snp.bottom)!).offset(20)
            make.left.equalTo(self.view).offset(kRegisterNameMargin)
            make.right.equalTo(self.view).offset(-50)
            make.height.equalTo(30)
        })
        
        //verifyImageView
        verifyImageView?.snp.makeConstraints({ (make) in
            make.left.equalTo((self.nameTextField?.snp.right)!).offset(5)
            make.right.equalTo(self.view).offset(-20)
            make.height.width.equalTo(25)
            make.centerY.equalTo(self.nameTextField!)
        })
        
        //firstLine
        firstLine?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(0)
            make.height.equalTo(0.3)
            make.top.equalTo((self.nameTextField?.snp.bottom)!).offset(10)
        })
        
        //errorHintLabel
        errorHintLabel?.snp.makeConstraints({ (make) in
            make.left.right.equalTo(self.view).offset(0)
            make.height.equalTo(40)
            make.top.equalTo((self.firstLine?.snp.bottom)!).offset(5)
        })
        
        //contentView
        contentView?.snp.makeConstraints({ (make) in
            make.left.right.equalTo(self.view).offset(0)
            make.height.equalTo(50)
            make.bottom.equalTo(self.view).offset(0)
        })
        
        //secondLine
        secondLine?.snp.makeConstraints({ (make) in
            make.left.right.equalTo(self.contentView!).offset(0)
            make.top.equalTo(self.contentView!).offset(0)
            make.height.equalTo(0.3)
        })
        
        //nextButton
        nextButton?.snp.makeConstraints({ (make) in
            make.right.equalTo(self.contentView!).offset(-20)
            make.height.equalTo(35)
            make.top.equalTo((self.secondLine?.snp.bottom)!).offset(7.5)
            make.width.equalTo(70)
        })
    }
    
    // MARK: - 绑定事件
    func setupEvent() -> Void 
    {
        //cancel
        cancelButton?.rx.tap
            .subscribe(onNext: { [unowned self] in
                self.view.endEditing(true)
                self.dismiss(animated: true, completion: { 
                    
                })})
            .disposed(by: disposeBag)
        
        //name 返回的是bool
        let nameObservable = nameTextField?.rx.text.share(replay: 1).map({($0?.count)! < 20})
        nameObservable?
            .subscribe(onNext:({valid in 
                if valid
                {
                    self.nameTextField?.textColor = kMainBlueColor()
                    self.errorHintLabel?.isHidden = true
                    if self.nameTextField?.text?.count == 0
                    {
                        self.nextButton?.setTitleColor(kMainGrayColor(), for: UIControlState.normal)
                        self.nextButton?.isEnabled     = false
                        self.verifyImageView?.isHidden = true
                    } else
                    {
                        self.nextButton?.setTitleColor(kMainWhiteColor(), for: UIControlState.normal)
                        self.nextButton?.isEnabled     = true
                        self.verifyImageView?.isHidden = false
                        self.verifyImageView?.image    = UIImage.init(named: "name_valid")
                        self.verifyImageView?.layer.borderColor = kMainGreenColor().cgColor
                    }
                    
                } else
                {
                    self.nameTextField?.textColor           = kMainRedColor()
                    self.verifyImageView?.isHidden          = false
                    self.verifyImageView?.image             = UIImage.init(named: "name_invalid")
                    self.verifyImageView?.layer.borderColor = kMainRedColor().cgColor
                    self.errorHintLabel?.isHidden           = false
                    self.nextButton?.setTitleColor(kMainGrayColor(), for: UIControlState.normal)
                    self.nextButton?.isEnabled              = false
                }}))
            .disposed(by: disposeBag)
        
        //nextButton
        nextButton?.rx.tap
            .subscribe(onNext:({[unowned self] in 
            
                self.sharedInstance.user_name = (self.nameTextField?.text)!
                
                let registerAccountVC         = MTTRegisterAccountViewController()
                self.navigationController?.pushViewController(registerAccountVC, animated: true)}))
            .disposed(by: disposeBag)
        
        //leftButton
        leftButton?.rx.tap
            .subscribe(onNext:({[unowned self] in 
            
                self.view.endEditing(true)
                
                self.dismiss(animated: true, completion: { })}))
            .disposed(by: disposeBag)
    }
    
    func addNotificationObserver() -> Void
    {
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(keyboardWillShowAction(notify:)), 
                                               name: NSNotification.Name.UIKeyboardWillShow, 
                                               object: nil)
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(keyboardWillHideAction(notify:)), 
                                               name: NSNotification.Name.UIKeyboardWillHide, 
                                               object: nil)
    }
    
    @objc func keyboardWillShowAction(notify:Notification) -> Void
    {
        let userInfo      = notify.userInfo
        let keyboardFrame = userInfo![UIKeyboardFrameEndUserInfoKey] as! CGRect
        UIView.animate(withDuration: 0.5, animations: {
            self.contentView?.y = keyboardFrame.origin.y - 50
        }) { (completed) in}
    }
    
    @objc func keyboardWillHideAction(notify:Notification) -> Void
    {
        UIView.animate(withDuration: 0.2, animations: {
            //contentView
            self.contentView?.frame = CGRect(x: 0, y: kScreenHeight - 50, width: kScreenWidth, height: 50)
        }) { (completed) in
            
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) 
    {
        self.view.endEditing(true)
    }
    
    deinit 
    {
        NotificationCenter.default.removeObserver(self)
    }

}
