
import UIKit
import SwiftSDK

class Utils {
    
    static let shared = Utils()
    
    private init() { }
    
    @available(iOS 12, *)
    func interfaceIsLight(_ viewController: UIViewController) -> Bool {
        if viewController.traitCollection.userInterfaceStyle == .light {
            return true
        }
        return false
    }
    
    func setDefaultImage(viewController: UIViewController, cell: UITableViewCell) {
        if let menuItemCell = cell as? MenuItemCell {
            if #available(iOS 12, *) {
                if interfaceIsLight(viewController) {
                    menuItemCell.menuItemImageView.image = UIImage(named: "noImageLight")
                }
                else {
                    menuItemCell.menuItemImageView.image = UIImage(named: "noImageDark")
                }
            }
            else {
                menuItemCell.menuItemImageView.image = UIImage(named: "noImageLight")
            }
        }
        else if let orderCell = cell as? OrderCell {
            if #available(iOS 12, *) {
                if interfaceIsLight(viewController) {
                    orderCell.menuItemImageView.image = UIImage(named: "noImageLight")
                }
                else {
                    orderCell.menuItemImageView.image = UIImage(named: "noImageDark")
                }
            }
            else {
                orderCell.menuItemImageView.image = UIImage(named: "noImageLight")
            }
        }
    }
    
    func orderToDictionary(_ order: CustomerOrder) -> [String : Any] {
        var dictionary = [String : Any]()
        dictionary["blLocalId"] = order.blLocalId
        dictionary["customerName"] = order.customerName
        dictionary["customerPhone"] = order.customerPhone
        
        var orderedItemsIdsString = ""
        for orderedItemId in order.orderedItemsIds {
            orderedItemsIdsString += "\(orderedItemId),"
        }
        orderedItemsIdsString.removeLast()
        
        dictionary["orderedItemsIdsString"] = orderedItemsIdsString
        return dictionary
    }
    
    func dictionaryToOrder(_ dictionary: [String : Any]) -> CustomerOrder {
        let order = CustomerOrder()
        if let blLocalId = dictionary["blLocalId"] as? Int {
            order.blLocalId = blLocalId
        }
        if let orderedItemsIdsString = dictionary["orderedItemsIdsString"] as? String {
            order.orderedItemsIds = orderedItemsIdsString.components(separatedBy: ",")
        }
        order.customerName = dictionary["customerName"] as? String
        order.customerPhone = dictionary["customerPhone"] as? String
        return order
    }
    
    func showErrorAlert(_ fault: Fault, viewController: UIViewController) {
        let alert = UIAlertController(title: "Error occured", message: "\(fault.message ?? "")", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        viewController.present(alert, animated: true, completion: nil)
    }
}
