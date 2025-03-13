import Foundation
import CoreData

class CalendarViewModel {
    
    // MARK: - Properties
    private(set) var events: [CalendarEventItem] = []
    private let coreDataManager = CoreDataManager.shared
    
    // Define a new struct to avoid conflicts with the model
    struct CalendarEventItem {
        let id: String
        let title: String
        let time: String
        let date: Date
        let ilacId: String
        let hatirlaticiId: String
    }
    
    // MARK: - Public Methods
    func fetchEvents() {
        let ilaclar = coreDataManager.fetchIlaclar()
        var newEvents: [CalendarEventItem] = []
        
        for ilac in ilaclar {
            guard let hatirlaticilarSet = ilac.value(forKey: "hatirlaticilar") as? NSSet else { continue }
            let hatirlaticilar = hatirlaticilarSet.allObjects as? [NSManagedObject] ?? []
            
            for hatirlatici in hatirlaticilar {
                guard let saat = hatirlatici.value(forKey: "saat") as? Date,
                      let hatirlaticiId = hatirlatici.value(forKey: "id") as? UUID,
                      let ilacId = ilac.value(forKey: "id") as? UUID,
                      let ilacAd = ilac.value(forKey: "ad") as? String else {
                    continue
                }
                
                let formatter = DateFormatter()
                formatter.dateFormat = "HH:mm"
                let timeString = formatter.string(from: saat)
                
                let event = CalendarEventItem(
                    id: hatirlaticiId.uuidString,
                    title: ilacAd,
                    time: timeString,
                    date: saat,
                    ilacId: ilacId.uuidString,
                    hatirlaticiId: hatirlaticiId.uuidString
                )
                
                newEvents.append(event)
            }
        }
        
        events = newEvents.sorted { $0.date < $1.date }
    }
    
    func getEventsForDate(_ date: Date) -> [CalendarEventItem] {
        let calendar = Calendar.current
        return events.filter { event in
            calendar.isDate(event.date, inSameDayAs: date)
        }
    }
} 