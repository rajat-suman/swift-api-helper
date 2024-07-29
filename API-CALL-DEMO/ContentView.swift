import SwiftUI
import Foundation
import Combine

struct ContentView: View {
    @StateObject private var viewModel = UserViewModel()
 var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundStyle(.tint)
            Text("Hello, world!")
            Button("FetchUsers") {
                viewModel.fetchUsers()
            }
            Button("FETCHPOSTS") {
                viewModel.fetchPosts()
            }
            
            if let errorMessage = viewModel.errorMessage {
                           Text("Error: \(errorMessage)")
                               .foregroundColor(.red)
                       }

                       List(viewModel.users) { user in
                           VStack(alignment: .leading) {
                               Text(user.name ?? "")
                                   .font(.headline)
                               Text(String(user.email ?? -1 ))
                                   .font(.subheadline)
                           }
                       }
        }
        .padding()
    }
}

#Preview {
    ContentView()
}

