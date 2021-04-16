//
//  NetworkRequestError.swift
//  RCDataManager
//
//  Created by mac on 08.10.2020.
// 
import Foundation

public struct NetworkRequestError: Error {
    public init(title: String = NSLocalizedString("NetworkRequestError.title", comment: "error"), type: NetworkRequestError.RequestErrorType = .any) {
        self.title = title
        self.type = type
    }

    public var title: String = NSLocalizedString("NetworkRequestError.title", comment: "error")
    public var type: RequestErrorType = .any
    public enum RequestErrorType {
        case nonconnetion
        case any
    }
}

public protocol ErrorRequest {
    var title: String { get set }
    var message: String { get set }
}

public struct ErrorRequestNetwork: ErrorRequest {
    public init(title: String, message: String = "", code: String = "200") {
        self.title = title
        self.message = message
        self.code = code
    }

    public var title: String
    public var message: String
    public var code: String
}

public struct ErrorRequestLocal: ErrorRequest {
    public var title: String
    public var message: String
    public  var type: ErrorRequestLocalType

    public enum ErrorRequestLocalType {
        case timeout
        case nonconnection
        case errorParser
        case badRequest
        case any
    }
}

