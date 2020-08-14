//
//  ViewController.swift
//  SecuXPaymentKitSample
//
//  Created by maochun on 2020/8/10.
//  Copyright © 2020 SecuX. All rights reserved.
//

import UIKit
import secux_paymentkit_v2

class ViewController: UIViewController {
    
    lazy var testButton:  UIButton = {
        
        let btn = UIButton()
        
    
    
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 22)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.setTitleColor(UIColor.gray, for: .disabled)
        btn.setTitle(NSLocalizedString("Test", comment: ""), for: .normal)
        
        btn.addTarget(self, action: #selector(testAction), for: .touchUpInside)
        
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowRadius = 2
        btn.layer.shadowOffset = CGSize(width: 2, height: 2)
        btn.layer.shadowOpacity = 0.3
        
        self.view.addSubview(btn)
        
        NSLayoutConstraint.activate([
            
            btn.bottomAnchor.constraint(equalTo: self.view.safeAreaLayoutGuide.bottomAnchor, constant: -66),
            btn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            btn.heightAnchor.constraint(equalToConstant: 46),
            
        ])
       
        return btn
    }()
    
    
    private let accountManager = SecuXAccountManager()
    private let paymentManager = SecuXPaymentManager()
    private var theUserAccount : SecuXUserAccount?

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let _ = self.testButton
    }

    @objc func testAction(){
        doEncryptPaymentDataTest()
    }

    
    func doEncryptPaymentDataTest(){
        let (ret, data) = accountManager.loginUserAccount(userAccount: theUserAccount!)
        guard ret == SecuXRequestResult.SecuXRequestOK else{
            print("login failed!")
            if let data = data{
                print("Error: \(String(data: data, encoding: String.Encoding.utf8) ?? "")")
            }
            return
        }
        
        let (encret, enctxt) = paymentManager.doActivity(userID: theUserAccount!.name, devID: "811c000009c5", coin: "$", token: "MQ03T",
                                                                 transID: "test123456", amount: "1", nonce: "abcdef")
        print("doEncryptPaymentDataTest result \(encret), \(enctxt)")
    }
}

