//
//  LoginViewController.swift
//  Chat App
//
//  Created by Ikenna on 9/7/23.
//

import UIKit
import FirebaseAuth
import JGProgressHUD

final class LoginViewController: UIViewController {
    
    private let spinner = JGProgressHUD(style: .dark)
    
    private let scrollView: UIScrollView =
    {
        let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    
    private let imageView: UIImageView =
    {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "logo")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let emailField: UITextField =
    {
        let field = UITextField()
//        field.text = "ikenna@gmail.com"
        field.textColor = .black
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .done
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(
            string: "Email Address",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField =
    {
        let field = UITextField()
//        field.text = "123456"
        field.textColor = .black
        field.autocapitalizationType = .none
        field.autocorrectionType = .no
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.attributedPlaceholder = NSAttributedString(
            string: "Password",
            attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 5, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton =
    {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.layer.cornerRadius = 12
        button.setTitleColor(.white, for: .normal)
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()

    
    private var loginObserver: NSObjectProtocol?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        loginObserver = NotificationCenter.default.addObserver(forName: .didLogInNotification, object: nil, queue: .main, using: {[weak self] _ in
            guard let strongSelf = self else {return}
            
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
        
        if #available(iOS 15, *) {
            UINavigationBar.appearance().scrollEdgeAppearance = UINavigationBarAppearance()
        }
        if #available(iOS 15, *) {
            UITabBar.appearance().scrollEdgeAppearance = UITabBarAppearance()
        }
        title = "Log In"
        view.backgroundColor = UIColor(named: "blue")
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        
        loginButton.addTarget(self,
                              action: #selector(loginButtonTapped ),
                              for: .touchUpInside)
        
        emailField.delegate = self
        passwordField.delegate = self
        
        // Add subviews
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width - size) / 2,
                                 y: 20,
                                 width: size,
                                 height: size)
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        passwordField.frame = CGRect(x: 30,
                                  y: emailField.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
        loginButton.frame = CGRect(x: 30,
                                  y: passwordField.bottom + 10,
                                  width: scrollView.width - 60,
                                  height: 52)
    }
    
    @objc private func loginButtonTapped() {
        
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        
        guard let email = emailField.text, let password = passwordField.text,
              !email.isEmpty, !password.isEmpty, password.count >= 6
        else
        {
            alertUserLoginError()
            return
        }
        
        spinner.show(in: view)
        
        // Firebase Login
        
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] authResult, error in
            guard let strongSelf = self else {return}
            
            DispatchQueue.main.async {
                strongSelf.spinner.dismiss()
            }
            
            guard let result = authResult, error == nil else
            {
                print("Failed to log in user with email: \(email)")
                return
            }
            
            let user = result.user
            
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: {result in
                switch result
                {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                    let firstName = userData["first_name"] as? String,
                    let lastName = userData["last_name"] as? String
                    else {return}
                    UserDefaults.standard.set("\(firstName) \(lastName)", forKey: "name")
                    
                case .failure(let error):
                    print("Failed to read data with error \(error)")
                }
            })
            
            UserDefaults.standard.set(email, forKey: "email")
            
            print("Logged In User: \(user)")
            strongSelf.navigationController?.dismiss(animated: true, completion: nil)
        })
    }
    
    func alertUserLoginError()
    {
        let alert = UIAlertController(title: "Whoops!",
                                      message: "Please enter all information to log in.",
                                      preferredStyle: .alert)
        present(alert, animated: true)
        
        alert.addAction(UIAlertAction(title:  "Dismiss",
                                      style: .cancel,
                                      handler: nil))
    }
    
    @objc private func didTapRegister()
    {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
}

extension LoginViewController: UITextFieldDelegate
{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField
        {
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField
        {
            loginButtonTapped()
        }
        return true
    }
}
