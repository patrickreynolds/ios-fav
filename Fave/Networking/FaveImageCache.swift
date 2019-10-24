// Inspiration found here:
// https://medium.com/journey-of-one-thousand-apps/caching-images-in-swift-e909a8e5db17

import UIKit

struct FaveImageCache {
    static let imageCache = NSCache<NSString, UIImage>()

    private init() {}

    static func downloadImage(url: URL, completion: @escaping (_ url: String, _ image: UIImage?) -> Void) {

        // TODO: (8/14/2019) Temporary hack to make sure we're not making too many requests to google
        // while we figure out rate limit issues
        if !UIApplication.shared.appDelegate.dependencyGraph.appConfiguration.production {
            completion(url.absoluteString, nil)

            return
        }
        // TODO: End

        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completion(url.absoluteString, cachedImage)

            return
        } else {
            DispatchQueue.global().async {
                do {
                    let data = try Data(contentsOf: url, options: [.mappedIfSafe, .uncached])

                    guard let image = UIImage(data: data) else {
                        completion("", nil)

                        return
                    }

                    imageCache.setObject(image, forKey: url.absoluteString as NSString)
                    completion(url.absoluteString, image)

                    return
                } catch {
                    print(error)
                    completion("", nil)
                }
            }
        }
    }
}
