import Foundation

struct Repository: Codable {
    var name: String
    let owner: Owner
    let html_url: URL
}
