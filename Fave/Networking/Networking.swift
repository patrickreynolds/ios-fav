import Foundation
import Alamofire

protocol NetworkingType {
    func sendGetRequest(endpoint: FaveEndpoint, completion: @escaping FaveAPICallResultCompletionBlock)
    func sendPostRequest(endpoint: FaveEndpoint, data: [String: String], completion: @escaping FaveAPICallResultCompletionBlock)
    func sendDeleteRequest(endpoint: FaveEndpoint, data: [String: String], completion: @escaping FaveAPICallResultCompletionBlock)

    func sendGraphqlRequest(query: String, completion: @escaping FaveAPICallResultCompletionBlock)
}

typealias FaveAPICallResultCompletionBlock = (_ response: AnyObject?, _ error: Error?) -> ()

struct Networking {

    private let baseUrl: String
    private let authenticator: Authenticator

    init(appConfiguration: AppConfiguration, authenticator: Authenticator) {
        self.authenticator = authenticator
        self.baseUrl = appConfiguration.baseUrl.isEmpty ? "http://flight-tracker-1816596686.us-east-2.elb.amazonaws.com/" : appConfiguration.baseUrl
    }

    func sendGraphqlRequest(query: String, completion: @escaping FaveAPICallResultCompletionBlock) {
        let endpoint = "\(baseUrl)\(FaveEndpoint.graphql.path)"

        print("\(endpoint)")

        var authToken: String = ""

        if let token = authenticator.token() {
            authToken = "bearer \(token)"
        }

        let headers: HTTPHeaders = [
            "Authorization": authToken,
            "Accept": "application/json",
            ]

        let data = [
            "query": query
        ]

        // "Content-Type": "application/json"


        DispatchQueue.main.async {
            // Show the actificy indicator during the network call
            UIApplication.shared.isNetworkActivityIndicatorVisible = true
        }

        print("\n \(endpoint) \n")

        Alamofire.request(endpoint, method: .post, parameters: data, headers: headers).responseJSON { response in

            print("\n Response received \n")

            DispatchQueue.main.async {
                // Hide the actificy indicator during the network call
                UIApplication.shared.isNetworkActivityIndicatorVisible = false
            }

            guard let result = response.result.value else {
                completion(nil, response.error)

                return
            }

            guard let newResult = result as? [String: AnyObject] else {
                completion(nil, response.error)

                return
            }

            guard let dataResult = newResult["data"] else {
                completion(nil, response.error)

                return
            }

            completion(dataResult, nil)
        }
    }

    func sendGetRequest(endpoint: FaveEndpoint, completion: @escaping FaveAPICallResultCompletionBlock) {
        let endpoint = "\(baseUrl)\(endpoint.path)"

        print("\(endpoint)")

        var authToken: String = ""

        if let token = authenticator.token() {
            authToken = "bearer \(token)"
        }

        let headers: HTTPHeaders = [
            "Authorization": authToken,
            "Accept": "application/json",
        ]

        // "Content-Type": "application/json"

        // Show the actificy indicator during the network call
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        Alamofire.request(endpoint, headers: headers).responseJSON { response in

            // Hide the actificy indicator during the network call
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            guard let result = response.result.value else {
                completion(nil, response.error)

                return
            }

            guard let newResult = result as? [String: AnyObject] else {
                completion(nil, response.error)

                return
            }

            if let dataResult = newResult["data"] {
                completion(dataResult, nil)
            } else {
                completion(result as AnyObject, nil)
            }
        }
    }

    func sendPostRequest(endpoint: FaveEndpoint, data: [String: String], completion: @escaping FaveAPICallResultCompletionBlock) {
        let endpoint = "\(baseUrl)\(endpoint.path)"
        print("Endpoint: \(endpoint)")

        var authToken: String = ""

        if let token = authenticator.token() {
            authToken = "bearer \(token)"
        }

        let headers: HTTPHeaders = [
            "Authorization": authToken,
            "Accept": "application/json",
        ]

        // "Content-Type": "application/json"

        // Show the actificy indicator during the network call
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        Alamofire.request(endpoint, method: .post, parameters: data, headers: headers).responseJSON { response in

            // Hide the actificy indicator during the network call
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            guard let result = response.result.value else {
                completion(nil, response.error)

                return
            }

            guard let newResult = result as? [String: AnyObject] else {
                completion(nil, response.error)

                return
            }

            if let dataResult = newResult["data"] {
                completion(dataResult, nil)
            } else {
                completion(result as AnyObject, nil)
            }
        }
    }

    func sendDeleteRequest(endpoint: FaveEndpoint, data: [String: String], completion: @escaping FaveAPICallResultCompletionBlock) {
        let endpoint = "\(baseUrl)\(endpoint.path)"

        print("\(endpoint)")

        var authToken: String = ""

        if let token = authenticator.token() {
            authToken = "bearer \(token)"
        }

        let headers: HTTPHeaders = [
            "Authorization": authToken,
            "Accept": "application/json",
            ]

        // "Content-Type": "application/json"

        // Show the actificy indicator during the network call
        UIApplication.shared.isNetworkActivityIndicatorVisible = true

        Alamofire.request(endpoint, method: .delete, parameters: data, headers: headers).responseJSON { response in

            // Hide the actificy indicator during the network call
            UIApplication.shared.isNetworkActivityIndicatorVisible = false

            guard let result = response.result.value else {
                completion(nil, response.error)

                return
            }

            guard let newResult = result as? [String: AnyObject] else {
                completion(nil, response.error)

                return
            }

            if let dataResult = newResult["data"] {
                completion(dataResult, nil)
            } else {
                completion(result as AnyObject, nil)
            }
        }
    }
}

extension Networking: NetworkingType {}
