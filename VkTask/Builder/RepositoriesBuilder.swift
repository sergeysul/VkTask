import UIKit

final class RepositoriesBuilder {
    static func build() -> UIViewController {
        let storage = RepositoryStorage()
        let githubLoader = GitHubLoader()
        let interactor = RepositoriesInteractor(githubLoader: githubLoader, storage: storage)
        let view = RepositoriesViewController()
        let presenter = RepositoriesPresenter(view: view, interactor: interactor)
        view.presenter = presenter
        return view
    }
}

