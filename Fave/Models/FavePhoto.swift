import UIKit

enum FavePhotoServiceType: String {
    case Fave
    case Google
}

protocol FavePhotoType {
    var url: URL { get set }
    var serviceType: FavePhotoServiceType { get set }
}

struct SavedPhoto {
    var url: URL
    var serviceType = FavePhotoServiceType.Fave

    init?(urlString: String) {
        guard let url = URL(string: urlString) else {
            return nil
        }

        self.url = url
    }
}

struct GooglePhoto {
    var url: URL
    var serviceType = FavePhotoServiceType.Google
    let width: Double
    let height: Double
    let googlePhotoReference: String

    init?(data: [String: AnyObject], maxWidth: Int = 400, maxHeight: Int = 400) {
        guard let width = data["width"] as? Double else {
            return nil
        }

        guard let height = data["height"] as? Double else {
            return nil
        }

        guard let googlePhotoReference = data["photoReference"] as? String else {
            return nil
        }

        let key = UIApplication.shared.appDelegate.dependencyGraph.appConfiguration.googleAPIKey

        guard let url = GooglePhoto.photoUrl(googleApiKey: key, googlePhotoReference: googlePhotoReference, maxWidth: maxWidth, maxHeight: maxHeight) else {
            return nil
        }

        self.url = url
        self.width = width
        self.height = height
        self.googlePhotoReference = googlePhotoReference
    }

    static func photoUrl(googleApiKey key: String, googlePhotoReference reference: String, maxWidth: Int, maxHeight: Int) -> URL? {
        return URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&maxheight=\(maxHeight)&photoreference=\(reference)&key=\(key)")
    }
}

extension SavedPhoto: FavePhotoType {}

extension GooglePhoto: FavePhotoType {}
