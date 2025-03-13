//
//  NotificationManager.swift
//  ilaç Vakti
//
//  Created for ilaç Vakti project.
//

import Foundation
import UserNotifications
import OneSignalFramework
import UIKit

/// Bildirim yönetimi için kullanılan servis sınıfı
class NotificationManager {
    // Singleton instance
    static let shared = NotificationManager()
    
    // Kullanılabilecek hatırlatma süreleri (dakika cinsinden)
    enum ReminderTime: Int, CaseIterable {
        case tenMinutes = 10
        case thirtyMinutes = 30
        case oneHour = 60
        
        var description: String {
            switch self {
            case .tenMinutes: return "10 dk önce"
            case .thirtyMinutes: return "30 dk önce"
            case .oneHour: return "1 saat önce"
            }
        }
    }
    
    private init() {}
    
    /// Bildirim izinlerini kontrol eder ve gerekirse ister
    func requestPermissions(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .notDetermined:
                // Bildirim izni henüz istenmemiş
                // OneSignal zaten izin istediği için burada tekrar istemiyoruz
                // Sadece OneSignal'ın izin istemesini bekleyelim
                print("Bildirim izni henüz istenmemiş, OneSignal tarafından istenecek")
                completion(false)
            case .authorized, .provisional:
                // Bildirim izni verilmiş
                completion(true)
            case .denied:
                // Bildirim izni reddedilmiş
                completion(false)
            case .ephemeral:
                // Geçici izin
                completion(true)
            @unknown default:
                completion(false)
            }
        }
    }
    
    /// Kullanıcıdan bildirim izni ister - Artık kullanılmıyor
    /// OneSignal tarafından izin isteniyor
    private func requestAuthorizationFromUser(completion: @escaping (Bool) -> Void) {
        // OneSignal zaten izin istediği için bu metodu kullanmıyoruz
        // Sadece mevcut izin durumunu kontrol ediyoruz
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            DispatchQueue.main.async {
                completion(settings.authorizationStatus == .authorized || 
                          settings.authorizationStatus == .provisional ||
                          settings.authorizationStatus == .ephemeral)
            }
        }
    }
    
    /// İlaç için bildirim planlar
    /// - Parameters:
    ///   - ilacAdi: İlaç adı
    ///   - ilacId: İlaç kimliği
    ///   - ilacSaati: İlacın alınması gereken saat
    ///   - hatirlatmaDakika: Kaç dakika önce hatırlatılacağı
    func scheduleNotification(ilacAdi: String, ilacId: String, ilacSaati: Date, hatirlatmaDakika: Int) {
        // İzinleri kontrol et
        requestPermissions { granted in
            guard granted else {
                print("Bildirim izni verilmedi, bildirim planlanamıyor")
                return
            }
            
            // Yerel bildirim planla
            self.scheduleLocalNotification(ilacAdi: ilacAdi, ilacId: ilacId, ilacSaati: ilacSaati, hatirlatmaDakika: hatirlatmaDakika)
            
            // OneSignal bildirimi planla
            self.scheduleOneSignalNotification(ilacAdi: ilacAdi, ilacId: ilacId, ilacSaati: ilacSaati, hatirlatmaDakika: hatirlatmaDakika)
        }
    }
    
    /// Yerel bildirim planlar
    private func scheduleLocalNotification(ilacAdi: String, ilacId: String, ilacSaati: Date, hatirlatmaDakika: Int) {
        let content = UNMutableNotificationContent()
        content.title = "İlaç Hatırlatması"
        content.body = "\(ilacAdi) alma vakti yaklaşıyor!"
        content.sound = UNNotificationSound.default
        content.userInfo = ["ilacId": ilacId]
        
        let calendar = Calendar.current
        
        // İlaç saatinden hatırlatma dakikasını çıkararak, bildirimin ne zaman gönderileceğini hesapla
        guard let notificationTime = calendar.date(byAdding: .minute, value: -hatirlatmaDakika, to: ilacSaati) else {
            print("Bildirim zamanı hesaplanamadı")
            return
        }
        
        // Bildirimin sadece saat ve dakikası alınıp, bugünün tarihine eklenerek tetikleyici oluşturulur
        var components = calendar.dateComponents([.hour, .minute], from: notificationTime)
        components.second = 0
        
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: true)
        
        // Benzersiz bir kimlik oluştur
        let identifier = "ilac_\(ilacId)_\(ilacAdi)_\(hatirlatmaDakika)"
        
        // Bildirimi ekle
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        
        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Bildirim eklenirken hata oluştu: \(error.localizedDescription)")
            } else {
                print("Bildirim başarıyla eklendi: \(identifier)")
            }
        }
    }
    
    /// OneSignal bildirimi planlar
    private func scheduleOneSignalNotification(ilacAdi: String, ilacId: String, ilacSaati: Date, hatirlatmaDakika: Int) {
        let calendar = Calendar.current
        
        guard let notificationTime = calendar.date(byAdding: .minute, value: -hatirlatmaDakika, to: ilacSaati) else {
            print("OneSignal bildirim zamanı hesaplanamadı")
            return
        }
        
        // Bildirim metnini oluştur
        let message = "\(ilacAdi) alma vakti yaklaşıyor!"
        
        // Benzersiz bir bildirim ID'si oluştur
        let currentTimestamp = Int(Date().timeIntervalSince1970)
        let notificationId = "ilac_reminder_\(ilacId)_\(currentTimestamp)"
        
        // Bildirimin gönderileceği zamanı Unix timestamp formatına çevir
        let deliveryTimestamp = Int(notificationTime.timeIntervalSince1970)
        
        // OneSignal'a bildirim gönderme isteği yap
        let notificationData: [String: Any] = [
            "contents": ["en": message],
            "headings": ["en": "İlaç Hatırlatması"],
            "data": ["ilacId": ilacId],
            "send_after": deliveryTimestamp,
            "app_id": "b2236778-2f10-4bbe-9afd-2a42959138bd" // AppDelegate'de tanımlanan OneSignal App ID'si
        ]
        
        // Kullanıcıya özel bildirim gönderme
        if let userId = OneSignal.User.pushSubscription.id {
            OneSignal.User.addTag(key: "ilacId", value: ilacId)
            
            let notificationRequest: [String: Any] = [
                "include_player_ids": [userId],
                "contents": ["en": message],
                "headings": ["en": "İlaç Hatırlatması"],
                "data": ["ilacId": ilacId],
                "send_after": ISO8601DateFormatter().string(from: notificationTime)
            ]
            
            // OneSignal REST API kullanarak bildirim gönderme 
            // Not: Bu işlevi sunucu tarafında yapmak daha güvenlidir
            // Burada sadece demo amaçlı gösteriyoruz
            print("OneSignal bildirim planlandı: ID \(notificationId) - Zaman: \(notificationTime)")
            print("Kullanıcı belirteci ile OneSignal bildirimleri için sunucu tarafında implementasyon önerilir")
        } else {
            print("OneSignal kullanıcı ID'si bulunamadı")
        }
    }
    
    /// Belirli bir ilaç için tüm bildirimleri iptal eder
    func cancelNotificationsForIlac(ilacId: String) {
        // Yerel bildirimleri iptal et
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let identifiers = requests.filter { $0.identifier.contains(ilacId) }.map { $0.identifier }
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: identifiers)
            print("\(identifiers.count) adet bildirim iptal edildi")
        }
        
        // OneSignal bildirimleri için iptal mekanizması buraya eklenebilir
        // Not: OneSignal zamanlanmış bildirimleri iptal etmek için özel bir API sağlamıyor
        // Bu nedenle, zamanlanmış bildirimleri takip etmek ve iptal etmek için kendi veritabanımızı oluşturmamız gerekebilir
    }
    
    /// Tüm bildirimleri iptal eder
    func cancelAllNotifications() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        print("Tüm bildirimler iptal edildi")
    }
    
    /// Bekleyen tüm bildirimleri listeler (debug için)
    func listAllPendingNotifications() {
        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            print("Bekleyen Bildirimler (\(requests.count)):")
            for request in requests {
                print("- ID: \(request.identifier)")
                print("  Başlık: \(request.content.title)")
                print("  Mesaj: \(request.content.body)")
                if let trigger = request.trigger as? UNCalendarNotificationTrigger {
                    print("  Tetikleyici: \(trigger.dateComponents)")
                    print("  Tekrarlı: \(trigger.repeats)")
                }
                print("-----")
            }
        }
    }
} 
