//
//  AppDelegate.swift
//  CarTalk
//
//  Created by LakshmiNarayananN on 26/03/18.
//  Copyright © 2018 Lakshmi Narayanan N. All rights reserved.
//

import UIKit
import GoogleMaps
import GooglePlaces
import Alamofire
import SwiftyJSON

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
         _ = DialogFlow()
        GMSPlacesClient.provideAPIKey("AIzaSyCcVY7BvOSp2U_p0f4SQbPDWd359zRsoOE")
        GMSServices.provideAPIKey("AIzaSyCcVY7BvOSp2U_p0f4SQbPDWd359zRsoOE")
        givenValue("Hello")
        return true
    }
    
    
    func givenValue(_ text: String) {
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

