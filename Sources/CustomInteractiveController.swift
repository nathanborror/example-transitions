import UIKit

class CustomInteractiveTransition: UIPercentDrivenInteractiveTransition {

    private var viewController: UIViewController

    init?(presented viewController: UIViewController?) {
        guard let viewController = viewController else { return nil }
        self.viewController = viewController
        super.init()

        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePanGesture))
        panGesture.cancelsTouchesInView = false
        panGesture.maximumNumberOfTouches = 1
        self.viewController.view.addGestureRecognizer(panGesture)

        print("+ init: CustomInteractiveTransition")
    }

    deinit {
        print("- deinit: CustomInteractiveTransition")
    }

    @objc func handlePanGesture(recognizer: UIPanGestureRecognizer) {
        let translate = recognizer.translation(in: recognizer.view)
        let percent = translate.y / recognizer.view!.bounds.height

        switch recognizer.state {
        case .began:
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

        case .cancelled:
            cancel()

        default:
            cancel()
        }
    }
}
