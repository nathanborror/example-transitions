import UIKit

class CustomAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    struct Options {
        var frame: (start: CGRect, end: CGRect)
        var alpha: (start: CGFloat, end: CGFloat)
        var transform: CGAffineTransform
        var duration: TimeInterval
        var delay: TimeInterval
        var dampingRatio: CGFloat
    }

    enum Stage {
        case presenting
        case dismissing
    }

    var options: Options
    var stage: Stage

    init(_ stage: Stage, options: Options) {
        self.options = options
        self.stage = stage
        super.init()
        print("+ init: CustomAnimationController (\(stage))")
    }

    deinit {
        print("- deinit: CustomAnimationController (\(stage))")
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        let transition = self.interruptibleAnimator(using: transitionContext)
        transition.startAnimation()
    }

    func presentTransition(using transitionContext: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        guard let presentedViewController = transitionContext.viewController(forKey: .to) else {
            fatalError("Missing 'to' view controller from context")
        }
        let containerView = transitionContext.containerView
        containerView.addSubview(presentedViewController.view)

        presentedViewController.view.alpha = options.alpha.start
        presentedViewController.view.transform = options.transform
        presentedViewController.view.frame = options.frame.start

        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext),
                                               dampingRatio: options.dampingRatio) {
            presentedViewController.view.alpha = self.options.alpha.end
            presentedViewController.view.frame = self.options.frame.end
            presentedViewController.view.transform = .identity
        }
        animator.addCompletion { position in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        animator.isInterruptible = true
        return animator
    }

    func dismissTransition(using transitionContext: UIViewControllerContextTransitioning) -> UIViewPropertyAnimator {
        guard let presentedViewController = transitionContext.viewController(forKey: .from) else {
            fatalError("Missing 'from' view controller from context")
        }

        let animator = UIViewPropertyAnimator(duration: transitionDuration(using: transitionContext),
                                               dampingRatio: options.dampingRatio) {
            presentedViewController.view.alpha = self.options.alpha.start
            presentedViewController.view.frame = self.options.frame.start
            presentedViewController.view.transform = self.options.transform
        }
        animator.addCompletion { position in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        }
        animator.isInterruptible = true
        return animator
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return options.duration
    }

    func interruptibleAnimator(using transitionContext: UIViewControllerContextTransitioning) -> UIViewImplicitlyAnimating {
        switch stage {
        case .presenting: return presentTransition(using: transitionContext)
        case .dismissing: return dismissTransition(using: transitionContext)
        }
    }
}
