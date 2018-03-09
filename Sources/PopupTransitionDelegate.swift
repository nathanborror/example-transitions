import UIKit

class PopupTransitionDelegate: NSObject,
                               UIGestureRecognizerDelegate,
                               UIViewControllerTransitioningDelegate,
                               UIViewControllerInteractiveTransitioning,
                               UIViewControllerAnimatedTransitioning {

    private weak var viewController: UIViewController?
    private var scrollUpdater: ScrollViewUpdater?

    private let animationStartFrame: CGRect
    private let animationEndFrame: CGRect
    private let animationDuration: TimeInterval = 0.35
    private let animationDampingRatio: CGFloat = 0.85
    private let panGesture: UIPanGestureRecognizer

    private var isPresenting = true
    private var driver: PopupTransitionDriver?
    private var isInteractive = false
    private var presentationController: PopupPresentationController?

    init(start: CGRect, end: CGRect, viewController: UIViewController) {
        self.animationStartFrame = start
        self.animationEndFrame = end
        self.viewController = viewController
        self.panGesture = UIPanGestureRecognizer()
        super.init()
        configureGesture()

        if let scrollView = (viewController as? ScrollableViewController)?.scrollView {
            self.scrollUpdater = ScrollViewUpdater(scrollView: scrollView)
        }
    }

    func configureGesture() {
        panGesture.delegate = self
        panGesture.addTarget(self, action: #selector(handlePanGesture))
        panGesture.maximumNumberOfTouches = 1
        viewController?.view.addGestureRecognizer(panGesture)
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
        presentationController = PopupPresentationController(presentedViewController: presented, presenting: presenting)
        return presentationController
    }

    // MARK: - UIViewControllerInteractiveTransitioning

    func startInteractiveTransition(_ transitionContext: UIViewControllerContextTransitioning) {
        let options = PopupTransitionDriver.Options(
            operation: isPresenting ? .present : .dismiss,
            startFrame: animationStartFrame,
            endFrame: animationEndFrame,
            duration: animationDuration,
            dampingRatio: animationDampingRatio
        )
        driver = PopupTransitionDriver(options: options, context: transitionContext, gesture: panGesture)

        // Pass the driver's property animator through to the presentation controller
        // so it can syncronize its animations alongside.
        presentationController?.propertyAnimator = driver?.propertyAnimator
    }

    var wantsInteractiveStart: Bool {
        return isInteractive
    }

    // MARK: - UIViewControllerAnimatedTransitioning

    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationDuration
    }

    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {}

    func animationEnded(_ transitionCompleted: Bool) {
        driver = nil
        isInteractive = false
        isPresenting = true
    }
}
