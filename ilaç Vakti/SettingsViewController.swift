import UIKit

class SettingsViewController: UIViewController {
    
    // MARK: - UI Components
    private let tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .insetGrouped)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.register(SettingsCell.self, forCellReuseIdentifier: "SettingsCell")
        tableView.backgroundColor = .systemGroupedBackground
        return tableView
    }()
    
    // MARK: - Properties
    private let viewModel = SettingsViewModel()
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupTableView()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemGroupedBackground
        title = "Ayarlar"
        
        navigationController?.navigationBar.prefersLargeTitles = true
        
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.topAnchor),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupTableView() {
        tableView.delegate = self
        tableView.dataSource = self
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "SettingsCell", for: indexPath)
        let item = viewModel.sections[indexPath.section].items[indexPath.row]
        
        cell.configure(with: item)
        
        switch item.type {
        case .toggle:
            let toggle = UISwitch()
            toggle.onTintColor = UIColor(named: "AccentColor")
            toggle.addTarget(self, action: #selector(switchChanged(_:)), for: .valueChanged)
            toggle.tag = indexPath.row
            
            // Set initial state for dark mode toggle
            if item.title == "Karanlık Mod" {
                toggle.isOn = UserDefaults.standard.bool(forKey: "isDarkMode")
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
        let section = 0  // App Settings section
        let indexPath = IndexPath(row: sender.tag, section: section)
        let item = viewModel.sections[section].items[indexPath.row]
        
        if item.title == "Karanlık Mod" {
            if let window = view.window {
                let newStyle: UIUserInterfaceStyle = sender.isOn ? .dark : .light
                window.overrideUserInterfaceStyle = newStyle
                UserDefaults.standard.set(sender.isOn, forKey: "isDarkMode")
            }
        }
        
        item.action?()
    }
    
    private func handleNavigation(for item: SettingsItem) {
        // Handle navigation based on item
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