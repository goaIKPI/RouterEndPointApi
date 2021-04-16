//
//  ResultRequest.swift
//  RC.Pay
//
//  Created by mac on 23.11.2020.
//  Copyright © 2020 Олег Герман. All rights reserved.
//

import Foundation

public typealias ResultRequest<T> = (ResultRequestCase<T>) -> Void

public enum ResultRequestCase<T> {
    case success(_ data: T)
    case errorNetwork(error: ErrorRequestNetwork)
    case errorLocal(error: ErrorRequestLocal)
}
