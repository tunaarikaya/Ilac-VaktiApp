import UIKit

class IlacTableViewCell: UITableViewCell {
    
    static let identifier = "IlacTableViewCell"
    
    // MARK: - UI Components
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGray6
        view.layer.cornerRadius = 16
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 6
        view.layer.shadowOpacity = 0.1
        return view
    }()
    
    private let ilacAdiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = .label
        return label
    }()
    
    private let saatLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14, weight: .regular)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let kullanimDurumuView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 14
        view.backgroundColor = .systemGreen
        return view
    }()
    
    private let kullanimDurumuImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        imageView.image = UIImage(systemName: "checkmark", withConfiguration: config)
        return imageView
    }()
    
    // MARK: - Properties
    var checkboxTapAction: (() -> Void)?
    
    // MARK: - Lifecycle
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        ilacAdiLabel.text = nil
        saatLabel.text = nil
        kullanimDurumuView.backgroundColor = .systemGreen
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(ilacAdiLabel)
        containerView.addSubview(saatLabel)
        containerView.addSubview(kullanimDurumuView)
        kullanimDurumuView.addSubview(kullanimDurumuImageView)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 12),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -12),
            
            ilacAdiLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            ilacAdiLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            ilacAdiLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -60),
            
            saatLabel.topAnchor.constraint(equalTo: ilacAdiLabel.bottomAnchor, constant: 8),
            saatLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            saatLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -16),
            
            kullanimDurumuView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            kullanimDurumuView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            kullanimDurumuView.widthAnchor.constraint(equalToConstant: 28),
            kullanimDurumuView.heightAnchor.constraint(equalToConstant: 28),
            
            kullanimDurumuImageView.centerXAnchor.constraint(equalTo: kullanimDurumuView.centerXAnchor),
            kullanimDurumuImageView.centerYAnchor.constraint(equalTo: kullanimDurumuView.centerYAnchor),
            kullanimDurumuImageView.widthAnchor.constraint(equalToConstant: 16),
            kullanimDurumuImageView.heightAnchor.constraint(equalToConstant: 16)
        ])
        
        // İlaç adı yazı tipi büyütme
        ilacAdiLabel.font = .systemFont(ofSize: 18, weight: .semibold)
    }
    
    // MARK: - Configuration
    func configure(with ilac: Ilac, kullanimDurumu: Bool? = nil) {
        ilacAdiLabel.text = ilac.ad
        
        if let dozBirimi = ilac.dozBirimi {
            saatLabel.text = "\(ilac.doz) \(dozBirimi)"
        } else {
            saatLabel.text = "\(ilac.doz)"
        }
        
        // İlaç alınma durumunu kontrol et ve uygun ikonu göster
        if let alindiMi = kullanimDurumu, alindiMi == true {
            // İlaç içildi/alındı
            kullanimDurumuView.backgroundColor = .systemGreen
            kullanimDurumuImageView.image = UIImage(systemName: "checkmark", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
        } else {
            // İlaç henüz içilmedi/alınmadı
            kullanimDurumuView.backgroundColor = .systemRed
            kullanimDurumuImageView.image = UIImage(systemName: "minus", withConfiguration: UIImage.SymbolConfiguration(pointSize: 16, weight: .bold))
        }
    }
} 
