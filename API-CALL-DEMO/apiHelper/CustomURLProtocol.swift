//
//  CustomURLProtocol.swift
//  API-CALL-DEMO
//
//  Created by Rajat Suman on 29/07/24.
//

import Foundation
import Combine

class CustomURLProtocol: URLProtocol {
    
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    override func startLoading() {
        var newRequest = request
        
        print("Url----> \(newRequest.url?.absoluteString ?? "")")
        
        print("Method----> \(newRequest.httpMethod ?? "")")
        
        let bodyData = readInputStream(stream : newRequest.httpBodyStream)
        
        print("Body----> \(String(describing: convertDataToDictionary(data:bodyData)))")
        
        if(bodyData != nil){
            newRequest.httpBody = bodyData
        }
        
        newRequest.allHTTPHeaderFields?.updateValue("application/json", forKey: "Content-Type")
        
        /**
         ENCRYPTION CODE
         */
        
        let token = "123456" //READ TOKEN FROM LOCAL STORAGE
        
        if(!token.isEmpty){
            newRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        }
        
        print("Content-Type----> \(String(describing: newRequest.allHTTPHeaderFields?["Content-Type"]))")
        
        let isEncryptedNeeded = newRequest.allHTTPHeaderFields?["encryptionNeeded"]?.getBoolValue() ?? false
        
        if(isEncryptedNeeded){
            let isMultiPart  = newRequest.allHTTPHeaderFields?["Content-Type"]?.contains("multipart/form-data") ?? false
            
            var headers = Encryption.shared.encryptHeaderData(parameter: newRequest.allHTTPHeaderFields ?? [:] )
            headers.updateValue("application/json", forKey: "Content-Type")
            newRequest.allHTTPHeaderFields = headers
            
            if(!isMultiPart && (newRequest.httpMethod == "POST" || newRequest.httpMethod == "PUT")){
                let body = Encryption.shared.encryptData(parameter: convertDataToDictionary(data: newRequest.httpBody) ?? [:])
                newRequest.httpBody = convertDictionaryToData(dictionary: body)
            }
        }
        
        print("Body----> \(String(describing: convertDataToDictionary(data:newRequest.httpBody)))")
        
       // Perform the request
        let task = URLSession.shared.dataTask(with: newRequest) { data, response, error in
        
            if let data = data {
                self.client?.urlProtocol(self, didLoad: data)
            }
            if let response = response {
                self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            }
            if let error = error {
                self.client?.urlProtocol(self, didFailWithError: error)
            }
            self.client?.urlProtocolDidFinishLoading(self)
        }
        task.resume()
    }
    override func stopLoading() {
        // Stop the loading process if necessary
    }
    
    
    
}


extension String {
    
    func getBoolValue() -> Bool?{
        switch self.lowercased() {
        case "true":
            return true
        case "false":
            return false
        default:
            return nil
        }
    }
   
}
