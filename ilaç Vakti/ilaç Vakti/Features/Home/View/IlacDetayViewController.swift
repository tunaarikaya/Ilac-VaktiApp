import UIKit
import CoreData

class IlacDetayViewController: UIViewController {
    
    // MARK: - UI Components
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "AccentColor")?.withAlphaComponent(0.1)
        view.layer.cornerRadius = 16
        return view
    }()
    
    private let ilacImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "pills.circle.fill")
        imageView.tintColor = UIColor(named: "AccentColor")
        return imageView
    }()
    
    private let ilacAdiLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .label
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()
    
    private let saatStackView: UIStackView = {
        let stack = UIStackView()
        stack.translatesAutoresizingMaskIntoConstraints = false
        stack.axis = .horizontal
        stack.spacing = 8
        stack.alignment = .center
        return stack
    }()
    
    private let saatImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "clock.fill")
        imageView.tintColor = .secondaryLabel
        return imageView
    }()
    
    private let saatLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let ilacIcildiButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.backgroundColor = UIColor(named: "AccentColor")
        button.setTitle("İlacımı İçtim", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 25
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .semibold)
        
        // Gölge efekti
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 4)
        button.layer.shadowRadius = 8
        button.layer.shadowOpacity = 0.1
        return button
    }()
    
    // MARK: - Properties
    var ilacKullanim: IlacKullanim?
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        configureWithIlacKullanim()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(headerView)
        headerView.addSubview(ilacImageView)
        headerView.addSubview(ilacAdiLabel)
        
        saatStackView.addArrangedSubview(saatImageView)
        saatStackView.addArrangedSubview(saatLabel)
        view.addSubview(saatStackView)
        
        view.addSubview(ilacIcildiButton)
        
        NSLayoutConstraint.activate([
            headerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            ilacImageView.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 24),
            ilacImageView.centerXAnchor.constraint(equalTo: headerView.centerXAnchor),
            ilacImageView.widthAnchor.constraint(equalToConstant: 80),
            ilacImageView.heightAnchor.constraint(equalToConstant: 80),
            
            ilacAdiLabel.topAnchor.constraint(equalTo: ilacImageView.bottomAnchor, constant: 16),
            ilacAdiLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            ilacAdiLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            ilacAdiLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -24),
            
            saatStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 32),
            saatStackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            saatImageView.widthAnchor.constraint(equalToConstant: 24),
            saatImageView.heightAnchor.constraint(equalToConstant: 24),
            
            ilacIcildiButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 24),
            ilacIcildiButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -24),
            ilacIcildiButton.heightAnchor.constraint(equalToConstant: 50),
            ilacIcildiButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -24)
        ])
        
        ilacIcildiButton.addTarget(self, action: #selector(ilacIcildiButtonTapped), for: .touchUpInside)
    }
    
    private func configureWithIlacKullanim() {
        guard let ilacKullanim = ilacKullanim else { return }
        
        ilacAdiLabel.text = ilacKullanim.ilac?.ad
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let tarih = ilacKullanim.tarih {
            saatLabel.text = dateFormatter.string(from: tarih)
        }
        
        updateButtonState()
    }
    
    private func updateButtonState() {
        if ilacKullanim?.alindiMi == true {
            ilacIcildiButton.backgroundColor = .systemGreen
            ilacIcildiButton.setTitle("İlacımı İçtim ✓", for: .normal)
        } else {
            ilacIcildiButton.backgroundColor = UIColor(named: "AccentColor")
            ilacIcildiButton.setTitle("İlacımı İçtim", for: .normal)
        }
    }
    
    @objc private func ilacIcildiButtonTapped() {
        guard let ilacKullanim = ilacKullanim else { return }
        
        // Haptic feedback ekle
        let generator = UIImpactFeedbackGenerator(style: .medium)
        generator.impactOccurred()
        
        // İlaç kullanım durumunu güncelle
        ilacKullanim.alindiMi.toggle()
        
        do {
            try coreDataManager.context.save()
            updateButtonState()
            NotificationCenter.default.post(name: NSNotification.Name("IlacKullanimiGuncellendi"), object: nil)
        } catch {
            print("Hata: İlaç kullanımı güncellenemedi - \(error.localizedDescription)")
        }
    }
}
