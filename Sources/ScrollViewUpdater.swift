import UIKit

protocol ScrollableViewController {
    var scrollView: UIScrollView { get }
}

class ScrollableUpdater {

    private var isDismissable = false
    private var offsetY: CGFloat {
        guard let scrollView = scrollView else { return 0 }
        return scrollView.contentOffset.y
    }

    weak var scrollView: UIScrollView?

    private var offsetObservation: NSKeyValueObservation?

    init(scrollView: UIScrollView) {
        self.scrollView = scrollView
        self.offsetObservation = scrollView.observe(\.contentOffset, options: [.initial]) { [weak self] (_, _) in
            self?.scrollViewDidScroll()
        }
    }

    deinit {
        offsetObservation = nil
    }

    func shouldDismiss() -> Bool {
        if offsetY <= 0 {
            return true
        }
        return isDismissable
    }

    func scrollViewDidScroll() {
        guard let scrollView = scrollView else {
            return
        }
        if offsetY > 0 {
            scrollView.bounces = true
            isDismissable = false
        } else {
            if scrollView.isDecelerating == false {
                scrollView.bounces = false
                isDismissable = true
            }
        }
    }
}
