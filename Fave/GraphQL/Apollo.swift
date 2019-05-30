import Apollo

class Apollo {

    static let shared = Apollo()
    let client: ApolloClient

    init() {
        client = ApolloClient(url: URL(string: "http://localhost:3000")!)
    }
}
