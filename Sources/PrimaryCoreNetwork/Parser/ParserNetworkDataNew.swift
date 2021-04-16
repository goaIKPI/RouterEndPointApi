//
//  ParserNetworkData.swift
//  RCDataManager
//
//  Created by mac on 03.11.2020.
//

import Foundation
import SwiftyJSON
import Network

public func handleNetworkResponse(_ response: HTTPURLResponse) -> NetworkResponseResult<String> {
    switch response.statusCode {
    case 200...299: return .success
    case 404: return .failure(NetworkResponseErrorString.userNotFound.rawValue)
    case 307: return .success
    case 401...500: return .failure(NetworkResponseErrorString.authenticationError.rawValue)
    case 501...599: return .failure(NetworkResponseErrorString.badRequest.rawValue)
    case 600: return .failure(NetworkResponseErrorString.outdated.rawValue)
    default: return .failure(NetworkResponseErrorString.failed.rawValue)
    }
}

public struct ParserNetworkResponseData<T: NetworkResponse> {
    public init(decodableStruct: T.Type, completionRequest: CompletionRequest, resultHandler: @escaping ResultRequest<T.U>) {
        self.decodableStruct = decodableStruct
        self.completionRequest = completionRequest
        self.resultHandler = resultHandler
    }

    public var decodableStruct: T.Type
    public var completionRequest: CompletionRequest
    public var resultHandler: ResultRequest<T.U>
}

public struct ParserCodableData<T> {
    public init(decodableStruct: T.Type, completionRequest: CompletionRequest, resultHandler: @escaping ResultRequest<T>) {
        self.decodableStruct = decodableStruct
        self.completionRequest = completionRequest
        self.resultHandler = resultHandler
    }

    public var decodableStruct: T.Type
    public var completionRequest: CompletionRequest
    public var resultHandler: ResultRequest<T>
}

public class ParserNetworkData {
    public init() { }
    public func parseRequestNetworkResponse<T: NetworkResponse>(data: ParserNetworkResponseData<T>) {
        parse(decodableStruct: data.decodableStruct, completionRequest: data.completionRequest) { result in
            switch result {
            case .success(let response):
                data.resultHandler(.success(response.data))
            case .errorLocal(let error):
                data.resultHandler(.errorLocal(error: error))
            case .errorNetwork(let error):
                data.resultHandler(.errorNetwork(error: error))
            }
        }
    }

    public func parseStruct<T: Codable>(data: ParserCodableData<T>) {
        parse(decodableStruct: data.decodableStruct, completionRequest: data.completionRequest,
              resultHandler: data.resultHandler)
    }
}

private extension ParserNetworkData {

    func printWarningJSON(data: Data?, error: Error?, code: Int = 0) {
        let data = String(data: data ?? Data(), encoding: String.Encoding.utf8) ?? ""
        let debugError = "Data: \(data) \n Error: \(String(describing: error?.localizedDescription)) \n Code: \(code)"
        Logger.error(debugError)
    }

    func getQueryStringParameter(url: String, param: String) -> String? {
        guard let url = URLComponents(string: url) else { return nil }
        return url.queryItems?.first(where: { $0.name == param })?.value
    }
}

private extension ParserNetworkData {
    func parse<T: Codable>(decodableStruct: T.Type,
                           completionRequest: CompletionRequest,
                           resultHandler: @escaping ResultRequest<T>) {
        let decodeStruct = decodableStruct
        let completionRequest = completionRequest
        let resultHandler = resultHandler
        let error = completionRequest.error
        let response = completionRequest.response
        let data = completionRequest.data

        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase

        localError(decodableStruct: decodeStruct, completionRequest: completionRequest, resultHandler: resultHandler)

        if let response = response as? HTTPURLResponse {
            let result = handleNetworkResponse(response)
            switch result {
            case .success:
                guard let responseData = data else {
                    resultHandler(.errorLocal(error: ErrorRequestLocal(title:
                                                                        NetworkResponseErrorString.noData.rawValue,
                                                                       message: error?.localizedDescription ?? "",
                                                                       type: .any)))
                    return
                }
                do {
                    if let jsonData = try JSONSerialization.jsonObject(with: responseData, options: []) as? [String: Any] {
                        Logger.debugString("RESPONSE: " + String(describing: jsonData))
                    }
                    
                    let apiResponse = try jsonDecoder.decode(decodeStruct.self, from: responseData)
                    resultHandler(.success(apiResponse))
                } catch DecodingError.keyNotFound(let key, let context) {
                    Swift.print("could not find key \(key) in JSON: \(context.debugDescription)")
                    if let data = data {
                        printWarningJSON(data: data, error: error)
                    }
                    resultHandler(.errorLocal(error: ErrorRequestLocal(title: "Ошибка парсера",
                                                                       message: error?.localizedDescription ?? "",
                                                                       type: .errorParser)))
                } catch DecodingError.valueNotFound(let type, let context) {
                    Swift.print("could not find type \(type) in JSON: \(context.debugDescription)")
                    if let data = data {
                        printWarningJSON(data: data, error: error)
                    }
                    resultHandler(.errorLocal(error: ErrorRequestLocal(title: "Ошибка парсера",
                                                                       message: error?.localizedDescription ?? "",
                                                                       type: .errorParser)))
                } catch DecodingError.typeMismatch(let type, let context) {
                    Swift.print("type mismatch for type \(type) in JSON: \(context.debugDescription)")
                    if let data = data {
                        printWarningJSON(data: data, error: error)
                    }
                    resultHandler(.errorLocal(error: ErrorRequestLocal(title: "Ошибка парсера",
                                                                       message: error?.localizedDescription ?? "",
                                                                       type: .errorParser)))
                } catch DecodingError.dataCorrupted(let context) {
                    Swift.print("data found to be corrupted in JSON: \(context.debugDescription)")
                    if let data = data {
                        printWarningJSON(data: data, error: error)
                    }
                    resultHandler(.errorLocal(error: ErrorRequestLocal(title: "Ошибка парсера",
                                                                       message: error?.localizedDescription ?? "",
                                                                       type: .errorParser)))
                } catch let error as NSError {
                    NSLog("Error in read(from:ofType:) domain= \(error.domain), description= \(error.localizedDescription)")
                    if let data = data {
                        printWarningJSON(data: data, error: error)
                    }
                    resultHandler(.errorLocal(error: ErrorRequestLocal(title: "Ошибка парсера",
                                                                       message: error.localizedDescription,
                                                                       type: .errorParser)))
                } catch let error {
                    if let data = data {
                        printWarningJSON(data: data, error: error)
                    }
                    resultHandler(.errorLocal(error: ErrorRequestLocal(title: "Ошибка парсера",
                                                                       message: error.localizedDescription,
                                                                       type: .errorParser)))
                }
            case .failure(let networkFailureError):
                printWarningJSON(data: data, error: error, code: response.statusCode)
                guard let responseData = data else {
                    let error = ErrorRequestNetwork(title: networkFailureError,
                                                    message: error?.localizedDescription ?? "",
                                                    code: "\(response.statusCode)")
                    resultHandler(.errorNetwork(error: error))
                    return
                }
                let json = try? JSON(data: responseData)
                let error = ErrorRequestNetwork(title: json?["message"].string ?? networkFailureError,
                                                message: error?.localizedDescription ?? networkFailureError,
                                                code: "\(response.statusCode)")
                resultHandler(.errorNetwork(error: error))
            }
        }
    }

    func localError<T: Codable>(decodableStruct: T.Type,
                                completionRequest: CompletionRequest,
                                resultHandler: @escaping ResultRequest<T>) {
        guard let reachability = try? Reachability() else { return }

        if reachability.connection == .unavailable {
            resultHandler(.errorLocal(error: ErrorRequestLocal(title: "Нет соединения",
                                                               message: "Попробовать снова",
                                                               type: .nonconnection)))
            return
        }

        if let error = completionRequest.error {
            var titleError: String = "Local error"
            var typeError: ErrorRequestLocal.ErrorRequestLocalType = .any

            if error._code == NSURLErrorTimedOut {
                titleError = NetworkResponseErrorString.outdated.rawValue
                typeError = .timeout
            }

            if error._code == NSURLErrorUnknown {
                titleError = NetworkResponseErrorString.failed.rawValue
                typeError = .any
            }

            if error._code == NSURLErrorBadURL {
                titleError = NetworkResponseErrorString.badRequest.rawValue
                typeError = .badRequest
            }

            resultHandler(.errorLocal(error: ErrorRequestLocal(title: titleError,
                                                               message: error.localizedDescription,
                                                               type: typeError)))

        }
    }
}
