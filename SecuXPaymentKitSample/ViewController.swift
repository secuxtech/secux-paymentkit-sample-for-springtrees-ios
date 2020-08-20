//
//  ViewController.swift
//  SecuXPaymentKitSample
//
//  Created by maochun on 2020/8/10.
//  Copyright © 2020 SecuX. All rights reserved.
//

import UIKit
import swiftScan
import secux_paymentkit_v2


class ViewController: BaseViewController {
    
    lazy var testButton:  UIButton = {
        
        let btn = UIButton()
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.titleLabel?.font = UIFont(name: "Helvetica-Bold", size: 22)
        btn.setTitleColor(UIColor.blue, for: .normal)
        btn.setTitleColor(UIColor.darkGray, for: .highlighted)
        btn.setTitleColor(UIColor.gray, for: .disabled)
        btn.setTitle(NSLocalizedString("Scan QRCode", comment: ""), for: .normal)
        
        btn.addTarget(self, action: #selector(testAction), for: .touchUpInside)
        
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowRadius = 2
        btn.layer.shadowOffset = CGSize(width: 2, height: 2)
        btn.layer.shadowOpacity = 0.3
        
        self.view.addSubview(btn)
        
        NSLayoutConstraint.activate([
            
            btn.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            btn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            btn.heightAnchor.constraint(equalToConstant: 46),
            
        ])
       
        return btn
    }()
    
    let scanQRCodeVC = LBXScanViewController()
    
    private let accountManager = SecuXAccountManager()
    private let paymentManager = SecuXPaymentManager()
    
    private let accountName = "secuxdemo"
    private let accountPwd = "secuxdemo168"
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = self.testButton
        
        self.accountManager.setBaseServer(url: "https://pmsweb-test.secux.io")
    }

    @objc func testAction(){
        
        var style = LBXScanViewStyle()
        style.centerUpOffset = 44
        style.photoframeAngleStyle = LBXScanViewPhotoframeAngleStyle.On
        style.photoframeLineW = 6
        style.photoframeAngleW = 24
        style.photoframeAngleH = 24
        style.colorAngle = UIColor(red: 0xEB/0xFF, green: 0xCB/0xFF, blue: 0x56/0xFF, alpha: 1)
        style.isNeedShowRetangle = true
        style.anmiationStyle = LBXScanViewAnimationStyle.NetGrid
        style.animationImage = UIImage(named: "CodeScan.bundle/qrcode_scan_part_net")
        
        
        scanQRCodeVC.scanStyle = style
        scanQRCodeVC.scanResultDelegate = self
        scanQRCodeVC.modalPresentationStyle = .overFullScreen

        self.present(scanQRCodeVC, animated: true, completion: nil)
        
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
    
    func doPromotionVerify(devQRCodeInfo: String, transID:String){
        
        guard let qrcodeParser = SecuXQRCodeParser(p22QRCode: devQRCodeInfo) else{
            self.showMessage(title: "Unsupported QRCode!", message: "")
            return
        }
        
        guard login(name: self.accountName, password: self.accountPwd) else{
            self.showMessageInMainThread(title: "Login failed. doEncryptPaymentData abort!", message: "")
            return
        }
        
        let (ret, error, storeInfo) = paymentManager.getStoreInfo(devID: qrcodeParser.devIDHash)
        
        guard ret == SecuXRequestResult.SecuXRequestOK else{
            self.showMessageInMainThread(title: "Get store info. failed!", message: "Error: \(error)")
            return
        }
        
        guard let devID = storeInfo?.devID else{
            self.showMessageInMainThread(title: "Invalid store info. no device ID", message: "")
            return
        }
        
        var (doActivityRet, doActivityError) = paymentManager.doActivity(userID: self.accountName, devID: devID,
                                                                         coin: qrcodeParser.coin,
                                                                         token: qrcodeParser.token,
                                                                         transID: transID,
                                                                         amount: qrcodeParser.amount,
                                                                         nonce: qrcodeParser.nonce)
        if doActivityRet == SecuXRequestResult.SecuXRequestUnauthorized{
            
            //If login session timeout, relogin the merchant account
            guard login(name: self.accountName, password: self.accountPwd) else{
                self.showMessageInMainThread(title: "Login failed. doEncryptPaymentData abort!", message: "")
                return
            }
            
            (doActivityRet, doActivityError) = paymentManager.doActivity(userID: "secuxdemo", devID: devID, coin: "DCT", token: "SPC",
                                                                         transID: "test12345678", amount: "1", nonce: "d54343e3")
        }
        
        if doActivityRet == SecuXRequestResult.SecuXRequestOK{
            self.showMessageInMainThread(title: "doEncryptPaymentDataTest result successfully!", message: "")
        }else{
            self.showMessageInMainThread(title: "doEncryptPaymentDataTest result failed!", message: "\(doActivityError)")
        }
    }
    
}

extension ViewController: LBXScanViewControllerDelegate{
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        
        scanQRCodeVC.dismiss(animated: false, completion: nil)
        print("scan ret = \(scanResult.strScanned ?? "")")
        
        if let infoStr = scanResult.strScanned{
            
            DispatchQueue.global().async {
                self.showProgress(info: "Processing...")
                self.doPromotionVerify(devQRCodeInfo:infoStr, transID: "Test0001")
                self.hideProgress()
            }
            return
        }
        
        self.showMessage(title: "Invalid QRCode!", message: "Please try again.")
    }
    
    
}
