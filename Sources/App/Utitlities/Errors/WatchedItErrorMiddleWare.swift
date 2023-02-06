//
//  File.swift
//  
//
//  Created by Joe Maghzal on 04/02/2023.
//

import Fluent
import Vapor

class WatchedItErrorMiddleWare: AsyncMiddleware {
    func respond(to request: Request, chainingTo next: AsyncResponder) async throws -> Response {
        do {
            let response = try await next.respond(to: request)
            return response
        }catch {
            if let error = error as? WatchedItError {
                return try await SendableResponse<EmptyData>.error(error).encodeResponse(for: request)
            }else if let error = error as? AbortError {
                return try await SendableResponse<EmptyData>.error(error).encodeResponse(for: request)
            }
            return try await SendableResponse<EmptyData>.error(error).encodeResponse(for: request)
        }
    }
}
