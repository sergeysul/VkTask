import UIKit
import Foundation


protocol RepositoriesPresenterProtocol: AnyObject {
    func viewDidLoad()
    func loadMoreRepositories()
    func edit(at index: Int, with newName: String)
    func delete(at index: Int)
}

final class RepositoriesPresenter: RepositoriesPresenterProtocol {
    
    private weak var view: RepositoriesViewControllerProtocol?
    private let interactor: RepositoriesInteractorProtocol
    private var currentPage = 1
    private var isLoading = false
    
    init(view: RepositoriesViewControllerProtocol, interactor: RepositoriesInteractorProtocol) {
        self.view = view
        self.interactor = interactor
    }
    
    func viewDidLoad() {
        let savedRepositories = interactor.loadSavedRepositories()
        if !savedRepositories.isEmpty {
            view?.showRepositories(savedRepositories)
        } else {
            loadRepositories()
        }
    }

    func loadMoreRepositories() {
        guard !isLoading else { return }
        loadRepositories()
    }
    
    private func loadRepositories() {
        isLoading = true
        view?.showLoading()
        interactor.fetchRepositories(page: currentPage) { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                self.isLoading = false
                self.view?.hideLoading()
                switch result {
                case .success(let repositories):
                    self.view?.showRepositories(repositories)
                    self.currentPage += 1
                case .failure(let error):
                    self.view?.showError(error)
                }
            }
        }
    }
    
    func edit(at index: Int, with newName: String) {
        interactor.editRepository(at: index, with: newName)
        view?.showRepositories(interactor.loadSavedRepositories())
    }

    func delete(at index: Int) {
        interactor.deleteRepository(at: index)
        view?.showRepositories(interactor.loadSavedRepositories())
    }
}
