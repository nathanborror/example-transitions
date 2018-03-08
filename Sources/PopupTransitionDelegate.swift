import UIKit

class PopupTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    private let options: CustomAnimationController.Options
    private let presenting: UIViewController
    private var interactiveTransition: UIPercentDrivenInteractiveTransition

    init(start: CGRect, end: CGRect, presenting viewController: UIViewController) {
        self.options = CustomAnimationController.Options(
            frame: (start: start, end: end),
            alpha: (start: 1, end: 1),
            transform: .identity,
            duration: 0.35,
            delay: 0.0,
            dampingRatio: 0.85)
        self.presenting = viewController
        self.interactiveTransition = UIPercentDrivenInteractiveTransition()
        super.init()

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGesture.cancelsTouchesInView = false
        panGesture.maximumNumberOfTouches = 1
        presenting.view.addGestureRecognizer(panGesture)

        print("+ init: PopupTransitionDelegate")
    }

    deinit {
        print("- deinit: PopupTransitionDelegate")
    }

    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let translate = recognizer.translation(in: recognizer.view)
        let percent = translate.y / recognizer.view!.bounds.height

        switch recognizer.state {
        case .began:
            presenting.

        case .changed:
            interactiveTransition.update(percent)

        case .ended:
            let velocity = recognizer.velocity(in: recognizer.view)
            if (percent > 0.5 && velocity.y == 0) || velocity.y > 0 {
                interactiveTransition.finish()
            } else {
                interactiveTransition.cancel()
            }

        case .cancelled:
            interactiveTransition.cancel()

        default:
            interactiveTransition.cancel()
        }
    }

    // MARK: - Delegate Methods

    func animationController(forPresented presented: UIViewController, presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAnimationController(.presenting, options: options)
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return CustomAnimationController(.dismissing, options: options)
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return CustomPresentationController(color: UIColor(white: 0, alpha: 0.3), presented: presented, presenting: presenting)
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveTransition
    }
}
