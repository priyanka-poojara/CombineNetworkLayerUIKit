//
//  NetworkLogs.swift
//  NetworkCall
//
//  Created by Priyanka on 02/09/23.
//

import Foundation

public class PNetworkLogs {
    
    public struct PLogs{
        var url : String?
        var time : Date?
        var statusCode : Int?
        var parameters : [String : Any]?
        var headers : [AnyHashable : Any]?
        var response : [String : Any]?
        var message : String?
        var httpMethod : String
        var fullResponse : URLResponse?
        var request : URLRequest?
        var fullData : String
    }
    /// Shared Object to access the Functions of PNetworkLogs
    public static let shared = PNetworkLogs()
    
    private var Logs = [PLogs]()
    
    /// This Variable Defines the Logging of request after it's Reconfiguration
    public var logging : Log = Log(logRequest: false, logResponse: false)
    
    /// This Function will be used in main codeBase to Log the Requests and Responses
    /// # WARNING : DO NOT MESS WITH THIS FUCNTION ONLY MADE TO BE USED IN THE MAIN CODEBASE
    public func setLog(url : String?, statusCode : Int?, parameters : [String:Any]?, headers : [String:String]?, response : [String:Any]?, message : String?, Method : String, urlResponse : URLResponse?, responseData : Data?, request : URLRequest?) {
        
        if logging.request == true{
            
            if logging.response == true{
                
                var responseDataString : String{
                    
                    if let responseData = responseData{
                        return String(data: responseData, encoding: .utf8) ?? "nil"
                    }else{
                        return "nil"
                    }
                    
                }
                
                Logs.append(PLogs(url: url, time: Date(), statusCode: statusCode, parameters: parameters, headers: headers, response: response, message: message, httpMethod: Method, fullResponse: urlResponse, request: request, fullData:responseDataString))
                
            }else{
                Logs.append(PLogs(url: url, time: Date(), statusCode: statusCode, parameters: parameters, headers: headers, response: nil, message: message, httpMethod: Method, fullResponse: nil, request: request, fullData: "nil"))
            }
        }
        
    }
    
    /// This Function Will print all the logged Requests and Responses
    /// - parameter filterByUrl : provide a url string to filter the result by the url
    /// - parameter filterByStatusCode : provide a HTTP Status code  to filter the result by the HTTP Status Code
    public func PrintNetworkLogs(filterByUrl : String? = nil, filterByStatusCode : Int? = nil, printFullResponse : Bool = true){
        
        if Logs.count <= 0{
            return
        }
        
        var logtoReturn = [PLogs]()
        
        if filterByUrl != nil || filterByStatusCode != nil{
            
            if let furl = filterByUrl{
                logtoReturn = Logs.filter { (log) -> Bool in
                    return log.url == furl
                }
            }
            
            if let fStatsus = filterByStatusCode{
                logtoReturn = Logs.filter { (log) -> Bool in
                    return log.statusCode == fStatsus
                }
            }
            
        }else{
            
            logtoReturn = Logs
            
        }
        
        print("--------PCombineNetworkServices----------")
        print("--------NETWORK LOG(S)----------")
        print("--------BEGIN-------\n")
        for L in 0...logtoReturn.count - 1{
            
            let Log = logtoReturn[L]
            print("------------------------")
            print("Log ID : \(L+1)")
            print("------------------------")
            print("URL : \(Log.url ?? "not found")")
            print("Method : \(Log.httpMethod)")
            print("statusCode : \(String(Log.statusCode ?? 0))")
            if Log.parameters != nil{
                print("Parameters : \(Log.parameters!)")
            }
            if Log.headers != nil{
                print("Headers : \(Log.headers!)")
            }
            if Log.response != nil{
                print("Response : \(Log.response!)")
            }
            if Log.message != nil{
                print("Message : \(Log.message!)")
            }
            if Log.time != nil{
                print("Log Time : \(Log.time!)")
            }
           
            print("Full Response Data Body: \(Log.fullData)")
            
            if Log.fullResponse != nil && printFullResponse == true{
                print("Full Response : \(Log.fullResponse!)")
            }
            
            if let request = Log.request{
                print("\n************************")
                print("cURL : ")
                print(cURL(urlRequest: request, pretty: true))
                print("************************\n")
            }
        }
        print("--------END-------")
        print("\n--------NETWORK LOG(S)----------")

    }
    
    func cURL(urlRequest : URLRequest, pretty: Bool = false) -> String {
        let newLine = pretty ? "\\\n" : ""
        let method = (pretty ? "--request " : "-X ") + "\(urlRequest.httpMethod ?? "GET") \(newLine)"
        let url: String = (pretty ? "--url " : "") + "\'\(urlRequest.url?.absoluteString ?? "")\' \(newLine)"
        var cURL = "curl "
        var header = ""
        var data: String = ""
        if let httpHeaders = urlRequest.allHTTPHeaderFields, httpHeaders.keys.count > 0 {
            for (key,value) in httpHeaders {
                header += (pretty ? "--header " : "-H ") + "\'\(key): \(value)\' \(newLine)"
            }
        }
        if let bodyData = urlRequest.httpBody, let bodyString = String(data: bodyData, encoding: .utf8),  !bodyString.isEmpty {
            data = "--data '\(bodyString)'"
        }
        cURL += method + url + header + data
        return cURL
    }
    
}
