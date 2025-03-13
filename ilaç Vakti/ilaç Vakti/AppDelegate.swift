//
//  AppDelegate.swift
//  ilaç Vakti
//
//  Created by Mehmet Tuna Arıkaya on 5.03.2025.
//

import UIKit
import CoreData
import OneSignalFramework
import UserNotifications

@main
class AppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        
        
        // Eagerly initialize the Core Data stack
        _ = persistentContainer.viewContext
        
        // Yerel bildirimler için delegate ayarla
        UNUserNotificationCenter.current().delegate = self
        
        // UNUserNotificationCenter için izinleri ayarla - KALDIRILIYOR
        // Artık sadece OneSignal üzerinden izin isteyeceğiz
        // let authOptions: UNAuthorizationOptions = [.alert, .badge, .sound]
        // UNUserNotificationCenter.current().requestAuthorization(
        //     options: authOptions,
        //     completionHandler: { granted, error in
        //         print("UNUserNotificationCenter izinleri: \(granted)")
        //         if let error = error {
        //             print("Bildirim izni alırken hata: \(error)")
        //         }
        //     }
        // )
        
        // Remove this method to stop OneSignal Debugging
        OneSignal.Debug.setLogLevel(.LL_VERBOSE)
          
        // OneSignal initialization
        OneSignal.initialize(Configuration.shared.oneSignalAppID, withLaunchOptions: launchOptions)
          
        // requestPermission will show the native iOS notification permission prompt.
        // We recommend removing the following code and instead using an In-App Message to prompt for notification permission
        OneSignal.Notifications.requestPermission({ accepted in
            print("User accepted notifications: \(accepted)")
        }, fallbackToSettings: true)
        
        return true
    }
    
    // MARK: - UNUserNotificationCenterDelegate
    
    // Uygulama ön plandayken bildirimlerin gösterilmesini sağlar
    func userNotificationCenter(_ center: UNUserNotificationCenter, 
                               willPresent notification: UNNotification,
                               withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Ön plandayken bildirim gösterilmesi için izin veriyoruz
        completionHandler([.banner, .sound, .badge])
    }
    
    // Bildirime tıklandığında çalışacak fonksiyon
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                               didReceive response: UNNotificationResponse,
                               withCompletionHandler completionHandler: @escaping () -> Void) {
        // Bildirim verilerini al
        let userInfo = response.notification.request.content.userInfo
        print("Bildirim tıklandı: \(userInfo)")
        
        // Bildirimin içeriğine göre uygulama içinde yönlendirme yapılabilir
        
        completionHandler()
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }

    // MARK: - Core Data stack

    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
        */
        let container = NSPersistentContainer(name: "IlacVakti")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                 
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }

}

