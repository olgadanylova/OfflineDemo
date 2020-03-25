
import Foundation
import SwiftSDK

class MenuItemsManager {
    
    static let shared = MenuItemsManager()
    
    private init() { }
    
    var menuItems = [MenuItem]()
    
    func getMenuItems() -> [MenuItem] {
        let queryBuilder = DataQueryBuilder()
        queryBuilder.setPageSize(pageSize: 100)
        queryBuilder.setSortBy(sortBy: ["category", "name"])
        queryBuilder.localStoragePolicy = .storeAll
        queryBuilder.dataRetrievalPolicy = .dynamic
        
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
                Backendless.shared.data.of(MenuItem.self).find(queryBuilder: queryBuilder, responseHandler: { foundMenuItems in
                guard let foundMenuItems = foundMenuItems as? [MenuItem] else { return }
                self.menuItems = foundMenuItems
                semaphore.signal()
            }, errorHandler: { fault in
                semaphore.signal()
            })
        }
        semaphore.wait()
        return menuItems        
    }
}
