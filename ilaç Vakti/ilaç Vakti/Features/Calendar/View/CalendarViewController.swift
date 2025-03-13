import UIKit
import CoreData

class CalendarViewController: UIViewController {
    
    // MARK: - UI Components
    private let calendarView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        return view
    }()
    
    private let monthYearLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(named: "AccentColor")
        label.textAlignment = .center
        return label
    }()
    
    private let previousButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "chevron.left", withConfiguration: config), for: .normal)
        button.tintColor = UIColor(named: "AccentColor")
        return button
    }()
    
    private let nextButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        let config = UIImage.SymbolConfiguration(pointSize: 18, weight: .medium)
        button.setImage(UIImage(systemName: "chevron.right", withConfiguration: config), for: .normal)
        button.tintColor = UIColor(named: "AccentColor")
        return button
    }()
    
    private let weekdayStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.alignment = .center
        return stackView
    }()
    
    private let daysCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 0
        layout.minimumLineSpacing = 0
        
        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.backgroundColor = .clear
        collectionView.isScrollEnabled = false
        return collectionView
    }()
    
    private let selectedDateView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let selectedDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.textColor = UIColor(named: "AccentColor")
        return label
    }()
    
    private let ilacTableView: UITableView = {
        let tableView = UITableView()
        tableView.translatesAutoresizingMaskIntoConstraints = false
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.showsVerticalScrollIndicator = false
        return tableView
    }()
    
    private let emptyStateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bu tarihte ilaç kullanımı bulunmuyor"
        label.font = .systemFont(ofSize: 16)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.isHidden = true
        return label
    }()
    
    // MARK: - Properties
    private let calendar = Calendar.current
    private var selectedDate = Date()
    private var totalSquares = [Date]()
    private let weekdays = ["Pzt", "Sal", "Çar", "Per", "Cum", "Cmt", "Paz"]
    private var selectedDateIlaclar: [IlacKullanim] = []
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupCalendar()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        updateSelectedDateIlaclar()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Takvim"
        
        // CollectionView kayıt
        daysCollectionView.register(CalendarCell.self, forCellWithReuseIdentifier: "CalendarCell")
        daysCollectionView.delegate = self
        daysCollectionView.dataSource = self
        
        // TableView kayıt
        ilacTableView.register(IlacKullanimCell.self, forCellReuseIdentifier: "IlacKullanimCell")
        ilacTableView.delegate = self
        ilacTableView.dataSource = self
        
        // Görünümleri ekle
        view.addSubview(calendarView)
        calendarView.addSubview(monthYearLabel)
        calendarView.addSubview(previousButton)
        calendarView.addSubview(nextButton)
        calendarView.addSubview(weekdayStackView)
        calendarView.addSubview(daysCollectionView)
        
        view.addSubview(selectedDateView)
        selectedDateView.addSubview(selectedDateLabel)
        view.addSubview(ilacTableView)
        view.addSubview(emptyStateLabel)
        
        setupWeekdayLabels()
        
        // Constraint'leri ayarla
        NSLayoutConstraint.activate([
            calendarView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            calendarView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            calendarView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            calendarView.heightAnchor.constraint(equalToConstant: 380),
            
            monthYearLabel.topAnchor.constraint(equalTo: calendarView.topAnchor, constant: 16),
            monthYearLabel.centerXAnchor.constraint(equalTo: calendarView.centerXAnchor),
            
            previousButton.centerYAnchor.constraint(equalTo: monthYearLabel.centerYAnchor),
            previousButton.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 16),
            previousButton.widthAnchor.constraint(equalToConstant: 44),
            previousButton.heightAnchor.constraint(equalToConstant: 44),
            
            nextButton.centerYAnchor.constraint(equalTo: monthYearLabel.centerYAnchor),
            nextButton.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -16),
            nextButton.widthAnchor.constraint(equalToConstant: 44),
            nextButton.heightAnchor.constraint(equalToConstant: 44),
            
            weekdayStackView.topAnchor.constraint(equalTo: monthYearLabel.bottomAnchor, constant: 20),
            weekdayStackView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 10),
            weekdayStackView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -10),
            weekdayStackView.heightAnchor.constraint(equalToConstant: 30),
            
            daysCollectionView.topAnchor.constraint(equalTo: weekdayStackView.bottomAnchor, constant: 10),
            daysCollectionView.leadingAnchor.constraint(equalTo: calendarView.leadingAnchor, constant: 10),
            daysCollectionView.trailingAnchor.constraint(equalTo: calendarView.trailingAnchor, constant: -10),
            daysCollectionView.bottomAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: -10),
            
            selectedDateView.topAnchor.constraint(equalTo: calendarView.bottomAnchor, constant: 16),
            selectedDateView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            selectedDateView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            selectedDateView.heightAnchor.constraint(equalToConstant: 50),
            
            selectedDateLabel.leadingAnchor.constraint(equalTo: selectedDateView.leadingAnchor, constant: 16),
            selectedDateLabel.centerYAnchor.constraint(equalTo: selectedDateView.centerYAnchor),
            
            ilacTableView.topAnchor.constraint(equalTo: selectedDateView.bottomAnchor, constant: 16),
            ilacTableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            ilacTableView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            ilacTableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            emptyStateLabel.centerXAnchor.constraint(equalTo: ilacTableView.centerXAnchor),
            emptyStateLabel.centerYAnchor.constraint(equalTo: ilacTableView.centerYAnchor)
        ])
    }
    
    private func setupWeekdayLabels() {
        weekdays.forEach { day in
            let label = UILabel()
            label.text = day
            label.font = .systemFont(ofSize: 14, weight: .medium)
            label.textColor = .secondaryLabel
            label.textAlignment = .center
            weekdayStackView.addArrangedSubview(label)
        }
    }
    
    private func setupCalendar() {
        setMonthView()
    }
    
    private func setupActions() {
        previousButton.addTarget(self, action: #selector(previousMonth), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextMonth), for: .touchUpInside)
    }
    
    // MARK: - Calendar Methods
    private func setMonthView() {
        totalSquares.removeAll()
        
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 0
        let firstDayOfMonth = calendar.date(from: calendar.dateComponents([.year, .month], from: selectedDate))!
        let startingSpaces = calendar.component(.weekday, from: firstDayOfMonth)
        let adjustedStartingSpaces = startingSpaces == 1 ? 6 : startingSpaces - 2
        
        var count: Int = 1
        
        while count <= 42 {
            if count <= adjustedStartingSpaces || count - adjustedStartingSpaces > daysInMonth {
                totalSquares.append(Date.distantPast)
            } else {
                let dayOffset = count - adjustedStartingSpaces - 1
                if let date = calendar.date(byAdding: .day, value: dayOffset, to: firstDayOfMonth) {
                    totalSquares.append(date)
                }
            }
            count += 1
        }
        
        // Ay ve yıl etiketlerini güncelle
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "tr_TR")
        dateFormatter.dateFormat = "MMMM yyyy"
        monthYearLabel.text = dateFormatter.string(from: selectedDate).capitalized
        
        // Seçili tarih etiketini güncelle
        dateFormatter.dateFormat = "d MMMM yyyy, EEEE"
        selectedDateLabel.text = dateFormatter.string(from: selectedDate).capitalized
        
        daysCollectionView.reloadData()
        updateSelectedDateIlaclar()
    }
    
    @objc private func previousMonth() {
        selectedDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) ?? selectedDate
        setMonthView()
    }
    
    @objc private func nextMonth() {
        selectedDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) ?? selectedDate
        setMonthView()
    }
    
    private func updateSelectedDateIlaclar() {
        // Seçili tarihe ait ilaç kullanımlarını getir
        let startOfDay = calendar.startOfDay(for: selectedDate)
        let endOfDay = calendar.date(byAdding: .day, value: 1, to: startOfDay)!
        
        let fetchRequest: NSFetchRequest<IlacKullanim> = IlacKullanim.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "tarih >= %@ AND tarih < %@", startOfDay as NSDate, endOfDay as NSDate)
        
        do {
            selectedDateIlaclar = try coreDataManager.context.fetch(fetchRequest)
            ilacTableView.reloadData()
            emptyStateLabel.isHidden = !selectedDateIlaclar.isEmpty
        } catch {
            print("Hata: İlaç kullanımları getirilemedi - \(error.localizedDescription)")
            selectedDateIlaclar = []
            emptyStateLabel.isHidden = false
        }
    }
}

// MARK: - UICollectionView Delegate & DataSource
extension CalendarViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return totalSquares.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CalendarCell", for: indexPath) as! CalendarCell
        
        let date = totalSquares[indexPath.item]
        let day = calendar.component(.day, from: date)
        let month = calendar.component(.month, from: date)
        let currentMonth = calendar.component(.month, from: selectedDate)
        
        // Boş günleri kontrol et
        if date == Date.distantPast {
            cell.dayLabel.text = ""
            cell.backgroundColor = .clear
            cell.layer.cornerRadius = 0
            return cell
        }
        
        // Gün numarasını ayarla
        cell.dayLabel.text = month == currentMonth ? "\(day)" : ""
        cell.dayLabel.textColor = .label
        
        // Bugünün tarihini vurgula
        if calendar.isDate(date, inSameDayAs: Date()) {
            cell.backgroundColor = UIColor(named: "AccentColor")?.withAlphaComponent(0.2)
            cell.layer.cornerRadius = 8
        } else if calendar.isDate(date, inSameDayAs: selectedDate) {
            cell.backgroundColor = UIColor(named: "AccentColor")?.withAlphaComponent(0.1)
            cell.layer.cornerRadius = 8
        } else {
            cell.backgroundColor = .clear
            cell.layer.cornerRadius = 0
        }
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        let width = (collectionView.frame.size.width - 2) / 7
        return CGSize(width: width, height: 40)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let date = totalSquares[indexPath.item]
        let month = calendar.component(.month, from: date)
        let currentMonth = calendar.component(.month, from: selectedDate)
        
        if month == currentMonth {
            selectedDate = date
            setMonthView()
        }
    }
}

// MARK: - UITableView Delegate & DataSource
extension CalendarViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return selectedDateIlaclar.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "IlacKullanimCell", for: indexPath) as! IlacKullanimCell
        let kullanim = selectedDateIlaclar[indexPath.row]
        cell.configure(with: kullanim)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
}

// MARK: - Calendar Cell
class CalendarCell: UICollectionViewCell {
    let dayLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 16)
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        contentView.addSubview(dayLabel)
        
        NSLayoutConstraint.activate([
            dayLabel.centerXAnchor.constraint(equalTo: contentView.centerXAnchor),
            dayLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        backgroundColor = .clear
        layer.cornerRadius = 0
        dayLabel.textColor = .label
    }
}

// MARK: - IlacKullanim Cell
class IlacKullanimCell: UITableViewCell {
    private let containerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .secondarySystemBackground
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let ilacNameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .semibold)
        return label
    }()
    
    private let saatLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let kullanimDurumuLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        backgroundColor = .clear
        selectionStyle = .none
        
        contentView.addSubview(containerView)
        containerView.addSubview(ilacNameLabel)
        containerView.addSubview(saatLabel)
        containerView.addSubview(kullanimDurumuLabel)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            
            ilacNameLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            ilacNameLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            ilacNameLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            saatLabel.topAnchor.constraint(equalTo: ilacNameLabel.bottomAnchor, constant: 4),
            saatLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            
            kullanimDurumuLabel.centerYAnchor.constraint(equalTo: saatLabel.centerYAnchor),
            kullanimDurumuLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16)
        ])
    }
    
    func configure(with kullanim: IlacKullanim) {
        ilacNameLabel.text = kullanim.ilac?.ad
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "HH:mm"
        if let tarih = kullanim.tarih {
            saatLabel.text = dateFormatter.string(from: tarih)
        }
        
        kullanimDurumuLabel.text = kullanim.alindiMi ? "✅ Alındı" : "❌ Alınmadı"
        kullanimDurumuLabel.textColor = kullanim.alindiMi ? .systemGreen : .systemRed
    }
} 