import Foundation
import CoreLocation
import MapKit

class MapViewModel {
    
    // MARK: - Properties
    private var eczaneler: [Eczane] = []
    
    // MARK: - Methods
    func createEczane(ad: String, adres: String, telefon: String, coordinate: CLLocationCoordinate2D) {
        let eczane = Eczane(
            ad: ad,
            adres: adres,
            telefon: telefon,
            latitude: coordinate.latitude,
            longitude: coordinate.longitude
        )
        eczaneler.append(eczane)
        // TODO: Veritabanına kaydetme işlemi burada yapılacak
    }
}

// MARK: - Models
struct Eczane {
    let ad: String
    let adres: String
    let telefon: String
    let latitude: Double
    let longitude: Double
} 