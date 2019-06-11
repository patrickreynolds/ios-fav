import Foundation

struct Item {
    let id: Int
    let dataId: Int
    let title: String
    let type: String
    let updatedAt: Date
    let createdAt: Date
    let connectorType: String
    let connectorId: String
    let note: String
    let isRecommendation: Bool
    let contextualItem: ItemType
    let content: [String: AnyObject]
    let numberOfFaves: Int
    let listId: Int
    let listTitle: String
    var addedBy: User
    var isSaved: Bool? = nil

    init?(data: [String: AnyObject]) {
        guard let id = data["id"] as? Int else {
            return nil
        }

        guard let dataId = data["dataId"] as? Int else {
            return nil
        }

        guard let title = data["title"] as? String else {
            return nil
        }

        guard let type = data["type"] as? String else {
            return nil
        }

        guard let updatedAtString = data["updatedAt"] as? String else {
            return nil
        }

        guard let createdAtString = data["createdAt"] as? String else {
            return nil
        }

        guard let dataItem = data["dataItem"] as? [String: AnyObject] else {
            return nil
        }

        guard let connectorType = dataItem["connectorType"] as? String else {
            return nil
        }

        guard let connectorId = dataItem["connectorId"] as? String else {
            return nil
        }

        guard let content = dataItem["content"] as? [String: AnyObject] else {
            return nil
        }

        guard let listData = data["list"] as? [String: AnyObject] else {
            return nil
        }

        guard let listId = listData["id"] as? Int else {
            return nil
        }

        guard let listTitle = listData["title"] as? String else {
            return nil
        }


//        let addedBy: User? = nil
        guard let addedByData = data["recommendedBy"] as? [String: AnyObject], let addedBy = User.init(data: addedByData) else {
            return nil
        }

        let dateFormatter = DateFormatter()
//        "2019-04-03T13:57:03.000Z"
        dateFormatter.dateFormat = "yyyy'-'MM'-'dd'T'HH':'mm':'ss.SSSZ"

        guard let updatedAtDate = dateFormatter.date(from: updatedAtString), let createdAtDate = dateFormatter.date(from: createdAtString) else {
            return nil
        }

        var potentialContextualItem: ItemType

        if connectorType.lowercased() == ConnectorType.google.rawValue {
            guard let connector = ContextualConnectorType.google(content: content).itemType else {
                return nil
            }

            potentialContextualItem = connector
        } else {
            return nil
        }

        self.contextualItem = potentialContextualItem

        let note = data["note"] as? String ?? ""

        let isRecommendation = data["isRecommendation"] as? Bool ?? false

        let numberOfFaves = data["numberOfFaves"] as? Int ?? 0

        self.id = id
        self.dataId = dataId
        self.title = title
        self.type = type
        self.updatedAt = updatedAtDate
        self.createdAt = createdAtDate
        self.connectorType = connectorType
        self.connectorId = connectorId
        self.note = note
        self.isRecommendation = isRecommendation
        self.content = content
        self.numberOfFaves = numberOfFaves
        self.listId = listId
        self.listTitle = listTitle
        self.addedBy = addedBy
    }
}

/*

 0 : 7 elements
 ▿ 0 : 2 elements
 - key : "type"
 - value : PLACE
 ▿ 1 : 2 elements
 - key : "content"
 - value : {"id": "e8741c0c6ededae2f9885cf7037003775c0fbec7", "url": "https://maps.google.com/?cid=3389884366903096466", "icon": "https://maps.gstatic.com/mapfiles/place_api/icons/restaurant-71.png", "name": "Arsicault Bakery", "scope": "GOOGLE", "types": ["bakery", "store", "point_of_interest", "food", "establishment"], "photos": [{"width": 4032, "height": 3024, "photoReference": "CmRaAAAAKoBXgRTdci9cgvQfq5Rm2ggumOdBTDhc9Y3TfwL5MSYz2UXbDj3f1cANI9ZS-0dn7FYxbtnwTyeZWKitq8R8JH5y2oMQ7K3r3f_xg4SLgslsJ0RsrXx9LzagMj9RhUFYEhAAQYDrNkb4wLzSJ8g0ONqzGhQ2Xa-nC0XOAKQxlgQpymEbhEZpRQ", "htmlAttributions": ["<a href=\"https://maps.google.com/maps/contrib/107804730062611548783/photos\">Taka Lee</a>"]}, {"width": 4032, "height": 3024, "photoReference": "CmRaAAAAphsVxVGqfE9IMMzfEs3EqW9cqakJJ2xa8DS1uvmDxTEIVeCOc2lZKrY0LWZev1xQ8XMRz8SEzC6OxFGNBEVkQHjSBUO75i5NHEfEnFInz-Tht6DLDDT7Q545pMPw4uKXEhCxZkURzttjy19u9aT3hmzVGhQc1E2pT7ENhvc3MDd58PhAiATpEw", "htmlAttributions": ["<a href=\"https://maps.google.com/maps/contrib/106896130956977876473/photos\">Patrick Gaarder</a>"]}, {"width": 6000, "height": 4000, "photoReference": "CmRaAAAATYpM2nP5mgj7T8_UohToprCvPJXxNpGydu1CCnkB5LMUFrtCeqKIBUfMkgZi_19PmzkC6C6xuYVqnZjwgLJIVXk9-Fx0G-Hvy4Cap0nk9v4SmB6XxoZ1QazMEg1GTbfVEhBXDc2K8gLCDEIRU_iB_uugGhSoqEE2o0JlLpv5j9HQNwLjdRm_2w", "htmlAttributions": ["<a href=\"https://maps.google.com/maps/contrib/116721167766263993432/photos\">Raymond Kim</a>"]}, {"width": 5248, "height": 2952, "photoReference": "CmRaAAAAiKVLe2EJ3JsfdKXAD5_qbnYqZ4RbWOv6EYqFXDq_xtMX96Y9jvmk2Jk_lph1XYqn61onr86oWXzlWDsS9IyidBuJuh8iLyjfnJhCL6ngARDczZUyj1Uiehl_OUFuupTEEhCZlSbsFI1mg9CLtHVdquZsGhSxKHrklnwBFhMcKc8Ptq0D1ExH3g", "htmlAttributions": ["<a href=\"https://maps.google.com/maps/contrib/115792997195009882813/photos\">Alphonzo Solorzano</a>"]}, {"width": 3120, "height": 3120, "photoReference": "CmRaAAAA0f2MvgvOeUPuI97Am2DZvbeHOEd6gKE6KM6mr3qQ-yLWicjpf5FXLldksaQElF-AvK7gBP2llTT61NBk6oHcYLAd78wwVVXA-VJ5KflPQPQQ5Xnx8pUGSARaWx9XgutxEhCdnSDujWFCA51mNct2oHxxGhTLk4LksWychp8pX99q3Ry2K6KsrQ", "htmlAttributions": ["<a href=\"https://maps.google.com/maps/contrib/102450396732922446059/photos\">Yejee Jeong</a>"]}, {"width": 3024, "height": 4032, "photoReference": "CmRaAAAAvSZMpXE9nPI6RRbE2P3GTM0RcnYuYf66gu6sV3WnnKY8polrlL4wsWNNJzoeT-MkyB4Ni5P3nPpAWeIYIWdeLNRM-eWIkOsFtYwF0ebtrbd5pxk4VJJ01l1K6z5tvo46EhBpnitCFZVMKBrvhaf10YZaGhTt5JpLFaDmlyBsXBHeFpKEqais3A", "htmlAttributions": ["<a href=\"https://maps.google.com/maps/contrib/112201285987403588477/photos\">Sean Ivester</a>"]}, {"width": 2536, "height": 3034, "photoReference": "CmRaAAAA40DTuvdi9Dw54ZuZKh3ZrA9foLOsEPZrKtUC0O9TyX0_c7BYbglb7ZkFBP8sYyjMRxCcc7EvxEs819NfmNZQ28G6V2x9EjD_vBXPD6bzYG4AHc2vreYobBTkuQigwYMmEhCcAkioCS24r0p44FexKM0PGhRuafk9jvgGhNF2i8gIGy9JkOwZvg", "htmlAttributions": ["<a href=\"https://maps.google.com/maps/contrib/117690109757598397593/photos\">John K</a>"]}, {"width": 4032, "height": 3024, "photoReference": "CmRaAAAAyWy5YvkUV0M3txVtkLEchD0WtHDusTRXSdwXBHGwQS4VnKbpUO-F4GM-KRw3yIf4piqI3qjhiaZOvaCtV9DKFhJ9qmKMbkiK6ObVdzaoakGThRtAH5ret0Ojxs68qYWZEhDqmK9FXB2eOHhH7H5XqPJsGhTBCNpJ1bTC6sovHwFQchOIBvUPUw", "htmlAttributions": ["<a href=\"https://maps.google.com/maps/contrib/106999574867187049818/photos\">Achilles Young</a>"]}, {"width": 5248, "height": 2952, "photoReference": "CmRaAAAAH4znimf7zl1sOCAf7itfkAHdOArlRDZSXsMPyOk9G9tI04-7khARaT9h9dU_KY5u6E5p-iYiAKjBpVzCfH3XPml0ksHsZMhjGQ_edchfc6sNMZTZwT5WtkopwftAOC7sEhCqA2OocIpaqA8uC7l-d9X9GhRYd2c02itkAy0JOicf8Htjw-cU_g", "htmlAttributions": ["<a href=\"https://maps.google.com/maps/contrib/115792997195009882813/photos\">Alphonzo Solorzano</a>"]}, {"width": 3024, "height": 4032, "photoReference": "CmRaAAAAGMquv8aQxN2xBQHxupeWfp2lmkjel2yw-5WZxWMcgzx82ijlCPvltR_LsRbrVzJSWLpjTWUKbuqd4u5kgmLZ6CsKYyEyPARuiX8dFt_lxtC3fxEQaChNvunEeTZTJnQvEhDCdHODvqKzDXXdI377WKQ4GhQnmwMZd1zr7c83zvFoRye9pTGy8g", "htmlAttributions": ["<a href=\"https://maps.google.com/maps/contrib/109776618474634873591/photos\">Nha Ha</a>"]}], "rating": 4.8, "placeId": "ChIJJ09d9DmHhYARkrToDt9JCy8", "reviews": [{"text": "Best croissants I’ve ever had— hands down. Every bite of their almond croissant is perfectly crunchy and contains the perfect ratio of croissant-to-almond filling. They have their reputation for a reason. I’ve tried the chocolate and plain croissants as well and the skill and perfection permeated to these as well. On the weekends the shop is likely to have a line, but it is undoubtedly worth the wait. I’ve waited in line for 15 minutes only to go back and wait again minutes later after sharing a croissant and coffee with a friend. Arsicault is at the top of my list for every time I visit SF. It is well worth the trip from other parts of the Bay Area, let alone SF.", "time": 1546235769, "rating": 5, "language": "en", "authorUrl": "https://www.google.com/maps/contrib/112193550675921220749/reviews", "authorName": "Rachel Abreau", "profilePhotoUrl": "https://lh4.googleusercontent.com/-2ybBhrwgbMA/AAAAAAAAAAI/AAAAAAAABd4/e6RulDMwaRc/s128-c0x00000000-cc-rp-mo/photo.jpg", "relativeTimeDescription": "3 months ago"}, {"text": "Came in a few weeks back on a whim to try out Ariz's pizza and was pleasantly surprised. For $2.75 you get a large slice of freshly made pizza.  The make one type per day, with the month's schedule of pizza listed on their web site.  The pizza is made with organic, sourdough crust, whole-milk mozzarella and organic veggies.  The crust is nicely baked (as to be expected) and has a solid but \"fold-able\" NYC quality to it.", "time": 1548994546, "rating": 4, "language": "en", "authorUrl": "https://www.google.com/maps/contrib/103414747105426205125/reviews", "authorName": "Millern Maxiner", "profilePhotoUrl": "https://lh4.googleusercontent.com/-vD7Vv1TEj2M/AAAAAAAAAAI/AAAAAAAAAAk/QodqlC9OttM/s128-c0x00000000-cc-rp-mo/photo.jpg", "relativeTimeDescription": "2 months ago"}, {"text": "This place is a gem. Be sure to come at least an hour before they close. Sometimes they run out of everything before closing time and you'll be supremely disappointed. \nThat said, these are possibly the best croissants I've ever had, including France... \nStreamlined system for line and payment, a bit pricey but it's worth it. Would drive across the bridge for these.", "time": 1550448230, "rating": 5, "language": "en", "authorUrl": "https://www.google.com/maps/contrib/118070060007066682173/reviews", "authorName": "Vivi Mage", "profilePhotoUrl": "https://lh3.googleusercontent.com/-rKbOsRZxvrA/AAAAAAAAAAI/AAAAAAAACnA/5lPHhHlRCb8/s128-c0x00000000-cc-rp-mo-ba5/photo.jpg", "relativeTimeDescription": "a month ago"}, {"text": "Great croissants. There's more filling in the chocolate almond than usual and it's quite sweet. It's still very tasty and great for sharing, but might be better suited for sharing.", "time": 1551228695, "rating": 5, "language": "en", "authorUrl": "https://www.google.com/maps/contrib/103932773735124084664/reviews", "authorName": "Joshua Hsiao", "profilePhotoUrl": "https://lh4.googleusercontent.com/-XB-X1zHF1Og/AAAAAAAAAAI/AAAAAAAAAAA/ACHi3rd7H5R13PG7__AwIuhPUir9eUbT2w/s128-c0x00000000-cc-rp-mo-ba3/photo.jpg", "relativeTimeDescription": "a month ago"}, {"text": "The best croissants in the country. They are so flaky on the outside, but so buttery and soft on the inside. You can't go wrong with anything on the menu. Need to get there early as the line forms fast, but its well worth it. the owner Armando is very friendly and often comes out to meet and greet with his customers.", "time": 1544587942, "rating": 5, "language": "en", "authorUrl": "https://www.google.com/maps/contrib/105072099058933517160/reviews", "authorName": "Kyle Beikirch", "profilePhotoUrl": "https://lh6.googleusercontent.com/-YOmGfy4pUR0/AAAAAAAAAAI/AAAAAAAAEng/aLtDU6h4TqI/s128-c0x00000000-cc-rp-mo-ba5/photo.jpg", "relativeTimeDescription": "3 months ago"}], "geometry": {"location": {"lat": 37.7834259, "lng": -122.4593062}}, "vicinity": "397 Arguello Boulevard, San Francisco", "reference": "ChIJJ09d9DmHhYARkrToDt9JCy8", "utcOffset": -420, "priceLevel": 2, "connectorType": "GOOGLE", "opening_hours": {"openNow": false, "periods": [], "weekdayText": null}, "formattedAddress": "397 Arguello Blvd, San Francisco, CA 94118, USA", "addressComponents": [{"types": ["street_number"], "longName": "397", "shortName": "397"}, {"types": ["route"], "longName": "Arguello Boulevard", "shortName": "Arguello Blvd"}, {"types": ["neighborhood", "political"], "longName": "Inner Richmond", "shortName": "Inner Richmond"}, {"types": ["locality", "political"], "longName": "San Francisco", "shortName": "SF"}, {"types": ["administrative_area_level_2", "political"], "longName": "San Francisco County", "shortName": "San Francisco County"}, {"types": ["administrative_area_level_1", "political"], "longName": "California", "shortName": "CA"}, {"types": ["country", "political"], "longName": "United States", "shortName": "US"}, {"types": ["postal_code"], "longName": "94118", "shortName": "94118"}], "formattedPhoneNumber": "(415) 750-9460", "internationalPhoneNumber": "+1 415-750-9460"}
 ▿ 2 : 2 elements
 - key : "updatedAt"
 - value : 2019-04-02T05:28:36.000Z
 ▿ 3 : 2 elements
 - key : "createdAt"
 - value : 2019-04-02T05:28:36.000Z
 ▿ 4 : 2 elements
 - key : "id"
 - value : 1
 ▿ 5 : 2 elements
 - key : "connectorType"
 - value : GOOGLE
 ▿ 6 : 2 elements
 - key : "connectorId"
 - value : ChIJJ09d9DmHhYARkrToDt9JCy8

 */
