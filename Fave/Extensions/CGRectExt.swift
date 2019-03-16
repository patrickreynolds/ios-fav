import UIKit

extension CGSize {
    func toRect() -> CGRect {
        return CGRect(x: 0, y: 0, width: width, height: height)
    }

    func withEdgeInsets(_ edgeInsets: UIEdgeInsets) -> CGSize {
        return CGSize(width: width - edgeInsets.left - edgeInsets.right, height: height - edgeInsets.top - edgeInsets.bottom)
    }

    func withHeight(_ height: CGFloat) -> CGSize {
        return CGSize(width: width, height: height)
    }

    func withWidth(_ width: CGFloat) -> CGSize {
        return CGSize(width: width, height: height)
    }
}

extension CGRect {
    var center: CGPoint {
        return CGPoint(x: origin.x + width / 2.0, y: origin.y + height / 2.0)
    }

    func centerHorizontallyIn(_ rect: CGRect) -> CGRect {
        return CGRect(x: rect.width / 2.0 - width / 2.0, y: origin.y, width: width, height: height)
    }

    func centerVerticallyIn(_ rect: CGRect) -> CGRect {
        return CGRect(x: origin.x, y: rect.height / 2.0 - height / 2.0, width: width, height: height)
    }

    func centerIn(_ rect: CGRect) -> CGRect {
        return centerHorizontallyIn(rect).centerVerticallyIn(rect)
    }

    func withOrigin(_ origin: CGPoint) -> CGRect {
        return CGRect(x: origin.x, y: origin.y, width: width, height: height)
    }

    func withX(_ x: CGFloat) -> CGRect {
        return withOrigin(CGPoint(x: x, y: origin.y))
    }

    func withY(_ y: CGFloat) -> CGRect {
        return withOrigin(CGPoint(x: origin.x, y: y))
    }

    func withSize(_ size: CGSize) -> CGRect {
        return CGRect(x: origin.x, y: origin.y, width: size.width, height: size.height)
    }

    func withSize(_ width: CGFloat, height: CGFloat) -> CGRect {
        return withWidth(width).withHeight(height)
    }

    func withScaleWidth(_ scale: CGFloat) -> CGRect {
        return withWidth(scale * width)
    }

    func withScaleHeight(_ scale: CGFloat) -> CGRect {
        return withHeight(scale * height)
    }

    func withScale(_ scale: CGFloat) -> CGRect {
        return withScaleWidth(scale).withScaleHeight(scale)
    }

    func withWidth(_ width: CGFloat) -> CGRect {
        return withSize(CGSize(width: width, height: size.height))
    }

    func withHeight(_ height: CGFloat) -> CGRect {
        return withSize(CGSize(width: size.width, height: height))
    }

    func withEdgeInsets(_ edgeInsets: UIEdgeInsets) -> CGRect {
        return inset(by: edgeInsets)
    }

    func fitWidth(_ rect: CGRect, inset: CGFloat) -> CGRect {
        let width = rect.size.width - inset - origin.x
        return CGRect(x: origin.x, y: origin.y, width: width, height: size.height)
    }

    func fitHeight(_ rect: CGRect, inset: CGFloat) -> CGRect {
        let height = rect.size.height - inset - origin.y
        return CGRect(x: origin.x, y: origin.y, width: size.width, height: height)
    }

    var bounds: CGRect {
        return withOrigin(CGPoint.zero)
    }

    var top: CGFloat {
        return origin.y
    }

    var left: CGFloat {
        return origin.x
    }

    var bottom: CGFloat {
        return top + height
    }

    var right: CGFloat {
        return left + width
    }
}

func CGPointMax(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
    return CGPoint(x: max(p1.x, p2.x), y: max(p1.y, p2.y))
}

func CGPointMax(_ point: CGPoint, x: CGFloat, y: CGFloat) -> CGPoint {
    return CGPointMax(point, CGPoint(x: x, y: y))
}

func CGPointMin(_ p1: CGPoint, _ p2: CGPoint) -> CGPoint {
    return CGPoint(x: min(p1.x, p2.x), y: min(p1.y, p2.y))
}

func CGPointMin(_ point: CGPoint, x: CGFloat, y: CGFloat) -> CGPoint {
    return CGPointMin(point, CGPoint(x: x, y: y))
}

extension CGPoint {
    func max(_ otherPoint: CGPoint) -> CGPoint {
        return CGPointMax(self, otherPoint)
    }

    func min(_ otherPoint: CGPoint) -> CGPoint {
        return CGPointMin(self, otherPoint)
    }
}

