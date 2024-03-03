//
//  NetworkService+URLBuilder.swift
//  NetworkCall
//
//  Created by Priyanka on 02/09/23.
//

import Foundation

public struct NetworkURL {
    let Url: String
    
    /// Init API URL with a ServiceName which will be appended to BaseUrl and APIVersion specified in PGlobalSharedVariable.swift
    /// # How it works :
    ///   - for example BaseUrl is set as : BaseUrl = "www.google.com"
    ///   - and APIVersion is : APIVersion =  "/api/v1/"
    ///   - and Service parameter is "GetUserData"
    ///   - API Going to be called will be "www.google.com/api/v1/GetUserData"
    /// - See ExapleViewController.swift for more info.
    /// - parameter Service : Service from Your BaseURL you would Like to call
    public init(withService Service : String) {
        if PNetworkServiceBaseUrl == ""{
            assertionFailure("Base URL is blank. Please Set PNetworkServiceBaseUrl")
        }
        self.Url = "\(PNetworkServiceBaseUrl)\(PNetworkServiceAPIVersion)\(Service)"
    }
    
    /// This function will create a API request from the static URL you provided
    /// - parameter Url : Full URL of the API in string you wanted to call
    public init(withURL Url : String) {
        self.Url = Url
    }
}

extension String {
    var isValidURL: Bool {
        let detector = try! NSDataDetector(types: NSTextCheckingResult.CheckingType.link.rawValue)
        if let match = detector.firstMatch(in: self, options: [], range: NSRange(location: 0, length: self.utf16.count)) {
            // it is a link, if the match covers the whole string
            return match.range.length == self.utf16.count
        } else {
            return false
        }
    }
}
