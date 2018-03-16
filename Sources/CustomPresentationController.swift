import UIKit

extension CustomTransition {

    final class PresentationController: UIPresentationController {

        var propertyAnimator: UIViewPropertyAnimator? {
            didSet { propertyAnimatorDidSet() }
        }

        private let dimmingView = UIView()
        private var isPresenting = true

        override init(presentedViewController: UIViewController, presenting presentingViewController: UIViewController?) {
            super.init(presentedViewController: presentedViewController, presenting: presentingViewController)

            dimmingView.alpha = 0
            dimmingView.backgroundColor = .black
            dimmingView.autoresizingMask = [.flexibleWidth, .flexibleHeight]

            let tap = UITapGestureRecognizer(target: self, action: #selector(handleDismiss))
            dimmingView.addGestureRecognizer(tap)
        }

        deinit {
            print("- deinit: PresentationController")
        }

        @objc private func handleDismiss() {
            presentedViewController.dismiss(animated: true, completion: nil)
        }

        private func propertyAnimatorDidSet() {

            // Add animations to the given property animator so they're
            // syncronized with the presenting / dismissing view animations.
            propertyAnimator?.addAnimations {
                self.dimmingView.alpha = self.isPresenting ? 0.25 : 0
            }
        }

        override func presentationTransitionWillBegin() {
            isPresenting = true

            // The dimming view needs to wait until the presentation begins so it
            // can inherit the container view's bounds and become a child view.
            guard let containerView = containerView else { return }
            dimmingView.frame = containerView.bounds
            containerView.addSubview(dimmingView)
        }

        override func dismissalTransitionWillBegin() {
            isPresenting = false
        }

        override func dismissalTransitionDidEnd(_ completed: Bool) {

            // Remove dimming view only if the dismissal transition was completed.
            guard completed else { return }
            dimmingView.removeFromSuperview()
        }
    }
}
