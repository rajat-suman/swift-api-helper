# Swift API Helper

Swift API Helper is a utility library designed to simplify API calls in Swift. It provides an easy-to-use interface for making network requests, handling responses, and managing errors.

## Features

- Simplified API request creation
- Supports GET, POST, PUT, DELETE methods
- JSON encoding and decoding
- Customizable URL session configurations
- Easy error handling
- Safe decoding with property wrappers

## Installation

### Swift Package Manager

Add the following line to your `Package.swift` file:

```swift
dependencies: [
    .package(url: "https://github.com/rajat-suman/swift-api-helper.git", from: "1.0.0")
]
```


## Usage

### Basic GET Request

```
import SwiftAPIHelper
import Combine

let apiClient = APIClient.getInstance()

let cancellable = apiClient.makeRequest(endpoint: "/users", method: "GET")
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("Request finished")
        case .failure(let error):
            print("Request failed with error: \(error)")
        }
    }, receiveValue: { (users: [User]) in
        print("Received users: \(users)")
    })
```

### POST Request with Body

```
import SwiftAPIHelper
import Combine

let parameters = ["name": "John Doe", "email": "john.doe@example.com"]
let apiClient = APIClient.getInstance()

let cancellable = apiClient.makeRequest(endpoint: "/users", method: "POST", body: parameters)
    .sink(receiveCompletion: { completion in
        switch completion {
        case .finished:
            print("Request finished")
        case .failure(let error):
            print("Request failed with error: \(error)")
        }
    }, receiveValue: { (response: User) in
        print("User created: \(response)")
    })
```

## Safe Decoding with Property Wrappers
Use the @SafeDecodable property wrapper to safely decode JSON responses, handling missing or mismatched data types by setting them to nil.

```
import SwiftAPIHelper

struct User: Decodable, Identifiable {
    @SafeDecodable var id: Int?
    @SafeDecodable var name: String?
    @SafeDecodable var email: String?
}
```

## Custom URL Protocol

The library allows you to customize the URL session configuration, such as adding encryption or modifying request headers.

```
class CustomURLProtocol: URLProtocol {
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        let newRequest = request

        // Custom modifications
        // ...

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
```

## License

This project is licensed under the MIT License - see the LICENSE file for details.


### Contributing

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/new-feature`)
3. Commit your changes (`git commit -am 'Add new feature'`)
4. Push to the branch (`git push origin feature/new-feature`)
5. Create a new Pull Request

## Contact

For any questions or feedback, please open an issue or contact me at [rsuman1997@gmail.com].



