import UIKit
import MapKit
import CoreData

class EczaneDetailViewController: UIViewController {
    
    // MARK: - UI Components
    private let containerView: UIView = {
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
    
    private let titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 22, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private let adresLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        label.numberOfLines = 0
        return label
    }()
    
    private let telefonLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 16)
        label.textAlignment = .left
        return label
    }()
    
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.layer.cornerRadius = 8
        return map
    }()
    
    private let callButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Ara", for: .normal)
        button.setImage(UIImage(systemName: "phone.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemGreen
        button.layer.cornerRadius = 8
        return button
    }()
    
    private let directionsButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Yol Tarifi", for: .normal)
        button.setImage(UIImage(systemName: "map.fill"), for: .normal)
        button.tintColor = .white
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 8
        return button
    }()
    
    // MARK: - Properties
    private var eczane: NSManagedObject
    private var coordinate: CLLocationCoordinate2D?
    
    // MARK: - Initialization
    init(eczane: NSManagedObject) {
        self.eczane = eczane
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        configureWithEczane()
        setupActions()
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Eczane Detayı"
        
        view.addSubview(containerView)
        containerView.addSubview(titleLabel)
        containerView.addSubview(adresLabel)
        containerView.addSubview(telefonLabel)
        containerView.addSubview(mapView)
        containerView.addSubview(callButton)
        containerView.addSubview(directionsButton)
        
        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16),
            containerView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            
            titleLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 16),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            adresLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 16),
            adresLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            adresLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            telefonLabel.topAnchor.constraint(equalTo: adresLabel.bottomAnchor, constant: 8),
            telefonLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            telefonLabel.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            
            mapView.topAnchor.constraint(equalTo: telefonLabel.bottomAnchor, constant: 16),
            mapView.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            mapView.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            mapView.heightAnchor.constraint(equalToConstant: 200),
            
            callButton.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            callButton.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 16),
            callButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.45),
            callButton.heightAnchor.constraint(equalToConstant: 50),
            
            directionsButton.topAnchor.constraint(equalTo: mapView.bottomAnchor, constant: 16),
            directionsButton.trailingAnchor.constraint(equalTo: containerView.trailingAnchor, constant: -16),
            directionsButton.widthAnchor.constraint(equalTo: containerView.widthAnchor, multiplier: 0.45),
            directionsButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func configureWithEczane() {
        guard let ad = eczane.value(forKey: "ad") as? String,
              let adres = eczane.value(forKey: "adres") as? String,
              let telefon = eczane.value(forKey: "telefon") as? String,
              let latitude = eczane.value(forKey: "latitude") as? Double,
              let longitude = eczane.value(forKey: "longitude") as? Double else {
            return
        }
        
        titleLabel.text = ad
        adresLabel.text = "Adres: \(adres)"
        telefonLabel.text = "Telefon: \(telefon)"
        
        coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        
        if let coordinate = coordinate {
            let annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            annotation.title = ad
            mapView.addAnnotation(annotation)
            
            let region = MKCoordinateRegion(
                center: coordinate,
                span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)
            )
            mapView.setRegion(region, animated: true)
        }
    }
    
    private func setupActions() {
        callButton.addTarget(self, action: #selector(callButtonTapped), for: .touchUpInside)
        directionsButton.addTarget(self, action: #selector(directionsButtonTapped), for: .touchUpInside)
    }
    
    // MARK: - Actions
    @objc private func callButtonTapped() {
        guard let telefon = eczane.value(forKey: "telefon") as? String,
              let url = URL(string: "tel://\(telefon.replacingOccurrences(of: " ", with: ""))") else {
            return
        }
        
        UIApplication.shared.open(url)
    }
    
    @objc private func directionsButtonTapped() {
        guard let coordinate = coordinate,
              let ad = eczane.value(forKey: "ad") as? String else {
            return
        }
        
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = ad
        
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }
}
