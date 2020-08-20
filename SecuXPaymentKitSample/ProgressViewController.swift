//
//  ProgressViewController.swift
//  APPCommon
//
//  Created by maochun on 2020/7/23.
//  Copyright © 2020 maochun. All rights reserved.
//

import UIKit


class ProgressViewController: UIViewController {
    
    lazy var bkView: UIView = {
        let bkview = UIView()
        bkview.translatesAutoresizingMaskIntoConstraints = false
        bkview.backgroundColor = .black
        
        bkview.layer.cornerRadius = 10
        /*
        bkview.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.2).cgColor
        bkview.layer.shadowOffset = CGSize(width: 1, height: 1)
        bkview.layer.shadowOpacity = 0.2
        bkview.layer.shadowRadius = 15
        */
        bkview.layer.shadowColor = UIColor.darkGray.cgColor
        //bkview.layer.shadowPath = UIBezierPath(roundedRect: bkview.bounds, cornerRadius: 10).cgPath
        bkview.layer.shadowOffset = CGSize(width: 0.0, height: 1.0)
        bkview.layer.shadowOpacity = 0.4
        bkview.layer.shadowRadius = 3.0
        
        //bkview.layer.borderColor = UIColor(red: 0.62, green: 0.62, blue: 0.62,alpha:1).cgColor
        //bkview.layer.borderWidth = 2
        
        //let tap = UITapGestureRecognizer(target: self, action: #selector(onTapped))
        //bkview.addGestureRecognizer(tap)
      
        
        self.view.addSubview(bkview)
        
        NSLayoutConstraint.activate([
            
            bkview.centerYAnchor.constraint(equalTo: self.view.centerYAnchor),
            bkview.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            bkview.widthAnchor.constraint(equalToConstant: 100),
            bkview.heightAnchor.constraint(equalToConstant: 120)
        ])
        
        return bkview
    }()
    
    lazy var progressLabel : UILabel = {
        let label = UILabel()

        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "10" //"\(row+1)"

        //label.font = UIFont.preferredFont(forTextStyle: .headline)
        //label.adjustsFontForContentSizeCategory = true
        label.font = UIFont.init(name: "Helvetica-Bold", size: 14)
        label.textColor = .white
        label.textAlignment = NSTextAlignment.left

        label.numberOfLines = 0
        label.lineBreakMode = NSLineBreakMode.byWordWrapping
        label.sizeToFit()


        self.view.addSubview(label)
        
        NSLayoutConstraint.activate([
            
            label.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            label.bottomAnchor.constraint(equalTo: self.bkView.bottomAnchor, constant: -20)
        ])
        
        
        return label
    }()
    
    
    lazy var progressIndicator: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView()
        indicator.translatesAutoresizingMaskIntoConstraints = false
        indicator.color = .white
        indicator.transform = CGAffineTransform(scaleX: 1.2, y: 1.2)
        
        
        if #available(iOS 13.0, *){
            indicator.style = .large
        }
        
        self.view.addSubview(indicator)
        
        
        NSLayoutConstraint.activate([
            
            indicator.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: -20),
            indicator.centerXAnchor.constraint(equalTo: self.view.centerXAnchor),
            
        ])
        
        return indicator
    }()
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        let _ = self.progressLabel
        
        let _ = self.bkView
        
        self.view.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.5)
        
        self.progressIndicator.startAnimating()
        
     
    }
    
    
}
