import Foundation

enum ConnectorType: String {
    case google
}

extension ConnectorType: Equatable {
    static func ==(lhs: ConnectorType, rhs: String) -> Bool {
        return lhs.rawValue == rhs
    }

    static func ==(lhs: String, rhs: ConnectorType) -> Bool {
        return lhs == rhs.rawValue
    }
}

enum ContextualConnectorType {
    case google(content: [String: AnyObject])

    var itemType: ItemType? {
        switch self {
        case .google(let content):
            return GoogleItemType(data: content)
        }
    }
}

protocol ItemType {
    var name: String { get }
}

struct GooglePhoto {
    let width: Double
    let height: Double
    let googlePhotoReference: String

    init?(data: [String: AnyObject]) {
        guard let width = data["width"] as? Double else {
            return nil
        }

        guard let height = data["height"] as? Double else {
            return nil
        }

        guard let googlePhotoReference = data["photoReference"] as? String else {
            return nil
        }

        self.width = width
        self.height = height
        self.googlePhotoReference = googlePhotoReference
    }

    func photoUrl(googleApiKey key: String, googlePhotoReference reference: String, maxHeight: Int, maxWidth: Int) -> URL? {
        return URL(string: "https://maps.googleapis.com/maps/api/place/photo?maxwidth=\(maxWidth)&maxheight=\(maxHeight)&photoreference=\(reference)&key=\(key)")
    }
}

struct GoogleItemType {
    let name: String
    let vicinity: String
    let website: String
    let geometry: GoogleGeometry
    let placeId: String
    let formattedAddress: String
    let internationalPhoneNumber: String?
    let formattedPhoneNumber: String?
    let keywords: [String]?
    let rating: Double
    let photos: [GooglePhoto]
    let savedPhotos: [String]

    init?(data: [String: AnyObject]) {
        guard let name = data["name"] as? String else {
            return nil
        }

        guard let vicinity = data["vicinity"] as? String else {
            return nil
        }

        let website = data["website"] as? String ?? ""

        guard let geometryData = data["geometry"] as? [String: AnyObject], let geometry = GoogleGeometry(data: geometryData) else {
            return nil
        }

        guard let placeId = data["placeId"] as? String else {
            return nil
        }

        guard let formattedAddress = data["formattedAddress"] as? String else {
            return nil
        }

        let internationalPhoneNumber: String? = data["internationalPhoneNumber"] as? String
        let formattedPhoneNumber: String? = data["formattedPhoneNumber"] as? String

        guard let rating = data["rating"] as? Double else {
            return nil
        }

        var photos = [GooglePhoto]()
        if let photoData = data["photos"] as? [[String: AnyObject]] {
            photos = photoData.map({GooglePhoto(data: $0)}).compactMap({ $0 })
        }

        var savedPhotos = [String]()
        if let savedPhotoData = data["savedPhotos"] as? [String] {
            savedPhotos = savedPhotoData
        }

        let potentialKeywords = data["types"] as? [String]

        self.name = name
        self.vicinity = vicinity
        self.website = website
        self.geometry = geometry
        self.placeId = placeId
        self.formattedAddress = formattedAddress
        self.formattedPhoneNumber = formattedPhoneNumber
        self.internationalPhoneNumber = internationalPhoneNumber
        self.rating = rating
        self.keywords = potentialKeywords
        self.photos = photos
        self.savedPhotos = savedPhotos
    }
}

struct GoogleGeometry {
    let latitude: Double
    let longitude: Double

    init?(data: [String: AnyObject]) {

        guard let location = data["location"] as? [String: AnyObject] else {
            return nil
        }

        guard let latitude = location["lat"] as? Double else {
            return nil
        }

        guard let longitude = location["lng"] as? Double else {
            return nil
        }

        self.latitude = latitude
        self.longitude = longitude

        //        key : "geometry"
        //        ▿ value : 1 element
        //        ▿ 0 : 2 elements
        //        - key : location
        //        ▿ value : 2 elements
        //        ▿ 0 : 2 elements
        //        - key : lat
        //        - value : 37.77677609999999
        //        ▿ 1 : 2 elements
        //        - key : lng
        //        - value : -122.4247969
    }
}

extension GoogleItemType: ItemType {}



/*
enum ConnectorType {
    case google(content: [String: AnyObject])

    var itemType: ItemType? {
        switch self {
        case .google(let content):
            return GoogleItemType(data: content)
        }
    }

    func connector(fromString string: String, withContent content: [String: AnyObject]) -> ConnectorType? {
        switch string.lowercased() {
        case "google":
            return .google(content: content)
        default:
            return nil
        }
    }

    var description: String {
        switch self {
        case .google:
            return "google"
        }

    }
}

*/

/*
22 elements
    ▿ 0 : 2 elements
- key : "vicinity"
- value : 500 Hayes Street, San Francisco
▿ 1 : 2 elements
- key : "website"
- value : http://www.laboulangeriesf.com/
▿ 2 : 2 elements
- key : "rating"
- value : 4.2
▿ 3 : 2 elements
- key : "reference"
- value : ChIJU3tHbqKAhYAR3MDnzOK40Nk
▿ 4 : 2 elements
- key : "icon"
- value : https://maps.gstatic.com/mapfiles/place_api/icons/cafe-71.png
▿ 5 : 2 elements
- key : "addressComponents"
▿ value : 8 elements
▿ 0 : 3 elements
▿ 0 : 2 elements
- key : types
▿ value : 1 element
- 0 : street_number
▿ 1 : 2 elements
- key : shortName
- value : 500
▿ 2 : 2 elements
- key : longName
- value : 500
▿ 1 : 3 elements
▿ 0 : 2 elements
- key : types
▿ value : 1 element
- 0 : route
▿ 1 : 2 elements
- key : shortName
- value : Hayes St
▿ 2 : 2 elements
- key : longName
- value : Hayes Street
▿ 2 : 3 elements
▿ 0 : 2 elements
- key : types
▿ value : 2 elements
- 0 : neighborhood
- 1 : political
▿ 1 : 2 elements
- key : shortName
- value : Western Addition
▿ 2 : 2 elements
- key : longName
- value : Western Addition
▿ 3 : 3 elements
▿ 0 : 2 elements
- key : types
▿ value : 2 elements
- 0 : locality
- 1 : political
▿ 1 : 2 elements
- key : shortName
- value : SF
▿ 2 : 2 elements
- key : longName
- value : San Francisco
▿ 4 : 3 elements
▿ 0 : 2 elements
- key : types
▿ value : 2 elements
- 0 : administrative_area_level_2
- 1 : political
▿ 1 : 2 elements
- key : shortName
- value : San Francisco County
▿ 2 : 2 elements
- key : longName
- value : San Francisco County
▿ 5 : 3 elements
▿ 0 : 2 elements
- key : types
▿ value : 2 elements
- 0 : administrative_area_level_1
- 1 : political
▿ 1 : 2 elements
- key : shortName
- value : CA
▿ 2 : 2 elements
- key : longName
- value : California
▿ 6 : 3 elements
▿ 0 : 2 elements
- key : types
▿ value : 2 elements
- 0 : country
- 1 : political
▿ 1 : 2 elements
- key : shortName
- value : US
▿ 2 : 2 elements
- key : longName
- value : United States
▿ 7 : 3 elements
▿ 0 : 2 elements
- key : types
▿ value : 1 element
- 0 : postal_code
▿ 1 : 2 elements
- key : shortName
- value : 94102
▿ 2 : 2 elements
- key : longName
- value : 94102
▿ 6 : 2 elements
- key : "geometry"
▿ value : 1 element
▿ 0 : 2 elements
- key : location
▿ value : 2 elements
▿ 0 : 2 elements
- key : lat
- value : 37.77677609999999
▿ 1 : 2 elements
- key : lng
- value : -122.4247969
▿ 7 : 2 elements
- key : "placeId"
- value : ChIJU3tHbqKAhYAR3MDnzOK40Nk
▿ 8 : 2 elements
- key : "internationalPhoneNumber"
- value : +1 415-400-4451
▿ 9 : 2 elements
- key : "url"
- value : https://maps.google.com/?cid=15695247985626038492
▿ 10 : 2 elements
- key : "types"
▿ value : 6 elements
- 0 : cafe
- 1 : bakery
- 2 : store
- 3 : point_of_interest
- 4 : food
- 5 : establishment
▿ 11 : 2 elements
- key : "utcOffset"
- value : -420
▿ 12 : 2 elements
- key : "priceLevel"
- value : 2
▿ 13 : 2 elements
- key : "scope"
- value : GOOGLE
▿ 14 : 2 elements
- key : "opening_hours"
▿ value : 3 elements
▿ 0 : 2 elements
- key : openNow
- value : 0
▿ 1 : 2 elements
- key : periods
- value : 0 elements
▿ 2 : 2 elements
- key : weekdayText
- value : <null>
▿ 15 : 2 elements
- key : "photos"
▿ value : 10 elements
▿ 0 : 4 elements
▿ 0 : 2 elements
- key : photoReference
- value : CmRaAAAAOtqXeD-iRafyIi9QbfUgknNJqfsYPWYtxbnO8wS_O2W2aNZDE2G4FoMkCqbs3UaM08w6_firydursRAL65JQ75FUQJxpz0VwYOgUlvbAMpFPmaxndrNfB4UoKIkFyrqoEhBv2dxrG1JyvgOa7Hs5q0IwGhQF3B0QJTTu4-EBtpSWu9Nt0-Llvw
▿ 1 : 2 elements
- key : htmlAttributions
▿ value : 1 element
- 0 : <a href="https://maps.google.com/maps/contrib/105969355905733223234/photos">Vince Mediaa</a>
▿ 2 : 2 elements
- key : height
- value : 3024
▿ 3 : 2 elements
- key : width
- value : 4032
▿ 1 : 4 elements
▿ 0 : 2 elements
- key : photoReference
- value : CmRaAAAAcON6Q0dMh7AZgGJ6RWkPZov17OeWE7Gk5ueqi72u7cDp45rEyeRCRDGu-6QwarujcxR6mWk3bKXOwMEb0buxSljDUxxeA1HNHoXU6q5tA6k3qQXfDa051bj3h2WytP18EhCur7Ldktm_sm3k8fiBIK3NGhRNaTk5qA2GEIK7IF_cyRZxtPunAQ
▿ 1 : 2 elements
- key : htmlAttributions
▿ value : 1 element
- 0 : <a href="https://maps.google.com/maps/contrib/105201699677486408719/photos">Mirela Spasova</a>
▿ 2 : 2 elements
- key : height
- value : 2992
▿ 3 : 2 elements
- key : width
- value : 4000
▿ 2 : 4 elements
▿ 0 : 2 elements
- key : photoReference
- value : CmRaAAAATehsIGbEIBvoX-gC9HZ71NAFaFeDYwkQKxPsaN54I67C466pNkNyL8fQ3G5XWKn6HjRc5xaPdWT0xxaOMEXGf1CgTfh7fkiOaMMJjA2ZFrUUVp-0M9HCIZPVWV5xyJK9EhBHZuHCGZTQlOIC39O29-WDGhSlDxdyuChQvaZFyk1FmgOhEFrjDw
▿ 1 : 2 elements
- key : htmlAttributions
▿ value : 1 element
- 0 : <a href="https://maps.google.com/maps/contrib/108830155997993832118/photos">Andrew Campbell</a>
▿ 2 : 2 elements
- key : height
- value : 3024
▿ 3 : 2 elements
- key : width
- value : 4032
▿ 3 : 4 elements
▿ 0 : 2 elements
- key : photoReference
- value : CmRaAAAAFeyRwdNPPrZ3SwWRSVU0-MMO-ez1hCmfNyyiKR_1XbmaRfv8o1VdFAvVac58KJvh56RQNKarAPdTZkx34YTsTSA-Tk7OdmnLwDpXBJslX7_irx2Jc8tWzMY3EGGWNsklEhAtGOisco_jud4SOHsxGgxvGhTdgHmhl5hpShWUnt4k33KHFk4a7w
▿ 1 : 2 elements
- key : htmlAttributions
▿ value : 1 element
- 0 : <a href="https://maps.google.com/maps/contrib/111677590642335227904/photos">Tomomi Imura</a>
▿ 2 : 2 elements
- key : height
- value : 2309
▿ 3 : 2 elements
- key : width
- value : 2308
▿ 4 : 4 elements
▿ 0 : 2 elements
- key : photoReference
- value : CmRaAAAAyR2NOHUz3MAQF7vBQM3p8KtN1ODJXWzbS2k-I6LRTX9v1Upnn82F-aaLwQtCSpDbN-iRHegyy5_57UqYy5_r5gm4rMHh7HK93ZpPfVxXvloNcV29uKSXFeIClN2voDjwEhAiKnLPehVB1xaWBuWc6VakGhTz4P4rsaOm_tbAKpcNVKaDpyupHw
▿ 1 : 2 elements
- key : htmlAttributions
▿ value : 1 element
- 0 : <a href="https://maps.google.com/maps/contrib/110732361458399132344/photos">Ori Rijo</a>
▿ 2 : 2 elements
- key : height
- value : 2610
▿ 3 : 2 elements
- key : width
- value : 4640
▿ 5 : 4 elements
▿ 0 : 2 elements
- key : photoReference
- value : CmRaAAAASMFh1VzLlKMRgCYNGGJGGzLXvt_sItFoIqzzFJc0Miz6984-ybSHt6XKkoUjqaa_DnWH_A2YRcJ4SrrixOZdos_wjmlEb56P6vi78SaxkZauJl0wa6V6jA75Y7pCFe3ZEhD4YYnaWsjifmgFUl91zOrPGhTSktGMXeBqzYeRlB35sUdVf_qLdA
▿ 1 : 2 elements
- key : htmlAttributions
▿ value : 1 element
- 0 : <a href="https://maps.google.com/maps/contrib/116772600361013391226/photos">Heejin Lee</a>
▿ 2 : 2 elements
- key : height
- value : 1616
▿ 3 : 2 elements
- key : width
- value : 1080
▿ 6 : 4 elements
▿ 0 : 2 elements
- key : photoReference
- value : CmRaAAAAPczy5tQQ0GVH7fo_BDDvfkopuUzLvjSIVC6EnHy24MgW5ju4qWOidKmkzmry7uHJtiM4Ps8AGqNJKAII0gcXEUtzxkmAHWMTrzYLG3U-sLDzoSOSXSwWOF1gta1YlLIIEhButzc6O6To-luaoXQIL6bcGhQvaw4z_EF37SfEMFwtylY2FoBy4w
▿ 1 : 2 elements
- key : htmlAttributions
▿ value : 1 element
- 0 : <a href="https://maps.google.com/maps/contrib/114832380918896847951/photos">Deby Page</a>
▿ 2 : 2 elements
- key : height
- value : 3024
▿ 3 : 2 elements
- key : width
- value : 4032
▿ 7 : 4 elements
▿ 0 : 2 elements
- key : photoReference
- value : CmRaAAAAOTbWKE6Z7QHDKMkDZanmWBhbHoAkg1qGRy4vQ5Y9c4QzoJx3qCKNKQQawH-KIoZOz2-FG807IVj1MvOJ9WexTOKjhcym7O3Vo86CF827-C45JCZ-peZzFBQyO9bElZNxEhDUfjFneWy5bX3EQw9Z1GgKGhS2dmoCxP-ltcNfkQW89K4hQ0dcUA
▿ 1 : 2 elements
- key : htmlAttributions
▿ value : 1 element
- 0 : <a href="https://maps.google.com/maps/contrib/100917366760507820453/photos">Bakery Addiction</a>
▿ 2 : 2 elements
- key : height
- value : 3024
▿ 3 : 2 elements
- key : width
- value : 4032
▿ 8 : 4 elements
▿ 0 : 2 elements
- key : photoReference
- value : CmRaAAAAP6gi2lzQgPZDu-hJcWbzgCLdpMlyhe5nx9EcSf_Vi3p1_2f-afotHY4dqnw1991IZJkmJ_-65QrfhM7mDI8x74hRa2qMV-uT591Qyk2ZsEVvQLr1rj9cjMnLFEh8sYeREhDfAfovognsCQ9tn2IL5n5uGhTo1gTThY2iryk43sY9wVDX226jYg
▿ 1 : 2 elements
- key : htmlAttributions
▿ value : 1 element
- 0 : <a href="https://maps.google.com/maps/contrib/111204103992600358534/photos">Daniel Bahmani</a>
▿ 2 : 2 elements
- key : height
- value : 3480
▿ 3 : 2 elements
- key : width
- value : 4640
▿ 9 : 4 elements
▿ 0 : 2 elements
- key : photoReference
- value : CmRaAAAAhG3XEeFP1q6Ig7FgKpFvtFjfC11DJL0MD7YNRBKxDgibLI5He8AXFF_pMclN9bu5VsgfUJXJpRwMJEbLewNoDH89AQ6VXLp9hDo2V6DL39Vd2SBGGI8g8xKASOwW27TyEhDgOJa_yeqFlL-eeJxIbka8GhRcCakbY_Dj0wgmwyr5wAZhLYZBEA
▿ 1 : 2 elements
- key : htmlAttributions
▿ value : 1 element
- 0 : <a href="https://maps.google.com/maps/contrib/103971455356823562009/photos">Ryan Asignacion</a>
▿ 2 : 2 elements
- key : height
- value : 3195
▿ 3 : 2 elements
- key : width
- value : 4792
▿ 16 : 2 elements
- key : "reviews"
▿ value : 5 elements
▿ 0 : 8 elements
▿ 0 : 2 elements
- key : rating
- value : 4
▿ 1 : 2 elements
- key : time
- value : 1552506787
▿ 2 : 2 elements
- key : profilePhotoUrl
- value : https://lh6.googleusercontent.com/-UWWoVIkwR9c/AAAAAAAAAAI/AAAAAAAAAPw/PWtxtKObZI8/s128-c0x00000000-cc-rp-mo-ba4/photo.jpg
▿ 3 : 2 elements
- key : authorName
- value : Jason Bodenheimer
▿ 4 : 2 elements
- key : language
- value : en
▿ 5 : 2 elements
- key : relativeTimeDescription
- value : 3 weeks ago
▿ 6 : 2 elements
- key : text
- value : I was sad when the Last Boulangerie near my house closed down. It's a rare opportunity for me to get my fix, buy when I'm in the area I have to visit. The Hazelnut Chocolate Croissants are heavenly and there are a free different savory croissants that will surprise you. They make their pastries with lots butter and and you can taste the difference in the quality. The manager on staff this morning was attentive, anticipated what his customers needed and the rest of the staff was cheerful and attentive as well.  Great little spot.  The 5th ? will appear when I come back to electrical jacks in the wall so I can post up with my laptop. It's 2019 guys, come on.  ;)
▿ 7 : 2 elements
- key : authorUrl
- value : https://www.google.com/maps/contrib/109448542650163047767/reviews
▿ 1 : 8 elements
▿ 0 : 2 elements
- key : rating
- value : 3
▿ 1 : 2 elements
- key : time
- value : 1548436735
▿ 2 : 2 elements
- key : profilePhotoUrl
- value : https://lh6.googleusercontent.com/-Lb8G9tQRiaA/AAAAAAAAAAI/AAAAAAAAAAk/DWo1IXH2T00/s128-c0x00000000-cc-rp-mo/photo.jpg
▿ 3 : 2 elements
- key : authorName
- value : Louis Edwards
▿ 4 : 2 elements
- key : language
- value : en
▿ 5 : 2 elements
- key : relativeTimeDescription
- value : 2 months ago
▿ 6 : 2 elements
- key : text
- value : This is a perfect place to go if you're wanting dessert in a relaxed, coffee shop environment. They make their desserts in-house every day and you can definitely tell the difference. My friends and I shared three different cheesecakes and weren't disappointed with any option.
▿ 7 : 2 elements
- key : authorUrl
- value : https://www.google.com/maps/contrib/114061967517305763777/reviews
▿ 2 : 8 elements
▿ 0 : 2 elements
- key : rating
- value : 5
▿ 1 : 2 elements
- key : time
- value : 1550936286
▿ 2 : 2 elements
- key : profilePhotoUrl
- value : https://lh3.googleusercontent.com/-6qBiu_I18aM/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rcB0Q5aedgxBonDI-mCkqNJjnJ6lw/s128-c0x00000000-cc-rp-mo-ba4/photo.jpg
▿ 3 : 2 elements
- key : authorName
- value : Sven S
▿ 4 : 2 elements
- key : language
- value : en
▿ 5 : 2 elements
- key : relativeTimeDescription
- value : a month ago
▿ 6 : 2 elements
- key : text
- value : Best breakfast in town. Incredible Croissants, wonderful coffee, very nice service. Great to sit there in the morning. Goods sandwiches during the day as well.
▿ 7 : 2 elements
- key : authorUrl
- value : https://www.google.com/maps/contrib/103390609489237303295/reviews
▿ 3 : 8 elements
▿ 0 : 2 elements
- key : rating
- value : 5
▿ 1 : 2 elements
- key : time
- value : 1551560808
▿ 2 : 2 elements
- key : profilePhotoUrl
- value : https://lh4.googleusercontent.com/-2g4UwvfjwZY/AAAAAAAAAAI/AAAAAAAA_Os/MzHuK_xj6Bk/s128-c0x00000000-cc-rp-mo-ba5/photo.jpg
▿ 3 : 2 elements
- key : authorName
- value : bryan wunsch
▿ 4 : 2 elements
- key : language
- value : en
▿ 5 : 2 elements
- key : relativeTimeDescription
- value : a month ago
▿ 6 : 2 elements
- key : text
- value : Fresh & Delicious.  Clean dining room.  Get some tasty breakfast here and enjoy the idyllic surroundings of Hayes Valley.
▿ 7 : 2 elements
- key : authorUrl
- value : https://www.google.com/maps/contrib/106964043234581740761/reviews
▿ 4 : 8 elements
▿ 0 : 2 elements
- key : rating
- value : 4
▿ 1 : 2 elements
- key : time
- value : 1549069572
▿ 2 : 2 elements
- key : profilePhotoUrl
- value : https://lh3.googleusercontent.com/-O4WOpHQkREc/AAAAAAAAAAI/AAAAAAAAAJ0/yZkgi3U7ASg/s128-c0x00000000-cc-rp-mo-ba5/photo.jpg
▿ 3 : 2 elements
- key : authorName
- value : Wayne Chang
▿ 4 : 2 elements
- key : language
- value : en
▿ 5 : 2 elements
- key : relativeTimeDescription
- value : 2 months ago
▿ 6 : 2 elements
- key : text
- value : The wheat croissant has an additional nutty sweet taste. Quite good! And cheaper by far to most other bakeries.
▿ 7 : 2 elements
- key : authorUrl
- value : https://www.google.com/maps/contrib/107497364939555971627/reviews
▿ 17 : 2 elements
- key : "formattedAddress"
- value : 500 Hayes St, San Francisco, CA 94102, USA
▿ 18 : 2 elements
- key : "name"
- value : La Boulangerie de San Francisco, Hayes
▿ 19 : 2 elements
- key : "connectorType"
- value : GOOGLE
▿ 20 : 2 elements
- key : "formattedPhoneNumber"
- value : (415) 400-4451
▿ 21 : 2 elements
- key : "id"
- value : 9a7febec4d42a6dd9f97a576f9b00499bb02cfe6
*/
