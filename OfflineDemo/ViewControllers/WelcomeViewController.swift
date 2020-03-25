
import UIKit

class WelcomeViewController: UIViewController {

    @IBOutlet weak var welcomeImageView: UIImageView!
    
    // MARK: override functions
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.welcomeImageView.image = getRandomWelcomeImage()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.setNavigationBarHidden(true, animated: animated)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        self.navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        self.welcomeImageView.image = getRandomWelcomeImage()
    }
    
    // MARK: private functions
    
    private func getRandomWelcomeImage() -> UIImage? {
        let randomNumber = Int.random(in: 1...10)  
        if #available(iOS 12, *) {
            if Utils.shared.interfaceIsLight(self) {
                return UIImage(named:"welcomeLight\(randomNumber)")
            }
            return UIImage(named:"welcomeDark\(randomNumber)")
        } else {
            return UIImage(named:"welcomeLight\(randomNumber)")
        }
    }
}
