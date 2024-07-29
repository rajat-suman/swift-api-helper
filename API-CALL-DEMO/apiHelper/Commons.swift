//
//  Commons.swift
//  API-CALL-DEMO
//
//  Created by Rajat Suman on 29/07/24.
//

import Foundation

func convertDataToDictionary(data: Data?) -> [String: Any]? {
    guard let data = data else { return nil }
    do {
        let json = try JSONSerialization.jsonObject(with: data, options: [])
        return json as? [String: Any]
    } catch {
        print("Error converting data to JSON dictionary: \(error)")
        return nil
    }
}

func convertDictionaryToData(dictionary: [String: Any]) -> Data? {
    do {
        let data = try JSONSerialization.data(withJSONObject: dictionary, options: [])
        return data
    } catch {
        print("Error converting dictionary to data: \(error)")
        return nil
    }
}

func readInputStream(stream: InputStream?) -> Data? {
   
    if let stream = stream {
        
        let bufferSize = 1024
        var buffer = [UInt8](repeating: 0, count: bufferSize)
        var data = Data()

        stream.open()
        defer {
            stream.close()
        }

        while stream.hasBytesAvailable {
            let bytesRead = stream.read(&buffer, maxLength: bufferSize)
            if bytesRead < 0 {
                if let error = stream.streamError {
                    print("Stream error: \(error.localizedDescription)")
                }
                return nil
            } else if bytesRead == 0 {
                // End of stream
                break
            } else {
                data.append(buffer, count: bytesRead)
            }
        }

        return data
        
    }
    
    return nil
   
}
