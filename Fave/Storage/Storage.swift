import Foundation

import Fabric
import Crashlytics

enum StorageKey: String {
    case currentUser
}

protocol StorageType {
    func saveUser(user: User)
    func getUser() -> User?
    func deleteUser()
}

struct TemporaryStorage {
    private let userDefaults = UserDefaults()

    init(appConfiguration: AppConfiguration) {}

    func saveUser(user: User) {
        userDefaults.set(user.id, forKey: "\(StorageKey.currentUser.rawValue).id))")
        userDefaults.set(user.firstName, forKey: "\(StorageKey.currentUser.rawValue).firstName))")
        userDefaults.set(user.lastName, forKey: "\(StorageKey.currentUser.rawValue).lastName))")
        userDefaults.set(user.email, forKey: "\(StorageKey.currentUser.rawValue).email))")
        userDefaults.set(user.handle, forKey: "\(StorageKey.currentUser.rawValue).handle))")
        userDefaults.set(user.profilePicture, forKey: "\(StorageKey.currentUser.rawValue).profilePicture))")
        userDefaults.set(user.createdAt, forKey: "\(StorageKey.currentUser.rawValue).createdAt))")
        userDefaults.set(user.updatedAt, forKey: "\(StorageKey.currentUser.rawValue).updatedAt))")

        userDefaults.synchronize()

        Crashlytics.sharedInstance().setUserIdentifier("\(user.id)")

        print("\n\nUser saved!\n\n")
    }

    func getUser() -> User? {
        let id = userDefaults.object(forKey: "\(StorageKey.currentUser.rawValue).id))") as? Int
        let firstName = userDefaults.object(forKey: "\(StorageKey.currentUser.rawValue).firstName))") as? String
        let lastName = userDefaults.object(forKey: "\(StorageKey.currentUser.rawValue).lastName))") as? String
        let email = userDefaults.object(forKey: "\(StorageKey.currentUser.rawValue).email))") as? String
        let handle = userDefaults.object(forKey: "\(StorageKey.currentUser.rawValue).handle))") as? String
        let profilePicture = userDefaults.object(forKey: "\(StorageKey.currentUser.rawValue).profilePicture))") as? String
        let createdAt = userDefaults.object(forKey: "\(StorageKey.currentUser.rawValue).createdAt))") as? String
        let updatedAt = userDefaults.object(forKey: "\(StorageKey.currentUser.rawValue).updatedAt))") as? String

        guard let unwrappedId = id,
            let unwrappedFirstName = firstName,
            let unwrappedLastName = lastName,
            let unwrappedEmail = email,
            let unwrappedHandle = handle,
            let unwrappedProfilePicture = profilePicture,
            let unwrappedCreatedAt = createdAt,
            let unwrappedUpdatedAt = updatedAt else {
                return nil
        }

        return User(id: unwrappedId,
                    firstName: unwrappedFirstName,
                    lastName: unwrappedLastName,
                    email: unwrappedEmail,
                    handle: unwrappedHandle,
                    profilePicture: unwrappedProfilePicture,
                    createdAt: unwrappedCreatedAt,
                    updatedAt: unwrappedUpdatedAt)
    }

    func deleteUser() {
        userDefaults.removeObject(forKey: "\(StorageKey.currentUser.rawValue).id))")
        userDefaults.removeObject(forKey: "\(StorageKey.currentUser.rawValue).firstName))")
        userDefaults.removeObject(forKey: "\(StorageKey.currentUser.rawValue).lastName))")
        userDefaults.removeObject(forKey: "\(StorageKey.currentUser.rawValue).email))")
        userDefaults.removeObject(forKey: "\(StorageKey.currentUser.rawValue).handle))")
        userDefaults.removeObject(forKey: "\(StorageKey.currentUser.rawValue).profilePicture))")
        userDefaults.removeObject(forKey: "\(StorageKey.currentUser.rawValue).createdAt))")
        userDefaults.removeObject(forKey: "\(StorageKey.currentUser.rawValue).updatedAt))")

        Crashlytics.sharedInstance().setUserIdentifier("")
    }
}

extension TemporaryStorage: StorageType {}
