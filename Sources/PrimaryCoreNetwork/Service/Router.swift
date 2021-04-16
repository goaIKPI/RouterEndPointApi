//
//  NetworkService.swift
//  NetworkLayer
//
//  Created by mac on 23.09.2020.
//  Copyright © 2020 Олег Герман. All rights reserved.
//

import Foundation
import Network

public typealias NetworkRouterCompletionData = (Data?, URLResponse?, Error?)
public typealias NetworkRouterCompletion = (NetworkRouterCompletionData) -> Void

public protocol NetworkRouter: class {
    associatedtype EndPoint: EndPointType
    func request(_ route: EndPoint, isLog: Bool, completion: @escaping NetworkRouterCompletion)
    func cancel()
}

public class Router<EndPoint: EndPointType>: NetworkRouter {
    private var tasks = AtomicArray<URLSessionTask>()
    private var mlock = NSLock()
    let configuration = URLSessionConfiguration.default
    private let delegateOperation = OperationQueue()
    lazy var session = URLSession(configuration: configuration, delegate: nil, delegateQueue: delegateOperation)

    public init() {
        delegateOperation.qualityOfService = .utility
        session = URLSession(configuration: configuration, delegate: nil, delegateQueue: delegateOperation)
    }

    public func request(_ route: EndPoint, isLog: Bool = true, completion: @escaping NetworkRouterCompletion) {
        var task: URLSessionTask?
        do {
            let request = try self.buildRequest(from: route)
            if isLog {
                NetworkLogger.log(request: request)
            }
            task = session.dataTask(with: request, completionHandler: { [weak self] data, response, error in
                guard let self = self,
                      let task = task else { return }
                if (error as NSError?)?.code == -999 { return }
                self.tasks.remove(task)
                completion((data, response, error))
            })
        } catch {
            completion((nil, nil, error))
        }
        if let task = task {
            tasks.append(task)
            task.resume()
        }
    }

    func isRequesting() -> Bool {
        return tasks.isNotEmpty
    }

    public func cancel() {
        self.tasks.cancelAll()
        self.tasks.removeAll()
    }

    fileprivate func buildRequest(from route: EndPoint) throws -> URLRequest {

        var request = URLRequest(url: route.baseURL.appendingPathComponent(route.path),
                                 cachePolicy: .reloadIgnoringLocalAndRemoteCacheData,
                                 timeoutInterval: 20)
        session.configuration.timeoutIntervalForRequest = 20
        session.configuration.timeoutIntervalForResource = 20
        request.httpMethod = route.httpMethod.rawValue
        do {
            switch route.task {
            case .request:
                request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            case .requestParameters(let bodyParameters,
                                    let bodyEncoding,
                                    let urlParameters):

                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)

            case .requestParametersAndHeaders(let bodyParameters,
                                              let bodyEncoding,
                                              let urlParameters,
                                              let additionalHeaders):

                self.addAdditionalHeaders(additionalHeaders, request: &request)
                try self.configureParameters(bodyParameters: bodyParameters,
                                             bodyEncoding: bodyEncoding,
                                             urlParameters: urlParameters,
                                             request: &request)
            }
            return request
        } catch {
            throw error
        }
    }

    fileprivate func configureParameters(bodyParameters: Parameters?,
                                         bodyEncoding: ParameterEncoding,
                                         urlParameters: Parameters?,
                                         request: inout URLRequest) throws {
        do {
            try bodyEncoding.encode(urlRequest: &request,
                                    bodyParameters: bodyParameters, urlParameters: urlParameters)
        } catch {
            throw error
        }
    }

    fileprivate func addAdditionalHeaders(_ additionalHeaders: HTTPHeaders?, request: inout URLRequest) {
        guard let headers = additionalHeaders else { return }
        for (key, value) in headers {
            request.setValue(value, forHTTPHeaderField: key)
        }
    }
}
