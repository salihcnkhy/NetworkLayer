//
//  HttpPropertyProviderProtocol.swift
//  
//
//  Created by Salihcan Kahya on 9.02.2022.
//

import Alamofire

public protocol HttpPropertyProviderProtocol {
    func getHttpHeaders() -> HTTPHeaders
    func getParameterEncoding(by method: HTTPMethod) -> ParameterEncoding
}
