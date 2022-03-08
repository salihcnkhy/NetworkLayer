//
//  HttpPropertyProviderProtocol.swift
//  
//
//  Created by Salihcan Kahya on 9.02.2022.
//

import Alamofire
import Foundation

public protocol HttpPropertyProviderProtocol {
    func getBaseUrl() -> String
    /// use for query params after path like hashed api key etc.
    func getDefaultQueryParams() -> [URLQueryItem]?
    func getHttpHeaders() -> HTTPHeaders
    func getParameterEncoding(by method: HTTPMethod) -> ParameterEncoding
}

public extension HttpPropertyProviderProtocol {
    
    func getDefaultQueryParams() -> [URLQueryItem]? {
        nil
    }
    
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
