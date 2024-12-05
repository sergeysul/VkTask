import UIKit

final class RepositoryCell: UITableViewCell {
    static let identifier = "RepositoryCell"
    
    private let profileAvatar: UIImageView = {
        let image = UIImageView()
        image.contentMode = .scaleAspectFill
        image.clipsToBounds = true
        image.layer.cornerRadius = 8
        return image
    }()
       
    private let profileLogin: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 18)
        label.textColor = .black
        return label
    }()
       
    private let repositoryName: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 14)
        label.textColor = .gray
        label.numberOfLines = 0
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        setupConstraints()
    }
       
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func addSubviews() {
        [
            profileAvatar,
            profileLogin,
            repositoryName,
        ].forEach {
            $0.translatesAutoresizingMaskIntoConstraints = false
            contentView.addSubview($0)
        }
    }
    
    func configure(with repository: Repository) {
        repositoryName.text = repository.name
        profileLogin.text = repository.owner.login
        
        let task = URLSession.shared.dataTask(with: repository.owner.avatar_url) { [weak self] data, response, error in
            guard let data = data, error == nil else {
                return
            }
                
            let image = UIImage(data: data)
            DispatchQueue.main.async {
                self?.profileAvatar.image = image
            }
        }
        task.resume()
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            profileAvatar.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            profileAvatar.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileAvatar.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            profileAvatar.widthAnchor.constraint(equalToConstant: 130),
            profileAvatar.heightAnchor.constraint(equalToConstant: 130),
               
            profileLogin.leadingAnchor.constraint(equalTo: profileAvatar.trailingAnchor, constant: 16),
            profileLogin.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            profileLogin.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
               
            repositoryName.leadingAnchor.constraint(equalTo: profileAvatar.trailingAnchor, constant: 16),
            repositoryName.topAnchor.constraint(equalTo: profileLogin.bottomAnchor, constant: 8),
            repositoryName.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            repositoryName.bottomAnchor.constraint(lessThanOrEqualTo: contentView.bottomAnchor, constant: -8)
        ])
    }
}
