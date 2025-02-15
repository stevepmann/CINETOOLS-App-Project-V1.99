import Foundation

struct KitSetup: Identifiable, Codable, Equatable {
    let id: UUID
    let name: String
    var brand: Int
    var model: Int
    var accessories: Set<Int>
    var isActive: Bool
} 