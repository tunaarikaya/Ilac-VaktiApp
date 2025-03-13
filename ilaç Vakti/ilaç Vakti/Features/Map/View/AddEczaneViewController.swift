import UIKit
import MapKit
import CoreLocation
import Foundation

protocol AddEczaneViewControllerDelegate: AnyObject {
    func didAddEczane()
}

class AddEczaneViewController: UIViewController {
    
    // MARK: - UI Components
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.showsUserLocation = true
        return map
    }()
    
    private let pinImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(systemName: "mappin")
        imageView.tintColor = UIColor(named: "AccentColor") ?? .systemBlue
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private let formContainerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemBackground
        view.layer.cornerRadius = 12
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.1
        view.layer.shadowOffset = CGSize(width: 0, height: -2)
        view.layer.shadowRadius = 4
        return view
    }()
    
    private let adTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Eczane Adı"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let adresTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Adres"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        return textField
    }()
    
    private let telefonTextField: UITextField = {
        let textField = UITextField()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.placeholder = "Telefon"
        textField.borderStyle = .roundedRect
        textField.clearButtonMode = .whileEditing
        textField.keyboardType = .phonePad
        return textField
    }()
    
    private let saveButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Kaydet", for: .normal)
        button.backgroundColor = UIColor(named: "AccentColor") ?? .systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let instructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Haritada eczanenin konumunu seçin"
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    private let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        button.tintColor = UIColor(named: "AccentColor") ?? .systemBlue
        button.backgroundColor = .white
        button.layer.cornerRadius = 25
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 4
        return button
    }()
    
    // MARK: - Properties
    private let locationManager = CLLocationManager()
    private let viewModel = MapViewModel()
    weak var delegate: AddEczaneViewControllerDelegate?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupLocationManager()
        setupActions()
        setupGestures()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Yeni Eczane Ekle"
        
        // Navigation bar setup
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .cancel,
            target: self,
            action: #selector(cancelButtonTapped)
        )
        
        view.addSubview(mapView)
        view.addSubview(pinImageView)
        view.addSubview(instructionLabel)
        view.addSubview(locationButton)
        view.addSubview(formContainerView)
        
        formContainerView.addSubview(adTextField)
        formContainerView.addSubview(adresTextField)
        formContainerView.addSubview(telefonTextField)
        formContainerView.addSubview(saveButton)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.heightAnchor.constraint(equalTo: view.heightAnchor, multiplier: 0.6),
            
            pinImageView.centerXAnchor.constraint(equalTo: mapView.centerXAnchor),
            pinImageView.centerYAnchor.constraint(equalTo: mapView.centerYAnchor, constant: -15), // Pin'in alt kısmı merkeze gelsin
            pinImageView.widthAnchor.constraint(equalToConstant: 30),
            pinImageView.heightAnchor.constraint(equalToConstant: 30),
            
            instructionLabel.bottomAnchor.constraint(equalTo: mapView.bottomAnchor, constant: -16),
            instructionLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            instructionLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            locationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            locationButton.bottomAnchor.constraint(equalTo: instructionLabel.topAnchor, constant: -16),
            locationButton.widthAnchor.constraint(equalToConstant: 50),
            locationButton.heightAnchor.constraint(equalToConstant: 50),
            
            formContainerView.topAnchor.constraint(equalTo: mapView.bottomAnchor),
            formContainerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            formContainerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            formContainerView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            adTextField.topAnchor.constraint(equalTo: formContainerView.topAnchor, constant: 24),
            adTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 16),
            adTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -16),
            adTextField.heightAnchor.constraint(equalToConstant: 44),
            
            adresTextField.topAnchor.constraint(equalTo: adTextField.bottomAnchor, constant: 16),
            adresTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 16),
            adresTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -16),
            adresTextField.heightAnchor.constraint(equalToConstant: 44),
            
            telefonTextField.topAnchor.constraint(equalTo: adresTextField.bottomAnchor, constant: 16),
            telefonTextField.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 16),
            telefonTextField.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -16),
            telefonTextField.heightAnchor.constraint(equalToConstant: 44),
            
            saveButton.topAnchor.constraint(equalTo: telefonTextField.bottomAnchor, constant: 24),
            saveButton.leadingAnchor.constraint(equalTo: formContainerView.leadingAnchor, constant: 16),
            saveButton.trailingAnchor.constraint(equalTo: formContainerView.trailingAnchor, constant: -16),
            saveButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupActions() {
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
    }
    
    private func setupGestures() {
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tapGesture)
    }
    
    private func centerMapOnUserLocation() {
        if let userLocation = locationManager.location?.coordinate {
            let region = MKCoordinateRegion(
                center: userLocation,
                span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
            )
            mapView.setRegion(region, animated: true)
        }
    }
    
    // MARK: - Actions
    @objc private func saveButtonTapped() {
        guard let ad = adTextField.text, !ad.isEmpty,
              let adres = adresTextField.text, !adres.isEmpty,
              let telefon = telefonTextField.text, !telefon.isEmpty else {
            
            let alert = UIAlertController(
                title: "Eksik Bilgi",
                message: "Lütfen tüm alanları doldurun",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Tamam", style: .default))
            present(alert, animated: true)
            return
        }
        
        // Haritanın merkezindeki koordinatı al
        let coordinate = mapView.centerCoordinate
        
        // Yeni eczane oluştur
        viewModel.createEczane(
            ad: ad,
            adres: adres,
            telefon: telefon,
            coordinate: coordinate
        )
        
        // Delegate'e haber ver
        delegate?.didAddEczane()
        
        // Ekranı kapat
        dismiss(animated: true)
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func locationButtonTapped() {
        centerMapOnUserLocation()
    }
    
    @objc private func dismissKeyboard() {
        view.endEditing(true)
    }
}

// MARK: - CLLocationManagerDelegate
extension AddEczaneViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        
        let region = MKCoordinateRegion(
            center: location.coordinate,
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
        
        // İlk konum güncellemesinde haritayı kullanıcının konumuna merkezle
        if mapView.region.span.latitudeDelta > 1.0 {
            mapView.setRegion(region, animated: true)
        }
    }
}
