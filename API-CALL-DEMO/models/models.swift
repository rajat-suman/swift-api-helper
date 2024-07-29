import Foundation

struct User: Decodable , Identifiable{
    @SafeDecodable var id: Int? = nil
    @SafeDecodable var name: String? = nil
    @SafeDecodable var name_ar: String? = nil
    @SafeDecodable var email: Int? = nil
    
    
    func getNameToShow(lang:String)->String{
        if lang=="ar"{
            return name_ar ?? ""
        }
        else {
            return name ?? ""
        }
    }
}


struct PostMy: Decodable, Identifiable {
    @SafeDecodable var userId: Int?
    @SafeDecodable var id: Int?
    @SafeDecodable var title: String?
    @SafeDecodable var body: String?
}
