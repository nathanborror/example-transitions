import UIKit

class ParentVC: UIViewController {

    let popupButton = UIButton(type: .system)
    let modalButton = UIButton(type: .system)

    override func viewDidLoad() {
        super.viewDidLoad()

        popupButton.setTitle("Show Popup", for: .normal)
        popupButton.addTarget(self, action: #selector(handlePopupButtonTap), for: .primaryActionTriggered)
        view.addSubview(popupButton)

        modalButton.setTitle("Show Modal", for: .normal)
        modalButton.addTarget(self, action: #selector(handleModalButtonTap), for: .primaryActionTriggered)
        view.addSubview(modalButton)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        popupButton.sizeToFit()
        popupButton.center = CGPoint(x: view.center.x, y: view.center.y - 44)

        modalButton.sizeToFit()
        modalButton.center = CGPoint(x: view.center.x, y: view.center.y + 44)
    }

    @objc func handlePopupButtonTap() {
        let vc = ChildVC()

        // Beginning frame is where the view will start and end frame is where it'll
        // spring to. Adding a bit of padding so the parent view doesn't show through
        // the bottom of the screen when the view is settling into place.

        let popupBeginFrame = CGRect(x: 0, y: view.bounds.height, width: view.bounds.width, height: view.bounds.height / 2)
        let popupEndFrame = CGRect(x: 0, y: view.bounds.height - popupBeginFrame.height + 5,
                                   width: popupBeginFrame.width, height: popupBeginFrame.height)

        let popupInteractiveTransition = CustomInteractiveTransition(presented: vc)
        let popupTransition = PopupTransitionDelegate(begin: popupBeginFrame, end: popupEndFrame)
        popupTransition.interactiveController = popupInteractiveTransition

        vc.transitioningDelegate = popupTransition
        vc.view.layer.cornerRadius = 10
        vc.modalPresentationStyle = .custom
        present(vc, animated: true, completion: nil)
    }

    @objc func handleModalButtonTap() {
        let vc = ChildVC()
        present(vc, animated: true, completion: nil)
    }
}
