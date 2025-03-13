import UIKit
import UserNotifications
import CoreData
import OneSignalFramework
import Foundation

class SettingsViewController: UIViewController {
    
    // MARK: - UI Components
    private let headerContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.clipsToBounds = true
        view.layer.cornerRadius = 20
        // Sadece alt köşelere yuvarlak kenar vermek için
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
        // Gölge ekle
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOffset = CGSize(width: 0, height: 4)
        view.layer.shadowRadius = 8
        view.layer.shadowOpacity = 0.3
        return view
    }()
    
    private let gradientLayer: CAGradientLayer = {
        let gradient = CAGradientLayer()
        gradient.colors = [
            UIColor(red: 0.0, green: 0.47, blue: 0.9, alpha: 1.0).cgColor, // Mavi
            UIColor(red: 0.05, green: 0.15, blue: 0.3, alpha: 1.0).cgColor // Koyu lacivert/siyah
        ]
        gradient.locations = [0.0, 1.0]
        gradient.startPoint = CGPoint(x: 0.0, y: 0.0)
        gradient.endPoint = CGPoint(x: 1.0, y: 1.0)
        return gradient
    }()
    
//    private let sparkleImageView: UIImageView = {
//        let imageView = UIImageView()
//        imageView.translatesAutoresizingMaskIntoConstraints = false
//        imageView.image = UIImage(systemName: "sparkles")
//        imageView.contentMode = .scaleAspectFit
//        imageView.tintColor = UIColor(white: 1.0, alpha: 0.7)
//        return imageView
//    }()
//    
    private let headerTitleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Ayarlar"
        label.font = UIFont.systemFont(ofSize: 32, weight: .bold)
        label.textColor = .white
        return label
    }()
    
    private let userNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = ""
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = UIColor(white: 1.0, alpha: 0.8)
        return label
    }()
    
    private let headerIconImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "gear.circle.fill")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .white
        
        // Görsel efekt için hafif gölge ekle
        imageView.layer.shadowColor = UIColor.black.cgColor
        imageView.layer.shadowOffset = CGSize(width: 0, height: 2)
        imageView.layer.shadowRadius = 4
        imageView.layer.shadowOpacity = 0.3
        return imageView
    }()
    
    private let wavePatternImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "waveform.path")
        imageView.contentMode = .scaleAspectFill
        imageView.tintColor = UIColor(white: 1.0, alpha: 0.2)
        imageView.alpha = 0.5
        return imageView
    }()
    
    private let separatorView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(white: 1.0, alpha: 0.3)
        return view
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.backgroundColor = .systemGroupedBackground
        // Hafif kenar yuvarlama
        tableView.layer.cornerRadius = 10
        tableView.clipsToBounds = true
        return tableView
    }()
    
    // MARK: - Properties
    private let viewModel = SettingsViewModel()
    private var sections: [SettingsSection] = []
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
        setupSections()
        
        // Kaydedilmiş tema ayarını kontrol et ve uygula
        applyThemeFromUserDefaults()
        
        // Animasyonları başlat
        animateHeaderElements()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        // Gradient layer'ı header container'ın boyutlarına uyarla
        gradientLayer.frame = headerContainerView.bounds
        
        // Gölge ayarlarını düzelt (clipToBounds ve shadow çakışmasını giderme)
        headerContainerView.layer.masksToBounds = false
        
        // iPhone modellerine göre header yüksekliğini dinamik olarak ayarla
        adjustHeaderHeightForDeviceType()
    }
    
    // Kayıtlı tema ayarını uygula
    private func applyThemeFromUserDefaults() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        if let window = view.window {
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }
    
    // Header elementlerinin animasyonu
    private func animateHeaderElements() {
        // Başlangıç değerleri
        headerTitleLabel.alpha = 0
        headerTitleLabel.transform = CGAffineTransform(translationX: -20, y: 0)
        
        userNameLabel.alpha = 0
        userNameLabel.transform = CGAffineTransform(translationX: -20, y: 0)
        
        headerIconImageView.alpha = 0
        headerIconImageView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        
//        sparkleImageView.alpha = 0
//        sparkleImageView.transform = CGAffineTransform(scaleX: 0.6, y: 0.6)
//      
      
        
        UIView.animate(withDuration: 0.6, delay: 0.1, options: .curveEaseOut) {
            self.headerIconImageView.alpha = 1
            self.headerIconImageView.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.3, options: .curveEaseOut) {
            self.headerTitleLabel.alpha = 1
            self.headerTitleLabel.transform = .identity
        }
        
        UIView.animate(withDuration: 0.6, delay: 0.4, options: .curveEaseOut) {
            self.userNameLabel.alpha = 1
            self.userNameLabel.transform = .identity
        }
//        
//        UIView.animate(withDuration: 0.6, delay: 0.5, options: .curveEaseOut) {
//            self.sparkleImageView.alpha = 1
//            self.sparkleImageView.transform = .identity
//        }
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        
        // Navigation bar'ı gizle
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        // Gradient header view'i ekle
        view.addSubview(headerContainerView)
        headerContainerView.layer.insertSublayer(gradientLayer, at: 0)
        
        // Dalga pattern arka planı ekle
        headerContainerView.addSubview(wavePatternImageView)
        
        // Header içeriğini ekle
        headerContainerView.addSubview(headerIconImageView)
        headerContainerView.addSubview(headerTitleLabel)
        headerContainerView.addSubview(userNameLabel)
     //   headerContainerView.addSubview(sparkleImageView)
        headerContainerView.addSubview(separatorView)
       
        
        // TableView'i ekle
        view.addSubview(tableView)
        
        // Constraints
        NSLayoutConstraint.activate([
            // Header container - çentik bölgesini dikkate alarak düzenlendi
            headerContainerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            // Yüksekliği, safe area'nın üstünden itibaren sabit bir değer artı safe area top inset olarak ayarla
            headerContainerView.heightAnchor.constraint(equalToConstant: 220), // Çentik için ekstra alan
            
            // Dalga pattern
            wavePatternImageView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -15),
            wavePatternImageView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            wavePatternImageView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            wavePatternImageView.heightAnchor.constraint(equalToConstant: 100),
            
          
            
            // Header icon - safe area üzerinden konumlandır
            headerIconImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            headerIconImageView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 20), // Sol kenara sabitlendi
            headerIconImageView.widthAnchor.constraint(equalToConstant: 40),
            headerIconImageView.heightAnchor.constraint(equalToConstant: 40),
//            
//            // Sparkle icon - safe area'ya göre konumlandır
//            sparkleImageView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor, constant: -20),
//            sparkleImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
//            sparkleImageView.widthAnchor.constraint(equalToConstant: 30),
//            sparkleImageView.heightAnchor.constraint(equalToConstant: 30),
//            
            // Header title
            headerTitleLabel.leadingAnchor.constraint(equalTo: headerIconImageView.trailingAnchor, constant: 16),
            headerTitleLabel.topAnchor.constraint(equalTo: headerIconImageView.topAnchor, constant: -5),
            headerTitleLabel.trailingAnchor.constraint(lessThanOrEqualTo: headerContainerView.trailingAnchor, constant: -20),
            
            // Kullanıcı adı
            userNameLabel.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor, constant: 20),
            userNameLabel.topAnchor.constraint(equalTo: headerTitleLabel.bottomAnchor, constant: 4),
            userNameLabel.trailingAnchor.constraint(lessThanOrEqualTo: headerContainerView.trailingAnchor, constant: -20),
            
            // Ayırıcı çizgi
            separatorView.bottomAnchor.constraint(equalTo: headerContainerView.bottomAnchor, constant: -1),
            separatorView.leadingAnchor.constraint(equalTo: headerContainerView.leadingAnchor),
            separatorView.trailingAnchor.constraint(equalTo: headerContainerView.trailingAnchor),
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            
            // TableView
            tableView.topAnchor.constraint(equalTo: headerContainerView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
        
        // TableView için ek padding ekle
        tableView.contentInset = UIEdgeInsets(top: 10, left: 0, bottom: 0, right: 0)
    }
    
  
    
    @objc private func backButtonTapped() {
        // Geri tuşuna basıldığında bir önceki ekrana dön
        navigationController?.popViewController(animated: true)
    }
    
    // İPhone modeline göre başlık yüksekliğini otomatik ayarla
    private func adjustHeaderHeightForDeviceType() {
        // Mevcut header constraint'ini bul
        let headerHeightConstraint = headerContainerView.constraints.first { constraint in
            return constraint.firstAttribute == .height && constraint.relation == .equal
        }
        
        // Cihaz modelini kontrol et ve yüksekliği ayarla
        let hasNotch = view.safeAreaInsets.top > 20 // Çentikli telefon kontrolü
        
        if hasNotch {
            // Çentikli telefonlar için daha yüksek header (iPhone X ve sonrası)
            headerHeightConstraint?.constant = 220 // 180 + 40 (çentik için ekstra alan)
        } else {
            // Standart telefonlar için normal header yüksekliği
            headerHeightConstraint?.constant = 180
        }
        
        // Layout'u güncelle
        view.layoutIfNeeded()
    }
    
    private func setupSections() {
        // Uygulama Ayarları
        let appSettings = SettingsSection(
            title: "Uygulama Ayarları",
            items: [
                SettingsItem(title: "Bildirimler", icon: "bell.fill", type: .toggle, action: { [weak self] in
                    // Bildirim ayarlarını açma işlemi
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }),
                SettingsItem(title: "Karanlık Mod", icon: "moon.fill", type: .toggle, action: { [weak self] in
                    // Bu action, toggle değiştiğinde çağrılacak
                    // SettingsViewController'daki switchChanged metodu ana işlevi yapacak
                })
            ]
        )
        
        // Sağlık Verileri Gizliliği
        let privacySettings = SettingsSection(
            title: "Sağlık Verileri ve Gizlilik",
            items: [
                SettingsItem(
                    title: "Veri Güvenliği Politikası",
                    icon: "lock.shield.fill",
                    type: .navigation,
                    action: { [weak self] in
                        self?.showHealthDataPrivacyInfo()
                    }
                ),
                SettingsItem(
                    title: "Verilerimi Sil",
                    icon: "trash.fill",
                    type: .destructive,
                    action: { [weak self] in
                        self?.handleDataDeletion()
                    }
                )
            ]
        )
        
        // Destek ve Bilgi
        let supportSettings = SettingsSection(
            title: "Destek ve Bilgi",
            items: [
                SettingsItem(
                    title: "Yardım ve Destek",
                    icon: "questionmark.circle.fill",
                    type: .navigation,
                    action: nil,
                    url: URL(string: "https://docs.google.com/document/d/1PR90g9mA0l8tYqH3-fFWQ1Ou1uuD7kGpEBWNbvgjf0U/edit?usp=sharing")
                ),
                SettingsItem(
                    title: "Gizlilik Politikası",
                    icon: "lock.fill",
                    type: .navigation,
                    action: nil,
                    url: URL(string: "https://docs.google.com/document/d/1WVh48rU1Xi34PkKJCkq09WOd4dQSJyqd5Ir6Ncq2048/edit?tab=t.0")
                ),
                SettingsItem(
                    title: "Uygulama Hakkında",
                    icon: "info.circle.fill",
                    type: .info,
                    action: nil
                )
            ]
        )
        
        self.sections = [appSettings, privacySettings, supportSettings]
    }
    
    // Sağlık verilerinin gizliliği hakkında bilgilendirme
    private func showHealthDataPrivacyInfo() {
        let alert = UIAlertController(
            title: "Sağlık Verilerinizin Güvenliği",
            message: """
            İlaç Vakti uygulaması, sağlık verilerinizin gizliliğini ve güvenliğini en üst düzeyde tutar:

            • Tüm verileriniz şifreli olarak saklanır
            • Verileriniz sadece sizin cihazınızda tutulur
            • Üçüncü taraflarla paylaşılmaz
            • İstediğiniz zaman verilerinizi silebilirsiniz
            • KVKK ve GDPR uyumlu veri işleme
            
            Detaylı bilgi için Gizlilik Politikamızı inceleyebilirsiniz.
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Anladım", style: .default))
        alert.addAction(UIAlertAction(title: "Gizlilik Politikası", style: .default) { [weak self] _ in
            if let url = URL(string: "https://docs.google.com/document/d/1WVh48rU1Xi34PkKJCkq09WOd4dQSJyqd5Ir6Ncq2048/edit?tab=t.0") {
                UIApplication.shared.open(url)
            }
        })
        
        present(alert, animated: true)
    }
    
    // Kullanıcı verilerini silme işlemi
    private func handleDataDeletion() {
        let alert = UIAlertController(
            title: "Verilerinizi Silmek İstiyor musunuz?",
            message: """
            Bu işlem:
            • Tüm ilaç hatırlatıcılarınızı
            • Kayıtlı bilgilerinizi
            • Uygulama ayarlarınızı
            
            kalıcı olarak silecektir. Bu işlem geri alınamaz.
            """,
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Sil", style: .destructive) { [weak self] _ in
            self?.deleteAllUserData()
        })
        
        present(alert, animated: true)
    }
    
    // Tüm kullanıcı verilerini silme
    private func deleteAllUserData() {
        // UserDefaults'ı temizle
        if let bundleID = Bundle.main.bundleIdentifier {
            UserDefaults.standard.removePersistentDomain(forName: bundleID)
        }
        
        // CoreData'yı temizle
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        let context = appDelegate.persistentContainer.viewContext
        
        let entities = appDelegate.persistentContainer.managedObjectModel.entities
        entities.forEach { entity in
            if let name = entity.name {
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: name)
                let batchDeleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
                
                do {
                    try context.execute(batchDeleteRequest)
                } catch {
                    print("Veri silme hatası: \(error)")
                }
            }
        }
        
        // Kullanıcıya bilgi ver
        let alert = UIAlertController(
            title: "Veriler Silindi",
            message: "Tüm verileriniz başarıyla silindi. Uygulama yeniden başlatılacak.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "Tamam", style: .default) { _ in
            // Uygulamayı yeniden başlat
            exit(0)
        })
        
        present(alert, animated: true)
    }
    
    // Memory leak kontrolü için deinit
    deinit {
        print("SettingsViewController deallocated")
        NotificationCenter.default.removeObserver(self)
    }
    
    // Bildirim izni uyarısını gösterme
    private func showNotificationPermissionAlert() {
        // Sistem ayarlarına yönlendirmek için bir uyarı göster
        let alert = UIAlertController(
            title: "Bildirim İzni Gerekli",
            message: "Bildirimleri etkinleştirmek için sistem ayarlarına gitmeniz gerekiyor.",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Ayarlara Git", style: .default) { _ in
            if let url = URL(string: UIApplication.openSettingsURLString) {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        })
        
        present(alert, animated: true)
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension SettingsViewController: UITableViewDelegate, UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.sections.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.sections[section].items.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath) as! SettingsCell
        let item = viewModel.sections[indexPath.section].items[indexPath.row]
        
        cell.configure(with: item)
        
        switch item.type {
        case .toggle:
            let toggle = UISwitch()
            toggle.onTintColor = UIColor(named: "AccentColor")
            toggle.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            toggle.tag = indexPath.row
            
            // Karanlık mod için doğru başlangıç durumunu ayarla
            if item.title == "Karanlık Mod" {
                if let window = view.window {
                    toggle.isOn = window.overrideUserInterfaceStyle == .dark
                } else {
                    // Eğer pencere henüz hazır değilse, UserDefaults'dan oku
                    toggle.isOn = UserDefaults.standard.bool(forKey: "isDarkMode")
                }
            }
            
            cell.accessoryView = toggle
            cell.selectionStyle = .none
        case .navigation:
            cell.accessoryType = .disclosureIndicator
        case .destructive:
            cell.textLabel?.textColor = .systemRed
            cell.imageView?.tintColor = .systemRed
        case .info:
            cell.selectionStyle = .none
            let versionLabel = UILabel()
            versionLabel.text = "1.0.0"
            versionLabel.textColor = .secondaryLabel
            versionLabel.font = .systemFont(ofSize: 15)
            cell.accessoryView = versionLabel
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return viewModel.sections[section].title
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = viewModel.sections[indexPath.section].items[indexPath.row]
        item.action?()
        
        switch item.type {
        case .navigation:
            handleNavigation(for: item)
        case .destructive:
            handleDestructiveAction(for: item)
        default:
            break
        }
    }
    
    // MARK: - Actions
    @objc private func switchChanged(_ sender: UISwitch) {
        let section = 0  // Uygulama Ayarları bölümü
        let rowIndex = sender.tag
        let item = viewModel.sections[section].items[rowIndex]
        
        if item.title == "Karanlık Mod" {
            if let window = view.window {
                let newStyle: UIUserInterfaceStyle = sender.isOn ? .dark : .light
                window.overrideUserInterfaceStyle = newStyle
                UserDefaults.standard.set(sender.isOn, forKey: "isDarkMode")
                print("Karanlık mod değiştirildi: \(sender.isOn ? "Açık" : "Kapalı")")
            }
        } else if item.title == "Bildirimler" {
            // Bildirim ayarlarını açmak için
            if sender.isOn {
                requestNotificationPermission()
            } else {
                // Bildirim ayarlarını değiştirmek için sistem ayarlarına yönlendir
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
        
        // İşlem varsa çalıştır
        item.action?()
    }
    
    // Bildirim izinlerini isteme
    private func requestNotificationPermission() {
        let notificationCenter = UNUserNotificationCenter.current()
        
        notificationCenter.getNotificationSettings { [weak self] settings in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                if settings.authorizationStatus != .authorized {
                    // Doğrudan UNUserNotificationCenter yerine OneSignal üzerinden izin isteyelim
                    OneSignal.Notifications.requestPermission({ [weak self] accepted in
                        guard let self = self else { return }
                        
                        DispatchQueue.main.async {
                            // Bildirim toggle'ını bul ve güncelle
                            if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SettingsCell,
                               let toggle = cell.accessoryView as? UISwitch {
                                toggle.isOn = accepted
                                
                                if !accepted {
                                    self.showNotificationPermissionAlert()
                                }
                            }
                        }
                    }, fallbackToSettings: true)
                } else {
                    // İzin zaten verildiyse, toggle'ı açık konumuna getir
                    if let cell = self.tableView.cellForRow(at: IndexPath(row: 0, section: 0)) as? SettingsCell,
                       let toggle = cell.accessoryView as? UISwitch {
                        toggle.isOn = true
                    }
                }
            }
        }
    }
    
    private func handleNavigation(for item: SettingsItem) {
        // URL varsa doğrudan aç, yoksa öğe başlığına göre URL belirle
        if let url = item.url {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
            return
        }
        
        // URL yoksa, başlıklara göre varsayılan URL'ler
        var urlString: String?
        
        switch item.title {
        case "Yardım ve Destek":
            urlString = "https://example.com/help"
        case "Gizlilik Politikası":
            urlString = "https://docs.google.com/document/d/1WVh48rU1Xi34PkKJCkq09WOd4dQSJyqd5Ir6Ncq2048/edit?tab=t.0"
        case "Uygulama Hakkında":
            urlString = "https://example.com/about"
        default:
            break
        }
        
        if let urlString = urlString, let url = URL(string: urlString) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
    
    private func handleDestructiveAction(for item: SettingsItem) {
        let alert = UIAlertController(
            title: "Emin misiniz?",
            message: "\(item.title) işlemini gerçekleştirmek istediğinizden emin misiniz?",
            preferredStyle: .alert
        )
        
        alert.addAction(UIAlertAction(title: "İptal", style: .cancel))
        alert.addAction(UIAlertAction(title: "Evet", style: .destructive) { _ in
            item.action?()
        })
        
        present(alert, animated: true)
    }
}

// MARK: - SettingsCell
class SettingsCell: UITableViewCell {
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: .default, reuseIdentifier: reuseIdentifier)
        setupCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupCell() {
        imageView?.tintColor = UIColor(named: "AccentColor")
        textLabel?.font = .systemFont(ofSize: 16)
    }
    
    func configure(with item: SettingsItem) {
        textLabel?.text = item.title
        imageView?.image = UIImage(systemName: item.icon)
    }
}
