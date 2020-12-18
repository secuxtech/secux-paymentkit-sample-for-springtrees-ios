//
//  SecuXQRCodeParser.swift
//  SecuXPaymentKitSample
//
//  Created by maochun on 2020/8/20.
//  Copyright © 2020 SecuX. All rights reserved.
//

import Foundation

extension String {


    var hexData: Data? {
        var data = Data(capacity: self.count / 2)

        let regex = try! NSRegularExpression(pattern: "[0-9a-f]{1,2}", options: .caseInsensitive)
        regex.enumerateMatches(in: self, range: NSRange(startIndex..., in: self)) { match, _, _ in
            let byteString = (self as NSString).substring(with: match!.range)
            let num = UInt8(byteString, radix: 16)!
            data.append(num)
        }

        guard data.count > 0 else { return nil }

        return data
    }

}

class SecuXQRCodeParser {
    
    //private let testQRCode = "{\"amount\":\"1\", \"coinType\":\"$:abcde\", \"nonce\":\"f\", \"deviceIDhash\":\"4afff62e0b314266d9e1b3a48158d56134331a9f\"}"
    
    public var theQRCodeStr = ""
    public var amount = ""
    public var refill = ""
    public var coin = ""
    public var token = ""
    public var nonce = ""
    public var nonceData : Data?
    public var devIDHash = ""
    
    
    init?(p22QRCode:String) {
        
        guard let qrcodeData = p22QRCode.data(using: .utf8),
            let qrcodeJson = try? JSONSerialization.jsonObject(with: qrcodeData, options: []) as? [String:String] else{
            return nil
        }
            
        guard let coinType = qrcodeJson["coinType"],
            let nonce = qrcodeJson["nonce"],
            let hashID = qrcodeJson["deviceIDhash"] else{
                return nil
        }
        
        let amount = qrcodeJson["amount"] ?? ""
        let refill = qrcodeJson["refill"] ?? ""
        if amount.count == 0, refill.count == 0 {
            return nil
        }
        
        let coinTypeInfoArr = coinType.split(separator: ":")
        guard coinTypeInfoArr.count == 2, coinTypeInfoArr[0].count > 0, coinTypeInfoArr[1].count > 0 else{
            return nil
        }
        
    
        self.amount = amount
        self.refill = refill
        self.coin = String(coinTypeInfoArr[0])
        self.token = String(coinTypeInfoArr[1])
        self.nonce = nonce
        self.devIDHash = hashID
        self.theQRCodeStr = p22QRCode
        self.nonceData = self.nonce.hexData
        
    }
}
