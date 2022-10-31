//
//  File.swift
//  
//
//  Created by ned on 31/10/22.
//

import Foundation

public enum API {

   public static let baseUrl = URL(string: "https://edoardo.fyi")!
   public static let baseImageUrl: String = "\(baseUrl)/img/"

   public enum Method: String {
      case GET, POST, PUT, PATCH, DELETE
   }

   public enum Endpoint {
      case data

      var path: String {
         switch self {
         case .data: return "/data.json"
         }
      }
   }

   static func generateRequest(_ method: Method, _ endpoint: Endpoint) -> URLRequest {
      var request = URLRequest(url: baseUrl.appendingPathComponent(endpoint.path))
      request.httpMethod = method.rawValue
      request.addValue("ned", forHTTPHeaderField: "User-Agent")
      return request
   }
}
