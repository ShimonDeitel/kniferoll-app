import Foundation

struct KnifeItem: Identifiable, Codable, Equatable {
    var id: UUID = UUID()
    var name: String
    var steelType: String
    var sharpened: String
    var notes: String = ""
    var dateAdded: Date = Date()
    var isFavorite: Bool = false
}
