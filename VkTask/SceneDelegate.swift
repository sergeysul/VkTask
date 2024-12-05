import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }

        let storage = RepositoryStorage()
        let githubLoader = GitHubLoader()
        let interactor = RepositoriesInteractor(githubLoader: githubLoader, storage: storage)
        let viewController = RepositoriesViewController()
        let presenter = RepositoriesPresenter(view: viewController, interactor: interactor)
        viewController.presenter = presenter
        let window = UIWindow(windowScene: windowScene)
        window.rootViewController = viewController
        self.window = window
        window.makeKeyAndVisible()
    }
}
