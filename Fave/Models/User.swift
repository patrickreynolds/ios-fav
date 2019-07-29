import Foundation

class User: NSObject, NSCoding {
    let id: Int
    @objc let firstName: String
    @objc let lastName: String
    @objc let email: String
    @objc let handle: String
    @objc let profilePicture: String
    @objc let createdAt: String
    @objc let updatedAt: String

    init(id: Int,
        firstName: String,
        lastName: String,
        email: String,
        handle: String,
        profilePicture: String,
        createdAt: String,
        updatedAt: String) {

        self.id = id
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.handle = handle
        self.profilePicture = profilePicture
        self.createdAt = createdAt
        self.updatedAt = updatedAt

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

        var createdAtString = ""

        if let unwrappedCreatedAtString = data["createdAt"] as? String {
            createdAtString = unwrappedCreatedAtString
        }

        var updatedAtString = ""
        if let unwrappedUpdatedAtString = data["updatedAt"] as? String {
            updatedAtString = unwrappedUpdatedAtString
        }

        let unwrappedEmail = data["email"] as? String ?? ""

        self.init(id: unwrappedId,
            firstName: unwrappedFirstName,
            lastName: unwrappedLastName,
            email: unwrappedEmail,
            handle: unwrappedHandle,
            profilePicture: unwrappedProfilePictureString,
            createdAt: createdAtString,
            updatedAt: updatedAtString)
    }

    func encode(with aCoder: NSCoder) {
        aCoder.encode(self.id, forKey: "id")
        aCoder.encode(self.firstName, forKey: "firstName")
        aCoder.encode(self.lastName, forKey: "lastName")
        aCoder.encode(self.email, forKey: "email")
        aCoder.encode(self.handle, forKey: "handle")
        aCoder.encode(self.profilePicture, forKey: "profilePic")
        aCoder.encode(self.createdAt, forKey: "createdAt")
        aCoder.encode(self.updatedAt, forKey: "updatedAt")
    }

    required init?(coder aDecoder: NSCoder) {
        id = aDecoder.decodeObject(forKey: "id") as! Int
        firstName = aDecoder.decodeObject(forKey: "firstName") as! String
        lastName = aDecoder.decodeObject(forKey: "lastName") as! String
        email = aDecoder.decodeObject(forKey: "email") as! String
        handle = aDecoder.decodeObject(forKey: "handle") as! String
        profilePicture = aDecoder.decodeObject(forKey: "profilePic") as! String
        createdAt = aDecoder.decodeObject(forKey: "createdAt") as! String
        updatedAt = aDecoder.decodeObject(forKey: "updatedAt") as! String
    }
}
