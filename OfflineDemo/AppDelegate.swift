
import UIKit
import SwiftSDK

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    var window: UIWindow?
    
    private let serverUrl = "http://api.backendless.com"
    private let appId = "359F93ED-3D1A-AE58-FF19-5F9806BE7000"
    private let apiKey = "7AABB480-B69E-4B6C-8B24-16561775747F"

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        initBackendless()
        return true
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    @available(iOS 13.0, *)
    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) { }
    
    private func initBackendless() {
        Backendless.shared.hostUrl = serverUrl
        Backendless.shared.initApp(applicationId: appId, apiKey: apiKey)
    }
}
