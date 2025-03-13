import Foundation
import UIKit

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
    let url: URL?
    
    init(title: String, icon: String, type: SettingsItemType, action: (() -> Void)? = nil, url: URL? = nil) {
        self.title = title
        self.icon = icon
        self.type = type
        self.action = action
        self.url = url
    }
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
        
        // Uygulama başlatıldığında kaydedilmiş tema ayarını uygula
        applyThemeFromUserDefaults()
    }
    
    // Kaydedilmiş tema ayarını yükle
    private func applyThemeFromUserDefaults() {
        let isDarkMode = UserDefaults.standard.bool(forKey: "isDarkMode")
        
        if let window = UIApplication.shared.windows.first {
            window.overrideUserInterfaceStyle = isDarkMode ? .dark : .light
        }
    }
    
    // MARK: - Setup
    private func setupSections() {
        // Uygulama Ayarları
        let appSettings = SettingsSection(
            title: "Uygulama Ayarları",
            items: [
                SettingsItem(title: "Bildirimler", icon: "bell.fill", type: .toggle, action: {
                    // Bildirim ayarlarını açma işlemi
                    if let url = URL(string: UIApplication.openSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                }),
                SettingsItem(title: "Karanlık Mod", icon: "moon.fill", type: .toggle, action: {
                    // Bu action, toggle değiştiğinde çağrılacak
                    // SettingsViewController'daki switchChanged metodu ana işlevi yapacak
                })
            ]
        )
        
        // Destek ve Bilgi
        let supportSettings = SettingsSection(
            title: "Destek ve Bilgi",
            items: [
                SettingsItem(
                    title: "Yardım ve Destek",
                    icon: "questionmark.circle.fill",
                    type: .navigation,
                    action: nil,
                    url: URL(string: "https://docs.google.com/document/d/1PR90g9mA0l8tYqH3-fFWQ1Ou1uuD7kGpEBWNbvgjf0U/edit?usp=sharing")
                ),
                SettingsItem(
                    title: "Gizlilik Politikası",
                    icon: "lock.fill",
                    type: .navigation,
                    action: nil,
                    url: URL(string: "https://docs.google.com/document/d/1WVh48rU1Xi34PkKJCkq09WOd4dQSJyqd5Ir6Ncq2048/edit?tab=t.0")
                ),
                SettingsItem(
                    title: "Uygulama Hakkında",
                    icon: "info.circle.fill",
                    type: .navigation,
                    action: nil,
                    url: URL(string: "https://docs.google.com/document/d/1PR90g9mA0l8tYqH3-fFWQ1Ou1uuD7kGpEBWNbvgjf0U/edit?usp=sharing")
                )
            ]
        )
        
        sections = [appSettings, supportSettings]
    }
}
