//
//  UserViewModel.swift
//  API-CALL-DEMO
//
//  Created by Rajat Suman on 29/07/24.
//

import Foundation
import Combine

class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

    func fetchUsers() {
        APIClient.getInstance().makeRequest(endpoint: "/users", method: "GET")
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

    func fetchPosts() {
        let body: [String: Any] = [
            "title": "foo",
            "body": "bar",
            "userId": 1
        ]
        APIClient.getInstance().makeRequest(endpoint: "/posts", method: "POST", body: body)
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
