
import UIKit
import SwiftSDK
import Kingfisher

class MenuTableViewController: UITableViewController {

    @IBOutlet weak var shoppingCartButton: UIBarButtonItem!
    
    private var menuItems = [MenuItem]()
    private let order = CustomerOrder()
    
    // MARK: override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.refreshControl?.addTarget(self, action: #selector(refresh), for: UIControl.Event.valueChanged)
        checkInterfaceAppearance()
        menuItems = MenuItemsManager.shared.getMenuItems()
        if menuItems.isEmpty {
            showNoItemsAlert()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.setHidesBackButton(true, animated: false)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationItem.setHidesBackButton(false, animated: false)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        checkInterfaceAppearance()
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return menuItems.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let menuItem = menuItems[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MenuItemCell", for: indexPath) as! MenuItemCell
        cell.nameLabel.text = "\(menuItem.name ?? "...")"
        cell.priceLabel.text = "\(menuItem.priceUsd)$"
        cell.categoryLabel.text = menuItem.category
        cell.descLabel.text = menuItem.desc
        if let imageUrl = menuItem.imageUrl {
            let url = URL(string: imageUrl)
            cell.menuItemImageView.kf.setImage(with: url, placeholder: nil)
        }
        else {
            Utils.shared.setDefaultImage(viewController: self, cell: cell)
        }
        return cell
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowOrderDetails",
            let orderVC = segue.destination as? OrderViewController {
            orderVC.order = order
        }
    }
    
    // MARK: private functions
    
    @objc private func refresh(_ sender: AnyObject) {
        menuItems = MenuItemsManager.shared.getMenuItems()
        if menuItems.isEmpty {
            showNoItemsAlert()
        }
        else {
            tableView.reloadData()
            refreshControl?.endRefreshing()
        }
    }
    
    private func checkInterfaceAppearance() {
        if #available(iOS 12, *) {
            if Utils.shared.interfaceIsLight(self) {
                self.shoppingCartButton.tintColor = .darkText
                self.navigationItem.backBarButtonItem?.tintColor = .darkText
            }
            else {
                self.shoppingCartButton.tintColor = .white
                self.navigationItem.backBarButtonItem?.tintColor = .white
            }
            tableView.reloadData()
        } else {
            self.shoppingCartButton.tintColor = .white
            self.navigationItem.backBarButtonItem?.tintColor = .white
        }
    }
    
    private func showNoItemsAlert() {
        let alert = UIAlertController(title: "", message: "No data found.\nPlease try again later", preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 2) {
            alert.dismiss(animated: true, completion: {
                self.refreshControl?.endRefreshing()
            })
        }
    }

    private func showItemAddedAlert(_ menuItem: MenuItem) {
        let alert = UIAlertController(title: "", message: "\(menuItem.name ?? "item") added to your order", preferredStyle: .alert)
        present(alert, animated: true)
        DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + 0.75) {
          alert.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: @IBAction functions
    
    @IBAction func addToCart(_ sender: Any) {
        if let cell = (sender as? UIButton)?.superview?.superview as? MenuItemCell,
            let indexPath = tableView.indexPath(for: cell) {
            let menuItem = menuItems[indexPath.row]            
            if let objectId = menuItem.objectId,
            !order.orderedItemsIds.contains(objectId) {
                order.orderedItemsIds.append(objectId)
            }
            showItemAddedAlert(menuItem)
        }
    }
    
    @IBAction func unwindToMenu(segue: UIStoryboardSegue) { }
}
