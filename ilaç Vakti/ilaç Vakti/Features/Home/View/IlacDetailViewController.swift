import UIKit

class IlacDetailViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let ilacImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.backgroundColor = .systemGray6
        imageView.layer.cornerRadius = 8
        imageView.clipsToBounds = true
        imageView.image = UIImage(systemName: "pill")
        imageView.tintColor = UIColor(named: "AccentColor")
        return imageView
    }()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 24)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let doseLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let dateRangeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .center
        label.textColor = .secondaryLabel
        label.numberOfLines = 0
        return label
    }()
    
    private let descriptionTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 18)
        label.text = "Açıklama"
        return label
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textColor = .label
        label.numberOfLines = 0
        return label
    }()
    
    private let remindersTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .boldSystemFont(ofSize: 18)
        label.text = "Hatırlatmalar"
        return label
    }()
    
    private let remindersTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "ReminderCell")
        tableView.isScrollEnabled = false
        return tableView
    }()
    
    private let editButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Düzenle", for: .normal)
        button.backgroundColor = UIColor(named: "AccentColor")
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let deleteButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Sil", for: .normal)
        button.backgroundColor = .systemRed
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Properties
    private let ilacId: UUID
    private let coreDataManager = CoreDataManager.shared
    private var ilac: Ilac?
    private var reminders: [Hatirlatici] = []
    
    // MARK: - Initialization
    init(ilacId: UUID) {
        self.ilacId = ilacId
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigationBar()
        setupActions()
        loadIlacData()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        contentView.addSubview(ilacImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(doseLabel)
        contentView.addSubview(dateRangeLabel)
        contentView.addSubview(descriptionTitleLabel)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(remindersTitleLabel)
        contentView.addSubview(remindersTableView)
        contentView.addSubview(editButton)
        contentView.addSubview(deleteButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            ilacImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 20),
            ilacImageView.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            ilacImageView.widthAnchor.constraint(equalToConstant: 120),
            ilacImageView.heightAnchor.constraint(equalToConstant: 120),
            
            nameLabel.topAnchor.constraint(equalTo: ilacImageView.bottomAnchor, constant: 16),
            nameLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            nameLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            doseLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            doseLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            doseLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            dateRangeLabel.topAnchor.constraint(equalTo: doseLabel.bottomAnchor, constant: 8),
            dateRangeLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            dateRangeLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionTitleLabel.topAnchor.constraint(equalTo: dateRangeLabel.bottomAnchor, constant: 24),
            descriptionTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            descriptionLabel.topAnchor.constraint(equalTo: descriptionTitleLabel.bottomAnchor, constant: 8),
            descriptionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            descriptionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            remindersTitleLabel.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 24),
            remindersTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            remindersTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            
            remindersTableView.topAnchor.constraint(equalTo: remindersTitleLabel.bottomAnchor, constant: 8),
            remindersTableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            remindersTableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            remindersTableView.heightAnchor.constraint(equalToConstant: 150),
            
            editButton.topAnchor.constraint(equalTo: remindersTableView.bottomAnchor, constant: 24),
            editButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            editButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45, constant: -15),
            editButton.heightAnchor.constraint(equalToConstant: 50),
            
            deleteButton.topAnchor.constraint(equalTo: remindersTableView.bottomAnchor, constant: 24),
            deleteButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            deleteButton.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.45, constant: -15),
            deleteButton.heightAnchor.constraint(equalToConstant: 50),
            deleteButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -20)
        ])
        
        remindersTableView.dataSource = self
        remindersTableView.delegate = self
    }
    
    private func setupNavigationBar() {
        title = "İlaç Detayı"
    }
    
    private func setupActions() {
        editButton.addTarget(self, action: #selector(editButtonTapped), for: .touchUpInside)
        deleteButton.addTarget(self, action: #selector(deleteButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Data Loading
    private func loadIlacData() {
        guard let ilac = coreDataManager.fetchIlac(byId: ilacId) else {
            showAlert(title: "Hata", message: "İlaç bulunamadı")
            return
        }
        
        self.ilac = ilac
        updateUI(with: ilac)
        
        // Hatırlatmaları yükle
        if let hatirlatmalar = ilac.hatirlaticilar?.allObjects as? [Hatirlatici] {
            self.reminders = hatirlatmalar.sorted { $0.saat! < $1.saat! }
            remindersTableView.reloadData()
        }
    }
    
    private func updateUI(with ilac: Ilac) {
        nameLabel.text = ilac.ad
        doseLabel.text = "\(ilac.doz) \(ilac.dozBirimi ?? "")"
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        
        var dateText = "Başlangıç: \(dateFormatter.string(from: ilac.baslangicTarihi!))"
        if let bitisTarihi = ilac.bitisTarihi {
            dateText += "\nBitiş: \(dateFormatter.string(from: bitisTarihi))"
        }
        dateRangeLabel.text = dateText
        
        if let aciklama = ilac.aciklama, !aciklama.isEmpty {
            descriptionLabel.text = aciklama
        } else {
            descriptionLabel.text = "Açıklama bulunmuyor."
        }
        
        if let resimURL = ilac.resimURL, let url = URL(string: resimURL), let data = try? Data(contentsOf: url), let image = UIImage(data: data) {
            ilacImageView.image = image
        }
    }
    
    // MARK: - Actions
    @objc private func editButtonTapped() {
        // İlaç düzenleme ekranına git
        // Bu kısım ileride uygulanacak
        showAlert(title: "Bilgi", message: "İlaç düzenleme özelliği henüz uygulanmadı.")
    }
    
    @objc private func deleteButtonTapped() {
        let alert = UIAlertController(title: "İlaç Sil", message: "Bu ilacı silmek istediğinize emin misiniz?", preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sil", style: .destructive) { [weak self] _ in
            guard let self = self, let ilac = self.ilac else { return }
            
            self.coreDataManager.deleteIlac(ilac: ilac)
            self.navigationController?.popViewController(animated: true)
        })
        
        present(alert, animated: true)
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDataSource
extension IlacDetailViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if reminders.isEmpty {
            return 1
        }
        return reminders.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReminderCell", for: indexPath)
        
        if reminders.isEmpty {
            cell.textLabel?.text = "Hatırlatma bulunmuyor."
            cell.textLabel?.textColor = .secondaryLabel
            cell.accessoryType = .none
        } else {
            let reminder = reminders[indexPath.row]
            
            let dateFormatter = DateFormatter()
            dateFormatter.timeStyle = .short
            dateFormatter.dateStyle = .none
            
            if let saat = reminder.saat {
                cell.textLabel?.text = dateFormatter.string(from: saat)
            } else {
                cell.textLabel?.text = "Bilinmeyen zaman"
            }
            
            cell.textLabel?.textColor = .label
            cell.accessoryType = .disclosureIndicator
        }
        
        return cell
    }
}

// MARK: - UITableViewDelegate
extension IlacDetailViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if !reminders.isEmpty {
            // Hatırlatma detayı göster
            // Bu kısım ileride uygulanacak
            showAlert(title: "Bilgi", message: "Hatırlatma detayı özelliği henüz uygulanmadı.")
        }
    }
} 
