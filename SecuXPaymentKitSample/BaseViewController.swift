//
//  BaseViewController.swift
//  SecuXWallet
//
//  Created by Maochun Sun on 2019/11/8.
//  Copyright © 2019 Maochun Sun. All rights reserved.
//

import UIKit
import CoreBluetooth

class BaseViewController: UIViewController {
    
    
    var theProgress  = ProgressViewController()


    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.theProgress.modalPresentationStyle = .overFullScreen

    }
    
    func hasBLEPermission() -> Bool{
        if #available(iOS 13.1, *) {
            let authStatus = CBPeripheralManager.authorization
            if authStatus == .denied{
                alertPromptAPPSettings(title: "APP would like to use Bluetooth",
                                       message: "Please grant Bluetooth permission")
                return false
                
            }
        } else {
            let authStatus = CBPeripheralManager.authorizationStatus()
            if authStatus == .denied{
                alertPromptAPPSettings(title: "APP would like to use Bluetooth",
                                     message: "Please grant Bluetooth permission")
                
                return false
              
            }
        }
        
        return true
    }

    func alertPromptAPPSettings(title:String, message:String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert )
        alert.addAction(UIAlertAction(title: "Settings", style: .default) { alert in
            guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
               return
            }

            if UIApplication.shared.canOpenURL(settingsUrl) {
               UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                   print("Settings opened: \(success)") // Prints true
               })
            }
        })
        present(alert, animated: true, completion: nil)
    }

    
    func showMessage(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showMessageInMainThread(title: String, message: String, closeProgress:Bool = false){
        DispatchQueue.main.async {
            if closeProgress{
                self.theProgress.dismiss(animated: true, completion: {
                    self.showMessage(title: title, message: message)
                
                })
            }else{
                self.showMessage(title: title, message: message)
            }
        }
    }
    
    
    func hideProgress(){
        self.theProgress.dismiss(animated: true, completion: nil)
    }

    
    func hideProgressInMain(){
        DispatchQueue.main.async {
            self.theProgress.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func showProgress(info: String){
        
        self.theProgress.progressLabel.text = info
        self.present(self.theProgress, animated: true, completion: nil)
        
    }
    
    func showProgressInMain(info: String){
        
        DispatchQueue.main.async {
            self.theProgress.progressLabel.text = info
            self.present(self.theProgress, animated: true, completion: nil)
            
        }
    }
    
    
    func updateProgress(info: String, type:Int = 0){
        DispatchQueue.main.async {
            
            self.theProgress.progressLabel.text = info
            
        }
    }
    
 
}

