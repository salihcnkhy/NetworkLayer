//
//  File.swift
//  
//
//  Created by 112471 on 26.01.2022.
//

import Foundation
import Alamofire
import NetworkEntityLayer
import Combine

public final class NetworkManager: NetworkMananagerProtocol {
    
    private var session: Session
    private let decoder = JSONDecoder()
    
    public init(configuration: URLSessionConfiguration, interceptor: RequestInterceptor, eventMonitors: [EventMonitor]) {
        session = Session(configuration: configuration, startRequestsImmediately: true, interceptor: interceptor, eventMonitors: eventMonitors)
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
