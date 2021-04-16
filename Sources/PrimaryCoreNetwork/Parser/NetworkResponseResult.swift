//
//  NetworkResponseString.swift
//  RCDataManager
//
//  Created by mac on 08.10.2020.
// 
import Foundation

public enum NetworkResponseResult<String> {
    case success
    case failure(String)
}

public enum NetworkResponseErrorString: String {
    case success
    case authenticationError = ""
    case badRequest = "Bad request"
    case outdated = "The url you requested is outdated."
    case failed = "Network request failed."
    case noData = "Response returned with no data to decode."
    case unableToDecode = "We could not decode the response."
    case userNotFound = "Пользователь не найден"
}
