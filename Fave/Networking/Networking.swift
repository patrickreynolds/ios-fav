import Foundation
import Alamofire

protocol NetworkingType {
    func sendGetRequest(endpoint: FaveEndpoint, completion: @escaping FaveAPICallResultCompletionBlock)
    func sendPostRequest(endpoint: FaveEndpoint, data: [String: String], completion: @escaping FaveAPICallResultCompletionBlock)
}

typealias FaveAPICallResultCompletionBlock = (_ response: [String: AnyObject]?, _ error: Error?) -> ()
typealias FaveAPICallPostResultCompletionBlock = (_ response: String?, _ error: Error?) -> ()

struct Networking {

    private let baseUrl: String
    private let authenticator: Authenticator

    init(appConfiguration: AppConfiguration, authenticator: Authenticator) {
        self.authenticator = authenticator
        self.baseUrl = appConfiguration.baseUrl.isEmpty ? "http://flight-tracker-1816596686.us-east-2.elb.amazonaws.com/" : appConfiguration.baseUrl
    }

    func sendGetRequest(endpoint: FaveEndpoint, completion: @escaping FaveAPICallResultCompletionBlock) {
        let endpoint = "\(baseUrl)\(endpoint.path)"

//        if let token = authenticator.token() {
//
//        } else {
//            completion(nil, Error(domain:"", code:"", userInfo: nil))
//        }

        let headers: HTTPHeaders = [
            "Authorization": authenticator.token() ?? "",
            "Accept": "application/json",
            "Content-Type": "application/json"
        ]

        Alamofire.request(endpoint, headers: headers).responseJSON { response in
            guard let result = response.result.value else {
                completion(nil, response.error)

                return
            }

            completion(result as? [String: AnyObject], nil)
        }
    }

    func sendPostRequest(endpoint: FaveEndpoint, data: [String: String], completion: @escaping FaveAPICallResultCompletionBlock) {
        let endpoint = "\(baseUrl)\(endpoint.path)"

        print("Endpoint: \(endpoint)")

        Alamofire.request(endpoint, method: .post, parameters: data).responseJSON { response in
            guard let result = response.result.value else {
                completion(nil, response.error)

                return
            }

            completion(result as? [String: AnyObject], nil)
        }
    }
}

extension Networking: NetworkingType {}
