
import Foundation
import CommonCrypto

var encryptionIV = "n9sQ1xJlwVIDXfxk"

class Encryption {
    static let shared = Encryption()

    private init() {
        
    }
    
    func encryptData(parameter:[String:Any]) -> [String:String] {
        var hash = ""
        var sek = ""
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: parameter,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
            let valuesss = encryption1(iv: theJSONText!)
            hash = valuesss.hash
            sek = valuesss.sek
        }
        let parameters = ["hash" : hash, "sek": sek]
        return parameters
    }
    func encryptHeaderData(parameter:[String:Any]) -> [String:String] {
        var hash = ""
        var sek = ""
        let myTimeStamp = Date().timeIntervalSince1970
        let utcString = Date(timeIntervalSince1970: myTimeStamp).toUTCString()
        
        let dateFormatter = ISO8601DateFormatter()
            dateFormatter.formatOptions = [.withInternetDateTime, .withFractionalSeconds]
            let dateString = dateFormatter.string(from: Date())

        var params = parameter
        params.updateValue(dateString, forKey: "appKey")
        if let theJSONData = try? JSONSerialization.data(
            withJSONObject: params,
            options: []) {
            let theJSONText = String(data: theJSONData,
                                     encoding: .ascii)
            let valuesss = encryption2(iv: theJSONText!)
            hash = valuesss.hash
            sek = valuesss.sek
        }
        let parameters = ["hash" : hash, "sek": sek, "deviceType": "ios"]
        return parameters
    }
}

class AESUtil {
    private static let CHARACTER_ENCODING = String.Encoding.utf8
    private static let iv: Data = encryptionIV.data(using: CHARACTER_ENCODING)!
    private static let cipher = "AES/CBC/PKCS5Padding"
    static func secKeyEncryptWithAppKey(dictionary : String) -> [String: String]? {
        do {
            var key = [UInt8](repeating: 0, count: 32)
            _ = SecRandomCopyBytes(kSecRandomDefault, key.count, &key)
            let randomString = getRandomString(length: 32).data(using: CHARACTER_ENCODING)!
            let encrypted = try encrypt(data: randomString, key: key)
            let dataHold = dictionary.data(using: CHARACTER_ENCODING)!
            let encrypted1 = try encrypt(data: dataHold, key: key)
            let sdf = DateFormatter()
            sdf.dateFormat = "yyyy-MM-d’T’HH:mm:ssZ"
            sdf.timeZone = TimeZone(identifier: "UTC")
            let formattedDate = sdf.string(from: Date())
            let matchencryp = try encrypt(data: formattedDate.data(using: CHARACTER_ENCODING)!, key: key)
            var result = [String: String]()
            result["encryptedData"] = encrypted.hexEncodedString()
            result["randomString"] = String(data: randomString, encoding: CHARACTER_ENCODING)!
            result["appKey"] = Data(key).hexEncodedString()
            result["matchdate"] = matchencryp.hexEncodedString()
            result["dataEncryt"] = encrypted1.hexEncodedString()
            return result
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    static func secKeyHeaderEncryptWithAppKey(dictionary : String) -> [String: String]? {
        do {
            var key = [UInt8](repeating: 0, count: 32)
            _ = SecRandomCopyBytes(kSecRandomDefault, key.count, &key)
            let randomString = getRandomString(length: 32).data(using: CHARACTER_ENCODING)!
            let encrypted = try encrypt(data: randomString, key: key)
            let dataHold = dictionary.data(using: CHARACTER_ENCODING)!
            let encrypted1 = try encrypt(data: dataHold, key: key)
            let sdf = DateFormatter()
            sdf.dateFormat = "yyyy-MM-d’T’HH:mm:ssZ"
            sdf.timeZone = TimeZone(identifier: "UTC")
            let formattedDate = sdf.string(from: Date())
            let matchencryp = try encrypt(data: formattedDate.data(using: CHARACTER_ENCODING)!, key: key)
            var result = [String: String]()
            result["encryptedData"] = encrypted.hexEncodedString()
            result["randomString"] = String(data: randomString, encoding: CHARACTER_ENCODING)!.lowercased()
            result["appKey"] = Data(key).hexEncodedString().lowercased()
            result["matchdate"] = matchencryp.hexEncodedString().lowercased()
            result["dataEncryt"] = encrypted1.hexEncodedString().lowercased()
            return result
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    private static func encrypt(data: Data, key: [UInt8]) throws -> Data {
        let cryptLength = size_t(data.count + kCCBlockSizeAES128)
        var cryptData = Data(count: cryptLength)
        let keyLength = size_t(kCCKeySizeAES256)
        let options = CCOptions(kCCOptionPKCS7Padding)
        var numBytesEncrypted: size_t = 0
        let cryptStatus = key.withUnsafeBytes { keyBytes in
            iv.withUnsafeBytes { ivBytes in
                data.withUnsafeBytes { dataBytes in
                    cryptData.withUnsafeMutableBytes { cryptBytes in
                        CCCrypt(CCOperation(kCCEncrypt),
                                CCAlgorithm(kCCAlgorithmAES),
                                options,
                                keyBytes.baseAddress,
                                keyLength,
                                ivBytes.baseAddress,
                                dataBytes.baseAddress,
                                dataBytes.count,
                                cryptBytes.baseAddress,
                                cryptLength,
                                &numBytesEncrypted)
                    }
                }
            }
        }
        
        guard cryptStatus == kCCSuccess else {
            throw NSError(domain: "encryption.error", code: Int(cryptStatus), userInfo: nil)
        }
        cryptData.removeSubrange(numBytesEncrypted..<cryptData.count)
        return cryptData
    }
    private static func getRandomString(length: Int) -> String {
        let allowedChars = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789")
        var randomString = ""
        for _ in 0..<length {
            let randomIndex = Int(arc4random_uniform(UInt32(allowedChars.count)))
            randomString.append(allowedChars[randomIndex])
        }
        return randomString
    }
    private static func hexStringToByteArray(_ hexString: String) -> [UInt8] {
        var hex = hexString
        var byteArray = [UInt8]()
        while !hex.isEmpty {
            let hexByte = String(hex.prefix(2))
            hex = String(hex.dropFirst(2))
            if let byte = UInt8(hexByte, radix: 16) {
                byteArray.append(byte)
            }
        }
        return byteArray
    }
}

extension Encryption {
    func encryption1(iv: String) -> EncryptionModel {
        let values = AESUtil.secKeyEncryptWithAppKey(dictionary: iv)
        let hash = values?["appKey"] ?? ""
        let sek = values?["encryptedData"] ?? ""
        let matchkey = values?["randomString"] ?? ""
        let formateddate = values?["matchdate"] ?? ""
        let dataEncryp = values?["dataEncryt"] ?? ""
        let dataa : EncryptionModel = EncryptionModel.init(hash: hash, sek: dataEncryp , match: matchkey, appkey: formateddate)
        return dataa
    } 
    func encryption2(iv: String) -> EncryptionModel {
        let values = AESUtil.secKeyHeaderEncryptWithAppKey(dictionary: iv)
        let hash = values?["appKey"] ?? ""
        let sek = values?["encryptedData"] ?? ""
        let matchkey = values?["randomString"] ?? ""
        let formateddate = values?["matchdate"] ?? ""
        let dataEncryp = values?["dataEncryt"] ?? ""
        let dataa : EncryptionModel = EncryptionModel.init(hash: hash, sek: dataEncryp , match: matchkey, appkey: formateddate)
        return dataa
    }
    
    func randomString(length: Int) -> String {
        let letters = "abcdefghijklmnopqrstuvwxyz1234567890"
        return String((0..<length).map{ _ in letters.randomElement()! })
    }
}

extension Data {
    func hexEncodedString() -> String {
        let hexDigits = Array("0123456789abcdef")
        var hexString = ""
        for byte in self {
            let hexByte = [hexDigits[Int(byte >> 4)], hexDigits[Int(byte & 0x0F)]]
            hexString.append(contentsOf: hexByte)
        }
        return hexString
    }
}

struct EncryptionModel {
    let hash : String
    let sek : String
    let match : String
    let appkey : String
}

extension Date {
    func toUTCString() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        return dateFormatter.string(from: self)
    }
}
