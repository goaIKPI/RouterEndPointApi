//
//  EndPoint.swift
//  NetworkLayer
//
//  Created by mac on 23.09.2020.
//  Copyright © 2020 Олег Герман. All rights reserved.
//

import Foundation

public protocol EndPointType {
    var environmentBaseURL: String { get }
    var baseURL: URL { get }
    var path: String { get }
    var httpMethod: HTTPMethod { get }
    var task: HTTPTask { get }
    var headers: HTTPHeaders? { get }
}

public protocol EndPointTypeNew: EndPointType {
    var environment: NetworkEnvironment { get }
    var apiKey: String { get set }
}
