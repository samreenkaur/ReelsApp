import RealmSwift

class RealmManager {
    static let shared = RealmManager()
    private let realm = try! Realm()
    
    func save<T: Object>(_ objects: [T]) {
        try? realm.write {
            realm.add(objects, update: .all)
        }
    }
    
    func fetchAll<T: Object>(_ type: T.Type) -> [T] {
        return Array(realm.objects(type))
    }
    
    func update(_ block: (Realm) -> Void) {
        let realm = getRealm()
        do {
            try realm.write {
                block(realm)
            }
        } catch {
            print("❌ Realm write error: \(error)")
        }
    }
    
    func getRealm() -> Realm {
        return realm
    }
}
