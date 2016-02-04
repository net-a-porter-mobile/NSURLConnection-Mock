//
//  NSURLSession+Mock.swift
//  Pods
//
//  Created by Sam Dean on 19/01/2016.
//
//

import Foundation

/**
 Set the debug level on NSURLSession to output all the request that flow through
 this extension.
 
 - None: Don't log any requests
 - Mocked: Only log requests which are mocked
 - All: Log all requests whether they match a mock or not
*/
public enum RequestDebugLevel: Int {
    case None
    case Mocked
    case All
}

extension NSURLSession {
    
    internal static let register = MockRegister()
    
    /**
     The next call exactly matching `request` will successfully return `body`
     
     - parameter request: The request to mock
     - parameter body: The data returned by the session data task. If this is `nil` then the didRecieveData callback won't be called.
     - parameter headers: The headers returned by the session data task
     - parameter statusCode: The status code (default=200) returned by the session data task
     - parameter delay: A artificial delay before the session data task starts to return response and data
     */
    public class func mockSingle(request: NSURLRequest, body: NSData?, headers: [String: String] = [:], statusCode: Int = 200, delay: Double = DefaultDelay) {
        let matcher = SimpleRequestMatcher(url: request.URL!, method: request.HTTPMethod!)
        self.mockSingle(matcher, body: body, headers: headers, statusCode: statusCode, delay: delay)
    }
    
    /**
     All calls exactly matching `request` will successfully return `body`
     
     - parameter request: The request to mock
     - parameter body: The data returned by the session data task. If this is `nil` then the didRecieveData callback won't be called.
     - parameter headers: The headers returned by the session data task
     - parameter statusCode: The status code (default=200) returned by the session data task
     - parameter delay: A artificial delay before the session data task starts to return response and data
     */
    public class func mockEvery(request: NSURLRequest, body: NSData?, headers: [String: String] = [:], statusCode: Int = 200, delay: Double = DefaultDelay) {
        let matcher = SimpleRequestMatcher(url: request.URL!, method: request.HTTPMethod!)
        self.mockEvery(matcher, body: body, headers: headers, statusCode: statusCode, delay: delay)
    }
    
    /**
     The next call matching `expression` will successfully return `body`
     
     - parameter expression: The regular expression to compare incoming requests against
     - parameter HTTPMethod: The method to match against
     - parameter body: The data returned by the session data task. If this is `nil` then the didRecieveData callback won't be called.     
     - parameter headers: The headers returned by the session data task
     - parameter statusCode: The status code (default=200) returned by the session data task
     - parameter delay: A artificial delay before the session data task starts to return response and data
     */
    public class func mockSingle(expression: String, HTTPMethod: String = "GET", body: NSData?, headers: [String: String] = [:], statusCode: Int = 200, delay: Double = DefaultDelay) throws {
        let matcher = try SimpleRequestMatcher(expression: expression, method: HTTPMethod)
        self.mockSingle(matcher, body: body, headers: headers, statusCode: statusCode, delay: delay)
    }
    
    /**
     All subsequent requests matching `expression` will successfully return `body`
     
     - parameter expression: The regular expression to compare incoming requests against
     - parameter HTTPMethod: The method to match against
     - parameter body: The data returned by the session data task. If this is `nil` then the didRecieveData callback won't be called.
     - parameter headers: The headers returned by the session data task
     - parameter statusCode: The status code (default=200) returned by the session data task
     - parameter delay: A artificial delay before the session data task starts to return response and data
     */
    public class func mockEvery(expression: String, HTTPMethod: String = "GET", body: NSData?, headers: [String: String] = [:], statusCode: Int = 200, delay: Double = DefaultDelay) throws {
        let matcher = try SimpleRequestMatcher(expression: expression, method: HTTPMethod)
        self.mockEvery(matcher, body: body, headers: headers, statusCode: statusCode, delay: delay)
    }
    
    /**
     Remove all mocks - NSURLSession will behave as if it had never been touched
     */
    public class func removeAllMocks() {
        self.register.removeAllMocks()
    }
    
    /**
     Remove all mocks matching the given request. All other requests will still
     be mocked
     */
    public class func removeAllMocks(of request: NSURLRequest) {
        self.register.removeAllMocks(of: request)
    }

    
    //MARK: Private methods
    
    // Add a request matcher to the list of mocks
    private class func mockSingle(matcher: RequestMatcher, body: NSData? , headers: [String: String], statusCode: Int, delay: Double) {
        let response = MockResponse(data: body, error: nil, headers: headers, statusCode: statusCode)
        self.register.addMock(SingleSuccessSessionMock(matching: matcher, response: response, delay: delay))
        swizzleIfNeeded()
    }
    
    // Add a request matcher to the list of mocks
    private class func mockEvery(matcher: RequestMatcher, body: NSData? , headers: [String: String], statusCode: Int, delay: Double) {
        let response = MockResponse(data: body, error: nil, headers: headers, statusCode: statusCode)
        self.register.addMock(SuccessSessionMock(matching: matcher, response: response, delay: delay))
        swizzleIfNeeded()
    }
}
