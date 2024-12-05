import UIKit
import Foundation


protocol RepositoriesViewControllerProtocol: AnyObject {
    func showRepositories(_ repositories: [Repository])
    func showError(_ error: Error)
    func showLoading()
    func hideLoading()
}

final class RepositoriesViewController: UIViewController, RepositoriesViewControllerProtocol {
    
    var presenter: RepositoriesPresenterProtocol?
    private var repositories: [Repository] = []
    
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Пользователи и их репозитории"
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = .black
        return label
    }()
    
    private var table: UITableView = {
        let table = UITableView()
        table.register(RepositoryCell.self, forCellReuseIdentifier: RepositoryCell.identifier)
        table.backgroundColor = .white
        table.separatorStyle = .none
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 100
        return table
    }()
    
    private let loading: UIActivityIndicatorView = {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.color = .gray
        indicator.hidesWhenStopped = true
        return indicator
    }()

    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        table.delegate = self
        table.dataSource = self
        addSubviews()
        setupConstraints()
        presenter?.viewDidLoad()
    }
    
    func setPresenter(_ presenter: RepositoriesPresenterProtocol){
        self.presenter = presenter
    }
    
    private func addSubviews() {
        [
            label,
            table,
            loading
        ].forEach { [weak self] in
            $0.translatesAutoresizingMaskIntoConstraints = false
            self?.view.addSubview($0)
        }
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([

            label.heightAnchor.constraint(equalToConstant: 30),
            label.widthAnchor.constraint(equalToConstant: 150),
            label.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 1),
            label.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 80),
            label.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            
            table.topAnchor.constraint(equalTo: label.bottomAnchor, constant: 20),
            table.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            table.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
            table.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
            
            loading.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            loading.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
    }
    
    func showRepositories(_ repositories: [Repository]) {
        self.repositories = repositories
        table.reloadData()
    }
    
    func showError(_ error: Error) {
        let alert = UIAlertController(title: "Ошибка", message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default))
        present(alert, animated: true)
    }
    
    func showLoading() {
        loading.startAnimating()
    }
    
    func hideLoading(){
        loading.stopAnimating()
    }
}

extension RepositoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return repositories.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = table.dequeueReusableCell(withIdentifier: RepositoryCell.identifier, for: indexPath) as? RepositoryCell else {
            return UITableViewCell()
        }
        
        let repository = repositories[indexPath.row]
        cell.configure(with: repository)
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        let repository = repositories[indexPath.row]
        let alert = UIAlertController(title: "Редактирование", message: "Измените название репозитория", preferredStyle: .alert)
        alert.addTextField { textField in
            textField.text = repository.name
        }
        alert.addAction(UIAlertAction(title: "Сохранить", style: .default, handler: { [weak self] _ in
            guard let newName = alert.textFields?.first?.text, !newName.isEmpty else { return }
            self?.presenter?.edit(at: indexPath.row, with: newName)
        }))
        alert.addAction(UIAlertAction(title: "Отмена", style: .cancel))
        present(alert, animated: true)
    }
        
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            presenter?.delete(at: indexPath.row)
        }
    }
}

extension RepositoriesViewController: UITableViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let position = scrollView.contentOffset.y
        let contentHeight = scrollView.contentSize.height
        let scrollViewHeight = scrollView.frame.size.height
        
        if position > contentHeight - scrollViewHeight - 100 {
            presenter?.loadMoreRepositories()
        }
    }
}

