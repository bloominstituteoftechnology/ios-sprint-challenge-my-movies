//
//  NetworkService.swift
//  MyMovies
//
//  Created by Kenny on 1/31/20.
//  Copyright © 2020 Lambda School. All rights reserved.
//

import Foundation

class NetworkService {
    
    enum HttpMethod: String {
        case get = "GET"
        case post = "POST"
        case put = "PUT"
        case delete = "DELETE"
    }
    
    /**
     used when the endpoint requires a header-type (i.e. "content-type") be specified in the header
     */
    enum HttpHeaderType: String {
        case contentType = "Content-Type"
    }
    /**
     the value of the header-type (i.e. "application/json")
     */
    enum HttpHeaderValue: String {
        case json = "application/json"
    }
    
    /**
     - parameter request: should return nil if there's an error or a valid request object if there isn't
     - parameter error: should return nil if the request succeeded and a valid error if it didn't
     */
    struct EncodingStatus {
        let request: URLRequest?
        let error: Error?
    }
    
    /**
     Create a request given a URL and HTTP Request Method
     - parameter url: the endpoint's URL
     - parameter method: GET, POST, CREATE, etc...
     - parameter headerType: used when the endpoint requires a header-type (i.e. "content-type") be specified in the header
     - parameter headerValue: the value of the header-type (i.e. "application/json")
     */
    class func createRequest(url: URL?, method: HttpMethod, headerType: HttpHeaderType? = nil, headerValue: HttpHeaderValue? = nil) -> URLRequest? {
        guard let requestUrl = url else {
            NSLog("request URL is nil")
            return nil
        }
        var request = URLRequest(url: requestUrl)
        request.httpMethod = method.rawValue
        if let headerType = headerType,
            let headerValue = headerValue {
            request.setValue(headerValue.rawValue, forHTTPHeaderField: headerType.rawValue)
        }
        return request
    }
    
    /**
     Encode from a Swift object to JSON for transmitting to an endpoint and returns an EncodingStatus object which should either contain an error and nil request or request and nil error
     
     NOTE: The type to be encoded MUST be defined in this function, or the app will crash
     
     - parameter type: the type to be encoded (i.e. MyCustomType.self)
     - parameter request: the URLRequest used to transmit the encoded result to the remote server
     
     */
    class func encode(from type: Any?, request: URLRequest) -> EncodingStatus {
        var localRequest = request
        let jsonEncoder = JSONEncoder()
        do {
            switch type {
            case is MovieRepresentation:
                localRequest.httpBody = try jsonEncoder.encode(type as? MovieRepresentation)
            default: fatalError("\(String(describing: type)) is not defined locally in encode function")
            }
        } catch {
            print("Error encoding object into JSON \(error)")
            return EncodingStatus(request: nil, error: error)
        }
        return EncodingStatus(request: localRequest, error: nil)
    }
    
    /**
     Decode a JSON data object to a Swift Object (i.e. MyCustomType) **NOTE: DEFINE YOUR OWN OPTIONAL RETURN TYPE**
     
     NOTE: The type to be decoded MUST be defined in this function, or the app will crash
     
     - parameter type: the type to be decoded to (i.e. MyCustomType.self)
     - parameter data: the JSON data to be decoded
     */
    class func decode(to type: Any?, data: Data) -> [String:MovieRepresentation]? {
        let decoder = JSONDecoder()
        
        do {
            switch type {
            case is [String:MovieRepresentation].Type:
                let entries = try decoder.decode([String:MovieRepresentation].self, from: data)
                return entries
            default: fatalError("type \(String(describing: type)) is not defined locally in decode function")
            }
        } catch {
            print("Error Decoding JSON into \(String(describing: type)) Object \(error)")
            return nil
        }
    }
}

