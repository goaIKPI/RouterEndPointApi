//
//  CompletionRequest.swift
//  RCDataManager
//
//  Created by mac on 08.10.2020.
// 
import Foundation

public struct CompletionRequest {
    public init(data: Data? = nil, response: URLResponse? = nil, error: Error? = nil) {
        self.data = data
        self.response = response
        self.error = error
    }

    public var data: Data?
    public var response: URLResponse?
    public var error: Error?
}
