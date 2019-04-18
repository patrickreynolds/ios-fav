import Foundation

enum StorageKey: String {
    case currentUser
}

protocol StorageType {
    func saveUser(user: User)
    func getUser() -> User?
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

        userDefaults.synchronize()

        print("\n\nUser saved!\n\n")
    }

    func getUser() -> User? {
        let id = userDefaults.object(forKey: "\(StorageKey.currentUser.rawValue).id))") as? Int
        let firstName = userDefaults.object(forKey: "\(StorageKey.currentUser.rawValue).firstName))") as? String
        let lastName = userDefaults.object(forKey: "\(StorageKey.currentUser.rawValue).lastName))") as? String
        let email = userDefaults.object(forKey: "\(StorageKey.currentUser.rawValue).email))") as? String
        let handle = userDefaults.object(forKey: "\(StorageKey.currentUser.rawValue).handle))") as? String
        let profilePicture = userDefaults.object(forKey: "\(StorageKey.currentUser.rawValue).profilePicture))") as? String

        guard let unwrappedId = id,
            let unwrappedFirstName = firstName,
            let unwrappedLastName = lastName,
            let unwrappedEmail = email,
            let unwrappedHandle = handle,
            let unwrappedProfilePicture = profilePicture else {
                return nil
        }

        return User(id: unwrappedId,
                    firstName: unwrappedFirstName,
                    lastName: unwrappedLastName,
                    email: unwrappedEmail,
                    handle: unwrappedHandle,
                    profilePicture: unwrappedProfilePicture)
    }
}

extension TemporaryStorage: StorageType {}
