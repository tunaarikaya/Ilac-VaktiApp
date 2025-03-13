import UIKit
import MapKit
import CoreLocation

class MapViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {
    
    // MARK: - UI Components
    private let mapView: MKMapView = {
        let map = MKMapView()
        map.translatesAutoresizingMaskIntoConstraints = false
        map.showsUserLocation = true
        map.mapType = .standard
        return map
    }()
    
    private let searchButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "magnifyingglass.circle.fill"), for: .normal)
        button.tintColor = UIColor(named: "AccentColor")
        button.backgroundColor = .white
        button.layer.cornerRadius = 30
        button.layer.shadowColor = UIColor.black.cgColor
        button.layer.shadowOffset = CGSize(width: 0, height: 2)
        button.layer.shadowOpacity = 0.2
        button.layer.shadowRadius = 4
        return button
    }()
    
    private let locationButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setImage(UIImage(systemName: "location.circle.fill"), for: .normal)
        button.tintColor = UIColor(named: "AccentColor")
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
    private var selectedAnnotation: MKPointAnnotation?
    private let searchRadius: CLLocationDistance = 5000 // 5 km radius
    private var searchCompleter: MKLocalSearchCompleter?
    private var currentSearch: MKLocalSearch?
    
    // MARK: - Lifecycle
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupUI()
        setupMapView()
        setupLocationManager()
        setupActions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }
    
    // MARK: - UI Setup
    private func setupUI() {
        view.backgroundColor = .systemBackground
        title = "Eczaneler"
        
        view.addSubview(mapView)
        view.addSubview(searchButton)
        view.addSubview(locationButton)
        
        NSLayoutConstraint.activate([
            mapView.topAnchor.constraint(equalTo: view.topAnchor),
            mapView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mapView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mapView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            
            searchButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            searchButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            searchButton.widthAnchor.constraint(equalToConstant: 60),
            searchButton.heightAnchor.constraint(equalToConstant: 60),
            
            locationButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            locationButton.bottomAnchor.constraint(equalTo: searchButton.topAnchor, constant: -20),
            locationButton.widthAnchor.constraint(equalToConstant: 50),
            locationButton.heightAnchor.constraint(equalToConstant: 50)
        ])
    }
    
    private func setupMapView() {
        mapView.delegate = self
    }
    
    private func setupLocationManager() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }
    
    private func setupActions() {
        searchButton.addTarget(self, action: #selector(searchButtonTapped), for: .touchUpInside)
        locationButton.addTarget(self, action: #selector(locationButtonTapped), for: .touchUpInside)
    }
    
    private func searchNearbyPharmacies() {
        guard let userLocation = locationManager.location else {
            showAlert(title: "Hata", message: "Konum bilgisi alınamadı.")
            return
        }

        let region = MKCoordinateRegion(
            center: userLocation.coordinate,
            latitudinalMeters: searchRadius,
            longitudinalMeters: searchRadius
        )

        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = "eczane"
        request.region = region

        currentSearch?.cancel()

        currentSearch = MKLocalSearch(request: request)
        currentSearch?.start { [weak self] response, error in
            guard let self = self else { return }

            if let error = error {
                self.showAlert(title: "Hata", message: error.localizedDescription)
                return
            }

            guard let response = response else { return }

            let existingAnnotations = self.mapView.annotations.filter { !($0 is MKUserLocation) }
            self.mapView.removeAnnotations(existingAnnotations)

            for item in response.mapItems {
                let annotation = MKPointAnnotation()
                annotation.coordinate = item.placemark.coordinate
                annotation.title = item.name
                let address = [item.placemark.thoroughfare, item.placemark.subThoroughfare, item.placemark.locality].compactMap { $0 }.joined(separator: " ")
                annotation.subtitle = address
                self.mapView.addAnnotation(annotation)
            }

            let region = MKCoordinateRegion(
                center: userLocation.coordinate,
                latitudinalMeters: self.searchRadius,
                longitudinalMeters: self.searchRadius
            )
            self.mapView.setRegion(region, animated: true)
        }
    }

    private func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Tamam", style: .default))
        present(alert, animated: true)
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
    @objc private func searchButtonTapped() {
        searchNearbyPharmacies()
    }
    
    @objc private func locationButtonTapped() {
        centerMapOnUserLocation()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .authorizedWhenInUse, .authorizedAlways:
            manager.startUpdatingLocation()
            mapView.showsUserLocation = true
            searchNearbyPharmacies()
            centerMapOnUserLocation()
        case .denied, .restricted:
            let alert = UIAlertController(
                title: "Konum İzni Gerekli",
                message: "Eczaneleri haritada görebilmek için konum izni vermeniz gerekmektedir.",
                preferredStyle: .alert
            )

            let settingsAction = UIAlertAction(title: "Ayarlar", style: .default) { _ in
                if let url = URL(string: UIApplication.openSettingsURLString) {
                    UIApplication.shared.open(url)
                }
            }

            let cancelAction = UIAlertAction(title: "İptal", style: .cancel)

            alert.addAction(settingsAction)
            alert.addAction(cancelAction)
            present(alert, animated: true)
        default:
            break
        }
    }
    
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
        
        locationManager.stopUpdatingLocation()
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print("Konum hatası: \(error.localizedDescription)")
    }

    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        guard !annotation.isKind(of: MKUserLocation.self) else {
            return nil
        }

        let identifier = "PharmacyAnnotation"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView

        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
            annotationView?.canShowCallout = true
            annotationView?.glyphImage = UIImage(systemName: "cross.fill")
            annotationView?.markerTintColor = UIColor(named: "AccentColor")

            let infoButton = UIButton(type: .detailDisclosure)
            annotationView?.rightCalloutAccessoryView = infoButton
        } else {
            annotationView?.annotation = annotation
        }

        return annotationView
    }

    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        if let annotation = view.annotation as? MKPointAnnotation {
            selectedAnnotation = annotation
        }
    }

    func mapView(_ mapView: MKMapView, didDeselect view: MKAnnotationView) {
        selectedAnnotation = nil
    }

    func mapView(_ mapView: MKMapView, annotationView view: MKAnnotationView, calloutAccessoryControlTapped control: UIControl) {
        guard let annotation = view.annotation else { return }

        if control == view.rightCalloutAccessoryView {
            let placemark = MKPlacemark(coordinate: annotation.coordinate)
            let mapItem = MKMapItem(placemark: placemark)
            mapItem.name = annotation.title ?? "Eczane"
            
            let alertController = UIAlertController(
                title: annotation.title ?? "Eczane",
                message: annotation.subtitle ?? "",
                preferredStyle: .alert
            )

            let navigateAction = UIAlertAction(title: "Yol Tarifi", style: .default) { _ in
                mapItem.openInMaps(launchOptions: [MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving])
            }

            let cancelAction = UIAlertAction(title: "Kapat", style: .cancel)

            alertController.addAction(navigateAction)
            alertController.addAction(cancelAction)

            present(alertController, animated: true)
        }
    }
}
