import UIKit

class ChildVC: UIViewController {

    let button = UIButton(type: .system)

    var customTransition: PopupTransitionDelegate?

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = view.tintColor

        button.setTitle("Dismiss", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleButtonTap), for: .primaryActionTriggered)
        view.addSubview(button)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        button.sizeToFit()
        button.center = CGPoint(x: view.bounds.midX, y: view.bounds.midY)
    }

    @objc func handleButtonTap() {
        dismiss(animated: true)
    }
}
