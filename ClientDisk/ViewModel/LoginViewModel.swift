//
//  LoginViewModel.swift
//  ClientDisk
//
//  Created by Roman on 22.09.2020.
//  Copyright © 2020 Roman Monakhov. All rights reserved.
//

import Foundation

class LoginViewModel{
    
    let clientId = "afa4121bb9c840f999d5654548657d77" // здесь должен быть ID вашего зарегистрированного приложения
    let scheme = "myclouddisk" // схема для callback


    
     var tokenGetRequest: URLRequest? {
        guard var urlComponents = URLComponents(string: "https://oauth.yandex.ru/authorize") else { return nil }

        urlComponents.queryItems = [
            URLQueryItem(name: "response_type", value: "token"),
            URLQueryItem(name: "client_id", value: "\(clientId)")
        ]

        guard let url = urlComponents.url else { return nil }

        return URLRequest(url: url)
    }

}
