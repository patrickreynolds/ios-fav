import Foundation

enum AnalyticsEvents: String {
    case installOpen = "Install Open"
    case itemFaved = "item_faved"
    case itemCreatedLocation = "item_created_location"
    case itemUpdatedLocation = "item_updated_location"
    case recommendationSent = "recommendation_sent"
    case pushPermissionDialogNo = "fave_push_permission_dialog_no_selected"
    case pushPermissionDialogYes = "fave_push_permission_dialog_yes_selected"
    case systemPushPermissionDialogShown = "system_push_permission_dialog_shown"
    case systemPushPermissionDialogYes = "system_push_permission_dialog_yes"
    case systemPushPermissionDialogNo = "system_push_permission_dialog_no"
    case favePushPermissionDialogShown = "fave_push_permission_dialog_shown"
    case onboardingScreenCreateListShown = "onboarding_screen_create_list_shown"
    case onboardingScreenListCreatedTitle = "onboarding_screen_list_created_title"
    case onboardingScreenAddEntryShown = "onboarding_screen_add_entry_shown"
    case onboardingScreenAskForRecsShown = "onboarding_screen_ask_for_recs_shown"
    case onboardingScreenGetUpdatesShown = "onboarding_screen_get_updates_shown"
    case onboardingScreenSkipped = "onboarding_screen_skipped"
    case splashScreenCreateListsShown = "splash_screen_create_lists_shown"
    case splashScreenShareRecommendationsShown = "splash_screen_share_recommendations_shown"
    case splashScreenDiscoverShown = "splash_screen_discover_shown"
}

enum AnalyticsImpressionEvent: String {
    case homescreenFeedScreenShown = "screen_shown_homescreen-feed"
    case discoverScreenShown = "screen_shown_discover"
    case profileScreenShown = "screen_shown_profile"
    case loggedOutScreenShown = "screen_shown_logged-out"
    case editProfileScreenShown = "screen_shown_edit-profile"
    case createListScreenShown = "screen_shown_create-list"
    case itemScreenShown = "screen_shown_item"
    case searchResultsScreenShown = "screen_shown_search-results"
    case myListsScreenShown = "screen_shown_my-lists"
    case shareItemScreenShown = "screen_shown_share-item"
    case createItemScreenShown = "screen_shown_create-item"
    case listScreenShown = "screen_shown_list"
    case selectListScreenShown = "screen_shown_select-list"
    case savedByScreenShown = "screen_shown_saved-by"
    case followedByScreenShown = "screen_shown_followed-by"
    case followingListsScreenShown = "screen_shown-following-lists"
    case splashScreenShown = "screen_shown-splash-screen"
    case onboardingScreenShown = "screen_shown-onboarding"
    case alertShown = "alert_shown"
}
