import UIKit
import MapKit
import CoreLocation
import UserNotifications
import OneSignalFramework
import CoreData

protocol AddIlacViewControllerDelegate: AnyObject {
    func didAddIlac()
}

class AddIlacViewController: UIViewController {
    
    // MARK: - UI Components
    private let scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.translatesAutoresizingMaskIntoConstraints = false
        scrollView.showsVerticalScrollIndicator = true
        scrollView.showsHorizontalScrollIndicator = false
        return scrollView
    }()
    
    private let contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private let headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = UIColor(named: "AccentColor")?.withAlphaComponent(0.1)
        view.layer.cornerRadius = 12
        return view
    }()
    
    private let headerImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        imageView.image = UIImage(systemName: "pills.fill")
        imageView.tintColor = UIColor(named: "AccentColor")
        return imageView
    }()
    
    private let headerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Yeni İlaç Bilgileri"
        label.font = .systemFont(ofSize: 20, weight: .bold)
        label.textColor = UIColor(named: "AccentColor")
        return label
    }()
    
    private let formStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 20
        stackView.distribution = .fill
        return stackView
    }()
    
    // İlaç Adı Bölümü
    private let nameContainerView = UIView()
    
    private let nameLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "İlaç Adı"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let nameTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "İlaç adını girin"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        return textField
    }()
    
    // Doz Bölümü
    private let doseContainerView = UIView()
    
    private let doseLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Doz Bilgisi"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let doseTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Miktar"
        textField.borderStyle = .roundedRect
        textField.keyboardType = .decimalPad
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        return textField
    }()
    
    private let doseUnitTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Birim (mg, ml, vb.)"
        textField.borderStyle = .roundedRect
        textField.backgroundColor = .systemBackground
        textField.layer.cornerRadius = 8
        textField.layer.borderWidth = 1
        textField.layer.borderColor = UIColor.systemGray4.cgColor
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: textField.frame.height))
        textField.leftViewMode = .always
        return textField
    }()
    
    // Alım Saati Bölümü
    private let timeContainerView = UIView()
    
    private let timeLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "İlaç Alım Saati"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let timePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .time
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .wheels
        }
        datePicker.tintColor = UIColor(named: "AccentColor")
        datePicker.backgroundColor = UIColor.systemGray6
        datePicker.layer.cornerRadius = 12
        datePicker.clipsToBounds = true
        datePicker.heightAnchor.constraint(equalToConstant: 180).isActive = true
        datePicker.widthAnchor.constraint(equalToConstant: 300).isActive = true
        return datePicker
    }()
    
    // Bildirim Hatırlatma Bölümü
    private let notificationContainerView = UIView()
    
    private let notificationLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Hatırlatma Zamanı"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let notificationSegmentedControl: UISegmentedControl = {
        let options = ["10 dk önce", "30 dk önce", "1 saat önce"]
        let segmentedControl = UISegmentedControl(items: options)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        segmentedControl.selectedSegmentIndex = 0
        segmentedControl.backgroundColor = .systemBackground
        return segmentedControl
    }()
    
    // Tarih Bölümü
    private let dateContainerView = UIView()
    
    private let dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Kullanım Tarihleri"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let startDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Başlangıç Tarihi"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let startDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .compact
        }
        datePicker.tintColor = UIColor(named: "AccentColor")
        return datePicker
    }()
    
    private let endDateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Bitiş Tarihi (Opsiyonel)"
        label.font = .systemFont(ofSize: 14)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let endDatePicker: UIDatePicker = {
        let datePicker = UIDatePicker()
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.datePickerMode = .date
        if #available(iOS 13.4, *) {
            datePicker.preferredDatePickerStyle = .compact
        }
        datePicker.tintColor = UIColor(named: "AccentColor")
        // Varsayılan olarak 1 ay sonrasını ayarla
        datePicker.date = Calendar.current.date(byAdding: .month, value: 1, to: Date()) ?? Date()
        return datePicker
    }()
    
    // Açıklama Bölümü
    private let descriptionContainerView = UIView()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Açıklama (Opsiyonel)"
        label.font = .systemFont(ofSize: 16, weight: .medium)
        return label
    }()
    
    private let descriptionTextView: UITextView = {
        let textView = UITextView()
        textView.translatesAutoresizingMaskIntoConstraints = false
        textView.layer.borderWidth = 1
        textView.layer.borderColor = UIColor.systemGray4.cgColor
        textView.layer.cornerRadius = 8
        textView.font = .systemFont(ofSize: 16)
        textView.textContainerInset = UIEdgeInsets(top: 8, left: 4, bottom: 8, right: 4)
        return textView
    }()
    
    // Save button removed and moved to navigation bar
    
    // MARK: - Properties
    weak var delegate: AddIlacViewControllerDelegate?
    private let coreDataManager = CoreDataManager.shared
    private let notificationManager = NotificationManager.shared
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupNavigationBar()
        setupActions()
        setupKeyboardDismissal()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        
        // Ana görünümleri ekle
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        
        // Header ekle
        contentView.addSubview(headerView)
        headerView.addSubview(headerImageView)
        headerView.addSubview(headerLabel)
        
        // Form stack view ekle
        contentView.addSubview(formStackView)
        
        // İlaç adı bölümü
        nameContainerView.translatesAutoresizingMaskIntoConstraints = false
        nameContainerView.addSubview(nameLabel)
        nameContainerView.addSubview(nameTextField)
        formStackView.addArrangedSubview(nameContainerView)
        
        // Doz bölümü
        doseContainerView.translatesAutoresizingMaskIntoConstraints = false
        doseContainerView.addSubview(doseLabel)
        doseContainerView.addSubview(doseTextField)
        doseContainerView.addSubview(doseUnitTextField)
        formStackView.addArrangedSubview(doseContainerView)
        
        // Alım saati bölümü
        timeContainerView.translatesAutoresizingMaskIntoConstraints = false
        timeContainerView.addSubview(timeLabel)
        timeContainerView.addSubview(timePicker)
        formStackView.addArrangedSubview(timeContainerView)
        
        // Bildirim Hatırlatma Bölümünü ekle
        notificationContainerView.translatesAutoresizingMaskIntoConstraints = false
        notificationContainerView.addSubview(notificationLabel)
        notificationContainerView.addSubview(notificationSegmentedControl)
        
        NSLayoutConstraint.activate([
            notificationLabel.topAnchor.constraint(equalTo: notificationContainerView.topAnchor),
            notificationLabel.leadingAnchor.constraint(equalTo: notificationContainerView.leadingAnchor),
            notificationLabel.trailingAnchor.constraint(equalTo: notificationContainerView.trailingAnchor),
            
            notificationSegmentedControl.topAnchor.constraint(equalTo: notificationLabel.bottomAnchor, constant: 8),
            notificationSegmentedControl.leadingAnchor.constraint(equalTo: notificationContainerView.leadingAnchor),
            notificationSegmentedControl.trailingAnchor.constraint(equalTo: notificationContainerView.trailingAnchor),
            notificationSegmentedControl.bottomAnchor.constraint(equalTo: notificationContainerView.bottomAnchor)
        ])
        
        // FormStackView'a ekle
        formStackView.addArrangedSubview(notificationContainerView)
        
        // Tarih bölümü
        dateContainerView.translatesAutoresizingMaskIntoConstraints = false
        dateContainerView.addSubview(dateLabel)
        dateContainerView.addSubview(startDateLabel)
        dateContainerView.addSubview(startDatePicker)
        dateContainerView.addSubview(endDateLabel)
        dateContainerView.addSubview(endDatePicker)
        formStackView.addArrangedSubview(dateContainerView)
        
        // Açıklama bölümü
        descriptionContainerView.translatesAutoresizingMaskIntoConstraints = false
        descriptionContainerView.addSubview(descriptionLabel)
        descriptionContainerView.addSubview(descriptionTextView)
        formStackView.addArrangedSubview(descriptionContainerView)
        
        // Save button removed from content view
        
        // Constraint'leri ayarla
        NSLayoutConstraint.activate([
            // ScrollView
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            // ContentView
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            // Header
            headerView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 16),
            headerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            headerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            headerView.heightAnchor.constraint(equalToConstant: 80),
            
            headerImageView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 16),
            headerImageView.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerImageView.widthAnchor.constraint(equalToConstant: 40),
            headerImageView.heightAnchor.constraint(equalToConstant: 40),
            
            headerLabel.leadingAnchor.constraint(equalTo: headerImageView.trailingAnchor, constant: 16),
            headerLabel.centerYAnchor.constraint(equalTo: headerView.centerYAnchor),
            headerLabel.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -16),
            
            // Form Stack View
            formStackView.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: 24),
            formStackView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            formStackView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            // İlaç Adı Bölümü
            nameContainerView.heightAnchor.constraint(equalToConstant: 80),
            nameLabel.topAnchor.constraint(equalTo: nameContainerView.topAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: nameContainerView.leadingAnchor),
            nameLabel.trailingAnchor.constraint(equalTo: nameContainerView.trailingAnchor),
            
            nameTextField.topAnchor.constraint(equalTo: nameLabel.bottomAnchor, constant: 8),
            nameTextField.leadingAnchor.constraint(equalTo: nameContainerView.leadingAnchor),
            nameTextField.trailingAnchor.constraint(equalTo: nameContainerView.trailingAnchor),
            nameTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Doz Bölümü
            doseContainerView.heightAnchor.constraint(equalToConstant: 80),
            doseLabel.topAnchor.constraint(equalTo: doseContainerView.topAnchor),
            doseLabel.leadingAnchor.constraint(equalTo: doseContainerView.leadingAnchor),
            doseLabel.trailingAnchor.constraint(equalTo: doseContainerView.trailingAnchor),
            
            doseTextField.topAnchor.constraint(equalTo: doseLabel.bottomAnchor, constant: 8),
            doseTextField.leadingAnchor.constraint(equalTo: doseContainerView.leadingAnchor),
            doseTextField.widthAnchor.constraint(equalTo: doseContainerView.widthAnchor, multiplier: 0.45),
            doseTextField.heightAnchor.constraint(equalToConstant: 44),
            
            doseUnitTextField.topAnchor.constraint(equalTo: doseLabel.bottomAnchor, constant: 8),
            doseUnitTextField.leadingAnchor.constraint(equalTo: doseTextField.trailingAnchor, constant: 16),
            doseUnitTextField.trailingAnchor.constraint(equalTo: doseContainerView.trailingAnchor),
            doseUnitTextField.heightAnchor.constraint(equalToConstant: 44),
            
            // Alım Saati Bölümü
            timeContainerView.heightAnchor.constraint(equalToConstant: 200),
            timeLabel.topAnchor.constraint(equalTo: timeContainerView.topAnchor),
            timeLabel.leadingAnchor.constraint(equalTo: timeContainerView.leadingAnchor),
            timeLabel.trailingAnchor.constraint(equalTo: timeContainerView.trailingAnchor),
            
            timePicker.topAnchor.constraint(equalTo: timeLabel.bottomAnchor, constant: 8),
            timePicker.centerXAnchor.constraint(equalTo: timeContainerView.centerXAnchor),
            timePicker.heightAnchor.constraint(equalToConstant: 160),
            
            // Tarih Bölümü
            dateContainerView.heightAnchor.constraint(equalToConstant: 140),
            dateLabel.topAnchor.constraint(equalTo: dateContainerView.topAnchor),
            dateLabel.leadingAnchor.constraint(equalTo: dateContainerView.leadingAnchor),
            dateLabel.trailingAnchor.constraint(equalTo: dateContainerView.trailingAnchor),
            
            startDateLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 16),
            startDateLabel.leadingAnchor.constraint(equalTo: dateContainerView.leadingAnchor),
            
            startDatePicker.centerYAnchor.constraint(equalTo: startDateLabel.centerYAnchor),
            startDatePicker.leadingAnchor.constraint(equalTo: startDateLabel.trailingAnchor, constant: 16),
            startDatePicker.trailingAnchor.constraint(equalTo: dateContainerView.trailingAnchor),
            
            endDateLabel.topAnchor.constraint(equalTo: startDateLabel.bottomAnchor, constant: 24),
            endDateLabel.leadingAnchor.constraint(equalTo: dateContainerView.leadingAnchor),
            
            endDatePicker.centerYAnchor.constraint(equalTo: endDateLabel.centerYAnchor),
            endDatePicker.leadingAnchor.constraint(equalTo: endDateLabel.trailingAnchor, constant: 16),
            endDatePicker.trailingAnchor.constraint(equalTo: dateContainerView.trailingAnchor),
            
            // Açıklama Bölümü
            descriptionContainerView.heightAnchor.constraint(equalToConstant: 150),
            descriptionLabel.topAnchor.constraint(equalTo: descriptionContainerView.topAnchor),
            descriptionLabel.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor),
            descriptionLabel.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor),
            
            descriptionTextView.topAnchor.constraint(equalTo: descriptionLabel.bottomAnchor, constant: 8),
            descriptionTextView.leadingAnchor.constraint(equalTo: descriptionContainerView.leadingAnchor),
            descriptionTextView.trailingAnchor.constraint(equalTo: descriptionContainerView.trailingAnchor),
            descriptionTextView.heightAnchor.constraint(equalToConstant: 100),
            
            // Bottom padding for the form
            formStackView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -24)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Yeni İlaç Ekle"
        
        let cancelButton = UIBarButtonItem(title: "Geri ",style:.plain , target: self, action: #selector(cancelButtonTapped))
        navigationItem.leftBarButtonItem = cancelButton
        
        let saveButton = UIBarButtonItem(title: "Kaydet", style: .plain, target: self, action: #selector(saveButtonTapped))
        navigationItem.rightBarButtonItem = saveButton
    }
    
    private func setupActions() {
        // Save button action is now handled by the navigation bar button
    }
    
    private func setupKeyboardDismissal() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
    
    // MARK: - Actions
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func saveButtonTapped() {
        // Zorunlu alanları kontrol et
        guard let name = nameTextField.text, !name.isEmpty else {
            showAlert(title: "Eksik Bilgi", message: "Lütfen ilaç adını girin")
            return
        }
        
        // CoreData context'ini al
        let context = CoreDataManager.shared.context
        
        // İlaç nesnesini oluştur
        let ilac = Ilac(context: context)
        ilac.id = UUID() // UUID tipinde ID ata
        ilac.ad = name
        
        // Doz bilgilerini kontrol et ve kaydet
        let dozBirimi = doseUnitTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let doseText = doseTextField.text, !doseText.isEmpty, let doseValue = Double(doseText) {
            ilac.doz = doseValue
        } else {
            ilac.doz = 1.0 // Varsayılan değer
        }
        
        // dozBirimi her durumda bir değer almalı
        ilac.dozBirimi = dozBirimi?.isEmpty == false ? dozBirimi! : "adet"
        
        // Açıklama
        ilac.aciklama = descriptionTextView.text
        
        // Tarih bilgilerini ayarla
        ilac.baslangicTarihi = startDatePicker.date
        ilac.bitisTarihi = endDatePicker.date
        
        // İlaç kullanım zamanını ayarla
        let ilacKullanim = IlacKullanim(context: context)
        ilacKullanim.id = UUID() // UUID tipinde ID ata
        ilacKullanim.tarih = timePicker.date
        ilacKullanim.alindiMi = false
        ilacKullanim.alinanDoz = ilac.doz
        ilacKullanim.ilac = ilac
        
        // Hatırlatma zamanını hesapla
        var reminderMinutes = 10 // Varsayılan
        switch notificationSegmentedControl.selectedSegmentIndex {
        case 0: reminderMinutes = 10
        case 1: reminderMinutes = 30
        case 2: reminderMinutes = 60
        default: reminderMinutes = 10
        }
        
        do {
            // Değişiklikleri kaydet
            try context.save()
            
            // İlaç için benzersiz kimlik oluştur
            let ilacId = ilac.id?.uuidString ?? UUID().uuidString // UUID'yi string'e çevir
            
            // Bildirimi planla
            notificationManager.scheduleNotification(
                ilacAdi: name,
                ilacId: ilacId,
                ilacSaati: timePicker.date,
                hatirlatmaDakika: reminderMinutes
            )
            
            // Başarılı kayıt
            delegate?.didAddIlac()
            dismiss(animated: true)
            
        } catch let error as NSError {
            // Hata detaylarını göster
            var errorMessage = "İlaç kaydedilirken bir hata oluştu:\n"
            if let detailedErrors = error.userInfo[NSDetailedErrorsKey] as? [NSError] {
                for detailedError in detailedErrors {
                    errorMessage += "\n- \(detailedError.localizedDescription)"
                }
            } else {
                errorMessage += "\n\(error.localizedDescription)"
            }
            
            showAlert(title: "Hata", message: errorMessage)
            print("CoreData kayıt hatası: \(error), \(error.userInfo)")
        }
    }
    
    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
    }
} 
