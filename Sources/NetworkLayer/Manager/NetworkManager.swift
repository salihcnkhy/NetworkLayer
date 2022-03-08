//
//  File.swift
//  
//
//  Created by 112471 on 26.01.2022.
//

import Alamofire
import Foundation
import Combine

public final class NetworkManager: NetworkMananagerProtocol {
    
    private var session: Session
    private let decoder = JSONDecoder()
    
    public init(configuration: URLSessionConfiguration, interceptor: RequestInterceptor, eventMonitors: [EventMonitor]) {
        session = Session(configuration: configuration, startRequestsImmediately: true, interceptor: interceptor, eventMonitors: eventMonitors)
    }
    
    public func execute<Response: Decodable, ServerError: Decodable>(with urlRequest: URLRequestConvertible) -> ResultPublisher<Response, ServerError> {
        session.request(urlRequest)
            .validate() // If server doesn't return 200-299 will cause failure
            .publishResponse(using: .data)
            .flatMap { response -> AnyPublisher<NetworkResponse<Response, ServerError>, Never> in
                let result = response.result
                return result
                    .publisher
                    .decode(type: Response.self, decoder: self.decoder) // check for success case at first
                    .compactMap { return NetworkResponse<Response,ServerError>(data: $0, networkError: nil) } // if ok compactMap
                    .catch { error in // if decode has error
                        result
                            .publisher
                            .decode(type: ServerError.self, decoder: self.decoder) // try to decode ServerError Type
                            .compactMap { NetworkResponse<Response,ServerError>(data: nil, networkError: NetworkError(data: $0)) } // if ok compactMap
                            .catch { afError in // catch error and it'll be a AFError
                                ResultResponse<Response,ServerError>.success(NetworkResponse<Response,ServerError>(data: nil, networkError: nil)).publisher
                            }
                            .eraseToAnyPublisher()
                    }.eraseToAnyPublisher()
            }.eraseToAnyPublisher()
    }
    
    public func execute<Response: Decodable, ServerError: Decodable>(with urlRequest: URLRequestConvertible) -> AnyPublisher<(Response?, ServerError?), Error> {
        let dataPublisher = session.request(urlRequest)
            .validate() // If server doesn't return 200-299 will cause failure
            .publishResponse(using: .data)
            .compactMap { $0.data }
            .eraseToAnyPublisher()
        
        let responsePublisher = dataPublisher
            .decode(type: Response?.self, decoder: decoder)
            .print("LOG Response")
            .tryCatch { error -> Just<Response?> in
                if error is Swift.DecodingError {
                    return .init(nil)
                } else {
                    throw error
                }
            }
            .eraseToAnyPublisher()
        
        let serverErrorPublisher = dataPublisher
            .decode(type: ServerError?.self, decoder: decoder)
            .print("LOG ServerErrorResponse")
            .eraseToAnyPublisher()
            .tryCatch { error -> Just<ServerError?> in
                if error is Swift.DecodingError {
                    return .init(nil)
                } else {
                    throw error
                }
            }
            .eraseToAnyPublisher()
        
        return responsePublisher
            .zip(serverErrorPublisher)
            .eraseToAnyPublisher()
    }
}
