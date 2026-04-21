//
//  PokeAPIError.swift
//  PokeGuessr
//
//  Created by Sébastien Hannay on 20/04/2026.
//


enum PokeAPIError: Error {
    case invalidURL(String)
    case requestFailed(statusCode: Int)
    case decodingFailed(Error)
    case networkError(Error)
    case missingData(String)
}