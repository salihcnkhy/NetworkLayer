//
//  File.swift
//  
//
//  Created by 112471 on 9.02.2022.
//

import Foundation

public struct NetworkError<ServerError: Decodable>: Error {
    let data: ServerError?
}
