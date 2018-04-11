//
//  DialogFlow.swift
//  cartalk
//
//  Created by sunil on 26/03/18.
//  Copyright © 2018 sunil. All rights reserved.
//

import ApiAI

class DialogFlow: NSObject {

    override init() {
        let configuration = AIDefaultConfiguration()
        configuration.clientAccessToken = "eab39eac0d414ab097a802116bc72717"
        let apiai = ApiAI.shared()
        apiai?.configuration = configuration
    }
}
