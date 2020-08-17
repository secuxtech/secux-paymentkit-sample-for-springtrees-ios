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
    
    private let accountName = "secuxdemo"
    private let accountPwd = "secuxdemo168"
    
    private let testQRCode = "{\"amount\":\"1\", \"coinType\":\"$:abcde\", \"nonce\":\"b29f5ceb\", \"deviceIDhash\":\"4afff62e0b314266d9e1b3a48158d56134331a9f\"}"

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let _ = self.testButton
        
        self.accountManager.setBaseServer(url: "https://pmsweb-test.secux.io")
    }

    @objc func testAction(){
        DispatchQueue.global().async {
            self.doEncryptPaymentData(devQRCodeInfo: self.testQRCode, transID: "Test0001")
        }
        
    }

    func login(name:String, password:String) -> Bool{
        let (ret, data) = accountManager.loginMerchantAccount(accountName: name, password: password)
        guard ret == SecuXRequestResult.SecuXRequestOK else{
            print("login failed!")
            if let data = data{
                print("Error: \(String(data: data, encoding: String.Encoding.utf8) ?? "")")
            }
            return false
        }
        
        return true
    }
    
    func doEncryptPaymentData(devQRCodeInfo: String, transID:String){
        
        
        
        guard login(name: self.accountName, password: self.accountPwd) else{
            print("Login failed. doEncryptPaymentData abort!")
            return
        }
        
        let (ret, error, storeInfo) = paymentManager.getStoreInfo(devID: "4afff62e0b314266d9e1b3a48158d56134331a9f")
        
        guard ret == SecuXRequestResult.SecuXRequestOK else{
            print("Get store info. failed! error: \(error)")
            return
        }
        
        guard let devID = storeInfo?.devID else{
            print("Invalid store info. no device ID")
            return
        }
        
        var (doActivityRet, doActivityError) = paymentManager.doActivity(userID: self.accountName, devID: devID, coin: "DCT", token: "SPC",
                                                                         transID: "test12345678", amount: "1", nonce: "d54343e3")
        if doActivityRet == SecuXRequestResult.SecuXRequestUnauthorized{
            
            //If login session timeout, relogin the merchant account
            guard login(name: self.accountName, password: self.accountPwd) else{
                print("Login failed. doEncryptPaymentData abort!")
                return
            }
            
            (doActivityRet, doActivityError) = paymentManager.doActivity(userID: "secuxdemo", devID: devID, coin: "DCT", token: "SPC",
                                                                         transID: "test12345678", amount: "1", nonce: "d54343e3")
        }
        
        print("doEncryptPaymentDataTest result \(doActivityRet), \(doActivityError)")
    }
}

