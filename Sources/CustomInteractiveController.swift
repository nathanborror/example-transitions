import UIKit

class CustomInteractiveTransition: UIPercentDrivenInteractiveTransition {

    private(set) var isInteractive: Bool

    private var viewController: UIViewController

    init(presented viewController: UIViewController) {
        self.viewController = viewController
        self.isInteractive = false
        super.init()

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGesture.cancelsTouchesInView = false
        panGesture.maximumNumberOfTouches = 1
        self.viewController.view.addGestureRecognizer(panGesture)
    }

    deinit {
        print("deinit: CustomInteractiveTransition")
    }

    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let translate = recognizer.translation(in: recognizer.view)
        let percent = translate.y / recognizer.view!.bounds.height

        switch recognizer.state {
        case .began:
            isInteractive = true
            viewController.dismiss(animated: true)

        case .changed:
            update(percent)

        case .ended:
            let velocity = recognizer.velocity(in: recognizer.view)
            if (percent > 0.5 && velocity.y == 0) || velocity.y > 0 {
                finish()
            } else {
                cancel()
            }
            isInteractive = false

        case .cancelled:
            cancel()
            isInteractive = false

        default:
            cancel()
            isInteractive = false
        }
    }
}
