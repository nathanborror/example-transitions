import UIKit

class PopupTransitionDelegate: NSObject, UIViewControllerTransitioningDelegate {

    let animationController: CustomAnimationController

    // Interactive controller is not necessary but if it's present the dismissal
    // animation will adjust its springs and easing curve so the presented view
    // tracks the touch position rather than veering away when the pan gesture
    // updates the transition progress.
    var interactiveController: CustomInteractiveTransition?

    init(begin: CGRect, end: CGRect) {

        let config = CustomAnimationController.Options(
            frameBegin: begin,
            frameEnd: end,
            contentTransform: .identity,
            duration: 0.35,
            delay: 0.0,
            springDamping: 0.85,
            springVelocity: 0.4,
            alphaBegin: 1,
            alphaEnd: 1,
            options: [.curveEaseInOut])

        self.animationController = CustomAnimationController(configuration: config)
    }

    func animationController(forPresented presented: UIViewController, presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.stage = .presenting
        return animationController
    }

    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        animationController.stage = .dismissing

        if interactiveController?.isInteractive ?? false {

            // This delay prevents the view from stuttering when the pan gesture is transitioning
            // between the 'began' state to 'changed'. Within that fraction of time the view
            // controller's being dismissed before the percent driven controller has a chance to
            // take over.
            animationController.options.delay = 0.1

            animationController.options.springDamping = nil
            animationController.options.springVelocity = nil
            animationController.options.options = [.curveLinear, .allowUserInteraction]
        } else {
            animationController.options.delay = 0.0
            animationController.options.springDamping = 0.9
            animationController.options.springVelocity = 0.4
            animationController.options.options = [.curveEaseInOut]
        }
        return animationController
    }

    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        let pc = CustomPresentationController(color: UIColor(white: 0, alpha: 0.3), presented: presented, presenting: presenting)
        pc.transitioningDelegate = self
        return pc
    }

    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
        return interactiveController
    }
}
