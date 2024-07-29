//
//  ApiError.swift
//  API-CALL-DEMO
//
//  Created by Rajat Suman on 29/07/24.
//

import Foundation

enum APIError: Error {
    case invalidURL
    case noData
    case decodingError(String)
    case networkError(String)
}
