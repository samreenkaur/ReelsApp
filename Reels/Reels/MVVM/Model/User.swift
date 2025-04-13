import RealmSwift

class User: EmbeddedObject, ObjectKeyIdentifiable {
    @Persisted var id: String = UUID().uuidString
    @Persisted var username: String = ""
}
