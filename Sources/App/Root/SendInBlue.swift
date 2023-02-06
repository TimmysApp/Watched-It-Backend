//
//  File.swift
//  
//
//  Created by Joe Maghzal on 04/02/2023.
//

import Vapor
import SendinBlueMailer

extension Application {
    var mailClient: SendInBlueClient {
        return SendInBlueClient(httpClient: http.client.shared, apiKey: "")
    }
}
