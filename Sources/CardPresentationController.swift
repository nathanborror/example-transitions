import UIKit

class CardPresentationController: UIPresentationController {

    let dimmingView = UIView()

    override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
        super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

        dimmingView.backgroundColor = .black

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
        dimmingView.addGestureRecognizer(tap)
    }

    override func presentationTransitionWillBegin() {

        dimmingView.frame = containerView?.bounds ?? .zero
        dimmingView.alpha = 0
        containerView?.insertSubview(dimmingView, at: 0)

        let animations = {
            self.dimmingView.alpha = 0.3
            self.presentedViewController.view.layer.cornerRadius = 10
            self.presentedViewController.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            self.presentedViewController.view.layer.masksToBounds = true
        }

        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                animations()
            }, completion: nil)
        } else {
            animations()
        }
    }

    override func dismissalTransitionWillBegin() {
        let animations = {
            self.dimmingView.alpha = 0
            self.presentedViewController.view.layer.cornerRadius = 0
        }

        if let coordinator = presentingViewController.transitionCoordinator {
            coordinator.animate(alongsideTransition: { _ in
                animations()
            }, completion: nil)
        } else {
            animations()
        }
    }

    override func size(forChildContentContainer container: UIContentContainer, withParentContainerSize parentSize: CGSize) -> CGSize {
        return CGSize(width: parentSize.width, height: round(parentSize.height / 2))
    }

    override var frameOfPresentedViewInContainerView: CGRect {
        let size = self.size(forChildContentContainer: presentedViewController, withParentContainerSize: containerView!.bounds.size)
        return CGRect(x: 0, y: containerView!.bounds.height - size.height, width: size.width, height: size.height)
    }

    @objc func handleDismiss() {
        presentingViewController.dismiss(animated: true, completion: nil)
    }
}
