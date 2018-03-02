import UIKit

class CustomPresentationController: UIPresentationController {

    let maskView: UIView

    // The PresentationController holds a strong reference to the transitioning
    // delegate because `UIViewController.transitioningDelegate` is a weak
    // property, and thus the `CustomPresentationController` would be deallocated
    // right after the presentation animation.
    //
    // Since the transitioningDelegate only vends the PresentationController
    // object and does not hold a reference to it, there is no issue of a
    // circular dependency here.
    var transitioningDelegate: UIViewControllerTransitioningDelegate?

    init(color: UIColor, presented: UIViewController, presenting: UIViewController?) {
        self.maskView = UIView()
        self.maskView.backgroundColor = color
        super.init(presentedViewController: presented, presenting: presenting)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleMaskTapped))
        maskView.addGestureRecognizer(tap)
    }

    deinit {
        print("deinit: CustomPresentationController")
    }

    override func presentationTransitionWillBegin() {
        maskView.frame = containerView?.frame ?? .zero
        maskView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView?.addSubview(maskView)

        maskView.alpha = 0
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.maskView.alpha = 1
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.maskView.alpha = 0
        }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        // Remove the mask view when the dismissal completes, otherwise keep it in
        // the view hierarchy. Incomplete dismissals happen when an interactive
        // transition cancels.
        guard completed else { return }
        maskView.removeFromSuperview()
    }

    @objc func handleMaskTapped(recognizer: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}
