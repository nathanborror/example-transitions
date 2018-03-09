import UIKit

class PopupTransitionDriver: NSObject {

    struct Options {
        var operation: Operation
        var startFrame: CGRect
        var endFrame: CGRect
        var duration: TimeInterval
        var dampingRatio: CGFloat
    }

    enum Operation {
        case none
        case present
        case dismiss
    }

    let options: Options
    let context: UIViewControllerContextTransitioning
    let panGesture: UIPanGestureRecognizer

    var propertyAnimator: UIViewPropertyAnimator!

    init(options: Options, context: UIViewControllerContextTransitioning, gesture: UIPanGestureRecognizer) {
        self.options = options
        self.context = context
        self.panGesture = gesture
        super.init()

        // Configure views and animators
        configure()

        // Add ourselves as a target of the pan gesture
        panGesture.addTarget(self, action: #selector(handleInteractionUpdate))

        // Begin the animation immediatly if not initially interactive
        if context.isInteractive == false {
            animate(to: .end)
        }
    }

    func configure() {

        // Identify view controllers and container view
        let fromViewController = context.viewController(forKey: .from)!
        let toViewController = context.viewController(forKey: .to)!
        let containerView = context.containerView

        // Presentation
        if options.operation == .present {

            // Position view controller about to be presented
            toViewController.view.frame = options.startFrame
            containerView.addSubview(toViewController.view)

            configureAnimator({
                toViewController.view.frame = self.options.endFrame
            }, completion: nil)
        }

        // Dismissal
        if options.operation == .dismiss {
            configureAnimator({
                fromViewController.view.frame = self.options.startFrame
            }, completion: nil)
        }
    }

    func configureAnimator(_ animation: @escaping () -> Void, completion: ((UIViewAnimatingPosition) -> Void)?) {
        propertyAnimator = UIViewPropertyAnimator(duration: options.duration, dampingRatio: options.dampingRatio, animations: animation)
        propertyAnimator.addCompletion { position in
            completion?(position)
            let completed = (position == .end)
            self.context.completeTransition(completed)
        }
    }

    @objc func handleInteractionUpdate(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began, .changed:
            let translation = recognizer.translation(in: context.containerView)

            let percentComplete = propertyAnimator.fractionComplete + progressStep(for: translation, in: recognizer.view)

            // Update the property animator's fraction complete to scrub it's animations
            propertyAnimator.fractionComplete = percentComplete

            // Inform the transition context of the updated percent complete
            context.updateInteractiveTransition(percentComplete)

            // Reset the gesture's translation
            recognizer.setTranslation(.zero, in: context.containerView)

        case .ended, .cancelled:
            endInteraction()

        default: break
        }
    }

    private func endInteraction() {
        guard context.isInteractive else { return }

        let velocity = panGesture.velocity(in: context.containerView)
        if (propertyAnimator.fractionComplete > 0.5 && velocity.y == 0) || velocity.y > 0 {
            context.finishInteractiveTransition()
            animate(to: .end)
        } else {
            context.cancelInteractiveTransition()
            animate(to: .start)
        }
    }

    private func animate(to position: UIViewAnimatingPosition) {
        propertyAnimator.isReversed = (position == .start)
        propertyAnimator.startAnimation()
    }

    private func progressStep(for translation: CGPoint, in view: UIView?) -> CGFloat {
        return (options.operation == .present ? -1.0 : 1.0) * translation.y / (view?.bounds.height ?? 0)
    }
}
