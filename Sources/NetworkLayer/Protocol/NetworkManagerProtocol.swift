//
//  NetworkManagerProtocol.swift
//  
//
//  Created by Salihcan Kahya on 9.02.2022.
//

import Combine
import Alamofire

public protocol NetworkMananagerProtocol {
    typealias ResultPublisher<T: Decodable, S: Decodable> = AnyPublisher<NetworkResponse<T,S>, Never>
    typealias ResultResponse<T: Decodable, S: Decodable> = Result<NetworkResponse<T,S>, Never>
    
    func execute<Response: Decodable, ServerError: Decodable>(with urlRequest: URLRequestConvertible) -> ResultPublisher<Response, ServerError>
    func execute<Response: Decodable, ServerError: Decodable>(with urlRequest: URLRequestConvertible) -> AnyPublisher<(Response?, ServerError?), Error>
}
