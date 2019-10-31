import UIKit

protocol FeedViewModelDelegate: class {
    func onFetchCompleted(with newIndexPathsToReload: [IndexPath]?)
    func didUpdateEvents(events: [FeedEvent])
//    func onFetchFailed(with reason: String)
}

class FeedViewModel {

    private weak var delegate: FeedViewModelDelegate?

    private var events: [FeedEvent] = []
    static let increment: Int = 8
    var currentFromIndex: Int = 0
    var currentToIndex: Int = 7
    private var total = 100
    var isInfinateScrollingFetchInProgress = false

    init(delegate: FeedViewModelDelegate) {
        self.delegate = delegate
    }

    var totalCount: Int {
        return total
    }

    var currentCount: Int {
        return events.count
    }

    func event(at index: Int) -> FeedEvent {
        return events[index]
    }

    func addNewEvents(events newEvents: [FeedEvent]) {
        self.events = self.events + newEvents

        delegate?.didUpdateEvents(events: self.events)

        bumpIncrement(newEvents: newEvents)
    }

    func resetContent() {
        self.events = []
        currentFromIndex = 0
        currentToIndex = 7
    }

    private func bumpIncrement(newEvents: [FeedEvent]) {
        self.currentToIndex += FeedViewModel.increment
        self.currentFromIndex += FeedViewModel.increment

        if self.currentCount > 0 {
            let indexPathsToReload = self.calculateIndexPathsToReload(from: newEvents)
            self.delegate?.onFetchCompleted(with: indexPathsToReload)
        } else {
            self.delegate?.onFetchCompleted(with: .none)
        }
    }

    private func calculateIndexPathsToReload(from newEvents: [FeedEvent]) -> [IndexPath] {
      let startIndex = events.count - newEvents.count
      let endIndex = startIndex + newEvents.count

      return (startIndex..<endIndex).map { IndexPath(row: $0, section: 0) }
    }
}
