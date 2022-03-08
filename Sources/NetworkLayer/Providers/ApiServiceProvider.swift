//
//  ApiServiceProvider.swift
//  
//
//  Created by Salihcan Kahya on 9.02.2022.
//

import Alamofire
import Foundation

open class ApiServiceProvider: URLRequestConvertible {
    
    private let baseUrl: String
    private let method: HTTPMethod
    private var path: String?
    private var isAuthRequested: Bool
    private var data: Encodable?
    private let httpPropertyProvider: HttpPropertyProviderProtocol
    
    /// Description: General Api call service provider. It's create a urlRequestConvertible object to pass as an argument to alamofire url session request
    /// - Parameters:
    ///   - method: http methods, default value is get
    ///   - path: url path, default value is nil
    ///   - isAuthRequested: it's used to pass accessToken to header or not. Default value is true
    ///   - data: Codable data. If request is post, patch or put it's used as body otherwise as query string
    public init(baseUrl: String, method: HTTPMethod = .get, path: String? = nil, httpPropertyProvider: HttpPropertyProviderProtocol, isAuthRequested: Bool = true, data: Encodable? = nil) {
        self.baseUrl = baseUrl
        self.method = method
        self.path = path
        self.isAuthRequested = isAuthRequested
        self.data = data
        self.httpPropertyProvider = httpPropertyProvider
    }
    
    public func asURLRequest() throws -> URLRequest {
        var url = try baseUrl.asURL()
        
        if let path = path {
            url = url.appendingPathComponent(path)
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = method.rawValue
        request.headers = headers
        request.cachePolicy = .reloadIgnoringCacheData
        
        return try encoding.encode(request, with: params)
    }
    
    // MARK: - Encoding -
    private var encoding: ParameterEncoding {
        httpPropertyProvider.getParameterEncoding(by: method)
    }
    
    private var params: Parameters? {
        return data?.asDictionary()
    }
    
    private var headers: HTTPHeaders {
        httpPropertyProvider.getHttpHeaders()
    }
}
