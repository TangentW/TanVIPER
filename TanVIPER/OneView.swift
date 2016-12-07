//
//  OneView.swift
//  TanVIPER
//
//  Created by Tan on 2016/12/6.
//  Copyright © 2016年 Tangent. All rights reserved.
//

import UIKit
import SnapKit

class OneView: View {

    //  MARK: - Life Cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.white
        
        self.buttonListener = OneViewButtonListener(jump: { 
            self.interator.refresh(request: OneRequest.jump)
        }, login: {
            self.interator.refresh(request: OneRequest.login(userName: self.userNameInput.text!, password: self.passwordInput.text!))
            self.loginButton.isEnabled = false
        })
        
        self.view.addSubview(self.jumpButton)
        self.view.addSubview(self.loginButton)
        self.view.addSubview(self.userNameInput)
        self.view.addSubview(self.passwordInput)
        
        self.layoutViews()
    }

    //  Override
    override func display(viewModel: ViewModel) {
        self.loginButton.isEnabled = true
        let alertMessage = (viewModel as! OneViewModel).alertMessage
        self.alertController.message = alertMessage
        self.present(alertController, animated: true, completion: nil)
    }
    
    override func show(router: Router, userInfo: Any?) {
        
    }
    
    //  MARK: - Pirvate Function
    private func layoutViews() {
        let viewHeight: CGFloat = 45
        let viewMargin: CGFloat = 30
        
        self.jumpButton.snp.makeConstraints { [unowned self] maker in
            maker.height.equalTo(viewHeight)
            maker.left.right.equalTo(self.view).inset(UIEdgeInsets(top: 0, left: viewMargin * 0.5, bottom: 0, right: viewMargin))
            maker.bottom.equalTo(self.view.snp.centerY).offset(-viewMargin)
        }
        
        self.loginButton.snp.makeConstraints { [unowned self] maker in
            maker.height.left.right.equalTo(self.jumpButton)
            maker.top.equalTo(self.view.snp.centerY).offset(viewMargin * 0.5)
        }
        
        self.userNameInput.snp.makeConstraints { [unowned self] maker in
            maker.height.left.right.equalTo(self.jumpButton)
        }
        
        self.passwordInput.snp.makeConstraints { [unowned self] maker in
            maker.height.left.right.equalTo(self.jumpButton)
            maker.top.equalTo(self.userNameInput.snp.bottom).offset(viewMargin)
            maker.bottom.equalTo(self.jumpButton.snp.top).offset(-viewMargin)
        }
    }
    
    private func initButton(_ button: UIButton, title: String, onClick: Selector) -> UIButton {
        button.setTitle(title, for: .normal)
        button.backgroundColor = UIColor.orange
        button.layer.masksToBounds = true
        button.layer.cornerRadius = 8
        button.setTitleColor(UIColor.white, for: .normal)
        button.setTitleColor(UIColor.gray, for: .highlighted)
        button.addTarget(self.buttonListener, action: onClick, for: .touchUpInside)
        return button
    }
    
    private func initTextField(_ textField: UITextField, placeHolder: String) -> UITextField {
        textField.backgroundColor = UIColor.green
        textField.textColor = UIColor.darkGray
        textField.layer.masksToBounds = true
        textField.layer.cornerRadius = 8
        textField.placeholder = placeHolder
        return textField
    }
    
    //  MARK: - Lazy
    private lazy var jumpButton: UIButton = {
        return self.initButton($0, title: "跳转", onClick: #selector(OneViewButtonListener.onJumpButtonClick))
    }(UIButton())
    
    private lazy var loginButton: UIButton = {
        return self.initButton($0, title: "登录", onClick: #selector(OneViewButtonListener.onLoginButtonClick))
    }(UIButton())
    
    private lazy var userNameInput: UITextField = {
        return self.initTextField($0, placeHolder: "用户名")
    }(UITextField())
    
    private lazy var passwordInput: UITextField = {
        return self.initTextField($0, placeHolder: "密码")
    }(UITextField())
    
    private lazy var alertController: UIAlertController = {
        let action = UIAlertAction(title: "确认", style: .default, handler: nil)
        $0.addAction(action)
        return $0
    }(UIAlertController(title: "登录提示", message: nil, preferredStyle: .alert))
    
    //  MARK: - Button Listener
    private var buttonListener: OneViewButtonListener?
    
    //  MARK: - Event
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
}

fileprivate class OneViewButtonListener {
    
    let jumpButtonClickCallback: () -> ()
    let loginButtonClickCallback: () -> ()
    
    init(jump: @escaping () -> (), login: @escaping () -> ()) {
        self.jumpButtonClickCallback = jump
        self.loginButtonClickCallback = login
    }
    
    @objc func onJumpButtonClick() {
        self.jumpButtonClickCallback()
    }
    
    @objc func onLoginButtonClick() {
        self.loginButtonClickCallback()
    }
}


