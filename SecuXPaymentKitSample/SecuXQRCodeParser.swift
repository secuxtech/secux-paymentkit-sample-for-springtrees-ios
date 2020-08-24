//
//  SecuXQRCodeParser.swift
//  SecuXPaymentKitSample
//
//  Created by maochun on 2020/8/20.
//  Copyright © 2020 SecuX. All rights reserved.
//

import Foundation

class SecuXQRCodeParser {
    
    //private let testQRCode = "{\"amount\":\"1\", \"coinType\":\"$:abcde\", \"nonce\":\"f\", \"deviceIDhash\":\"4afff62e0b314266d9e1b3a48158d56134331a9f\"}"
    
    public var theQRCodeStr = ""
    public var amount = ""
    public var coin = ""
    public var token = ""
    public var nonce = ""
    public var devIDHash = ""
    
    init?(p22QRCode:String) {
        
        guard let qrcodeData = p22QRCode.data(using: .utf8),
            let qrcodeJson = try? JSONSerialization.jsonObject(with: qrcodeData, options: []) as? [String:String] else{
            return nil
        }
            
        guard let amount = qrcodeJson["amount"],
            let coinType = qrcodeJson["coinType"],
            let nonce = qrcodeJson["nonce"],
            let hashID = qrcodeJson["deviceIDhash"] else{
                return nil
        }
        
        let coinTypeInfoArr = coinType.split(separator: ":")
        guard coinTypeInfoArr.count == 2, coinTypeInfoArr[0].count > 0, coinTypeInfoArr[1].count > 0 else{
            return nil
        }
        
        self.amount = amount
        self.coin = String(coinTypeInfoArr[0])
        self.token = String(coinTypeInfoArr[1])
        self.nonce = nonce
        self.devIDHash = hashID
        self.theQRCodeStr = p22QRCode
        
    }
}
