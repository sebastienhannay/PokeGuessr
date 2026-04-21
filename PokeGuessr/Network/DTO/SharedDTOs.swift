import Foundation

struct NamedAPIResource: Codable {
    let name: String
    let url: String
}

struct APIResource: Codable {
    let url: String
}
