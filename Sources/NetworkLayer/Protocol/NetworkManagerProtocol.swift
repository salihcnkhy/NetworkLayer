//
//  NetworkManagerProtocol.swift
//  
//
//  Created by Salihcan Kahya on 9.02.2022.
//

import Combine
import Alamofire
import NetworkEntityLayer

public protocol NetworkMananagerProtocol {
    func execute<Response: Decodable, ServerError: ServerErrorProtocol>(with urlRequest: URLRequestConvertible) -> AnyPublisher<Response, ServerError>
}
