import Foundation
import Combine

class APIClient {
    private static var apiClient :APIClient?
    
    static func getInstance()-> APIClient {
        if(apiClient==nil){
            apiClient = APIClient()
        }
        return apiClient!
    }

    private init() {}

    private let baseURL = "https://jsonplaceholder.typicode.com"
    
    func makeRequest<T: Decodable>(endpoint: String, method: String, body: [String: Any]? = nil, fileData: Data? = nil, fileName: String? = nil, encryptionNeeded : Bool = false ) -> AnyPublisher<T, Error> {
    
        guard let url = URL(string: "\(baseURL)\(endpoint)") else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("\(encryptionNeeded)", forHTTPHeaderField: "encryptionNeeded")

        if method != "GET" , body != nil, fileData == nil {
            request.httpBody = convertDictionaryToData(dictionary: body ?? [:])
        }
        
        if let fileData = fileData{
            let boundary = "Boundary-\(UUID().uuidString)"
            request.setValue("multipart/form-data; boundary=\(boundary)", forHTTPHeaderField: "Content-Type")
            let body = createMultipartBody(parameters: body ?? [:], filePathKey: "file", fileData: fileData, boundary: boundary, fileName: fileName ?? "")
            request.httpBody = body
        }
    
        request.httpMethod = method
        
        let config = URLSessionConfiguration.default
        config.protocolClasses = [CustomURLProtocol.self]
        
        return URLSession(configuration: config).dataTaskPublisher(for: request)
                .map(\.data)
                .decode(type: T.self, decoder: JSONDecoder())
                .mapError { error in
                    print("Error------> \(error)")
                    print("Error------> \(error.localizedDescription)")
                    return error as Error
                }.eraseToAnyPublisher()
        }
    

    
    // Function to create a multipart/form-data body
    func createMultipartBody(parameters: [String: Any], filePathKey: String, fileData: Data, boundary: String, fileName: String) -> Data {
        var body = Data()

        // Add the parameters
        for (key, value) in parameters {
            body.append("--\(boundary)\r\n".data(using: .utf8)!)
            body.append("Content-Disposition: form-data; name=\"\(key)\"\r\n\r\n".data(using: .utf8)!)
            body.append("\(value)\r\n".data(using: .utf8)!)
        }

        // Add the file data
        let mimeType = "application/octet-stream"
        body.append("--\(boundary)\r\n".data(using: .utf8)!)
        body.append("Content-Disposition: form-data; name=\"\(filePathKey)\"; filename=\"\(fileName)\"\r\n".data(using: .utf8)!)
        body.append("Content-Type: \(mimeType)\r\n\r\n".data(using: .utf8)!)
        body.append(fileData)
        body.append("\r\n".data(using: .utf8)!)

        // End of the body
        body.append("--\(boundary)--\r\n".data(using: .utf8)!)

        return body
    }
}









