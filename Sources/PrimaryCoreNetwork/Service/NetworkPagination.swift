//
//  NetworkPagination.swift
//  RC.Pay
//
//  Created by mac on 02.03.2021.
//  Copyright © 2021 Олег Герман. All rights reserved.
//

import Foundation

struct NetworkPagination: Codable {
    let totalItems, currentPage: Int
    let hasMorePages, hasPages: Bool
    let lastPage, perPage: Int
}
