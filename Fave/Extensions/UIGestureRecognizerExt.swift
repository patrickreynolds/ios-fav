import UIKit

extension UIView {
    /**
     * Adds a tap gesture to the view with a block that will be invoked whenever
     * the gesture's state changes, e.g., when a tap completes.
     *
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The tap gesture.
     */
    func tapped(_ callback: @escaping (UITapGestureRecognizer) -> Void) -> Responder {
        let gr = UITapGestureRecognizer().any(callback)
        addGestureRecognizer(gr.gestureRecognizer)
        return gr
    }
}

extension UITapGestureRecognizer {
    /**
     * Takes a callback that will be invoked upon any gesture recognizer state
     * change, returning the gesture itself.
     *
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    func any(_ callback: @escaping (UITapGestureRecognizer) -> Void) -> Responder {
        return on(AllStates, callback)
    }

    /**
     * Takes a callback that will be invoked upon the given gesture recognizer
     * state change, returning the gesture itself.
     *
     * - parameter state: The state upon which to invoke the callback.
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    func on(_ state: UIGestureRecognizer.State, _ callback: @escaping (UITapGestureRecognizer) -> Void) -> Responder {
        return on([state], callback)
    }

    /**
     * Takes a callback that will be invoked upon the given gesture recognizer
     * state changes, returning the gesture itself.
     *
     * - parameter states: The states upon which to invoke the callback.
     * - parameter callback: Invoked whenever the gesture's state changes.
     * - returns: The gesture itself (self).
     */
    func on(_ states: [UIGestureRecognizer.State], _ callback: @escaping (UITapGestureRecognizer) -> Void) -> Responder {
        let responder = Responder(gesture: self)
        responder.on(states) { tap in
            callback(tap)
        }
        return responder
    }
}

private let AllStates: [UIGestureRecognizer.State] = [.possible, .began, .cancelled, .changed, .ended, .failed]

private let responders = NSMapTable<UITapGestureRecognizer, Responder>.weakToStrongObjects()

class Responder {

    var callbacks: [UIGestureRecognizer.State: [(UITapGestureRecognizer) -> Void]] = [
        .possible: [],
        .began: [],
        .cancelled: [],
        .changed: [],
        .ended: [],
        .failed: []
    ]

    let gestureRecognizer: UITapGestureRecognizer

    let selector = #selector(Responder.recognized(_:))

    init(gesture gestureRecognizer: UITapGestureRecognizer) {
        self.gestureRecognizer = gestureRecognizer
        responders.setObject(self, forKey: gestureRecognizer)
        gestureRecognizer.addTarget(self, action: selector)
    }

    func on(_ states: [UIGestureRecognizer.State], _ callback: @escaping (UITapGestureRecognizer) -> Void) {
        for state in states {
            callbacks[state]?.append(callback)
        }
    }

    @objc func recognized(_ gesture: UITapGestureRecognizer) {
        for callback in callbacks[gesture.state]! {
            callback(gesture)
        }
    }

    func removeTarget() {
        gestureRecognizer.removeTarget(self, action: selector)
    }
}
