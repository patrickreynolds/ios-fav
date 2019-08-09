// Inspiration found here:
// https://medium.com/journey-of-one-thousand-apps/caching-images-in-swift-e909a8e5db17

import UIKit

struct FaveImageCache {
    static let imageCache = NSCache<NSString, UIImage>()

    private init() {}

    static func downloadImage(url: URL, completion: @escaping (_ image: UIImage?) -> Void) {
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(cachedImage)
        } else {

            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: url)

                    DispatchQueue.main.async {
                        guard let image = UIImage(data: data) else {
                            completion(nil)

                            return
                        }

                        imageCache.setObject(image, forKey: url.absoluteString as NSString)
                        completion(image)
                    }
                    return
                } catch {
                    completion(nil)
                }
            }


            // ---------------------------

//            MTAPIClient.downloadData(url: url) { data, response, error in
//                if let error = error {
//                    completion(nil, error)
//
//                } else if let data = data, let image = UIImage(data: data) {
//                    imageCache.setObject(image, forKey: url.absoluteString as NSString)
//                    completion(image, nil)
//                } else {
//                    completion(nil, NSError.generalParsingError(domain: url.absoluteString))
//                }
//            }
        }
    }
}
