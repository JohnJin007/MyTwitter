//
//  MTTUserDetailViewController.swift
//  MyTwitter
//
//  Created by WangJunZi on 2017/11/7.
//  Copyright © 2017年 waitWalker. All rights reserved.
//

import UIKit
import RxCocoa
import RxSwift
import RxGesture

class MTTUserDetailViewController: MTTViewController
{
    var disposeBag = DisposeBag()
    
    let kHeaderBackgroundImageViewHeight:CGFloat = 130
    let kHeaderContainerViewHeight:CGFloat = 220
    let kNavigationBarHeight:CGFloat = 64
    
    
    var headerBackgroundImageView:UIImageView!
    
    var userDetailTableView:UITableView!
    
    var isFirstTime:Bool!
    
    var backButton:UIButton!
    
    var rightButton:UIButton!
    
    var headerContainerView:UIView!
    var avatarContainerView:UIView!
    var avatarImageView:UIImageView!
    
    var bottomContainerView:MTTUserDetailBottomContainerView!
    
    let reusedUserDetailCellID:String = "reusedUserDetailCellID"
    
    
    // 简介相关视图 
    var followingButton:UIButton!
    var noticeButton:UIButton!
    var settingButton:UIButton!
    
    
    
    var userDetailTopIntroductionView:MTTUserDetailTopIntroductionView!
    
    
    
    override func viewWillAppear(_ animated: Bool) 
    {
        super.viewWillAppear(animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) 
    {
        super.viewWillDisappear(animated)
        self.navigationController?.navigationBar.setBackgroundImage(nil, for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = nil
    }
    
    
    override func viewDidLoad()
    {
        super.viewDidLoad()
        
        setupSubview()
        
        layoutSubview()
        
        setupEvent()
        
        setupNotification()
    }
    
    func setupSubview() -> Void
    {
        setupNavigationBar()

        isFirstTime                                        = true

        userDetailTableView                                = UITableView()
        userDetailTableView.showsVerticalScrollIndicator   = false
        userDetailTableView.delegate                       = self
        userDetailTableView.dataSource                     = self
        userDetailTableView.frame                          = CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight)
        userDetailTableView.register(MTTUserDetailContainerCell.self, forCellReuseIdentifier: reusedUserDetailCellID)
        userDetailTableView.separatorStyle                 = UITableViewCellSeparatorStyle.none
        userDetailTableView.contentInset                   = UIEdgeInsetsMake(kHeaderBackgroundImageViewHeight + kHeaderContainerViewHeight, 0, 0, 0)
        self.automaticallyAdjustsScrollViewInsets          = false
        self.view.addSubview(userDetailTableView)

        headerBackgroundImageView                          = UIImageView()
        headerBackgroundImageView.frame                    = CGRect(x: 0, y: 0, width: kScreenWidth, height: kHeaderBackgroundImageViewHeight)
        headerBackgroundImageView.image                    = UIImage.imageNamed(name: "user_detail_header_background")
        headerBackgroundImageView.isUserInteractionEnabled = true
        self.view.addSubview(headerBackgroundImageView)

        headerContainerView                                = UIView()
        headerContainerView.backgroundColor                = UIColor.white
        headerContainerView.frame                          = CGRect(x: 0, y: kHeaderBackgroundImageViewHeight, width: kScreenWidth, height: kHeaderContainerViewHeight)
        self.view.addSubview(headerContainerView)

        avatarContainerView                                = UIView()
        avatarContainerView.backgroundColor                = UIColor.white
        avatarContainerView.layer.cornerRadius             = 40
        avatarContainerView.frame                          = CGRect(x: 30, y: -30, width: 80, height: 80)
        headerContainerView.addSubview(avatarContainerView)

        avatarImageView                                    = UIImageView()
        avatarImageView.isUserInteractionEnabled           = true
        avatarImageView.backgroundColor                    = kMainRandomColor()
        avatarImageView.frame                              = CGRect(x: 0, y: 0, width: 70, height: 70)
        avatarImageView.center                             = avatarContainerView.center
        avatarImageView.layer.cornerRadius                 = 35
        avatarImageView.clipsToBounds                      = true
        headerContainerView.addSubview(avatarImageView)
        
        userDetailTopIntroductionView = MTTUserDetailTopIntroductionView(frame: CGRect(x: 0, y: 55, width: kScreenWidth, height: 165))
        headerContainerView.addSubview(userDetailTopIntroductionView)
        
        followingButton = UIButton()
        followingButton.backgroundColor = kMainBlueColor()
        followingButton.titleLabel?.font = UIFont.systemFont(ofSize: 14)
        followingButton.setTitleColor(UIColor.white, for: UIControlState.normal)
        followingButton.setTitleColor(kMainGrayColor(), for: UIControlState.highlighted)
        followingButton.setTitle("正在关注", for: UIControlState.normal)
        followingButton.layer.cornerRadius = 15
        followingButton.clipsToBounds = true
        headerContainerView.addSubview(followingButton)
        
        noticeButton = UIButton()
        noticeButton.layer.borderColor = kMainBlueColor().cgColor
        noticeButton.layer.borderWidth = 1.0
        noticeButton.setImage(UIImage.imageNamed(name: "user_detail_notice"), for: UIControlState.normal)
        noticeButton.layer.cornerRadius = 15
        noticeButton.clipsToBounds = true
        headerContainerView.addSubview(noticeButton)
        
        settingButton = UIButton()
        settingButton.layer.borderColor = kMainBlueColor().cgColor
        settingButton.layer.borderWidth = 1.0
        settingButton.setImage(UIImage.imageNamed(name: "user_detail_setting"), for: UIControlState.normal)
        settingButton.layer.cornerRadius = 15
        settingButton.clipsToBounds = true
        headerContainerView.addSubview(settingButton)
        
    }
    
    private func setupNavigationBar() -> Void 
    {
        backButton                             = UIButton()
        backButton.setImage(UIImage.imageNamed(name: "back_placeholder"), for: UIControlState.normal)
        backButton.imageEdgeInsets             = UIEdgeInsetsMake(3, 3, 3, 3)
        backButton.frame                       = CGRect(x: 0, y: 0, width: 32, height: 32)
        self.navigationItem.leftBarButtonItem  = UIBarButtonItem(customView: backButton)

        rightButton                            = UIButton()
        rightButton.setImage(UIImage.imageNamed(name: "twitter_push"), for: UIControlState.normal)
        rightButton.imageEdgeInsets            = UIEdgeInsetsMake(3, 3, 3, 3)
        rightButton.frame                      = CGRect(x: 0, y: 0, width: 32, height: 32)
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(customView: rightButton)

        self.navigationController?.navigationBar.setBackgroundImage(UIImage(), for: UIBarMetrics.default)
        self.navigationController?.navigationBar.shadowImage = UIImage()
        
    }
    
    
    func layoutSubview() -> Void
    {
        followingButton.snp.makeConstraints { make in
            make.top.equalTo(headerContainerView).offset(5)
            make.right.equalTo(headerContainerView).offset(-15)
            make.height.equalTo(30)
            make.width.equalTo(80)
        }
        
        noticeButton.snp.makeConstraints { make in
            make.top.height.equalTo(followingButton)
            make.right.equalTo(followingButton.snp.left).offset(-10)
            make.width.equalTo(30)
        }
        
        settingButton.snp.makeConstraints { make in
            make.top.height.width.equalTo(followingButton)
            make.right.equalTo(noticeButton.snp.left).offset(-10)
        }
    }
    
    func setupEvent() -> Void
    {
        backButton.rx.tap
            .subscribe(onNext:{[unowned self] in
                self.navigationController?.popViewController(animated: true)})
            .disposed(by: disposeBag)
    }
    
    
    
    func setupNotification() -> Void
    {
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(handleOuterTableViewCanScrollNotification), 
                                               name: NSNotification.Name(rawValue: kUserDetailOuterTableViewCanScrollNotification), 
                                               object: nil)
    }
    
    @objc func handleOuterTableViewCanScrollNotification() -> Void 
    {
        userDetailTableView.isScrollEnabled = true
    }
    
    deinit 
    {
        NotificationCenter.default.removeObserver(self)
    }
    
}

extension MTTUserDetailViewController :UITableViewDelegate, UITableViewDataSource ,UIScrollViewDelegate
{
    func numberOfSections(in tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell
    {
        var cell = tableView.dequeueReusableCell(withIdentifier: reusedUserDetailCellID) as? MTTUserDetailContainerCell
        if cell == nil 
        {
            cell = MTTUserDetailContainerCell(style: UITableViewCellStyle.default, reuseIdentifier: reusedUserDetailCellID)
        }
        
        cell?.textLabel?.text = "第\(indexPath.item)行"
        bottomContainerView = MTTUserDetailBottomContainerView(frame: CGRect(x: 0, y: 0, width: kScreenWidth, height: kScreenHeight))
        bottomContainerView.tabConfig = [1,2,3,4]
        cell?.contentView.addSubview(bottomContainerView)
        return cell!
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat 
    {
        return kScreenHeight
    }
    
    
    // MARK: - scrollViewDelegate
    func scrollViewDidScroll(_ scrollView: UIScrollView)
    {
        
        if isFirstTime 
        {
            isFirstTime = false
        } else
        {
            let offSetY = scrollView.contentOffset.y + kHeaderContainerViewHeight
            
            print("偏移量:\(offSetY)")
            
            print("真实偏移量:\(scrollView.contentOffset.y)")
            
            if scrollView.contentOffset.y >= -64.0
            {
                self.userDetailTableView.isScrollEnabled = false
                self.userDetailTableView.contentOffset = CGPoint(x: 0, y: -64)
                
                NotificationCenter.default.post(name: NSNotification.Name(rawValue: kUserDetailInnerTableViewCanScrollNotification), object: nil)
            }
            
            // 设置背景头像下面的头容器 
            self.headerBackgroundImageView.y = -offSetY - kHeaderBackgroundImageViewHeight
            
            if -offSetY >= kHeaderBackgroundImageViewHeight
            {
                self.headerBackgroundImageView.height = -offSetY
                self.headerBackgroundImageView.y = 0
            }
            self.headerContainerView.y = -offSetY
            
            let alpha = (offSetY + kHeaderBackgroundImageViewHeight) / (kHeaderBackgroundImageViewHeight - kNavigationBarHeight)
            
            print("透明度:\(alpha)")
            
            let scale = (150 - kNavigationBarHeight) / (offSetY + 300 - kNavigationBarHeight)
            print("比例:\(scale)")
            
            let finalScale = 1 - scale
            
            let x = 30 * (1 + finalScale)
            let y = -30 * (1 - alpha)
            let widthHeight = 80 * (1 - finalScale)
            let avatarImageViewWidthHeight = 70 * (1 - finalScale)
            
            if abs(scale) >= 1.0
            {
                avatarContainerView.layer.cornerRadius = 40        
                avatarContainerView.frame = CGRect(x: 30, y: -30, width: 80, height: 80)
                
                avatarImageView.frame = CGRect(x: 0, y: 0, width: 70, height: 70)        
                avatarImageView.center = avatarContainerView.center
                avatarImageView.layer.cornerRadius = 35        
                avatarImageView.clipsToBounds = true
            } else if scale < 1.0 && scale > 0.5
            {
                self.avatarContainerView.cornerRadius = widthHeight * 0.5
                self.avatarContainerView.clipsToBounds = true
                self.avatarContainerView.frame = CGRect(x: x, y: y, width: widthHeight, height: widthHeight)
                
                self.avatarImageView.cornerRadius = avatarImageViewWidthHeight * 0.5
                self.avatarImageView.clipsToBounds = true
                self.avatarImageView.frame = CGRect(x: 0, y: 0, width: avatarImageViewWidthHeight, height: avatarImageViewWidthHeight)
                self.avatarImageView.center = self.avatarContainerView.center
                
            } else
            {
                avatarContainerView.layer.cornerRadius = 20        
                avatarContainerView.frame = CGRect(x: 45, y: 0, width: 40, height: 40)
                
                avatarImageView.frame = CGRect(x: 0, y: 0, width: 35, height: 35)        
                avatarImageView.center = avatarContainerView.center
                avatarImageView.layer.cornerRadius = 17.5        
                avatarImageView.clipsToBounds = true
            }
            
            if -offSetY <= kNavigationBarHeight
            {
                self.navigationController?.navigationBar.setBackgroundImage(UIImage.imageNamed(name: "user_detail_header_background"), for: UIBarMetrics.default)
            } else
            {
                self.navigationController?.navigationBar.setBackgroundImage(UIImage.imageWithColor(color: UIColor(white: 1, alpha: alpha)), for: UIBarMetrics.default)
            }
            
        }
        
    }
    
    
}


