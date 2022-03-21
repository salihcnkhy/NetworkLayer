//
//  NetworkManagerProtocol.swift
//  
//
//  Created by Salihcan Kahya on 9.02.2022.
//

import Alamofire
import Combine
import Foundation
import NetworkEntityLayer

public protocol NetworkMananagerProtocol {
    func execute<Response: Decodable, ServerError: ServerErrorProtocol>(with urlRequest: URLRequestConvertible) -> AnyPublisher<Response, ServerError>
    func execute(with urlRequest: URLRequestConvertible) -> AnyPublisher<Data, Error>
}
