import Foundation

enum AnalyticsEvents: String {
    case installOpen = "Install Open"
}

enum AnalyticsImpressionEvent: String {
    case homescreenFeedTabScreenShown = "screen_shown_homescreen-feed-tab"
    case discoverScreenShown = "screen_shown_discover"
    case profileScreenShown = "screen_shown_profile-tab"
    case loggedOutScreenShown = "screen_shown_logged-out"
    case editProfileScreenShown = "screen_shown_edit-profile"
    case createListScreenShown = "screen_shown_create-list"
    case itemScreenShown = "screen_shown_item"
    case searchResultsScreenShown = "screen_shown_search-results"
    case myListsScreenShown = "screen_shown_my-lists"
    case shareItemScreenShown = "screen_shown_share_item"
}
