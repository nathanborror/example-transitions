import UIKit

class CustomPresentationController: UIPresentationController {

    let dimmingView: UIView

    init(color: UIColor, presented: UIViewController, presenting: UIViewController?) {
        self.dimmingView = UIView()
        self.dimmingView.backgroundColor = color
        super.init(presentedViewController: presented, presenting: presenting)

        let tap = UITapGestureRecognizer(target: self, action: #selector(handleMaskTapped))
        dimmingView.addGestureRecognizer(tap)

        print("+ init: CustomPresentationController")
    }

    deinit {
        print("- deinit: CustomPresentationController")
    }

    override func presentationTransitionWillBegin() {
        dimmingView.frame = containerView?.frame ?? .zero
        dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView?.addSubview(dimmingView)

        dimmingView.alpha = 0

        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimmingView.alpha = 1
            self.presentingViewController.view.tintAdjustmentMode = .dimmed
        }, completion: nil)
    }

    override func dismissalTransitionWillBegin() {
        if let coordinator = presentedViewController.transitionCoordinator {
            if coordinator.isInteractive { return }
        }
        print("dismissalTransitionWillBegin: \(presentedViewController.transitionCoordinator?.initiallyInteractive) - \(presentedViewController.transitionCoordinator?.isInteractive)")
        presentedViewController.transitionCoordinator?.animate(alongsideTransition: { context in
            self.dimmingView.alpha = 0
            self.presentingViewController.view.tintAdjustmentMode = .normal
        }, completion: nil)
    }

    override func dismissalTransitionDidEnd(_ completed: Bool) {
        // Remove the mask view when the dismissal completes, otherwise keep it in
        // the view hierarchy. Incomplete dismissals happen when an interactive
        // transition cancels.
        guard completed else { return }
        dimmingView.removeFromSuperview()
    }

    @objc func handleMaskTapped(recognizer: UITapGestureRecognizer) {
        presentedViewController.dismiss(animated: true, completion: nil)
    }
}

