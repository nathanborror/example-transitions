import UIKit

extension CustomTransition {

    final class Driver: NSObject {

        let options: Options
        let context: UIViewControllerContextTransitioning
        let panGesture: UIPanGestureRecognizer
        let isPresenting: Bool

        var propertyAnimator: UIViewPropertyAnimator!

        init(options: Options, presenting: Bool, context: UIViewControllerContextTransitioning, gesture: UIPanGestureRecognizer) {
            self.options = options
            self.context = context
            self.panGesture = gesture
            self.isPresenting = presenting
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
            if isPresenting {

                // Position view controller about to be presented
                toViewController.view.frame = options.frame
                toViewController.view.transform = options.transform
                containerView.addSubview(toViewController.view)

                configureAnimator({
                    toViewController.view.transform = .identity
                }, completion: nil)
            } else {
                configureAnimator({
                    fromViewController.view.transform = self.options.transform
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

                let percentComplete = propertyAnimator.fractionComplete + progressStep(for: translation, in: context.containerView)

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
            var isFinished = false

            switch options.axis {
            case .horizontal:
                isFinished = (propertyAnimator.fractionComplete > 0.5 && velocity.x == 0) || velocity.x > 0
            case .vertical:
                isFinished = (propertyAnimator.fractionComplete > 0.5 && velocity.y == 0) || velocity.y > 0
            }

            if isFinished {
                finish()
            } else {
                cancel()
            }
        }

        func finish() {
            context.finishInteractiveTransition()
            animate(to: .end)
        }

        func cancel() {
            context.cancelInteractiveTransition()
            animate(to: .start)
        }

        private func animate(to position: UIViewAnimatingPosition) {

            // Reverse animation when returning to start position
            propertyAnimator.isReversed = (position == .start)

            // Start or continue the animator
            if propertyAnimator.state == .inactive {
                propertyAnimator.startAnimation()
            } else {
                let timingParams = timingParameters()
                let durationFactor = 1 - propertyAnimator.fractionComplete
                propertyAnimator.continueAnimation(withTimingParameters: timingParams, durationFactor: durationFactor)
            }
        }

        private func progressStep(for translation: CGPoint, in view: UIView) -> CGFloat {
            switch options.axis {
            case .horizontal:
                return (isPresenting ? -1.0 : 1.0) * translation.x / view.bounds.width
            case .vertical:
                return (isPresenting ? -1.0 : 1.0) * translation.y / view.bounds.height
            }
        }

        private func timingParameters() -> UISpringTimingParameters {
            let velocity = panGesture.velocity(in: context.containerView)
            let vector = CGVector(dx: velocity.x / 100, dy: velocity.y / 100)
            return UISpringTimingParameters(dampingRatio: options.dampingRatio, initialVelocity: vector)
        }
    }
}
