import UIKit

class TabBarController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupViewControllers()
        setupTabBarAppearance()
    }
    
    private func setupViewControllers() {
        // Ana Sayfa (İlaç Takibi)
        let homeVC = UINavigationController(rootViewController: HomeViewController())
        homeVC.tabBarItem = UITabBarItem(title: "Ana Sayfa", image: UIImage(systemName: "pill"), tag: 0)
        
        // Takvim
        let calendarVC = UINavigationController(rootViewController: CalendarViewController())
        calendarVC.tabBarItem = UITabBarItem(title: "Takvim", image: UIImage(systemName: "calendar"), tag: 1)
        
        // Harita
        let mapVC = UINavigationController(rootViewController: MapViewController())
        mapVC.tabBarItem = UITabBarItem(title: "Eczaneler", image: UIImage(systemName: "map"), tag: 2)
        
        // Profil
        let profileVC = UINavigationController(rootViewController: SettingsViewController())
        profileVC.tabBarItem = UITabBarItem(title: "Profil", image: UIImage(systemName: "person"), tag: 3)
        
        viewControllers = [homeVC, calendarVC, mapVC, profileVC]
    }
    
    private func setupTabBarAppearance() {
        // TabBar görünümünü özelleştirme
        if #available(iOS 15.0, *) {
            let appearance = UITabBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundColor = .systemBackground
            
            tabBar.standardAppearance = appearance
            tabBar.scrollEdgeAppearance = appearance
        }
        
        tabBar.tintColor = .systemBlue
    }
} 
