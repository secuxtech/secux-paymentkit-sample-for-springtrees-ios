//
//  PromotionDetailsView.swift
//  SecuXPaymentKitSample
//
//  Created by maochun on 2020/8/24.
//  Copyright © 2020 SecuX. All rights reserved.
//

import UIKit
import secux_paymentkit_v2

class OperationDetailsView: UIView {
    
    
    lazy var storeNameLabel : UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "N/A"
        
        label.font = UIFont(name: "Helvetica-Bold", size: 18)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor(red: 0x75/0xFF, green: 0x75/0xFF, blue: 0x75/0xFF, alpha: 1)
        label.textAlignment = NSTextAlignment.center
        
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.sizeToFit()
        
        
        self.addSubview(label)
        
        
        NSLayoutConstraint.activate([
        
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor, constant: 0),
            label.topAnchor.constraint(equalTo: self.topAnchor, constant: 10),
        
        ])
        
        
        return label
    }()
    
    lazy var storeImg: UIImageView = {

        let imageView = UIImageView()
        //imageView.image = UIImage(named: "storeinfo_error")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(imageView)
        
    
        NSLayoutConstraint.activate([
           
            imageView.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            imageView.topAnchor.constraint(equalTo: self.storeNameLabel.bottomAnchor, constant: 10),
            imageView.widthAnchor.constraint(equalToConstant: 50),
            imageView.heightAnchor.constraint(equalToConstant: 50)
           
        ])
        
    
        return imageView
    }()
    
    lazy var nameLabel : UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        
        label.font = UIFont(name: "Arial", size: 18)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor(red: 0x1F/0xFF, green: 0x20/0xFF, blue: 0x20/0xFF, alpha: 1)
        label.textAlignment = NSTextAlignment.left
        
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.sizeToFit()
        
        
        self.addSubview(label)
        
        
        NSLayoutConstraint.activate([
        
            label.topAnchor.constraint(equalTo: self.storeImg.bottomAnchor, constant: 30),
            label.leftAnchor.constraint(equalTo: self.leftAnchor, constant:20)
        
        ])
        
        
        return label
    }()
    
    
    lazy var descLabel : UILabel = {
        let label = UILabel()
        
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        
        label.font = UIFont(name: "Arial", size: 18)
        label.adjustsFontForContentSizeCategory = true
        label.textColor = UIColor(red: 0x1F/0xFF, green: 0x20/0xFF, blue: 0x20/0xFF, alpha: 1)
        label.textAlignment = NSTextAlignment.left
        
        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.sizeToFit()
        
        
        self.addSubview(label)
        
        
        NSLayoutConstraint.activate([
        
            label.topAnchor.constraint(equalTo: self.nameLabel.bottomAnchor, constant: 20),
            label.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 20),
            label.widthAnchor.constraint(equalToConstant: 350)
        
        
        ])
        
        
        return label
    }()
    
    func setup(storeInfo:SecuXStoreInfo, promoInfo:SecuXPromotion){
        
        self.storeImg.image = storeInfo.logo
        self.storeNameLabel.text = storeInfo.name
        self.nameLabel.text = "Promotion Name:\n" + promoInfo.name
        self.descLabel.text = "Promotion Desc:\n" + promoInfo.desc
        
    }
    
    func setup(storeInfo:SecuXStoreInfo, coin:String, token:String, amount:String){
        
        self.storeImg.image = storeInfo.logo
        self.storeNameLabel.text = storeInfo.name
        self.nameLabel.text = "CoinToken:  " + coin + ":" + token
        self.descLabel.text = "Amount:  " + amount
        
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor(red: 0.96, green: 0.96, blue: 0.96, alpha: 1)
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        

    }
}

