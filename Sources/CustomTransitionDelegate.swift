import UIKit

extension CustomTransition {

    final class Delegate: NSObject, UIGestureRecognizerDelegate, UIViewControllerTransitioningDelegate, UIViewControllerInteractiveTransitioning, UIViewControllerAnimatedTransitioning {

        private var options: Options
        private var isPresenting: Bool
        private var isInteractive: Bool
        private var driver: Driver?
        private var panGesture: UIPanGestureRecognizer
        private var scrollUpdater: ScrollableUpdater?
        private var presentationController: PresentationController?

        private weak var viewController: UIViewController?

        init(_ options: Options, viewController: UIViewController) {
            self.options = options
            self.isPresenting = true
            self.isInteractive = false
            self.viewController = viewController
            self.panGesture = UIPanGestureRecognizer()

            super.init()

            panGesture.delegate = self
            panGesture.addTarget(self, action: #selector(handlePanGesture))
            panGesture.maximumNumberOfTouches = 1
            viewController.view.addGestureRecognizer(panGesture)

            if let scrollView = (viewController as? ScrollableViewController)?.scrollView {
                self.scrollUpdater = ScrollableUpdater(scrollView: scrollView)
            }
        }

        deinit {
            print("- deinit: Delegate")
        }

        @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
            guard scrollUpdater?.shouldDismiss() ?? true else {
                driver?.cancel()
                return
            }
            if (recognizer.state == .began || recognizer.state == .changed) && driver == nil {
                isInteractive = true
                viewController?.dismiss(animated: true, completion: nil)
                recognizer.setTranslation(.zero, in: recognizer.view)
            }
        }

        // MARK: - UIGestureRecognizerDelegate

        func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer,
                               shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
            return true
        }

        // MARK: - UIViewControllerTransitioningDelegate

        func animationController(forPresented presented: UIViewController, presenting: UIViewController,
                                 source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            isPresenting = true
            return self
        }

        func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
            isPresenting = false
            return self
        }

        func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
            return self
        }

        func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning) -> UIViewControllerInteractiveTransitioning? {
            return self
        }

        func presentationController(forPresented presented: UIViewController, presenting: UIViewController?,
                                    source: UIViewController) -> UIPresentationController? {
            presentationController = PresentationController(presentedViewController: presented, presenting: presenting)
            return presentationController
        }

        // MARK: - UIViewControllerInteractiveTransitioning

        func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
            driver = Driver(options: options, presenting: isPresenting, context: transitionContext, gesture: panGesture)

            // Pass the driver's property animator through to the presentation controller
            // so it can syncronize its animations alongside.
            presentationController?.propertyAnimator = driver?.propertyAnimator
        }

        var wantsInteractiveStart: Bool {
            return isInteractive
        }

        // MARK: - UIViewControllerAnimatedTransitioning

        func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
            return options.duration
        }

        func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}

        func animationEnded(_ transitionCompleted: Bool) {
            driver = nil
            isInteractive = false
            isPresenting = true
        }
    }
}
