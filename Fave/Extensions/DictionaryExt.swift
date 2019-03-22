import Foundation

extension Dictionary {
    // Return a new dictionary with values from `self` and `other`.  For duplicate keys, other wins.
    func combinedWith(_ other: [Key: Value]) -> [Key: Value] {
        var combined = self
        for (key, value) in other {
            combined[key] = value
        }
        return combined
    }
}

func + <Key, Value>(lhs: [Key: Value], rhs: [Key: Value]) -> [Key: Value] {
    return lhs.combinedWith(rhs)
}
