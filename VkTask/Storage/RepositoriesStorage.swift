import Foundation

class RepositoryStorage {
    
    private let key = "repositories"

    func saveRepositories(_ repositories: [Repository]) {
        let encoder = JSONEncoder()
        if let encoded = try? encoder.encode(repositories) {
            UserDefaults.standard.set(encoded, forKey: key)
        }
    }

    func loadRepositories() -> [Repository] {
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        let decoder = JSONDecoder()
        return (try? decoder.decode([Repository].self, from: data)) ?? []
    }
}

