import Foundation

class User: NSObject, NSCoding {
    let id: Int
    @objc let firstName: String
    @objc let lastName: String
    @objc let email: String
    @objc let handle: String
    let profilePicture: String


    init(id: Int,
        firstName: String,
        lastName: String,
        email: String,
        handle: String,
        profilePicture: String) {

        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.handle = handle
        self.profilePicture = profilePicture

        super.init()
    }

    convenience init?(data: [String: AnyObject]) {
        guard let unwrappedId = data["id"] as? Int else {
            return nil
        }

        guard let unwrappedFirstName = data["firstName"] as? String else {
            return nil
        }

        guard let unwrappedLastName = data["lastName"] as? String else {
            return nil
        }

        guard let unwrappedHandle = data["handle"] as? String else {
            return nil
        }

        guard let unwrappedProfilePictureString = data["profilePic"] as? String else {
            return nil
        }

        let unwrappedEmail = data["email"] as? String ?? ""

        self.init(id: unwrappedId,
            firstName: unwrappedFirstName,
            lastName: unwrappedLastName,
            email: unwrappedEmail,
            handle: unwrappedHandle,
            profilePicture: unwrappedProfilePictureString)
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
        profilePicture = aDecoder.decodeObject(forKey: "profilePic") as! String
    }
}

//extension User {
//    static func ==(lhs: User, rhs: User) -> Bool {
//        return lhs.id == rhs.id &&
//            lhs.firstName == rhs.firstName &&
//            lhs.lastName == rhs.lastName &&
//            lhs.email == rhs.email &&
//            lhs.handle == rhs.handle &&
//            lhs.profilePicture == rhs.profilePicture
//    }
//}
