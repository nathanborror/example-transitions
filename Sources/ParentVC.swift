import UIKit

import UIKit

class ParentVC: UITableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: .default, reuseIdentifier: nil)
        switch indexPath.row {
        case 0:  cell.textLabel?.text = "Typical Modal"
        case 1:  cell.textLabel?.text = "Custom Transition"
        case 2:  cell.textLabel?.text = "Presentation Controller"
        default: cell.textLabel?.text = "Popover"
        }
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        defer { tableView.deselectRow(at: indexPath, animated: true) }
        
        switch indexPath.row {
        case 0:
            let vc = UINavigationController(rootViewController: ChildVC())
            present(vc, animated: true, completion: nil)

        case 1:
            let vc = ChildVC()

            let size = CGSize(width: view.bounds.width, height: view.bounds.height / 2)
            let frame = CGRect(origin: CGPoint(x: 0, y: view.bounds.height - size.height), size: size)
            let transform = CGAffineTransform(translationX: 0, y: view.bounds.height - frame.minY)

            let options = CustomTransition.Options(
                frame: frame,
                transform: transform,
                duration: 0.35,
                dampingRatio: 0.85,
                axis: .vertical)

            customTransitioningDelegate = CustomTransition.Delegate(options, viewController: vc)

            vc.transitioningDelegate = customTransitioningDelegate
            vc.view.layer.cornerRadius = 10
            vc.view.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
            vc.view.layer.masksToBounds = true
            vc.modalPresentationStyle = .custom
            present(vc, animated: true, completion: nil)

        case 2:
            let vc = ChildVC()
            vc.transitioningDelegate = self
            vc.modalPresentationStyle = .custom
            present(vc, animated: true, completion: nil)

        default:
            let cell = tableView.cellForRow(at: indexPath)
            let vc = ChildVC()
            vc.preferredContentSize = CGSize(width: view.bounds.width / 1.25, height: 300)
            vc.modalPresentationStyle = .popover

            vc.popoverPresentationController?.backgroundColor = .white
            vc.popoverPresentationController?.permittedArrowDirections = .up
            vc.popoverPresentationController?.delegate = self
            vc.popoverPresentationController?.sourceView = cell
            vc.popoverPresentationController?.sourceRect = CGRect(x: view.bounds.width/2, y: 44, width: 0, height: 0)

            present(vc, animated: true, completion: nil)
        }
    }

    private var customTransitioningDelegate: CustomTransition.Delegate?
}

extension ParentVC: UIPopoverPresentationControllerDelegate {

    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle {
        return .none
    }
}

extension ParentVC: UIViewControllerTransitioningDelegate {
    func presentationController(forPresented presented: UIViewController, presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return CardPresentationController(presentedViewController: presented, presenting: presenting)
    }
}
