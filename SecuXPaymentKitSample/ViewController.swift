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
        
        self.showProgress(info: "Processing...")
        guard let qrcodeParser = SecuXQRCodeParser(p22QRCode: devQRCodeInfo) else{
            self.showMessageInMainThread(title: "Unsupported QRCode!", message: "", closeProgress: true)
            return
        }
        
        /*
         Login Merchant Account
         
         Server:
              POST /api/Admin/Login
         
         param:
             {
                 "account": "account",
                 "password": "account"
             }
         
        */
        guard login(name: self.accountName, password: self.accountPwd) else{
            self.showMessageInMainThread(title: "Login failed. doEncryptPaymentData abort!", message: "", closeProgress: true)
            return
        }
        
        /*
         Get Store Info
         
         Server:
              POST /api/Terminal/GetStore
         
         param:
             {
                 "deviceIDhash": "41193d32d520e114a3730d458f4389b5b9a7114d"
             }
         
         return:
             {
               "storeCode": "568a88ed64b5426eb747f7db00763494",
               "name": "SecuX Cafe",
               "deviceId": "4ab10000726b",
               "icon": "",
               "scanTimeout": 10,
               "checkRSSI": -80,
               "connectionTimeout": 30,
               "supportedSymbol": [
                 [
                   "DCT",
                   "SPC"
                 ]
               ],
               "supportedPromotion": [
                 {
                   "type": "Promotion",
                   "code": "test",
                   "name": "q",
                   "icon": ""
                 }
               ]
             }
         
        */
        
        
        let (ret, error, info) = paymentManager.getStoreInfo(devID: qrcodeParser.devIDHash)
     
        
        guard ret == SecuXRequestResult.SecuXRequestOK, let storeInfo = info else{
            self.showMessageInMainThread(title: "Get store info. failed!", message: "Error: \(error)", closeProgress: true)
            return
        }
        
        guard storeInfo.devID.count > 0 else{
            self.showMessageInMainThread(title: "Invalid store info. no device ID", message: "", closeProgress: true)
            return
        }
        
        /*
        guard let promotionInfo = storeInfo.getPromotionDetails(code: qrcodeParser.token) else{
            self.showMessageInMainThread(title: "Invalid store protmotion code", message: "")
            return
        }
        */
        guard let promotionInfo = storeInfo.getPromotionDetails(code: "test") else{
            self.showMessageInMainThread(title: "Invalid store protmotion code", message: "", closeProgress: true)
            return
        }
        
        DispatchQueue.main.async {
            
            self.hideProgressSync()
        
            let alertController = UIAlertController(title: promotionInfo.type, message: nil, preferredStyle: .actionSheet)
            alertController.view.translatesAutoresizingMaskIntoConstraints = false
            alertController.view.heightAnchor.constraint(equalToConstant: 500).isActive = true
            
            let customView = PromotionDetailsView()
            alertController.view.addSubview(customView)
            customView.translatesAutoresizingMaskIntoConstraints = false
            customView.topAnchor.constraint(equalTo: alertController.view.topAnchor, constant: 45).isActive = true
            customView.rightAnchor.constraint(equalTo: alertController.view.rightAnchor, constant: -10).isActive = true
            customView.leftAnchor.constraint(equalTo: alertController.view.leftAnchor, constant: 10).isActive = true
            customView.bottomAnchor.constraint(equalTo: alertController.view.bottomAnchor, constant: -130).isActive = true
            
            customView.setup(storeInfo: storeInfo, promoInfo: promotionInfo)

    
            let selectAction = UIAlertAction(title: "Confirm", style: .default) { (action) in
               
                self.showProgress(info: "")
                DispatchQueue.global().async {
                    self.confirmPromotion(devID: storeInfo.devID, transID: transID, qrcodeParser: qrcodeParser)
                }
                
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            alertController.addAction(selectAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    func confirmPromotion(devID:String, transID:String, qrcodeParser:SecuXQRCodeParser){
        /*
         
         */
        
        
        var (doActivityRet, doActivityError) = paymentManager.doActivity(userID: self.accountName, devID: devID,
                                                                         coin: qrcodeParser.coin,
                                                                         token: qrcodeParser.token,
                                                                         transID: transID,
                                                                         amount: qrcodeParser.amount,
                                                                         nonce: qrcodeParser.nonce)
        
        if doActivityRet == SecuXRequestResult.SecuXRequestUnauthorized{
            
            //If login session timeout, relogin the merchant account
            guard login(name: self.accountName, password: self.accountPwd) else{
                //hideProgress()
                self.showMessageInMainThread(title: "Login failed. doEncryptPaymentData abort!", message: "",closeProgress: true)
                return
            }
            
            (doActivityRet, doActivityError) = paymentManager.doActivity(userID: self.accountName, devID: devID,
                                                                        coin: qrcodeParser.coin,
                                                                        token: qrcodeParser.token,
                                                                        transID: transID,
                                                                        amount: qrcodeParser.amount,
                                                                        nonce: qrcodeParser.nonce)
        }
        
 
        if doActivityRet == SecuXRequestResult.SecuXRequestOK{
            self.showMessageInMainThread(title: "doEncryptPaymentDataTest result successfully!", message: "", closeProgress: true)
        }else{
            self.showMessageInMainThread(title: "doEncryptPaymentDataTest result failed!", message: "\(doActivityError)", closeProgress: true)
        }
    }
    
}

extension ViewController: LBXScanViewControllerDelegate{
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        
        scanQRCodeVC.dismiss(animated: false, completion: nil)
        print("scan ret = \(scanResult.strScanned ?? "")")
        
        if let infoStr = scanResult.strScanned{
            
            DispatchQueue.global().async {
                
                self.doPromotionVerify(devQRCodeInfo:infoStr, transID: "Test0001")
                
            }
            return
        }
        
        self.showMessage(title: "Invalid QRCode!", message: "Please try again.")
    }
    
    
}
