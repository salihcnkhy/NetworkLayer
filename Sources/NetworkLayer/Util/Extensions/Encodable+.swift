//
//  Encodable+.swift
//  
//
//  Created by Salihcan Kahya on 9.02.2022.
//

import Alamofire
import Foundation

public extension Encodable {
    func asDictionary(with dateFormatter: DateFormatter = DateFormatter()) -> Parameters {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .formatted(dateFormatter)
            let data = try encoder.encode(self)
            return try JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] ?? [:]
        } catch {
            return [:]
        }
    }
    
    var jsonData: Data? {
        let encoder = JSONEncoder()
        return try? encoder.encode(self)
    }
    
    var jsonString: String? {
        guard let data = self.jsonData else { return nil }
        return String(data: data, encoding: .utf8)
    }
    
    func toJson() -> Data? {
        return try? JSONEncoder().encode(self)
    }
    
}
