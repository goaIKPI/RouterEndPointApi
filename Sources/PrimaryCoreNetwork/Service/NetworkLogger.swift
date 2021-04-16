//
//  NetworkLogger.swift
//  NetworkLayer
//
//  Created by mac on 23.09.2020.
//  Copyright © 2020 Олег Герман. All rights reserved.
//

import Foundation

class NetworkLogger {
    static func log(request: URLRequest) {
        print("\n - - - - - - - - - - OUTGOING - - - - - - - - - - \n")
        defer { print("\n - - - - - - - - - -  END - - - - - - - - - - \n") }

        let urlAsString = request.url?.absoluteString ?? ""
        let urlComponents = NSURLComponents(string: urlAsString)

        let method = request.httpMethod != nil ? "\(request.httpMethod ?? "")" : ""
        let path = "\(urlComponents?.path ?? "")"
        let query = "\(urlComponents?.query ?? "")"
        let host = "\(urlComponents?.host ?? "")"

        var logOutput = """
                        \(urlAsString) \n\n
                        \(method) \(path)?\(query) HTTP/1.1 \n
                        HOST: \(host)\n
                        """
        for (key, value) in request.allHTTPHeaderFields ?? [:] {
            logOutput += "\(key): \(value) \n"
        }
        if let body = request.httpBody {
            logOutput += "\n \(NSString(data: body, encoding: String.Encoding.utf8.rawValue) ?? "")"
        }

        if let cookies = readCookie(forURL: request.url) {
            logOutput += "\n \(cookies)"
        }

        Logger.debug(logOutput)
    }

    static func readCookie(forURL url: URL?) -> [HTTPCookie]? {
        guard let url = url else { return nil }
        let cookieStorage = HTTPCookieStorage.shared
        let cookies = cookieStorage.cookies(for: url) ?? nil
        return cookies
    }

    static func log(response: URLResponse) {}
}
