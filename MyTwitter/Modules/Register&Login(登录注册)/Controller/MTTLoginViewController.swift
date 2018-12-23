//
//  MTTLoginViewController.swift
//  MyTwitter
//
//  Created by WangJunZi on 2017/9/18.
//  Copyright © 2017年 waitWalker. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa

class MTTLoginViewController: MTTViewController,MTTLoginViewModelDelegate {
    
    var cancelButton:UIButton?
    var logoImageView:UIImageView?
    var rightButton:UIButton?
    var loginLabel:UILabel?
    var accountTextField:UITextField?
    var clearAllButton:UIButton?
    
    
    var firstLineView:UIView?
    
    var passwordTextField:UITextField?
    var secondLineView:UIView?
    var showOrHiddenButton:UIButton?
    
    
    var contentView:UIView?
    var loginButton:UIButton?
    var secondLine:UIView?
    var forgetButton:UIButton?
    
    
    

    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        self.setupSubview()
        self.layoutSubview()
        self.setupEvent()
        
        print(kScreenWidth,kScreenHeight)
    }
    
    func setupSubview() -> Void
    {
        //cancelButton
        cancelButton = UIButton()
        cancelButton?.setTitle("取消", for: UIControlState.normal)
        cancelButton?.setTitleColor(kMainBlueColor(), for: UIControlState.normal)
        cancelButton?.titleLabel?.font = UIFont.systemFont(ofSize: 15.0)
        self.view.addSubview(cancelButton!)
        
        //logo
        logoImageView = UIImageView()
        logoImageView?.image = UIImage.init(named: "twitter_logo")
        logoImageView?.isUserInteractionEnabled = true
        self.view.addSubview(logoImageView!)
        
        //rightButton
        rightButton = UIButton()
        rightButton?.setImage(UIImage.init(named: "more"), for: UIControlState.normal)
        self.view.addSubview(rightButton!)
        
        //loginLabel
        loginLabel = UILabel()
        loginLabel?.text = "登录 Twitter"
        loginLabel?.textColor = UIColor.black
        loginLabel?.font = UIFont.boldSystemFont(ofSize: 20)
        loginLabel?.textAlignment = NSTextAlignment.left
        self.view.addSubview(loginLabel!)
        
        //accountTextField
        accountTextField = UITextField()
        accountTextField?.placeholder = "手机号码,邮箱或者用户名"
        accountTextField?.textAlignment = NSTextAlignment.left
        accountTextField?.textColor = kMainBlueColor()
        accountTextField?.font = UIFont.systemFont(ofSize: 18)
        self.view.addSubview(accountTextField!)
        
        //clearAllButton
        clearAllButton = UIButton()
        clearAllButton?.setImage(UIImage.init(named: "delete_all"), for: UIControlState.normal)
        self.view.addSubview(clearAllButton!)
        
        //firstLineView
        firstLineView = UIView()
        firstLineView?.backgroundColor = kMainGrayColor()
        self.view.addSubview(firstLineView!)
        
        //passwordTextField
        passwordTextField = UITextField()
        passwordTextField?.placeholder = "密码"
        passwordTextField?.isSecureTextEntry = true
        passwordTextField?.textAlignment = NSTextAlignment.left
        passwordTextField?.textColor = kMainBlueColor()
        passwordTextField?.font = UIFont.systemFont(ofSize: 18)
        self.view.addSubview(passwordTextField!)
        
        //secondLineView
        secondLineView = UIView()
        secondLineView?.backgroundColor = kMainGrayColor()
        self.view.addSubview(secondLineView!)
        
        //showOrHiddenButton
        showOrHiddenButton = UIButton()
        showOrHiddenButton?.setTitle("显示密码", for: UIControlState.normal)
        showOrHiddenButton?.setTitleColor(kMainBlueColor(), for: UIControlState.normal)
        showOrHiddenButton?.isHidden = true
        showOrHiddenButton?.titleLabel?.font = UIFont.systemFont(ofSize: 15)
        self.view.addSubview(showOrHiddenButton!)
        
        //contentView
        contentView = UIView()
        self.view.addSubview(contentView!)
        
        //secondLine
        secondLine = UIView()
        secondLine?.backgroundColor = kMainGrayColor()
        contentView?.addSubview(secondLine!)
        
        //forgetButton
        forgetButton = UIButton()
        forgetButton?.setTitle("忘记密码?", for: UIControlState.normal)
        forgetButton?.setTitleColor(kMainBlueColor(), for: UIControlState.normal)
        forgetButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        contentView?.addSubview(forgetButton!)
        
        //loginButton
        loginButton = UIButton()
        loginButton?.setTitle("登录", for: UIControlState.normal)
        loginButton?.setTitleColor(kMainWhiteColor(), for: UIControlState.normal)
        loginButton?.titleLabel?.font = UIFont.systemFont(ofSize: 16)
        loginButton?.backgroundColor = kMainBlueColor()
        loginButton?.layer.cornerRadius = 17.5
        loginButton?.clipsToBounds = true
        contentView?.addSubview(loginButton!)
        
    }
    
    func layoutSubview() -> Void
    {
        //cancel
        cancelButton?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view).offset(20)
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
        
        //rightButton
        rightButton?.snp.makeConstraints({ (make) in
            make.width.equalTo(25)
            make.height.equalTo(15)
            make.right.equalTo(self.view.snp.right).offset(-20)
            make.centerY.equalTo(logoImageView!)
        })
        
        //loginLabel
        loginLabel?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view).offset(20)
            make.height.equalTo(40)
            make.width.equalTo(150)
            make.top.equalTo(self.view).offset(80)
        })
        
        //accountTextField
        accountTextField?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view).offset(20)
            make.top.equalTo((self.loginLabel?.snp.bottom)!).offset(20)
            make.right.equalTo(self.view.snp.right).offset(-50)
            make.height.equalTo(40)
        })
        
        //clearAllButton
        clearAllButton?.snp.makeConstraints({ (make) in
            make.width.height.equalTo(15)
            make.centerY.equalTo(self.accountTextField!)
            make.right.equalTo(self.view.snp.right).offset(-20)
        })
        
        //firstLineView
        firstLineView?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(0)
            make.height.equalTo(0.3)
            make.top.equalTo((self.accountTextField?.snp.bottom)!).offset(1)
        })
        
        //passwordTextField
        passwordTextField?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view).offset(20)
            make.top.equalTo((self.firstLineView?.snp.bottom)!).offset(1)
            make.right.equalTo(self.view.snp.right).offset(-50)
            make.height.equalTo(40)
        })
        
        //secondLineView
        secondLineView?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view).offset(20)
            make.right.equalTo(self.view).offset(0)
            make.height.equalTo(0.3)
            make.top.equalTo((self.passwordTextField?.snp.bottom)!).offset(1)
        })
        
        //showOrHiddenButton
        showOrHiddenButton?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.view).offset(20)
            make.width.equalTo(70)
            make.top.equalTo((self.secondLineView?.snp.bottom)!).offset(10)
            make.height.equalTo(20)
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
        
        //forgetButton
        forgetButton?.snp.makeConstraints({ (make) in
            make.left.equalTo(self.contentView!).offset(20)
            make.width.equalTo(80)
            make.height.equalTo(35)
            make.top.equalTo((self.secondLine?.snp.bottom)!).offset(7.5)
        })
        
        //loginButton
        loginButton?.snp.makeConstraints({ (make) in
            make.right.equalTo(self.contentView!).offset(-20)
            make.height.equalTo(35)
            make.top.equalTo((self.secondLine?.snp.bottom)!).offset(7.5)
            make.width.equalTo(70)
        })

    }
    
    func setupEvent() -> Void
    {
        //accountTextField
        let accountTextFieldObserable = accountTextField?.rx.text.map({($0?.count)! > 0})
        
        accountTextFieldObserable?.subscribe(onNext:{valid in
            
            self.clearAllButton?.isHidden = valid ? false : true
            
        }).disposed(by: disposeBag)
        
        //passwordTextField
        let passwordTextFieldObserable = passwordTextField?.rx.text.map({($0?.count)! > 0})
        passwordTextFieldObserable?.subscribe(onNext:{valid in
            self.showOrHiddenButton?.isHidden = valid ? false : true
        }).disposed(by: disposeBag)
        
        //showOrHiddenButton
        showOrHiddenButton?.rx.tap.subscribe(onNext:{ 
            self.showOrHiddenButton?.isSelected = !(self.showOrHiddenButton?.isSelected)!
            
            if (self.showOrHiddenButton?.isSelected)!
            {
                self.showOrHiddenButton?.setTitle("显示密码", for: UIControlState.normal)
                self.passwordTextField?.isSecureTextEntry = true
            } else
            {
                self.showOrHiddenButton?.setTitle("隐藏密码", for: UIControlState.normal)
                self.passwordTextField?.isSecureTextEntry = false
            }
            
        }).disposed(by: disposeBag)
        
        //rightButton
        rightButton?.rx.tap.subscribe(onNext:{
            
            let aboutVC = MTTAboutTwitterViewController()
            let nav = MTTNavigationController.init(rootViewController: aboutVC)
            self.present(nav, animated: true, completion: {
                
            })
            
        }).disposed(by: disposeBag)
        
        
        //clearAllButton
        clearAllButton?.rx.tap.subscribe(onNext:{
            self.accountTextField?.text = ""
        }).disposed(by: disposeBag)
        
        //cancelButton
        (cancelButton?.rx.tap)?.subscribe(onNext:{ [unowned self] in
            self.dismiss(animated: true, completion: {
                
            })
        }).disposed(by: disposeBag)
        
        //loginButton
//        Observable.combineLatest(accountTextFieldObserable, passwordTextFieldObserable) { $0 && $1 }
//            .shareReplay(1)
        loginButton?.rx.tap.subscribe(onNext:{
            
            if (self.passwordTextField?.text?.count)! > Int(0) && (self.accountTextField?.text?.count)! > Int(0)
            {
                let para = ["email":self.accountTextField?.text,
                            "password":self.passwordTextField?.text]
                
                let loginViewModel = MTTLoginViewModel()
                loginViewModel.delegate = self
                loginViewModel.getLoginStatus(parameter: para as NSDictionary)
                
            }
            
        }).disposed(by: disposeBag)
    }

    // MARK: - loginViewModelDelegate
    func successCallBack(data: NSDictionary) 
    {
        print(data)
        let responseObject = data.object(forKey: "responseObject") as! NSDictionary
        let result:String = responseObject.object(forKey: "result") as! String
        
        if result == "1" 
        {
            let tabBarVC = MTTTabBarController()
            let appDelegate = UIApplication.shared.delegate! as UIApplicationDelegate
            appDelegate.window??.rootViewController = tabBarVC
            appDelegate.window??.makeKeyAndVisible()
        }
    }
    
    func failureCallBack(error: NSError) 
    {
        
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
        }) { (completed) in
            
        }
    }
    
    @objc func keyboardWillHideAction(notify:Notification) -> Void
    {
        UIView.animate(withDuration: 0.2, animations: {
            //contentView
            self.contentView?.frame = CGRect(x: 0, y: kScreenHeight - 50, width: kScreenWidth, height: 50)
        }) { (completed) in
            
        }
    }
    

    
}
