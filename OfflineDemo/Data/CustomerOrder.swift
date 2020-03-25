
import SwiftSDK

@objcMembers class CustomerOrder: NSObject, BackendlessObject {
    
    var blLocalId: Int = 1
    var objectId: String?
    var customerName: String?
    var customerPhone: String?
    var totalPriceUsd: Double = 0.0
    var orderedItemsIds = [String]()
    
    override init() {
        super.init()
        let semaphore = DispatchSemaphore(value: 0)
        DispatchQueue.global().async {
            let queryBuilder = DataQueryBuilder()
            queryBuilder.dataRetrievalPolicy = .offlineOnly
            Backendless.shared.data.ofTable("CustomerOrder").findFirst(queryBuilder: queryBuilder, responseHandler: { orderDict in
                if let blLocalId = orderDict["blLocalId"] as? NSNumber {
                    self.blLocalId = blLocalId.intValue
                }
                if let orderedItemsIdsString = orderDict["orderedItemsIdsString"] as? String {
                    self.orderedItemsIds = orderedItemsIdsString.components(separatedBy: ",")
                }
                self.customerName = orderDict["customerName"] as? String
                self.customerPhone = orderDict["customerPhone"] as? String
                semaphore.signal()
            }, errorHandler: { fault in
                semaphore.signal()
            })
        }
        semaphore.wait()
    }
}
