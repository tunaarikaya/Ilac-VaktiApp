import Foundation

// MARK: - Data Models
struct SettingsSection {
    let title: String
    let items: [SettingsItem]
}

struct SettingsItem {
    let title: String
    let icon: String
    let type: SettingsItemType
    let action: (() -> Void)?
}

enum SettingsItemType {
    case toggle
    case navigation
    case destructive
    case info
}

class SettingsViewModel {
    
    // MARK: - Properties
    var sections: [SettingsSection] = []
    
    // MARK: - Initialization
    init() {
        setupSections()
    }
    
    // MARK: - Setup
    private func setupSections() {
        let appSettings = SettingsSection(
            title: "Uygulama Ayarları",
            items: [
                SettingsItem(title: "Bildirimler", icon: "bell.fill", type: .toggle, action: nil),
                SettingsItem(title: "Karanlık Mod", icon: "moon.fill", type: .toggle, action: { [weak self] in
                    if let window = UIApplication.shared.windows.first {
                        let newStyle: UIUserInterfaceStyle = window.overrideUserInterfaceStyle == .dark ? .light : .dark
                        window.overrideUserInterfaceStyle = newStyle
                        UserDefaults.standard.set(newStyle == .dark, forKey: "isDarkMode")
                    }
                }),
                SettingsItem(title: "İlaç Hatırlatıcı Sesi", icon: "speaker.wave.2.fill", type: .navigation, action: nil)
            ]
        )
        
        // Hesap Ayarları
        let accountSettings = SettingsSection(
            title: "Hesap Ayarları",
            items: [
                SettingsItem(title: "Profil Bilgileri", icon: "person.fill", type: .navigation, action: nil),
                SettingsItem(title: "İlaç Geçmişi", icon: "clock.fill", type: .navigation, action: nil),
                SettingsItem(title: "Veri Yedekleme", icon: "icloud.fill", type: .navigation, action: nil)
            ]
        )
        
        // Destek ve Bilgi
        let supportSettings = SettingsSection(
            title: "Destek ve Bilgi",
            items: [
                SettingsItem(title: "Yardım ve Destek", icon: "questionmark.circle.fill", type: .navigation, action: nil),
                SettingsItem(title: "Gizlilik Politikası", icon: "lock.fill", type: .navigation, action: nil),
                SettingsItem(title: "Uygulama Hakkında", icon: "info.circle.fill", type: .info, action: nil),
                SettingsItem(title: "Sürüm", icon: "checkmark.seal.fill", type: .info, action: nil)
            ]
        )
        
        // Hesap İşlemleri
        let accountActions = SettingsSection(
            title: "Hesap İşlemleri",
            items: [
                SettingsItem(title: "Tüm Verileri Temizle", icon: "trash.fill", type: .destructive, action: nil),
                SettingsItem(title: "Çıkış Yap", icon: "rectangle.portrait.and.arrow.right.fill", type: .destructive, action: nil)
            ]
        )
        
        sections = [appSettings, accountSettings, supportSettings, accountActions]
    }
}