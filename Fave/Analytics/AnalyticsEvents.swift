import Foundation

enum AnalyticsEvents: String {
    case installOpen = "Install Open"
}

enum AnalyticsImpressionEvent: String {
    case homescreenFeedTabScreenShown = "screen_shown_homescreen-feed-tab"
    case createEntryTabScreenShown = "screen_shown_create-entry-tab"
    case profileScreenShown = "screen_shown_profile-tab"
    case loggedOutScreenShown = "screen_shown_logged-out-screen"
    case editProfileScreenShown = "screen_shown_edit-profile"
    case createListScreenShown = "screen_shown_create-list"
}
