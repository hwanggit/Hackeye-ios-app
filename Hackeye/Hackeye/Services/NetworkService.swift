//
//  NetworkService.swift
//  Hackeye
//
//  Created by Luhao Wang on 7/8/19.
//  Copyright © 2019 Luhao Wang. All rights reserved.
//

import Foundation

// Define api url request data class
class NetworkService {
    var clientId : String?
    var clientSecret : String?
    var userKey : String?
    var apiUrl : String?
    var currUrl : URL?
    var openCageDataUrl: String?
    var openCageDataApiKey: String?
    
    // Initialize API Urls and Keys
    init() {
        self.clientId = "oPMf6Sam7tHN9sQp2VFiv58NV0xSu4ACLMOMJcp0AEmBkynP"
        self.clientSecret = "JVF24v3BmZNQAfR9Q2fxtm5GIEX8zPRyKGXKFyfkAWbIuYGi"
        self.userKey = "?api_key=hscFz8Qque9ABbEF"
        self.apiUrl = "https://api.hackaday.io/v1/"
        self.currUrl = nil
        self.openCageDataUrl = "https://api.opencagedata.com/geocode/v1/json?q="
        self.openCageDataApiKey = "&key=9005e9fb50d34eb5a0a6bb2a827615a2&language=en&pretty=1"
    }
    
    // Create Hackaday API URL from instance variables and parameters
    func setHackADayURL (_ objectType : String, _ perPage : Int, _ pgNum : Int, _ sortParam : String) -> URL{
        
        let objectURL : String = apiUrl! + objectType
        let numPerPage : String = "&per_page=" + String(perPage)
        let pageNum : String = numPerPage + "&page=" + String(pgNum)
        let sort : String = "&sortby=" + sortParam
        let finalUrl = objectURL + userKey! + pageNum + sort
        self.currUrl = URL(string: finalUrl)!
        
        return self.currUrl!
    }
    
    // Create openCageData API Url to geocode locations
    func setOpenCageDataUrl (_ location: String) -> URL? {
        // Parse location parameter, and replace ", " with %2C%20
        var parsedLocation = location.replacingOccurrences(of: ",", with: "%2C")
        parsedLocation = parsedLocation.replacingOccurrences(of: " ", with: "%20")

        // Construct location URL
        let locationURL = openCageDataUrl! + parsedLocation + openCageDataApiKey!
        
        // Set current URL
        self.currUrl = URL(string: locationURL)
        
        return self.currUrl
    }
    
}
