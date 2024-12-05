import Foundation

protocol GitHubLoaderProtocol {
    func loadRepositories(for page: Int, handler: @escaping (Result<[Repository], Error>) -> Void)
}

struct GitHubLoader: GitHubLoaderProtocol {
    private let networkClient: NetworkClientProtocol
    
    init(networkClient: NetworkClientProtocol = NetworkClient()) {
        self.networkClient = networkClient
    }
    
    private func repositoriesUrl(for page: Int) -> URL {
        guard let url = URL(string: "https://api.github.com/search/repositories?q=swift&sort=stars&order=asc&page=\(page)") else {
            preconditionFailure("Unable to construct repositoriesUrl")
        }
        return url
    }
    
    func loadRepositories(for page: Int, handler: @escaping (Result<[Repository], Error>) -> Void) {
        networkClient.fetch(url: repositoriesUrl(for: page)) { result in
            switch result {
            case .success(let data):
                do {
                    let searchResult = try JSONDecoder().decode(GitHubSearchResult.self, from: data)
                    handler(.success(searchResult.items))
                } catch {
                    handler(.failure(error))
                }
            case .failure(let error):
                handler(.failure(error))
            }
        }
    }
}

