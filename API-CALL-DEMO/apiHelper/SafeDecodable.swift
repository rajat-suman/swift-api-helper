import Foundation

@propertyWrapper
struct SafeDecodable<T: Decodable>: Decodable {
    var wrappedValue: T?

    init(wrappedValue: T?) {
        self.wrappedValue = wrappedValue
    }

    init(from decoder: Decoder)  throws {
        let container =  try decoder.singleValueContainer()
        wrappedValue = try? container.decode(T.self)
    }

}

extension KeyedDecodingContainer {
    func decode<T: Decodable>(_ type: SafeDecodable<T>.Type, forKey key: Key) -> SafeDecodable<T> {
        return (try? decodeIfPresent(type, forKey: key)) ?? SafeDecodable(wrappedValue: nil)
    }
}

