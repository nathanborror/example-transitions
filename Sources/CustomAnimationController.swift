import UIKit

class CustomAnimationController: NSObject, UIViewControllerAnimatedTransitioning {

    struct Options {
        var frameBegin: CGRect
        var frameEnd: CGRect
        var contentTransform: CGAffineTransform
        var duration: TimeInterval
        var delay: TimeInterval
        var springDamping: CGFloat?
        var springVelocity: CGFloat?
        var alphaBegin: CGFloat
        var alphaEnd: CGFloat
        var options: UIViewAnimationOptions
    }

    enum Stage {
        case presenting
        case dismissing
    }

    var options: Options
    var stage: Stage

    init(configuration: Options) {
        self.options = configuration
        self.stage = .presenting
        super.init()
    }

    deinit {
        print("deinit: CustomAnimationController")
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        switch stage {
        case .presenting: presentTransition(using: transitionContext)
        case .dismissing: dismissTransition(using: transitionContext)
        }
    }

    func presentTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedViewController = transitionContext.viewController(forKey: .to) else {
            return
        }
        let containerView = transitionContext.containerView
        containerView.addSubview(presentedViewController.view)

        presentedViewController.view.alpha = options.alphaBegin
        presentedViewController.view.transform = options.contentTransform
        presentedViewController.view.frame = options.frameBegin

        animate(duration: transitionDuration(using: transitionContext), animations: {
            presentedViewController.view.alpha = self.options.alphaEnd
            presentedViewController.view.transform = .identity
            presentedViewController.view.frame = self.options.frameEnd
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    func dismissTransition(using transitionContext: UIViewControllerContextTransitioning) {
        guard let presentedViewController = transitionContext.viewController(forKey: .from) else {
            return
        }
        animate(duration: transitionDuration(using: transitionContext), animations: {
            presentedViewController.view.alpha = self.options.alphaBegin
            presentedViewController.view.transform = self.options.contentTransform
            presentedViewController.view.frame = self.options.frameBegin
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return options.duration
    }

    private func animate(duration: TimeInterval, animations: @escaping () -> Void,
                         completion: @escaping (Bool) -> Void) {
        if let velocity = options.springVelocity, let damping = options.springDamping {
            UIView.animate(withDuration: duration, delay: options.delay,
                           usingSpringWithDamping: damping, initialSpringVelocity: velocity,
                           options: options.options,
                           animations: animations, completion: completion)
        } else {
            UIView.animate(withDuration: duration, delay: options.delay,
                           options: options.options,
                           animations: animations, completion: completion)
        }
    }
}
