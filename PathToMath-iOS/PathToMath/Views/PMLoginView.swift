//
//  PMLoginView.swift
//  PathToMath
//
//  Created by Kevin Yufei Chen on 9/16/15.
//  Copyright © 2015 Kevin Yufei Chen. All rights reserved.
//

import UIKit

protocol PMLoginViewDataSource: NSObjectProtocol {
    
    func savedUsernameInLoginView(loginView: PMLoginView) -> String?
    
    func savedPasswordInLoginView(loginView: PMLoginView) -> String?
}

protocol PMLoginViewDelegate: NSObjectProtocol {
    
    func loginView(loginView: PMLoginView, didTapLoginButtonWithUsername username: String, password: String)
    
    func loginView(loginView: PMLoginView, didTapForgotPasswordButtonWithUsername username: String)
    
    func didTapGuestButtonInLoginView(loginView: PMLoginView)
}

class PMLoginView: UIView, UITextFieldDelegate {
    
    private let kTextFieldHeight = CGFloat(50)
    private let kTextFieldHorizontaladding = CGFloat(40)
    private let kTextFieldVerticalPadding = CGFloat(10)
    private let kTextFieldIconSize = CGFloat(30)
    private let kTextFieldIconPadding = CGFloat(10)
    
    weak var dataSource: PMLoginViewDataSource?
    weak var delegate: PMLoginViewDelegate?
    
    private var usernameTextField: UITextField!
    private var passwordTextField: UITextField!
    private var forgotPasswordButton: UIButton!
    private var loginButton: UIButton!
    private var loginButtonActivityIndicatorView: UIActivityIndicatorView?
    private var guestButton: UIButton!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.usernameTextField = UITextField(frame: .zero)
        self.passwordTextField = UITextField(frame: .zero)
        self.forgotPasswordButton = UIButton(frame: .zero)
        self.loginButton = UIButton(frame: .zero)
        self.loginButtonActivityIndicatorView = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        self.guestButton = UIButton(frame: .zero)
        
        self.backgroundColor = .clearColor()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func drawRect(rect: CGRect) {
        super.drawRect(rect)
        
        self.usernameTextField.frame = CGRect(x: kTextFieldHorizontaladding, y: kTextFieldVerticalPadding, width: rect.width - 2 * kTextFieldHorizontaladding, height: kTextFieldHeight)
        self.usernameTextField.delegate = self
        self.usernameTextField.autocorrectionType = .No
        self.usernameTextField.autocapitalizationType = .None
        self.usernameTextField.returnKeyType = .Next
        self.usernameTextField.layer.cornerRadius = 5
        self.usernameTextField.layer.borderWidth = 1
        self.usernameTextField.layer.borderColor = UIColor.whiteColor().CGColor
        self.usernameTextField.placeholder = "username"
        self.usernameTextField.leftView = UIImageView(image: UIImage(named: "LoginViewUsername"))
        self.usernameTextField.leftView?.frame = CGRect(x: 0, y: 0, width: kTextFieldIconSize + 2 * kTextFieldIconPadding, height: kTextFieldIconSize)
        self.usernameTextField.leftView?.contentMode = .ScaleAspectFit
        self.usernameTextField.leftViewMode = .Always
        self.usernameTextField.text = self.dataSource?.savedUsernameInLoginView(self)
        self.addSubview(self.usernameTextField)
        
        self.passwordTextField.frame = CGRect(x: kTextFieldHorizontaladding, y: CGRectGetMaxY(self.usernameTextField.frame) + kTextFieldVerticalPadding, width: rect.width - 2 * kTextFieldHorizontaladding, height: kTextFieldHeight)
        self.passwordTextField.delegate = self
        self.passwordTextField.secureTextEntry = true
        self.passwordTextField.autocorrectionType = .No
        self.passwordTextField.autocapitalizationType = .None
        self.passwordTextField.returnKeyType = .Go
        self.passwordTextField.layer.cornerRadius = 5
        self.passwordTextField.layer.borderWidth = 1
        self.passwordTextField.layer.borderColor = UIColor.whiteColor().CGColor
        self.passwordTextField.placeholder = "password"
        self.passwordTextField.leftView = UIImageView(image: UIImage(named: "LoginViewPassword"))
        self.passwordTextField.leftView?.frame = CGRect(x: 0, y: 0, width: kTextFieldIconSize + 2 * kTextFieldIconPadding, height: kTextFieldIconSize)
        self.passwordTextField.leftView?.contentMode = .ScaleAspectFit
        self.passwordTextField.leftViewMode = .Always
        self.passwordTextField.text = self.dataSource?.savedPasswordInLoginView(self)
        self.addSubview(self.passwordTextField)
        
        self.forgotPasswordButton.frame = CGRect(x: kTextFieldHorizontaladding, y: CGRectGetMaxY(self.passwordTextField.frame) + kTextFieldVerticalPadding, width: rect.width - 2 * kTextFieldHorizontaladding, height: 20)
        self.forgotPasswordButton.backgroundColor = .clearColor()
        self.forgotPasswordButton.setTitle("forgot your password?", forState: .Normal)
        self.forgotPasswordButton.titleLabel?.font = self.forgotPasswordButton.titleLabel?.font.fontWithSize(UIFont.smallSystemFontSize())
        self.forgotPasswordButton.contentHorizontalAlignment = .Right
        self.forgotPasswordButton.addTarget(self, action: "didTapForgotPasswordButton:", forControlEvents: .TouchUpInside)
        self.addSubview(self.forgotPasswordButton)

        self.loginButton.frame = CGRect(x: kTextFieldHorizontaladding, y: CGRectGetMaxY(self.forgotPasswordButton.frame) + kTextFieldVerticalPadding, width: rect.width - 2 * kTextFieldHorizontaladding, height: kTextFieldHeight)
        self.loginButton.setTitle("login", forState: .Normal)
        self.loginButton.layer.cornerRadius = 5
        self.loginButton.layer.masksToBounds = true
        self.loginButton.setBackgroundImage(UIImage(named: "ButtonBackgroundGreen"), forState: .Normal)
        self.loginButton.contentVerticalAlignment = .Center
        self.loginButton.addTarget(self, action: "didTapLoginButton:", forControlEvents: .TouchUpInside)
        self.addSubview(self.loginButton)
        
        self.guestButton.frame = CGRect(x: 0, y: CGRectGetMaxY(self.loginButton.frame) + kTextFieldVerticalPadding, width: 80, height: 30)
        self.guestButton.center = CGPoint(x: self.loginButton.center.x, y: self.guestButton.center.y)
        self.guestButton.setTitle("I'm a guest", forState: .Normal)
        self.guestButton.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        self.guestButton.titleLabel?.font = self.guestButton.titleLabel?.font.fontWithSize(UIFont.smallSystemFontSize())
        self.guestButton.addTarget(self, action: "didTapGuestButton:", forControlEvents: .TouchUpInside)
        self.addSubview(self.guestButton)
    }
    
    func startLoginActivityIndicatorAnimation() {
        self.loginButton.setTitle("", forState: .Normal)
        self.loginButtonActivityIndicatorView?.frame = self.loginButton.bounds
        self.loginButton.addSubview(loginButtonActivityIndicatorView!)
        self.loginButton.userInteractionEnabled = false
        self.loginButtonActivityIndicatorView?.startAnimating()
    }
    
    func stopLoginActivityIndicatorAnimation() {
        self.loginButton.setTitle("login", forState: .Normal)
        self.loginButtonActivityIndicatorView?.stopAnimating()
        self.loginButtonActivityIndicatorView?.removeFromSuperview()
        self.loginButton.userInteractionEnabled = true
    }
    
    func didTapForgotPasswordButton(button: UIButton) {
        self.delegate?.loginView(self, didTapForgotPasswordButtonWithUsername: self.usernameTextField.text!)
    }
    
    func didTapLoginButton(button: UIButton) {
        self.delegate?.loginView(self, didTapLoginButtonWithUsername: self.usernameTextField.text!, password: self.passwordTextField.text!)
    }
    
    func didTapGuestButton(button: UIButton) {
        self.delegate?.didTapGuestButtonInLoginView(self)
    }
    
    
    // MARK: UITextFieldDelegate
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        if (textField == self.usernameTextField) {
            self.passwordTextField.becomeFirstResponder()
        }
        if (textField == self.passwordTextField) {
            self.endEditing(true)
            self.delegate?.loginView(self, didTapLoginButtonWithUsername: self.usernameTextField.text!, password: self.passwordTextField.text!)
        }
        return true
    }
    
}
