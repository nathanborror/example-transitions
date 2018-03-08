import UIKit

class PopupTransitionDelegate: NSObject,
                               UIViewControllerTransitioningDelegate,
                               UIViewControllerInteractiveTransitioning,
                               UIViewControllerAnimatedTransitioning {

    private weak var viewController: UIViewController?

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
    }

    func configureGesture() {
        panGesture.addTarget(self, action: #selector(handlePanGesture))
        panGesture.cancelsTouchesInView = false
        panGesture.maximumNumberOfTouches = 1
        viewController?.view.addGestureRecognizer(panGesture)
    }

    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        if recognizer.state == .began && driver == nil {
            isInteractive = true
            viewController?.dismiss(animated: true, completion: nil)
        }
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
