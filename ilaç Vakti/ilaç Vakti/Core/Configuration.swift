import Foundation

class Configuration {
    static let shared = Configuration()
    
    private init() {}
    
    // OneSignal App ID
    let oneSignalAppID: String = {
        #if DEBUG
        return "b2236778-2f10-4bbe-9afd-2a42959138bd" // Development
        #else
        return "PRODUCTION_APP_ID" // Production - App Store'a yüklemeden önce değiştirin
        #endif
    }()
} 