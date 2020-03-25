
import UIKit
import SwiftSDK

class OrderViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var completeButton: UIButton!
    @IBOutlet weak var removeOrderButton: UIBarButtonItem!
    
    var order: CustomerOrder!
    
    private var orderedItems = [MenuItem]()
    private var totalPrice: Double = 0.0
    
    private let refreshControl = UIRefreshControl()
    
    // MARK: override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if #available(iOS 10.0, *) {
            tableView.refreshControl = refreshControl
        } else {
            tableView.addSubview(refreshControl)
        }
        refreshControl.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        
        checkInterfaceAppearance()
        getOrderedItems()
        if orderedItems.count == 0 {
            showBackToMenuAlert()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        checkInterfaceAppearance()
    }
    
    // MARK: tableView functions
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return orderedItems.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuItem = orderedItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "OrderCell", for: indexPath) as! OrderCell
        cell.nameLabel.text = "\(menuItem.name ?? "...")"
        cell.priceLabel.text = "\(menuItem.priceUsd)$"
        if let imageUrl = menuItem.imageUrl {
            let url = URL(string: imageUrl)
            cell.menuItemImageView.kf.setImage(with: url, placeholder: nil)
        }
        else {
            Utils.shared.setDefaultImage(viewController: self, cell: cell)
        }
        return cell
    }
    
    // MARK: private functions
    
    @objc private func refresh(_ sender: AnyObject) {
        orderedItems.removeAll()
        self.getOrderedItems()
        tableView.reloadData()
        refreshControl.endRefreshing()
    }
    
    private func checkInterfaceAppearance() {
        if #available(iOS 12, *) {
            if Utils.shared.interfaceIsLight(self) {
                self.removeOrderButton.tintColor = .darkText
                self.navigationItem.backBarButtonItem?.tintColor = .darkText
            }
            else {
                self.removeOrderButton.tintColor = .white
                self.navigationItem.backBarButtonItem?.tintColor = .white
            }
            tableView.reloadData()
        } else {
            self.removeOrderButton.tintColor = .white
            self.navigationItem.backBarButtonItem?.tintColor = .white
        }
    }
    
    private func getOrderedItems() {
        let orderedItemsIds = order.orderedItemsIds
        let menuItems = MenuItemsManager.shared.getMenuItems()
        for objectId in orderedItemsIds {
            if let menuItem = menuItems.first(where: { $0.objectId == objectId }) {
                orderedItems.append(menuItem)
            }
        }
        calculateTotalPrice()
        tableView.reloadData()
    }
    
    private func calculateTotalPrice() {
        totalPrice = 0
        for menuItem in orderedItems {
            let menuItemPrice = menuItem.priceUsd
            totalPrice += menuItemPrice
        }
        completeButton.setTitle("Complete Order (\(totalPrice)$)", for: .normal)
    }
    
    private func showBackToMenuAlert() {
        let alert = UIAlertController(title: "Add items", message: "Please add some items from the menu to continue", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Back to Menu", style: .default, handler: { action in
            self.performSegue(withIdentifier: "UnwindToMenu", sender: nil)
        }))
        present(alert, animated: true, completion: nil)
    }
    
    private func showFieldsMisisngAlert() {
        let alert = UIAlertController(title: "", message: "Please enter your name and phone number", preferredStyle: .alert)
        present(alert, animated: true, completion: nil)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 1) {
            alert.dismiss(animated: true, completion: nil)
        }
    }
    
    private func showOrderCompleteAlert(_ orderId: String) {
        let alert = UIAlertController(title: "Order id: \(orderId)", message: "Your order is completed.\nOur manager will contact you in a few minutes", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: { _ in
            self.order.orderedItemsIds.removeAll()
            self.orderedItems.removeAll()
            self.performSegue(withIdentifier: "UnwindToMenu", sender: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    // MARK: @IBAction functions
    
    @IBAction func removeOrderedItem(_ sender: Any) {
        if let cell = (sender as? UIButton)?.superview?.superview as? OrderCell,
            let indexPath = tableView.indexPath(for: cell) {
            let menuItem = orderedItems[indexPath.row]
            if let objectId = menuItem.objectId {
                order.orderedItemsIds.removeAll(where: { $0 == objectId })
            }
            orderedItems.remove(at: indexPath.row)
            calculateTotalPrice()
            tableView.reloadData()
            if orderedItems.count == 0 {
                showBackToMenuAlert()
            }
        }
    }
    
    @IBAction func removeOrder(_ sender: Any) {
        let alert = UIAlertController(title: "Delete order", message: "This order will be deleted", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { action in
            Backendless.shared.data.ofTable("CustomerOrder").clearLocalDatabase()
            self.order.orderedItemsIds.removeAll()
            self.orderedItems.removeAll()
            self.showBackToMenuAlert()
        }))
        present(alert, animated: true, completion: nil)
    }
    
    @IBAction func completeOrder(_ sender: Any) {
        let alert = UIAlertController(title: "Compete Your Order: \(totalPrice)$", message: "Your order is almost complete.\nPlease, enter your personal information, so we can contact you", preferredStyle: .alert)
        
        alert.addTextField(configurationHandler: { nameField in
            nameField.keyboardType = .default
            nameField.autocapitalizationType = .words
            nameField.placeholder = "Your Name"
            if let customerName = self.order.customerName, !customerName.isEmpty {
                nameField.text = customerName
            }
        })
        alert.addTextField(configurationHandler: { phoneField in
            phoneField.keyboardType = .phonePad
            phoneField.placeholder = "Your Phone Number"
            if let customerPhone = self.order.customerPhone, !customerPhone.isEmpty {
                phoneField.text = customerPhone
            }
        })
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        alert.addAction(UIAlertAction(title: "Confirm", style: .default, handler: { action in
            if let customerName = alert.textFields?[0].text, !customerName.isEmpty,
                let customerPhone = alert.textFields?[1].text, !customerPhone.isEmpty {
                self.order.customerName = customerName
                self.order.customerPhone = customerPhone
                self.order.totalPriceUsd = self.totalPrice
                
                if Reachability.isConnectedToNetwork() {
                    let orderStore = Backendless.shared.data.of(CustomerOrder.self)
                    orderStore.save(entity: self.order!, responseHandler: { savedOrder in
                        if let savedOrder = savedOrder as? CustomerOrder,
                            let savedOrderObjectId = savedOrder.objectId {
                            orderStore.setRelation(columnName: "menuItems", parentObjectId: savedOrderObjectId, childrenObjectIds: self.order.orderedItemsIds, responseHandler: { relationSet in
                                orderStore.clearLocalDatabase()
                                self.showOrderCompleteAlert(savedOrderObjectId)
                            }, errorHandler: { fault in
                                Utils.shared.showErrorAlert(fault, viewController: self)
                            })
                        }
                    }, errorHandler: { fault in
                        Utils.shared.showErrorAlert(fault, viewController: self)
                    })
                }
                else {
                    let alert = UIAlertController(title: "No Internet connection", message: "Please, try to complete your order later", preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { action in
                        let orderDict = Utils.shared.orderToDictionary(self.order)
                        Backendless.shared.data.ofTable("CustomerOrder").saveEventually(entity: orderDict)
                    }))
                    self.present(alert, animated: true, completion: nil)             
                }
            }
            else {
                self.showBackToMenuAlert()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
}
