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
    
    init() {
        self.clientId = "oPMf6Sam7tHN9sQp2VFiv58NV0xSu4ACLMOMJcp0AEmBkynP"
        self.clientSecret = "JVF24v3BmZNQAfR9Q2fxtm5GIEX8zPRyKGXKFyfkAWbIuYGi"
        self.userKey = "?api_key=hscFz8Qque9ABbEF"
        self.apiUrl = "https://api.hackaday.io/v1/"
        self.currUrl = nil
    }
    
    // Create API URLs:
    func setURL (_ objectType : String, _ perPage : Int, _ pgNum : Int, _ sortParam : String) {
        
        let objectURL : String = apiUrl! + objectType
        let numPerPage : String = "&per_page=" + String(perPage)
        let pageNum : String = numPerPage + "&page=" + String(pgNum)
        let sort : String = "&sortby=" + sortParam
        let finalUrl = objectURL + userKey! + pageNum + sort
        
        self.currUrl = URL(string: finalUrl)!
    }
    
    // make requests, and return JSON object
    func requestData() {
        let task1 = URLSession.shared.dataTask(with: self.currUrl!) { (data, response, error) in
            guard let responseData = data, error == nil else {
                print(error?.localizedDescription ?? "Response Error")
                return
            }
            
            //parse data received from a network request
            do {
                let jsonResponse = try JSONSerialization.jsonObject(with: responseData, options: [])
                print(jsonResponse)
            }
            catch let parsingError {
                print("Error", parsingError)
            }
        }
        task1.resume()
    }
}
