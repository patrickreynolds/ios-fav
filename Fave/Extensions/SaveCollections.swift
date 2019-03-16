import Foundation

extension Array {
    subscript (safe index: Int) -> Element? {
        guard index >= 0 && index < count else {
            return nil
        }

        return self[index]
    }

    func mapMaybe<T>(_ transform: (Element) -> T?) -> [T] {
        var mappedArray = [T]()
        mappedArray.reserveCapacity(self.count)

        for element in self {
            if let mappedElement = transform(element) {
                mappedArray.append(mappedElement)
            }
        }

        return mappedArray
    }

    func find(_ isMatchingElement: ((Element) -> Bool)) -> Element? {
        for element in self {
            if isMatchingElement(element) {
                return element
            }
        }

        return nil
    }
}

extension Dictionary {
    subscript (safe key: Key) -> Value? {
        return self[key]
    }
}
