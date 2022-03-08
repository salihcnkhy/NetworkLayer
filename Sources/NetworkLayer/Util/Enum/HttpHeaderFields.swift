//
//  File.swift
//  
//
//  Created by Salihcan Kahya on 9.02.2022.
//

import Alamofire

public enum HTTPHeaderFields {
    case contentType
    
    public var value: HTTPHeader {
        switch self {
            case .contentType:
                return HTTPHeader(name: "Content-Type", value: "application/json; charset=utf-8")
        }
    }
}
