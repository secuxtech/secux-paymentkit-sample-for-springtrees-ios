# secux-paymentkit-v2

[![Version](https://img.shields.io/cocoapods/v/secux-paymentkit-v2.svg?style=flat)](https://cocoapods.org/pods/secux-paymentkit-v2)
[![License](https://img.shields.io/cocoapods/l/secux-paymentkit-v2.svg?style=flat)](https://cocoapods.org/pods/secux-paymentkit-v2)
[![Platform](https://img.shields.io/cocoapods/p/secux-paymentkit-v2.svg?style=flat)](https://cocoapods.org/pods/secux-paymentkit-v2)

## Example

To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Requirements

## Installation

secux-paymentkit-v2 is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'secux-paymentkit-v2'
```

### Add bluetooth privacy permissions in the plist

![Screenshot](Readme_PlistImg.png)

### Import the module

```swift 
    import secux_paymentkit_v2
```

## Usage

The secux-paymentkit-sample-for-springtrees-ios is a sample APP for showing how to scan
the QRCode from P22 and confirm the promotion to the P22 device. 

## APIs

### SecuXAccount related operations

Use SecuXAccountManager object to do the operations below
```swift
    let accManager = SecuXAccountManager()
```

1. <b>Merchant Login</b>

Must login the assigned merchant account before calling payment related APIs.

Note: <span style="color:red">Login session is valid for 30 minutes</span>. To continue use after 30 minutes, relogin is required.

#### <u>Declaration</u>
```swift
    func loginMerchantAccount(accountName:String, password:String) 
                                                -> (SecuXRequestResult, Data?)
```
#### <u>Parameter</u>
```
    accountName:    Merchant account name.
    password:       Merchant account password.
```

#### <u>Return value</u>
```
    SecuXRequestResult shows the operation result. If the result is SecuXRequestOK, 
    login is successful, otherwise login failed and data might contain an error message.
```

#### <u>Sample</u>
```swift
    func login(name:String, password:String) -> Bool{
        let (ret, data) = accountManager.loginMerchantAccount(accountName: name, 
                                                              password: password)
        guard ret == SecuXRequestResult.SecuXRequestOK else{
            print("login failed!")
            if let data = data, 
               let error = String(data: data, encoding: String.Encoding.utf8)  {
                print("Error: \(error)")
            }
            return false
        }
        
        return true
    }
```

### SecuXPayment related operations

Use SecuXPaymentManager object to do the operations below

```swift
    let paymentManager = SecuXPaymentManager()
```

1. <b>Get store information</b>

Get store information via the hashed device ID in P22 QRCode.
#### <u>Declaration</u>
```swift
    func getStoreInfo(devID:String) -> (SecuXRequestResult, String, SecuXStoreInfo?)
```
#### <u>Parameter</u>
```
    devID: Hashed device ID from P22 QRCode
```
#### <u>Return value</u>
```
    SecuXRequestResult shows the operation result. If the result is SecuXRequestOK, 
    getting store information is successfully, store information is in the SecuXStoreInfo, 
    otherwise getting store information is failed and string might contain an error message.

    Note: if return result is SecuXRequestNoToken / SecuXRequestUnauthorized, the login 
    session is timeout, please relogin the system.

    SecuXStoreInfo contains store code, store name, store icon, store device id and 
    store supported coin/token array
```
#### <u>Sample</u>
```swift
    let (ret, error, storeInfo) = paymentManager.getStoreInfo(devID: devIDHash)
        
    guard ret == SecuXRequestResult.SecuXRequestOK else{
        self.showMessageInMainThread(title: "Get store info. failed!", 
                                   message: "Error: \(error)")
        return
    }
    
    guard let devID = storeInfo?.devID else{
        self.showMessageInMainThread(title: "Invalid store info. no device ID", 
                                   message: "")
        return
    }
```

2. <b>Do promotation activity</b>

Confirm the promotation acitvity to the P22 device.

#### <u>Declaration</u>
```swift
    func doActivity(userID:String, 
                    devID:String, 
                    coin:String, 
                    token:String, 
                    transID:String, 
                    amount:String, 
                    nonce:String) ->(SecuXRequestResult, String)
```
#### <u>Parameter</u>
```
    userID:     Merchant account name.
    devID:      Current device ID, which can be get via getStoreInfo API
    coin:       Coin info. from the QRCode.
    token:      Token info. from the QRCode.
    transID:    Transaction ID assigned by merchant. 
    amount:     Amount info. from the QRCode.
    nonce:      Nonce info. from the QRCode. 
```
#### <u>Return value</u>
```
    SecuXRequestResult shows the operation result. If the result is SecuXRequestOK, 
    doActivity is successfully and P22 should show the successful message, otherwise doActivity is failed and string might contain an error message.

    Note: if return result is SecuXRequestNoToken / SecuXRequestUnauthorized, the login 
    session is timeout, please relogin the system.
```
#### <u>Sample</u>

```swift
    var (doActivityRet, doActivityError) = paymentManager.doActivity(userID: self.accountName, 
                                                                    devID: devID,
                                                                    coin: qrcodeParser.coin,
                                                                    token: qrcodeParser.token,
                                                                    transID: transID,
                                                                    amount: qrcodeParser.amount,
                                                                    nonce: qrcodeParser.nonce)
    if doActivityRet == SecuXRequestResult.SecuXRequestUnauthorized{
        
        //If login session timeout, relogin the merchant account
        guard login(name: self.accountName, password: self.accountPwd) else{
            self.showMessageInMainThread(title: "Login failed. doEncryptPaymentData abort!", 
                                       message: "")
            return
        }
        
        (doActivityRet, doActivityError) = paymentManager.doActivity(userID: self.accountName, 
                                                                    devID: devID,
                                                                    coin: qrcodeParser.coin,
                                                                    token: qrcodeParser.token,
                                                                    transID: transID,
                                                                    amount: qrcodeParser.amount,
                                                                    nonce: qrcodeParser.nonce)
    }
    
    if doActivityRet == SecuXRequestResult.SecuXRequestOK{
        self.showMessageInMainThread(title: "doEncryptPaymentDataTest result successfully!", 
                                   message: "")
    }else{
        self.showMessageInMainThread(title: "doEncryptPaymentDataTest result failed!", 
                                   message: "\(doActivityError)")
    }
    
```

## Author

maochuns, maochunsun@secuxtech.com

## License

secux-paymentkit is available under the MIT license. 

