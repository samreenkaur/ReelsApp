// MARK: - Reel.swift (Realm Model)
import Foundation
import RealmSwift

class Reel: Object {
    @objc dynamic var id: String = ""
    @objc dynamic var mediaURL: String = ""
    @objc dynamic var isVideo: Bool = false
    @objc dynamic var isLiked: Bool = false
    @objc dynamic var isMuted: Bool = false

    override static func primaryKey() -> String? {
        return "id"
    }
}
