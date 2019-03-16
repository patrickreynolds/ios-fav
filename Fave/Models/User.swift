import Foundation

class User: NSObject, NSCoding {
    let id: Int
    let firstName: String
    let lastName: String
    let email: String
    let handle: String
    let profilePicture: NSData


    init(id: Int,
        firstName: String,
        lastName: String,
        email: String,
        handle: String,
        profilePicture: NSData) {

        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.handle = handle
        self.profilePicture = profilePicture

        super.init()
    }

    convenience init?(data: [String: AnyObject]) {
        guard let unwrappedId = data["id"] as? Int,
            let unwrappedFirstName = data["firstName"] as? String,
            let unwrappedLastName = data["lastName"] as? String,
            let unwrappedEmail = data["email"] as? String,
            let unwrappedHandle = data["handle"] as? String,
            let unwrappedProfilePictureString = data["profilePic"] as? String,
            let unwrappedProfilePicture = NSData(base64Encoded: unwrappedProfilePictureString, options: NSData.Base64DecodingOptions.ignoreUnknownCharacters) else {
                return nil
        }

        self.init(id: unwrappedId,
            firstName: unwrappedFirstName,
            lastName: unwrappedLastName,
            email: unwrappedEmail,
            handle: unwrappedHandle,
            profilePicture: unwrappedProfilePicture)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.firstName, forKey: "firstName")
        aCoder.encode(self.lastName, forKey: "lastName")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.handle, forKey: "handle")
        aCoder.encode(self.profilePicture, forKey: "profilePic")
    }

    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as! Int
        firstName = aDecoder.decodeObject(forKey: "firstName") as! String
        lastName = aDecoder.decodeObject(forKey: "lastName") as! String
        email = aDecoder.decodeObject(forKey: "email") as! String
        handle = aDecoder.decodeObject(forKey: "handle") as! String
        profilePicture = aDecoder.decodeObject(forKey: "profilePic") as! NSData
    }
}

extension User {
    static func ==(lhs: User, rhs: User) -> Bool {
        return lhs.id == rhs.id &&
            lhs.firstName == rhs.firstName &&
            lhs.lastName == rhs.lastName &&
            lhs.email == rhs.email &&
            lhs.handle == rhs.handle &&
            lhs.profilePicture == rhs.profilePicture
    }
}
