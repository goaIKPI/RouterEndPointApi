//
//  HTTPTask.swift
//  NetworkLayer
//
//  Created by mac on 23.09.2020.
//  Copyright © 2020 Олег Герман. All rights reserved.
//

import Foundation

public typealias HTTPHeaders = [String: String]

public enum HTTPTask {
    case request

    case requestParameters(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?)

    case requestParametersAndHeaders(bodyParameters: Parameters?,
        bodyEncoding: ParameterEncoding,
        urlParameters: Parameters?,
        additionHeaders: HTTPHeaders?)
}
