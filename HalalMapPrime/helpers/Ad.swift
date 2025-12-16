import Foundation

struct Ad: Identifiable, Hashable, Codable {

    enum Tier: String, Codable {
        case free, standard, prime

        var priority: Int {
            switch self {
            case .free: return 0
            case .standard: return 1
            case .prime: return 2
            }
        }
    }

    enum Status: String, Codable {
        case pending, active, paused, expired
    }

    let id: String
    let placeId: String
    let imagePaths: [String]   // local filenames الآن
    let tier: Tier
    let status: Status
    let createdAt: Date

    init(
        id: String = UUID().uuidString,
        placeId: String,
        imagePaths: [String],
        tier: Tier,
        status: Status = .active,
        createdAt: Date = Date()
    ) {
        self.id = id
        self.placeId = placeId
        self.imagePaths = Array(imagePaths.prefix(3))
        self.tier = tier
        self.status = status
        self.createdAt = createdAt
    }
}
