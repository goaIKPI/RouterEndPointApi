//
//  NetworkResponse.swift
//  RCDataManager
//
//  Created by mac on 08.10.2020.
// 
import Foundation

public protocol NetworkResponse: Codable {
    associatedtype U: Codable
    var data: U { get set }
    var error: Bool? { get set }
    var code: Int? { get set }
    var message: String? { get set }
}

public struct NetworkResponseDefault<T: Codable>: NetworkResponse {
    public var data: T
    public var error: Bool?
    public var code: Int?
    public var message: String?
}

