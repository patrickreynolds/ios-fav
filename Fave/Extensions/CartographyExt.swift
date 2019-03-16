import UIKit
import Cartography

public enum ConstraintAlignmentEdge: Int {
    case top, left, bottom, right
}

struct ConstraintAlignmentGroup {
    let group: ConstraintGroup

    let top: NSLayoutConstraint?
    let left: NSLayoutConstraint?
    let bottom: NSLayoutConstraint?
    let right: NSLayoutConstraint?

    var constraints: [NSLayoutConstraint] {
        return [top, left, bottom, right].mapMaybe { $0 }
    }
}

func constrainToSuperview(_ view: UIView, exceptEdges: [ConstraintAlignmentEdge] = [], edgeInsets: UIEdgeInsets = UIEdgeInsets.zero) {
    guard let superview = view.superview else {
        fatalError("View must have a superview.")
    }

    constrain(view, superview) { view, superview in
        if !exceptEdges.contains(.top) {
            view.top == superview.top + edgeInsets.top
        }

        if !exceptEdges.contains(.left) {
            view.left == superview.left + edgeInsets.left
        }

        if !exceptEdges.contains(.bottom) {
            view.bottom == superview.bottom - edgeInsets.bottom
        }

        if !exceptEdges.contains(.right) {
            view.right == superview.right - edgeInsets.right
        }
    }
}

func constrainWidth(_ view: UIView, width: CGFloat) -> (group: ConstraintGroup, width: NSLayoutConstraint) {
    var widthConstraint: NSLayoutConstraint!
    let group = constrain(view) { view in
        widthConstraint = view.width == width
    }
    return (group: group, width: widthConstraint)
}

func constrainHeight(_ view: UIView, height: CGFloat) -> (group: ConstraintGroup, height: NSLayoutConstraint) {
    var heightConstraint: NSLayoutConstraint!
    let group = constrain(view) { view in
        heightConstraint = view.height == height
    }
    return (group: group, height: heightConstraint)
}
