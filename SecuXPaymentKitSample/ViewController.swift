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
import secux_paymentdevicekit
import CoreBluetooth

extension UIButton {
    func setBackgroundColor(color: UIColor, forState: UIControl.State) {
        self.clipsToBounds = true  // add this to maintain corner radius
        UIGraphicsBeginImageContext(CGSize(width: 1, height: 1))
        if let context = UIGraphicsGetCurrentContext() {
            context.setFillColor(color.cgColor)
            context.fill(CGRect(x: 0, y: 0, width: 1, height: 1))
            let colorImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            self.setBackgroundImage(colorImage, for: forState)
        }
    }
}

class ViewController: BaseViewController {
    
    lazy var scanQRCodeButton:  UIButton = {
        
        let btn = UIButton()
        
        btn.translatesAutoresizingMaskIntoConstraints = false
        
        btn.setBackgroundColor(color: UIColor(red: 0xDF/0xFF, green: 0xB4/0xFF, blue: 0x45/0xFF, alpha: 1), forState: .normal)
        btn.setBackgroundColor(color: UIColor(red: 0x86/0xFF, green: 0x6E/0xFF, blue: 0x31/0xFF, alpha: 1), forState: .highlighted)
        btn.titleLabel?.font = UIFont(name: "Helvetica", size: 20)
        btn.setTitleColor(UIColor.black, for: .normal)
        btn.setTitle(NSLocalizedString("Scan QRCode", comment: ""), for: .normal)
        
        btn.addTarget(self, action: #selector(scanQRCodeAction), for: .touchUpInside)
        
        btn.layer.shadowColor = UIColor.black.cgColor
        btn.layer.shadowRadius = 2
        btn.layer.shadowOffset = CGSize(width: 2, height: 2)
        btn.layer.shadowOpacity = 0.3
        
        self.view.addSubview(btn)
        
        NSLayoutConstraint.activate([
            
            btn.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            btn.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            btn.heightAnchor.constraint(equalToConstant: 46),
            btn.widthAnchor.constraint(equalToConstant: 300)
            
        ])
       
        return btn
    }()
    
    var scanQRCodeVC : LBXScanViewController?
    
    private let accountManager = SecuXAccountManager()
    private let paymentManager = SecuXPaymentManager()
//    private let paymentPeripheralManager = SecuXPaymentPeripheralManager(scanTimeout: 10, connTimeout: 90, checkRSSI: -75)
    var paymentPeripheralManager: SecuXPaymentPeripheralManager = SecuXPaymentPeripheralManager(scanTimeout: 10, connTimeout: 90, checkRSSI: -75)

    private var devIVKey = ""
 
    // sandbox
//    private let userName = "sttest"
//    private let userPwd = "sttest168"
    
    
    // io
    private let userName = "secuxstream"
    private let userPwd = "secuxstream168"
    
//    private let userName = "sttest"
//    private let userPwd = "sttest168"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let _ = self.scanQRCodeButton
        
        self.accountManager.setBaseServer(url: "https://pmsweb-sandbox.secuxtech.com")
//        self.accountManager.setBaseServer(url: "https://pmsweb-test.secux.io")

        SecuXBLEManager.shared.delegate = self
    }

    @objc func scanQRCodeAction(){
        
        if !hasBLEPermission(){
            return
        }
        
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
        
        scanQRCodeVC = LBXScanViewController()
        scanQRCodeVC!.scanStyle = style
        scanQRCodeVC!.scanResultDelegate = self
        scanQRCodeVC!.modalPresentationStyle = .overFullScreen

        self.present(scanQRCodeVC!, animated: true, completion: nil)
        
        self.paymentPeripheralManager = SecuXPaymentPeripheralManager(scanTimeout: 10, connTimeout: 30, checkRSSI: -75)
        
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
    
    func showPromotionDetails(storeInfo:SecuXStoreInfo, promotionInfo:SecuXPromotion, qrcodeParser:SecuXQRCodeParser){
        
        DispatchQueue.main.async {
            
            self.hideProgress()
            
            var style = UIAlertController.Style.actionSheet
            if UIDevice.current.userInterfaceIdiom == .pad{
                style = UIAlertController.Style.alert
                
            }
            
            let alertController = UIAlertController(title: promotionInfo.type, message: nil, preferredStyle: style)
            alertController.view.translatesAutoresizingMaskIntoConstraints = false
            alertController.view.heightAnchor.constraint(equalToConstant: 560).isActive = true
           
        
            let customView = OperationDetailsView()
            customView.translatesAutoresizingMaskIntoConstraints = false
            alertController.view.addSubview(customView)
            
            customView.topAnchor.constraint(equalTo: alertController.view.subviews[0].topAnchor, constant: 45).isActive = true
            customView.rightAnchor.constraint(equalTo: alertController.view.subviews[0].rightAnchor, constant: -10).isActive = true
            customView.leftAnchor.constraint(equalTo: alertController.view.subviews[0].leftAnchor, constant: 10).isActive = true
            customView.bottomAnchor.constraint(equalTo: alertController.view.subviews[0].bottomAnchor, constant: -130).isActive = true
            
            
            customView.setup(storeInfo: storeInfo, promoInfo: promotionInfo, promoImgData: promotionInfo.imgData)

    
            let selectAction = UIAlertAction(title: "Confirm", style: .default) { (action) in
               
                self.showProgress(info: "")
                DispatchQueue.global().async {
                    self.confirmOperation(devID: storeInfo.devID, transID: "Promotion0001", qrcodeParser: qrcodeParser, type: "promotion")
                }
                
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {(action) in
                
                self.cancelOperation()
            }
            alertController.addAction(selectAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    
    func showPaymentDetails(storeInfo:SecuXStoreInfo, qrcodeParser:SecuXQRCodeParser){
        
        DispatchQueue.main.async {
            
            self.hideProgress()
            
            var style = UIAlertController.Style.actionSheet
            if UIDevice.current.userInterfaceIdiom == .pad{
                style = UIAlertController.Style.alert
            }
            
            let alertController = UIAlertController(title: "Payment", message: nil, preferredStyle: style)
            alertController.view.translatesAutoresizingMaskIntoConstraints = false
            alertController.view.heightAnchor.constraint(equalToConstant: 400).isActive = true
            
            let customView = OperationDetailsView()
            alertController.view.addSubview(customView)
            customView.translatesAutoresizingMaskIntoConstraints = false
            customView.topAnchor.constraint(equalTo: alertController.view.subviews[0].topAnchor, constant: 45).isActive = true
            customView.rightAnchor.constraint(equalTo: alertController.view.subviews[0].rightAnchor, constant: -10).isActive = true
            customView.leftAnchor.constraint(equalTo: alertController.view.subviews[0].leftAnchor, constant: 10).isActive = true
            customView.bottomAnchor.constraint(equalTo: alertController.view.subviews[0].bottomAnchor, constant: -130).isActive = true
            
            
            customView.setup(storeInfo: storeInfo, coin: qrcodeParser.coin, token: qrcodeParser.token, amount: qrcodeParser.amount)

    
            let selectAction = UIAlertAction(title: "Confirm", style: .default) { (action) in
               
                self.showProgress(info: "")
                DispatchQueue.global().async {
                    self.confirmOperation(devID: storeInfo.devID, transID: "Payment0001", qrcodeParser: qrcodeParser, type: "payment")
                   
                }
                
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {(action) in
                
                self.cancelOperation()
            }
            alertController.addAction(selectAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func showRefillDetails(storeInfo:SecuXStoreInfo, qrcodeParser:SecuXQRCodeParser){
        
        DispatchQueue.main.async {

            self.hideProgress()
            
   
            var style = UIAlertController.Style.actionSheet
            if UIDevice.current.userInterfaceIdiom == .pad{
                style = UIAlertController.Style.alert
            }
            
            let alertController = UIAlertController(title: "Refill", message: nil, preferredStyle: style)
            alertController.view.translatesAutoresizingMaskIntoConstraints = false
            alertController.view.heightAnchor.constraint(equalToConstant: 400).isActive = true
            
            let customView = OperationDetailsView()
            alertController.view.addSubview(customView)
            customView.translatesAutoresizingMaskIntoConstraints = false
            customView.topAnchor.constraint(equalTo: alertController.view.subviews[0].topAnchor, constant: 45).isActive = true
            customView.rightAnchor.constraint(equalTo: alertController.view.subviews[0].rightAnchor, constant: -10).isActive = true
            customView.leftAnchor.constraint(equalTo: alertController.view.subviews[0].leftAnchor, constant: 10).isActive = true
            customView.bottomAnchor.constraint(equalTo: alertController.view.subviews[0].bottomAnchor, constant: -130).isActive = true
            
            
            customView.setup(storeInfo: storeInfo, coin: qrcodeParser.coin, token: qrcodeParser.token, amount: qrcodeParser.refill)

    
            let selectAction = UIAlertAction(title: "Confirm", style: .default) { (action) in
               
                self.showProgress(info: "")
                DispatchQueue.global().async {
                    self.confirmOperation(devID: storeInfo.devID, transID: "Refill0001", qrcodeParser: qrcodeParser, type: "refill")
                }
                
            }

            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) {(action) in
                
                self.cancelOperation()
            }
            alertController.addAction(selectAction)
            alertController.addAction(cancelAction)
            self.present(alertController, animated: true, completion: nil)
        }
        
    }
    
    func cancelOperation(){
        self.paymentPeripheralManager.requestDisconnect()
    }
    
    func confirmOperation(devID:String, transID:String, qrcodeParser:SecuXQRCodeParser, type:String){

        var amount = qrcodeParser.amount
        if amount.count == 0{
            amount = qrcodeParser.refill
        }
        

        // sandbox
//        let operatorName = "springtreesoperator"
//        let operatorPwd = "springtrees"
        
        // io
        let operatorName = "secuxstream"
        let operatorPwd = "secuxstream168"
        let timeZone = "8"
        
        amount = "0" //JUDY2
        
        guard self.login(name: operatorName, password: operatorPwd) else{
           self.showMessageInMainThread(title: "Operator login failed. Confirm abort!", message: "", closeProgress: true)
           return
        }
        
        let (svrRet, reply) = self.paymentManager.generateEncryptedData(ivkey:     self.devIVKey,
                                                                        userID:    operatorName,
                                                                        devID:     devID,
                                                                        coin:      qrcodeParser.coin,
                                                                        token:     qrcodeParser.token,
                                                                        transID:   transID,
//                                                                        amount:    qrcodeParser.amount,//JUDY2
                                                                        amount:    amount,
                                                                        type:      type,
                                                                        timeZone:  timeZone)
        
        if svrRet == SecuXRequestResult.SecuXRequestOK, let replyData = reply.data(using: .utf8){
            if let replyJson = try? JSONSerialization.jsonObject(with: replyData, options: []) as? [String:Any]{
                    
                guard let statusCode = replyJson["statusCode"] as? Int,
                    let statusDesc = replyJson["statusDesc"] as? String,
                    let encryptedText = replyJson["encryptedText"] as? String else{
                        
                        self.showMessageInMainThread(title: "ConfirmOperation result failed!",
                                                 message: "Invalid reply data from server \(replyJson.description)",
                                                 closeProgress: true)
                        return
                }
                
                if statusCode == 200, statusDesc == "OK", encryptedText.count > 0, let encryptedData = Data(base64Encoded: encryptedText){
                    
                    let (verifyRet, errorMsg) = self.paymentPeripheralManager.doPaymentVerification(encPaymentData: encryptedData)
                    if verifyRet == .OprationSuccess{
                        self.showMessageInMainThread(title: "ConfirmOperation result successfully!", message: "", closeProgress: true)
                        return;
                    }
                    
                    self.showMessageInMainThread(title: "ConfirmOperation result failed!",
                                                 message: "Send device verification failed! error = \(errorMsg)",
                                                 closeProgress: true)
                 
                    
                }else{
                   
                    self.showMessageInMainThread(title: "ConfirmOperation result failed!",
                                                 message: "Gen ciper failed. statusCode=\(statusCode) statusDesc=\(statusDesc) encTxt=\(encryptedText)",
                                                 closeProgress: true)
                }
                
            }else{
  
                
                self.showMessageInMainThread(title: "ConfirmOperation result failed!",
                                             message: "Invalid json response from server",
                                             closeProgress: true)
            }
        }
        
        
        paymentPeripheralManager.requestDisconnect()
    }
    
    
    
}

extension ViewController: LBXScanViewControllerDelegate{
    func scanFinished(scanResult: LBXScanResult, error: String?) {
        
        self.devIVKey = ""
        
        guard let scanQRCodeVC = self.scanQRCodeVC else{
            return
        }
    
        scanQRCodeVC.dismiss(animated: false, completion: nil)
        print("scan ret = \(scanResult.strScanned ?? "")")
        
        if let devQRCodeInfo = scanResult.strScanned{
            
            
            DispatchQueue.global().async {
                
                guard let qrcodeParser = SecuXQRCodeParser(p22QRCode: devQRCodeInfo) else{
                   self.showMessageInMainThread(title: "Unsupported QRCode!", message: "", closeProgress: true)
                   return
                }
                
                self.showProgressInMain(info: "Processing...")

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
                guard self.login(name: self.userName, password: self.userPwd) else{
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


                let (ret, error, info) = self.paymentManager.getStoreInfo(devID: qrcodeParser.devIDHash)

                guard ret == SecuXRequestResult.SecuXRequestOK, let storeInfo = info else{
                   self.showMessageInMainThread(title: "Get store info. failed!", message: "Error: \(error)", closeProgress: true)
                   return
                }

                guard storeInfo.devID.count > 0 else{
                   self.showMessageInMainThread(title: "Invalid store info. no device ID", message: "", closeProgress: true)
                   return
                }
                
                if qrcodeParser.coin == "$"{
                    guard let _ = storeInfo.getPromotionDetails(code: qrcodeParser.token) else{
                       self.showMessageInMainThread(title: "Invalid store protmotion code", message: "", closeProgress: true)
                       return
                    }
                    
                }
                
                guard let nonce = qrcodeParser.nonceData else{
                    self.showMessageInMainThread(title: "Invalid qrcode nonce!", message: "", closeProgress: true)
                    return
                }

                let (getKeyRet, ivkey) = self.paymentPeripheralManager.doGetIVKey(devID: storeInfo.devID, nonce:[UInt8](nonce))
                guard getKeyRet == .OprationSuccess else{
          
                    self.showMessageInMainThread(title: "Connect with P22/P20 failed!",
                                                 message: "Get dev ivkey failed! error = \(ivkey)",
                                                 closeProgress: true)
                    return
                }
                self.devIVKey = ivkey
        
                if qrcodeParser.coin == "$"{
                    
                    self.showPromotionDetails(storeInfo: storeInfo,
                                              promotionInfo: storeInfo.getPromotionDetails(code: qrcodeParser.token)!,
                                              qrcodeParser: qrcodeParser)
                    
                }else if qrcodeParser.amount.count > 0{
                    
                    self.showPaymentDetails(storeInfo: storeInfo, qrcodeParser: qrcodeParser)
                    
                }else if qrcodeParser.refill.count > 0{

                    self.showRefillDetails(storeInfo: storeInfo, qrcodeParser: qrcodeParser)
                    
                }
                
                
                
            }
            return
        }
        
        self.showMessage(title: "Invalid QRCode!", message: "Please try again.")
    }
    
    
}

extension ViewController: BLEDevControllerDelegate{
    
    
    func enableBLESetting() {
        DispatchQueue.main.async {
            
            let alert = UIAlertController(title: "Bluetooth is off",
                                          message:"Please turn on your bluetooth",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Setting",
                                          style: .default,
                                          handler: {
                                            
                                            (action) in
                                            if action.style == .default{
                                                
                                                if let url = URL(string:UIApplication.openSettingsURLString)
                                                {
                                                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                                                }
                                                
                                            }
            }))
            
            
            alert.addAction(UIAlertAction(title: "Cancel",
                                          style: .default,
                                          handler: nil))
            
            
            self.present(alert, animated: true, completion:nil)
        }
    }
    
 
    
    func updateBLESetting(state: CBManagerState) {
        
        if state != CBManagerState.poweredOn{
            
            DispatchQueue.main.async {
                self.alertPromptAPPSettings(title: "APP would like to use Bluetooth",
                                     message: "Please turn on the Bluetooth!")
            }
            
        }
    }
    
    func updateConnDevStatus(status: Int) {
        
    }
    
    
}
