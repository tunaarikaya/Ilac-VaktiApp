import CoreData
import Foundation
import UIKit

class CoreDataManager {
    static let shared = CoreDataManager()
    
    private init() {
        // Use the AppDelegate's persistent container instead of creating our own
    }
    
    // Get the persistent container from AppDelegate
    private var persistentContainer: NSPersistentContainer {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            fatalError("Could not access AppDelegate")
        }
        return appDelegate.persistentContainer
    }
    
    // Get the managed object context from the persistent container
    var context: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    // Save the context through AppDelegate
    func saveContext() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else {
            print("Could not access AppDelegate")
            return
        }
        appDelegate.saveContext()
    }
    
    // MARK: - İlaç İşlemleri
    func createIlac(ad: String, doz: Double, dozBirimi: String, baslangicTarihi: Date, bitisTarihi: Date?, aciklama: String?, resimURL: String?) -> Ilac {
        let ilac = Ilac(context: context)
        ilac.id = UUID()
        ilac.ad = ad
        ilac.doz = doz
        ilac.dozBirimi = dozBirimi
        ilac.baslangicTarihi = baslangicTarihi
        ilac.bitisTarihi = bitisTarihi
        ilac.aciklama = aciklama
        ilac.resimURL = resimURL
        
        do {
            try context.save()
        } catch {
            print("İlaç oluşturma hatası: \(error)")
            context.rollback()
        }
        
        return ilac
    }
    
    func fetchIlaclar() -> [Ilac] {
        let fetchRequest: NSFetchRequest<Ilac> = Ilac.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("İlaçları getirme hatası: \(error)")
            return []
        }
    }
    
    func fetchIlac(byId id: UUID) -> Ilac? {
        let fetchRequest: NSFetchRequest<Ilac> = Ilac.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", id as CVarArg)
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("İlaç getirme hatası: \(error)")
            return nil
        }
    }
    
    func deleteIlac(ilac: Ilac) {
        context.delete(ilac)
        saveContext()
    }
    
    // MARK: - Hatırlatıcı İşlemleri
    func createHatirlatici(ilac: Ilac, saat: Date) -> Hatirlatici {
        let hatirlatici = Hatirlatici(context: context)
        hatirlatici.id = UUID()
        hatirlatici.saat = saat
        hatirlatici.aktif = true
        hatirlatici.ilac = ilac
        
        do {
            try context.save()
        } catch {
            print("Hatırlatıcı oluşturma hatası: \(error)")
            context.rollback()
        }
        
        return hatirlatici
    }
    
    func fetchHatirlaticilar() -> [Hatirlatici] {
        let fetchRequest: NSFetchRequest<Hatirlatici> = Hatirlatici.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Hatırlatıcıları getirme hatası: \(error)")
            return []
        }
    }
    
    // MARK: - İlaç Kullanım İşlemleri
    func createIlacKullanim(ilac: Ilac, tarih: Date, alindiMi: Bool) -> IlacKullanim {
        let kullanim = IlacKullanim(context: context)
        kullanim.id = UUID()
        kullanim.ilac = ilac
        kullanim.tarih = tarih
        kullanim.alindiMi = alindiMi
        kullanim.alinanDoz = ilac.doz
        
        do {
            try context.save()
        } catch {
            print("İlaç kullanım oluşturma hatası: \(error)")
            context.rollback()
        }
        
        return kullanim
    }
    
    func fetchIlacKullanimlar() -> [IlacKullanim] {
        let fetchRequest: NSFetchRequest<IlacKullanim> = IlacKullanim.fetchRequest()
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("İlaç kullanımlarını getirme hatası: \(error)")
            return []
        }
    }
    
    // MARK: - Core Data Saving
    // Note: The saveContext method is now implemented at the top of this class
    // and uses the AppDelegate's implementation
    
    // MARK: - Kullanıcı İşlemleri
    func fetchKullanici() -> NSManagedObject? {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Kullanici")
        fetchRequest.fetchLimit = 1
        
        do {
            let results = try context.fetch(fetchRequest)
            return results.first
        } catch {
            print("Kullanıcı getirme hatası: \(error)")
            return nil
        }
    }
    
    func createKullanici(ad: String, soyad: String, email: String) -> NSManagedObject {
        let kullanici = NSEntityDescription.insertNewObject(forEntityName: "Kullanici", into: context)
        kullanici.setValue(UUID(), forKey: "id")
        kullanici.setValue(ad, forKey: "ad")
        kullanici.setValue(soyad, forKey: "soyad")
        kullanici.setValue(email, forKey: "email")
        
        saveContext()
        return kullanici
    }
    
    func updateKullanici(kullanici: NSManagedObject) {
        saveContext()
    }
    
    // MARK: - Eczane İşlemleri
    func fetchEczaneler() -> [NSManagedObject] {
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Eczane")
        
        do {
            return try context.fetch(fetchRequest)
        } catch {
            print("Eczaneleri getirme hatası: \(error)")
            return []
        }
    }
    
    func createEczane(ad: String, adres: String, telefon: String, latitude: Double, longitude: Double) -> NSManagedObject {
        let eczane = NSEntityDescription.insertNewObject(forEntityName: "Eczane", into: context)
        eczane.setValue(UUID(), forKey: "id")
        eczane.setValue(ad, forKey: "ad")
        eczane.setValue(adres, forKey: "adres")
        eczane.setValue(telefon, forKey: "telefon")
        eczane.setValue(latitude, forKey: "latitude")
        eczane.setValue(longitude, forKey: "longitude")
        
        saveContext()
        return eczane
    }
    
    func deleteEczane(eczane: NSManagedObject) {
        context.delete(eczane)
        saveContext()
    }
} 