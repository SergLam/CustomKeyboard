//
//  Catboard.swift
//  TransliteratingKeyboard
//
//  Created by Alexei Baboulevitch on 9/24/14.
//  Copyright (c) 2014 Alexei Baboulevitch ("Archagon"). All rights reserved.
//

import UIKit

/*
This is the demo keyboard. If you're implementing your own keyboard, simply follow the example here and then
set the name of your KeyboardViewController subclass in the Info.plist file.
*/

let kCatTypeEnabled = "kCatTypeEnabled"
let TEXT_TO_UPLOAD = "TextToUpload"
let NO_INTERNET = "noInternet"
var txtReturn = ""
var extraText = ""

class Catboard: KeyboardViewController {
    
    let takeDebugScreenshot: Bool = false
    
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        UserDefaults.standard.register(defaults: [kCatTypeEnabled: true])
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
//        if var textToUpload:String = UserDefaults.standard.value(forKey: TEXT_TO_UPLOAD) as? String {
//            textToUpload = textToUpload.trimmingCharacters(in: .whitespacesAndNewlines)
//            print("textToUpload",textToUpload)
//            if textToUpload != "" {
//                postAction(textToUpload)
//            }
//        }
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func keyPressed(_ key: Key) {
        print(key)
        let textDocumentProxy = self.textDocumentProxy
        
        let keyOutput = key.outputForCase(self.shiftState.uppercase())
        print(keyOutput)
        if !UserDefaults.standard.bool(forKey: kCatTypeEnabled) {
            textDocumentProxy.insertText(keyOutput)
            return
        }
        
        if key.type == .character || key.type == .specialCharacter {
            if let context = textDocumentProxy.documentContextBeforeInput {
//                if context.count < 2 {
//                    textDocumentProxy.insertText(keyOutput)
//                    return
//                }
//
//                var index = context.endIndex
//
//                index = context.index(before: index)
//                if context[index] != " " {
//                    textDocumentProxy.insertText(keyOutput)
//                    return
//                }
//
//                index = context.index(before: index)
//                if context[index] == " " {
//                    textDocumentProxy.insertText(keyOutput)
//                    return
//                }

            //    textDocumentProxy.insertText("\(randomCat())")
               // textDocumentProxy.insertText(" ")
                textDocumentProxy.insertText(keyOutput)
                
            }
            else {
                textDocumentProxy.insertText(keyOutput)
                
            }
        }
        else {
            textDocumentProxy.insertText(keyOutput)
            
        }
        
        completeText = textDocumentProxy.documentContextBeforeInput!
        print("complete text sadsad ",completeText)
        extraText = completeText
        if keyOutput == "\n"{
            lastText = lastText + keyOutput
            if lastText == completeText{
                completeText = ""
            }
            if Connectivity.isConnectedToInternet{
                print("Connected")
               if completeText != ""{
                   //    let newString = completeText.replacingOccurrences(of: " ", with: ",", options: .literal, range: nil)
              
                    DispatchQueue.main.async {
                       self.postAction(completeText)
                    }
              }
           }
           else{
                print("No Internet")
                //if let text = UserDefaults.standard.set(completeText, forKey: NO_INTERNET) as? String {
                    localString = localString + completeText
                    UserDefaults.standard.set(localString, forKey: NO_INTERNET)
                    extraText = ""
               //}
            }
       
            print("Its the time to hit amazing API.")
        }
        UserDefaults.standard.set(completeText, forKey: TEXT_TO_UPLOAD)
        return
    }
    
//    func postAction(_ text:String) {
//        let Url = String(format: "http://dev4.csdevhub.com/parakeet/api/addUserKeyword")
//        guard let serviceUrl = URL(string: Url) else { return }
//        let parameterDictionary:[String:Any] = ["deviceId" : deviceID, "keyWord" : text]
//        var request = URLRequest(url: serviceUrl)
//        request.httpMethod = "POST"
//        print(parameterDictionary)
//        let postStr = self.getPostString(params: parameterDictionary)
//        let httpBody = postStr.data(using: .utf8)
//        request.httpBody = httpBody
//
//        let session = URLSession.shared
//        session.dataTask(with: request) { (data, response, error) in
//
//            print("response:--")
//            if let response = response {
//                print("response:--",response)
//            } else if let error = error {
//                print("error", error.localizedDescription)
//            }
//            if let data = data {
//                do {
//                    let json = try JSONSerialization.jsonObject(with: data, options: [])
//                    print(json)
//                    completeText = ""
//                } catch {
//                    print(error)
//                }
//            }
//            }.resume()
//    }
    
    func fullDocumentContext() {
        let textDocumentProxy = self.textDocumentProxy
        
        var before = textDocumentProxy.documentContextBeforeInput
        
        var completePriorString = "";
        
        // Grab everything before the cursor
        while (before != nil && !before!.isEmpty) {
            completePriorString = before! + completePriorString
            
            let length = before!.lengthOfBytes(using: String.Encoding.utf8)
            
            textDocumentProxy.adjustTextPosition(byCharacterOffset: -length)
            Thread.sleep(forTimeInterval: 0.01)
            before = textDocumentProxy.documentContextBeforeInput
        }
        
        // Move the cursor back to the original position
        self.textDocumentProxy.adjustTextPosition(byCharacterOffset: completePriorString.count)
        Thread.sleep(forTimeInterval: 0.01)
        
        var after = textDocumentProxy.documentContextAfterInput
        
        var completeAfterString = "";
        
        // Grab everything after the cursor
        while (after != nil && !after!.isEmpty) {
            completeAfterString += after!
            
            let length = after!.lengthOfBytes(using: String.Encoding.utf8)
            
            textDocumentProxy.adjustTextPosition(byCharacterOffset: length)
            Thread.sleep(forTimeInterval: 0.01)
            after = textDocumentProxy.documentContextAfterInput
        }
        
        // Go back to the original cursor position
        self.textDocumentProxy.adjustTextPosition(byCharacterOffset: -(completeAfterString.count))
        
        let completeString = completePriorString + completeAfterString
        
        print("Final result: ",completeString)
        
        //        return completeString
    }
    
    override func setupKeys() {
        super.setupKeys()
        
        if takeDebugScreenshot {
            if self.layout == nil {
                return
            }
            
            for page in keyboard.pages {
                for rowKeys in page.rows {
                    for key in rowKeys {
                        if let keyView = self.layout!.viewForKey(key) {
                            keyView.addTarget(self, action: #selector(Catboard.takeScreenshotDelay), for: .touchDown)
                        }
                    }
                }
            }
        }
    }
    
    override func createBanner() -> ExtraView? {
        return CatboardBanner(globalColors: type(of: self).globalColors, darkMode: false, solidColorMode: self.solidColorMode())
    }
    
 @objc func takeScreenshotDelay() {
        Timer.scheduledTimer(timeInterval: 0.1, target: self, selector: #selector(Catboard.takeScreenshot), userInfo: nil, repeats: false)
    }
    
    @objc func takeScreenshot() {
        if !self.view.bounds.isEmpty {
            UIDevice.current.beginGeneratingDeviceOrientationNotifications()
            
            let oldViewColor = self.view.backgroundColor
            self.view.backgroundColor = UIColor(hue: (216/360.0), saturation: 0.05, brightness: 0.86, alpha: 1)
            
            let rect = self.view.bounds
            UIGraphicsBeginImageContextWithOptions(rect.size, true, 0)
            self.view.drawHierarchy(in: self.view.bounds, afterScreenUpdates: true)
            let capturedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
            
            // AB: consider re-enabling this when interfaceOrientation actually breaks
            //// HACK: Detecting orientation manually
            //let screenSize: CGSize = UIScreen.main.bounds.size
            //let orientation: UIInterfaceOrientation = screenSize.width < screenSize.height ? .portrait : .landscapeLeft
            //let name = (orientation.isPortrait ? "Screenshot-Portrait" : "Screenshot-Landscape")
            
            let name = (self.interfaceOrientation.isPortrait ? "Screenshot-Portrait" : "Screenshot-Landscape")
            let imagePath = "/Users/archagon/Documents/Programming/OSX/RussianPhoneticKeyboard/External/tasty-imitation-keyboard/\(name).png"
            
            if let pngRep = capturedImage!.pngData() {
                try? pngRep.write(to: URL(fileURLWithPath: imagePath), options: [.atomic])
            }
            
            self.view.backgroundColor = oldViewColor
        }
    }
}

func randomCat() -> String {
    let cats = "🐱😺😸😹😽😻😿😾😼🙀"
    
    let numCats = cats.count
    let randomCat = arc4random() % UInt32(numCats)
    
    let index = cats.index(cats.startIndex, offsetBy: Int(randomCat))
    let character = cats[index]
    
    return String(character)
}
