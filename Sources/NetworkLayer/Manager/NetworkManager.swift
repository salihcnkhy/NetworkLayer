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
    
    public func execute<Response: Decodable, ServerError: ServerErrorProtocol>(with urlRequest: URLRequestConvertible) -> AnyPublisher<Response, ServerError> {
        session.request(urlRequest)
            .validate()
            .publishData()
            .compactMap { $0.result }
            .tryMap { (result: Result<Data, AFError>) -> Response in
                switch result {
                    case .success(let data):
                        if let response = try? self.decoder.decode(Response.self, from: data) {
                            return response
                        } else if let serverError = try? self.decoder.decode(ServerError.self, from: data) {
                            throw serverError
                        } else {
                            throw ServerError.init(description: "unexpected")
                        }
                    case .failure(let failure):
                        let error = ServerError.init(description: failure.localizedDescription)
                        throw error
                }
            }
            .mapError { $0 as! ServerError }
            .eraseToAnyPublisher()
    }
}

public protocol ServerErrorProtocol: Decodable, Error {
    var description: String? { get set }
    init(description: String?)
}
