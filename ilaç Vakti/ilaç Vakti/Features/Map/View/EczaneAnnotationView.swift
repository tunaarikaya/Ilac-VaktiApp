import MapKit

class EczaneAnnotationView: MKMarkerAnnotationView {
    
    static let identifier = "EczaneAnnotationView"
    
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        setupView()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }
    
    private func setupView() {
        // Eczane pin'i için özel görünüm ayarları
        markerTintColor = UIColor(named: "AccentColor") ?? .systemBlue
        glyphImage = UIImage(systemName: "cross.fill")
        glyphTintColor = .white
        
        // Callout ayarları
        canShowCallout = true
        
        // Detay butonu
        let infoButton = UIButton(type: .detailDisclosure)
        rightCalloutAccessoryView = infoButton
        
        // Silme butonu
        let deleteButton = UIButton(type: .custom)
        deleteButton.setImage(UIImage(systemName: "trash"), for: .normal)
        deleteButton.tintColor = .systemRed
        leftCalloutAccessoryView = deleteButton
        
        // Animasyon
        animatesWhenAdded = true
    }
}
