//
//  File.swift
//  
//
//  Created by 112471 on 9.02.2022.
//

import Foundation

public struct NetworkResponse<Response: Decodable, ServerError: Decodable> {
    let data: Response?
    let networkError: NetworkError<ServerError>?
}
