import Foundation
import CoreData

protocol HomeViewModelDelegate: AnyObject {
    func didUpdateIlaclar()
    func didFailWithError(error: Error)
}

class HomeViewModel {
    
    // MARK: - Properties
    private(set) var ilaclar: [Ilac] = []
    private(set) var filteredIlaclar: [Ilac] = []
    private(set) var selectedDate: Date = Date()
    weak var delegate: HomeViewModelDelegate?
    
    private let coreDataManager = CoreDataManager.shared
    
    // MARK: - Public Methods
    func fetchIlaclar() {
        do {
            ilaclar = coreDataManager.fetchIlaclar()
            filterIlaclarForSelectedDate()
            delegate?.didUpdateIlaclar()
        } catch {
            delegate?.didFailWithError(error: error)
        }
    }
    
    func deleteIlac(ilac: Ilac) {
        do {
            coreDataManager.deleteIlac(ilac: ilac)
            fetchIlaclar()
        } catch {
            delegate?.didFailWithError(error: error)
        }
    }
    
    func getIlacAt(index: Int) -> Ilac? {
        guard index >= 0 && index < filteredIlaclar.count else { return nil }
        return filteredIlaclar[index]
    }
    
    func getIlaclarCount() -> Int {
        return filteredIlaclar.count
    }
    
    // MARK: - Date Management
    func setSelectedDate(_ date: Date) {
        selectedDate = Calendar.current.startOfDay(for: date)
        filterIlaclarForSelectedDate()
        delegate?.didUpdateIlaclar()
    }
    
    func moveToNextDay() {
        if let nextDay = Calendar.current.date(byAdding: .day, value: 1, to: selectedDate) {
            setSelectedDate(nextDay)
        }
    }
    
    func moveToPreviousDay() {
        if let previousDay = Calendar.current.date(byAdding: .day, value: -1, to: selectedDate) {
            setSelectedDate(previousDay)
        }
    }
    
    func moveToToday() {
        setSelectedDate(Date())
    }
    
    // MARK: - Ilaç Kullanım Management
    
    func createIlacKullanim(for ilac: Ilac) -> IlacKullanim? {
        // Bugünün tarihini kullan
        let tarih = selectedDate
        
        // Varsayılan olarak ilaç kullanılmadı olarak işaretle
        let alindiMi = false
        
        // CoreDataManager'ı kullanarak yeni bir IlacKullanim oluştur
        let yeniKullanim = coreDataManager.createIlacKullanim(ilac: ilac, tarih: tarih, alindiMi: alindiMi)
        
        return yeniKullanim
    }
    
    func getIlacKullanimDurumu(ilac: Ilac) -> Bool? {
        // Kullanım durumunu getir
        let kullanim = getIlacKullanim(for: ilac)
        return kullanim?.alindiMi
    }
    
    func getIlacKullanim(for ilac: Ilac) -> IlacKullanim? {
        let fetchRequest: NSFetchRequest<IlacKullanim> = IlacKullanim.fetchRequest()
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        
        fetchRequest.predicate = NSPredicate(format: "ilac == %@ AND tarih >= %@ AND tarih < %@", 
                                           ilac,
                                           startOfDay as NSDate,
                                           endOfDay as NSDate)
        
        do {
            let kullanimlar = try coreDataManager.context.fetch(fetchRequest)
            return kullanimlar.first
        } catch {
            print("Hata: İlaç kullanımı getirilemedi - \(error.localizedDescription)")
            return nil
        }
    }
    

    // MARK: - Private Methods
    private func filterIlaclarForSelectedDate() {
        let calendar = Calendar.current
        let startOfSelectedDay = calendar.startOfDay(for: selectedDate)
        
        filteredIlaclar = ilaclar.filter { ilac in
            guard let baslangicTarihi = ilac.baslangicTarihi else { return false }
            let startOfBaslangic = calendar.startOfDay(for: baslangicTarihi)
            
            // Bitiş tarihi kontrolü
            if let bitisTarihi = ilac.bitisTarihi {
                let startOfBitis = calendar.startOfDay(for: bitisTarihi)
                return startOfBaslangic <= startOfSelectedDay && startOfSelectedDay <= startOfBitis
            }
            
            // Bitiş tarihi yoksa, başlangıç tarihinden sonra ise göster
            return startOfBaslangic <= startOfSelectedDay
        }
    }
} 
