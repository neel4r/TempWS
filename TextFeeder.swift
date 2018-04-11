//
//  TextFeeder.swift
//  cartalk
//
//  Created by sunil on 25/03/18.
//  Copyright © 2018 sunil. All rights reserved.
//

import Speech
import Alamofire
import SwiftyJSON

protocol TextFeederProtocol {
    func voiceToText(message:String)
    func authorization(authStatus:SFSpeechRecognizerAuthorizationStatus)
    func speechRecognizer(status:Bool)
}

class TextFeeder: NSObject, SFSpeechRecognizerDelegate {
    
    private let speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-IN"))!
    
    var recognitionRequest: SFSpeechAudioBufferRecognitionRequest?
    var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()
    
    let speechSynthesizer = AVSpeechSynthesizer()
    
    static let sharedInstance = TextFeeder()
    var  delegate:TextFeederProtocol?
    
    override init(){
        super.init()
        self.config()
        self.auth()
    }
    
    func config(){
        speechRecognizer.delegate = self
    }
    
    func auth(){
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            self.delegate?.authorization(authStatus: authStatus)
            //            switch authStatus {
            //            case .authorized:
            //            case .denied:
            //            case .restricted:
            //            case .notDetermined:
            //            }
        }
    }
    
    func beginingRecording(){
        if audioEngine.isRunning {
            stopRecording()
        } else {
            recordRecongnizeSpeech()
        }
    }
    
   /* func cancelRecord(){
        audioEngine.stop()
        let node = audioEngine.inputNode
        node.removeTap(onBus: 0)
        recognitionTask?.cancel()
    } */
    
    func stopRecording(){
        audioEngine.stop()
        recognitionTask?.cancel()
        recognitionRequest?.endAudio()
    }
    
    func recordRecongnizeSpeech() {
        
        if recognitionTask != nil {  //1
            recognitionTask?.cancel()
            recognitionTask = nil
        }
        
        let audioSession = AVAudioSession.sharedInstance()  //2
        do {
            try audioSession.setCategory(AVAudioSessionCategoryRecord)
            try audioSession.setMode(AVAudioSessionModeMeasurement)
            try audioSession.setActive(true, with: .notifyOthersOnDeactivation)
        } catch {
            print("audioSession properties weren't set because of an error.")
        }
        
        recognitionRequest = SFSpeechAudioBufferRecognitionRequest()  //3
        
        let inputNode = audioEngine.inputNode
        
        guard let recognitionRequest = recognitionRequest else {
            fatalError("Unable to create an SFSpeechAudioBufferRecognitionRequest object")
        } //5
        
        recognitionRequest.shouldReportPartialResults = true  //6
        
        recognitionTask = speechRecognizer.recognitionTask(with: recognitionRequest, resultHandler: { (result, error) in  //7
            
            var isFinal = false  //8
            
            if result != nil {
                let text = result?.bestTranscription.formattedString  //9
                self.getVoiceResponseAsText(text ?? "")
                return
//                self.delegate?.voiceToText(message: text!)
                isFinal = (result?.isFinal)!
            }
            
            if error != nil || isFinal {  //10
                self.audioEngine.stop()
                inputNode.removeTap(onBus: 0)
                
                self.recognitionRequest = nil
                self.recognitionTask = nil
            }
        })
        
        let recordingFormat = inputNode.outputFormat(forBus: 0)  //11
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { (buffer, when) in
            self.recognitionRequest?.append(buffer)
        }
        
        audioEngine.prepare()  //12
        
        do {
            try audioEngine.start()
        } catch {
            print("audioEngine couldn't start because of an error.")
        }
    }
    
    func speechAndText(text: String) {
        if audioEngine.isRunning {
            audioEngine.stop()
            recognitionRequest?.endAudio()
            let audioSession = AVAudioSession.sharedInstance()
            do {
                
                try audioSession.setCategory(AVAudioSessionCategoryPlayback)
                try audioSession.setMode(AVAudioSessionModeDefault)
                
            } catch {
                print("audioSession properties weren't set because of an error.")
            }
            let speechUtterance = AVSpeechUtterance(string: text)
            speechUtterance.voice = AVSpeechSynthesisVoice(language: "en-IN")
            speechSynthesizer.speak(speechUtterance)
        }
    }
    
    func speechRecognizer(_ speechRecognizer: SFSpeechRecognizer, availabilityDidChange available: Bool) {
        
    }
    
    func getVoiceResponseAsText(_ text: String) {
        
        let url: String = "http://localhost:8081/speak"
        let parameters = ["userName": "Siva",
                          "userSays": text]

        
        let headers: HTTPHeaders = [
        "Content-Type": "application/x-www-form-urlencoded",
        "X-HTTP-Method-Override": "PATCH"
        ]
        
        Alamofire.request(url, method:.post, parameters:parameters, headers:headers).responseJSON { response in
            switch response.result {
            case .success:
                debugPrint(response)
                
            case .failure(let error):
                print(error)
            }
        }
    }
}
