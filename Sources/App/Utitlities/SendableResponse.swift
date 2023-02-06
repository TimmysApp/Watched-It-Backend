//
//  File.swift
//  
//
//  Created by Joe Maghzal on 04/02/2023.
//

import Vapor
import Fluent

struct SendableResponse<T: Content> {
    //MARK: - Properties
    var status: HTTPStatus
    var headers = HTTPHeaders.defaultHeaders
    var visible: BaseResponse<T>
}

//MARK: - Functions
extension SendableResponse {
    static func error(_ error: WatchedItError?) -> SendableResponse<T> {
        return SendableResponse(status: error?.status ?? .notFound, visible: .error(error))
    }
    static func error(_ error: AbortError?) -> SendableResponse<T> {
        return SendableResponse(status: error?.status ?? .notFound, visible: .error(error))
    }
    static func error(_ error: Error?) -> SendableResponse<T> {
        return SendableResponse(status: .notFound, visible: .error(error))
    }
}

//MARK: - AsyncResponseEncodable
extension SendableResponse: AsyncResponseEncodable {
    func encodeResponse(for request: Request) async throws -> Response {
        let encoder = JSONEncoder()
        if visible.error {
            return Response(status: status, version: .http1_1, headers: headers, body: .init(data: try encoder.encode(visible)))
        }
        return Response(status: status, version: .http1_1, headers: headers, body: .init(data: try encoder.encode(visible.data)))
    }
}

struct BaseResponse<T: Content>: Content {
    //MARK: - Properties
    var error: Bool
    var message: String?
    var summary: String?
    var data: T?
}

//MARK: - Functions
extension BaseResponse {
    static func error(_ error: WatchedItError?) -> BaseResponse<T> {
        return BaseResponse(error: true, message: error?.reason, summary: error?.description, data: nil)
    }
    static func error(_ error: AbortError?) -> BaseResponse<T> {
        return BaseResponse(error: true, message: error?.reason, summary: nil, data: nil)
    }
    static func error(_ error: Error?) -> BaseResponse<T> {
        return BaseResponse(error: true, message: error?.localizedDescription, summary: nil, data: nil)
    }
    static func success(_ data: T) -> BaseResponse<T> {
        return BaseResponse(error: false, message: nil, summary: nil, data: data)
    }
    static func success() -> BaseResponse<T> {
        return BaseResponse(error: false, message: nil, summary: nil, data: nil)
    }
}

struct EmptyBody: Content {
}
