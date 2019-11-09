import UIKit

protocol FeedViewModelDelegate: class {
    func onFetchCompleted(indexPaths: [IndexPath])
    func didUpdateEvents(events: [FeedEvent])
//    func onFetchFailed(with reason: String)
}

class FeedViewModel {

    private weak var delegate: FeedViewModelDelegate?

    private var events: [FeedEvent] = []
    static let increment: Int = 10
    var currentFromIndex: Int = 0
    var currentToIndex: Int = FeedViewModel.increment
    var isInfinateScrollingFetchInProgress = false
    var hasReachedEndOfList = false

    init(delegate: FeedViewModelDelegate) {
        self.delegate = delegate
    }

    var currentCount: Int {
        return events.count
    }

    func event(at index: Int) -> FeedEvent? {
        return events[safe: index]
    }

    func addNewEvents(events newEvents: [FeedEvent]) {
        self.events = self.events + newEvents

        delegate?.didUpdateEvents(events: self.events)

        bumpIncrement(newEvents: newEvents)
    }

    func resetContent() {
        self.events = []
        currentFromIndex = 0
        currentToIndex = FeedViewModel.increment
    }

    private func bumpIncrement(newEvents: [FeedEvent]) {
        var indexPaths: [IndexPath] = []

        let upTo = self.currentFromIndex + newEvents.count

        for index in self.currentFromIndex..<upTo {
            indexPaths.append(IndexPath(row: index, section: 0))
        }

        if newEvents.count < FeedViewModel.increment {
            self.currentToIndex += newEvents.count
            self.currentFromIndex += newEvents.count
            hasReachedEndOfList = true
        } else {
            self.currentToIndex += FeedViewModel.increment
            self.currentFromIndex += FeedViewModel.increment
            hasReachedEndOfList = false
        }

        self.delegate?.onFetchCompleted(indexPaths: indexPaths)
    }
}
