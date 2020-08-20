//
//  BaseViewController.swift
//  SecuXWallet
//
//  Created by Maochun Sun on 2019/11/8.
//  Copyright © 2019 Maochun Sun. All rights reserved.
//

import UIKit


class BaseViewController: UIViewController {
    
    
    var theProgress  = ProgressViewController()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = .white
        
        self.theProgress.modalPresentationStyle = .overFullScreen

    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        
    }
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }
    

    
    func showMessage(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        self.present(alert, animated: true, completion: nil)
    }
    
    func showMessageInMainThread(title: String, message: String){
        DispatchQueue.main.async {
            self.showMessage(title: title, message: message)
        }
    }
    
    
    func hideProgress(){
        DispatchQueue.main.async {
            self.theProgress.dismiss(animated: true, completion: nil)
        }
        
    }
    
    func showProgress(info: String){
        
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

