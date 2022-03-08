//
//  HttpPropertyProviderProtocol.swift
//  
//
//  Created by Salihcan Kahya on 9.02.2022.
//

import Alamofire

public protocol HttpPropertyProviderProtocol {
    func getBaseUrl() -> String
    func getHttpHeaders() -> HTTPHeaders
    func getParameterEncoding(by method: HTTPMethod) -> ParameterEncoding
}

public extension HttpPropertyProviderProtocol {
    
    func getHttpHeaders() -> HTTPHeaders {
        var httpHeaders = HTTPHeaders()
        httpHeaders.add(HTTPHeaderFields.contentType.value)
        return httpHeaders
    }
    
    func getParameterEncoding(by method: HTTPMethod) -> ParameterEncoding {
        switch method {
            case .post, .patch, .put:
                return JSONEncoding.default
            default:
                return URLEncoding.queryString
        }
    }
}
