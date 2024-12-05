import Foundation

protocol RepositoriesInteractorProtocol {
    func fetchRepositories(page: Int, completion: @escaping (Result<[Repository], Error>) -> Void)
    func editRepository(at index: Int, with newName: String)
    func deleteRepository(at index: Int)
    func loadSavedRepositories() -> [Repository]
}

final class RepositoriesInteractor: RepositoriesInteractorProtocol {
    private let githubLoader: GitHubLoaderProtocol
    private let storage: RepositoryStorage
    private var repositories: [Repository] = []
    
    init(githubLoader: GitHubLoaderProtocol, storage: RepositoryStorage) {
        self.githubLoader = githubLoader
        self.storage = storage
        self.repositories = storage.loadRepositories()
    }
    
    func fetchRepositories(page: Int, completion: @escaping (Result<[Repository], Error>) -> Void) {
        githubLoader.loadRepositories(for: page) { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let newRepositories):
                self.repositories.append(contentsOf: newRepositories)
                self.storage.saveRepositories(self.repositories)
                completion(.success(self.repositories))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }
    
    func editRepository(at index: Int, with newName: String) {
        guard repositories.indices.contains(index) else { return }
        repositories[index].name = newName
        storage.saveRepositories(repositories)
    }
    
    func deleteRepository(at index: Int) {
        guard repositories.indices.contains(index) else { return }
        repositories.remove(at: index)
        storage.saveRepositories(repositories)
    }
    
    func loadSavedRepositories() -> [Repository] {
        return repositories
    }
}

