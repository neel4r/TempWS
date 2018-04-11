//
//  Coordinator.swift
//  cartalk
//
//  Created by sunil on 26/03/18.
//  Copyright © 2018 sunil. All rights reserved.
//

import Foundation
import Speech
import ApiAI

class Coordinator: NSObject, TextFeederProtocol {

    let textFeeder:TextFeeder = TextFeeder()
    var inputText:String? = ""
    let speechSynthesizer = AVSpeechSynthesizer()
    static let sharedInstance = Coordinator()

    private override init() {
        super.init()
        textFeeder.delegate = self
    }

    // Mark : protocol
    func speechRecognizer(status: Bool) {
        print("Speech rec")
    }

    func voiceToText(message: String) {
        //        instructionSet.append(message)
        inputText = message
        print("message 1 : \(message.description)")
        sendMessage()
    }

    func authorization(authStatus: SFSpeechRecognizerAuthorizationStatus) {
        print("\(authStatus.hashValue)")
    }

    func speechAndText(text: String) {
        let speechUtterance = AVSpeechUtterance(string: text)
        speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-IN")
        speechSynthesizer.speak(speechUtterance)
    }
    
    func sendMessage() {
        let request = ApiAI.shared().textRequest()
        if let text = inputText, text != "" {
            request?.query = text
        } else {
            return
        }

        request?.setMappedCompletionBlockSuccess({ (request, response) in
            let response = response as! AIResponse
            if let textResponse:[[AnyHashable:Any]] = response.result.fulfillment.messages {
                //                self.speechAndText(text: textResponse)
                for responseItem in textResponse{
                    print("API response : \(String(describing: responseItem["speech"]))")
                    self.textFeeder.speechAndText(text: responseItem["speech"] as! String)
                }
                //                print("API response : \(textResponse["speech"])")
            }
        }, failure: { (request, error) in
            print(error!)
        })

        ApiAI.shared().enqueue(request)
        inputText = ""
    }
    
}
