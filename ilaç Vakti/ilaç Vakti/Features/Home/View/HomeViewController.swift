import UIKit

class HomeViewController: UIViewController {
    
    // MARK: - UI Components
    private let calendarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: 2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textAlignment = .center
        return label
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.left"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "chevron.right"), for: .normal)
        button.tintColor = .label
        return button
    }()
    
    private let calendarImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "calendar")
        imageView.tintColor = UIColor(named: "AccentColor")
        return imageView
    }()
    
    private let tableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(IlacTableViewCell.self, forCellReuseIdentifier: IlacTableViewCell.identifier)
        tableView.backgroundColor = .systemBackground
        tableView.separatorStyle = .singleLine
        return tableView
    }()
    
    private let emptyStateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.isHidden = true
        return view
    }()
    
    private let emptyStateImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "pills")
        imageView.contentMode = .scaleAspectFit
        imageView.tintColor = .systemGray3
        return imageView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bu tarihte ilaç yok"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 18, weight: .medium)
        label.textColor = .systemGray
        return label
    }()
    
    // MARK: - Properties
    private let viewModel = HomeViewModel()
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "d MMMM yyyy"
        formatter.locale = Locale(identifier: "tr_TR")
        return formatter
    }()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupTableView()
        setupNavigationBar()
        setupNotifications()
        setupActions()
        
        viewModel.delegate = self as HomeViewModelDelegate
        viewModel.fetchIlaclar()
        updateDateLabel()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        viewModel.fetchIlaclar()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        view.addSubview(calendarView)
        calendarView.addSubview(dateLabel)
        calendarView.addSubview(previousButton)
        calendarView.addSubview(nextButton)
        calendarView.addSubview(calendarImageView)
        
        view.addSubview(tableView)
        view.addSubview(emptyStateView)
        
        emptyStateView.addSubview(emptyStateImageView)
        emptyStateView.addSubview(emptyStateLabel)
        
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 8),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            calendarView.heightAnchor.constraint(equalToConstant: 70),
            
            dateLabel.topAnchor.constraint(equalTo: calendarView.topAnchor, constant: 16),
            dateLabel.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 50),
            dateLabel.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -50),
            
            previousButton.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 16),
            previousButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            previousButton.widthAnchor.constraint(equalToConstant: 30),
            previousButton.heightAnchor.constraint(equalToConstant: 30),
            
            nextButton.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -16),
            nextButton.centerYAnchor.constraint(equalTo: dateLabel.centerYAnchor),
            nextButton.widthAnchor.constraint(equalToConstant: 30),
            nextButton.heightAnchor.constraint(equalToConstant: 30),
            
            calendarImageView.centerXAnchor.constraint(equalTo: calendarView.centerXAnchor),
            calendarImageView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 4),
            calendarImageView.widthAnchor.constraint(equalToConstant: 24),
            calendarImageView.heightAnchor.constraint(equalToConstant: 24),
            
            tableView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 8),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateView.centerXAnchor.constraint(equalTo: tableView.centerXAnchor),
            emptyStateView.centerYAnchor.constraint(equalTo: tableView.centerYAnchor),
            emptyStateView.widthAnchor.constraint(equalToConstant: 200),
            emptyStateView.heightAnchor.constraint(equalToConstant: 200),
            
            emptyStateImageView.topAnchor.constraint(equalTo: emptyStateView.topAnchor),
            emptyStateImageView.centerXAnchor.constraint(equalTo: emptyStateView.centerXAnchor),
            emptyStateImageView.widthAnchor.constraint(equalToConstant: 100),
            emptyStateImageView.heightAnchor.constraint(equalToConstant: 100),
            
            emptyStateLabel.topAnchor.constraint(equalTo: emptyStateImageView.bottomAnchor, constant: 16),
            emptyStateLabel.leadingAnchor.constraint(equalTo: emptyStateView.leadingAnchor),
            emptyStateLabel.trailingAnchor.constraint(equalTo: emptyStateView.trailingAnchor),
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    private func setupNavigationBar() {
        title = "İlaçlarım"
        
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(addButtonTapped))
        addButton.tintColor = .systemBlue
        navigationItem.rightBarButtonItem = addButton
    }
    
    private func setupNotifications() {
        // İlaç kullanım durumu güncellendiğinde tabloyu yenile
        NotificationCenter.default.addObserver(self, 
                                               selector: #selector(ilacKullanimiGuncellendi), 
                                               name: NSNotification.Name("IlacKullanimiGuncellendi"), 
                                               object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    private func setupActions() {
        previousButton.addTarget(self, action: #selector(previousButtonTapped), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonTapped), for: .touchUpInside)
        
        // Takvim ikonuna tıklanınca bugüne git
        let calendarTapGesture = UITapGestureRecognizer(target: self, action: #selector(calendarImageTapped))
        calendarImageView.isUserInteractionEnabled = true
        calendarImageView.addGestureRecognizer(calendarTapGesture)
    }
    
    private func updateDateLabel() {
        dateLabel.text = dateFormatter.string(from: viewModel.selectedDate)
    }
    
    // MARK: - Actions
    @objc private func previousButtonTapped() {
        viewModel.moveToPreviousDay()
        updateDateLabel()
    }
    
    @objc private func nextButtonTapped() {
        viewModel.moveToNextDay()
        updateDateLabel()
    }
    
    @objc private func calendarImageTapped() {
        viewModel.moveToToday()
        updateDateLabel()
    }
    
    @objc private func ilacKullanimiGuncellendi() {
        // İlaç kullanım durumu güncellendiğinde tabloyu yenile
        viewModel.fetchIlaclar()
        tableView.reloadData()
    }
    
    @objc private func addButtonTapped() {
        let addIlacVC = AddIlacViewController()
        addIlacVC.delegate = self as AddIlacViewControllerDelegate
        let navController = UINavigationController(rootViewController: addIlacVC)
        present(navController, animated: true)
    }
    
    private func updateEmptyState() {
        emptyStateView.isHidden = !viewModel.filteredIlaclar.isEmpty
    }
}

// MARK: - UITableViewDelegate, UITableViewDataSource
extension HomeViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return viewModel.filteredIlaclar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: IlacTableViewCell.identifier, for: indexPath) as? IlacTableViewCell else {
            return UITableViewCell()
        }
        
        let ilac = viewModel.filteredIlaclar[indexPath.row]
        let kullanimDurumu = viewModel.getIlacKullanimDurumu(ilac: ilac)
        cell.configure(with: ilac, kullanimDurumu: kullanimDurumu)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let ilac = viewModel.filteredIlaclar[indexPath.row]
        
        // Önce mevcut kullanım kaydını kontrol et
        if let ilacKullanim = viewModel.getIlacKullanim(for: ilac) {
            let detayVC = IlacDetayViewController()
            detayVC.ilacKullanim = ilacKullanim
            navigationController?.pushViewController(detayVC, animated: true)
        } else {
            // Kullanım kaydı yoksa yeni bir kayıt oluştur
            if let yeniKullanim = viewModel.createIlacKullanim(for: ilac) {
                let detayVC = IlacDetayViewController()
                detayVC.ilacKullanim = yeniKullanim
                navigationController?.pushViewController(detayVC, animated: true)
            } else {
                // Kullanım kaydı oluşturulamadıysa hata mesajı göster
                let alert = UIAlertController(title: "Hata", message: "İlaç kullanım kaydı oluşturulamadı.", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Tamam", style: .default))
                present(alert, animated: true)
            }
        }
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let ilac = viewModel.filteredIlaclar[indexPath.row]
        
        let detailAction = UIContextualAction(style: .normal, title: "Detay") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            let detailVC = IlacDetailViewController(ilacId: ilac.id!)
            self.navigationController?.pushViewController(detailVC, animated: true)
            completion(true)
        }
        
        detailAction.backgroundColor = .systemBlue
        detailAction.image = UIImage(systemName: "info.circle")
        
        let configuration = UISwipeActionsConfiguration(actions: [detailAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .destructive, title: "Sil") { [weak self] (_, _, completion) in
            guard let self = self else { return }
            
            let ilac = self.viewModel.filteredIlaclar[indexPath.row]
            self.viewModel.deleteIlac(ilac: ilac)
            completion(true)
        }
        
        deleteAction.image = UIImage(systemName: "trash")
        
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100 // Hücre yüksekliğini artırıyoruz
    }
}

// MARK: - HomeViewModelDelegate
extension HomeViewController: HomeViewModelDelegate {
    func didUpdateIlaclar() {
        DispatchQueue.main.async {
            self.tableView.reloadData()
            self.updateEmptyState()
        }
    }
    
    func didFailWithError(error: Error) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: "Hata", message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            self.present(alert, animated: true)
        }
    }
}

// MARK: - AddIlacViewControllerDelegate
extension HomeViewController: AddIlacViewControllerDelegate {
    func didAddIlac() {
        viewModel.fetchIlaclar()
    }
}
