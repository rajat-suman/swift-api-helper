README

##Swift Networking Example

This repository contains an example of networking in Swift, showcasing how to make GET and POST requests using Combine and handle decoding using custom property wrappers for safe decoding.

Table of Contents

****Requirements****

Model
API Client
View Model
License

****Requirements****
**Xcode 12.0+
Swift 5.3+
iOS 14.0+ (if applicable)**

**Model**
Define a model conforming to Decodable and Identifiable protocols, using a custom property wrapper for safe decoding:

struct PostMy: Decodable, Identifiable {
    @SafeDecodable var userId: Int?
    @SafeDecodable var id: Int?
    @SafeDecodable var title: String?
    @SafeDecodable var body: String?
}

**API Client**
Implement a singleton APIClient to handle network requests:

Api Client Class is responsible for handling all the network calls, it internally calls Multer, Get, Post, CustomUrlProtocol, Encryption, Adding Authorization tokens etc.

**View Model**
Use UserViewModel to manage data fetching and state:

import Combine
import SwiftUI

class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    // GET request
    func fetchUsers() {
        APIClient.shared.makeRequest(endpoint: "/users", method: "GET")
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            } receiveValue: { (users: [User]) in
                self.users = users
            }
            .store(in: &cancellables)
    }

    // POST request
    func fetchPosts() {
        let body: [String: Any] = [
            "title": "foo",
            "body": "bar",
            "userId": 1
        ]
        APIClient.shared.makeRequest(endpoint: "/posts", method: "POST", body: body)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    self.errorMessage = error.localizedDescription
                case .finished:
                    break
                }
            } receiveValue: { (posts: PostMy) in
                print(posts)
            }
            .store(in: &cancellables)
    }
}

**License**
This project is licensed under the MIT License. See the LICENSE file for details.

