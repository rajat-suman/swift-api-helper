Defining Model

struct PostMy: Decodable, Identifiable {
    @SafeDecodable var userId: Int?
    @SafeDecodable var id: Int?
    @SafeDecodable var title: String?
    @SafeDecodable var body: String?
}


API Calling

class UserViewModel: ObservableObject {
    @Published var users: [User] = []
    @Published var errorMessage: String?

    private var cancellables = Set<AnyCancellable>()

//GET TYPE API
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

//POST TYPE API
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


