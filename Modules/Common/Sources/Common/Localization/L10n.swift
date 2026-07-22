import Foundation

public enum L10n {
    public enum Common {
        public static var save: String { String(localized: "common.save", bundle: .module) }
        public static var cancel: String { String(localized: "common.cancel", bundle: .module) }
        public static var `continue`: String { String(localized: "common.continue", bundle: .module) }
        public static var gotIt: String { String(localized: "common.got_it", bundle: .module) }
        public static var pleaseTryAgain: String { String(localized: "common.please_try_again", bundle: .module) }
        public static var close: String { String(localized: "common.close", bundle: .module) }
    }
    
    public enum Onboarding {
        public static var welcomeTitle: String { String(localized: "onboarding.welcome_title", bundle: .module) }
        public static var welcomeSubtitle: String { String(localized: "onboarding.welcome_subtitle", bundle: .module) }
        public static var letsGo: String { String(localized: "onboarding.lets_go", bundle: .module) }
        public static var skipSetup: String { String(localized: "onboarding.skip_setup", bundle: .module) }
        public static var nameTitle: String { String(localized: "onboarding.name_title", bundle: .module) }
        public static var nameSubtitle: String { String(localized: "onboarding.name_subtitle", bundle: .module) }
        public static var firstNameLabel: String { String(localized: "onboarding.first_name_label", bundle: .module) }
        public static var firstNamePlaceholder: String { String(localized: "onboarding.first_name_placeholder", bundle: .module) }
        public static var lastNameLabel: String { String(localized: "onboarding.last_name_label", bundle: .module) }
        public static var lastNamePlaceholder: String { String(localized: "onboarding.last_name_placeholder", bundle: .module) }
        public static var previewLabel: String { String(localized: "onboarding.preview_label", bundle: .module) }
        public static var wakeSleepTitle: String { String(localized: "onboarding.wake_sleep_title", bundle: .module) }
        public static var wakeLabel: String { String(localized: "onboarding.wake_label", bundle: .module) }
        public static var sleepLabel: String { String(localized: "onboarding.sleep_label", bundle: .module) }
        public static var midnightNote: String { String(localized: "onboarding.midnight_note", bundle: .module) }
        public static var zonesTitle: String { String(localized: "onboarding.zones_title", bundle: .module) }
        public static var setManually: String { String(localized: "onboarding.set_manually", bundle: .module) }
        public static var useThis: String { String(localized: "onboarding.use_this", bundle: .module) }
        public static var changeAnytime: String { String(localized: "onboarding.change_anytime", bundle: .module) }
        public static var addZone: String { String(localized: "onboarding.add_zone", bundle: .module) }
        public static var yourDayLabel: String { String(localized: "onboarding.your_day_label", bundle: .module) }
        public static func openSkyHours(_ hours: Int) -> String { String(format: String(localized: "onboarding.open_sky_hours", bundle: .module), hours) }
        public static var zonesFillNext: String { String(localized: "onboarding.zones_fill_next", bundle: .module) }
        public static var skip: String { String(localized: "onboarding.skip", bundle: .module) }
        public static var zoneNameLabel: String { String(localized: "onboarding.zone_name_label", bundle: .module) }
        public static var zoneNamePlaceholder: String { String(localized: "onboarding.zone_name_placeholder", bundle: .module) }
        public static var zoneColorLabel: String { String(localized: "onboarding.zone_color_label", bundle: .module) }
        public static var zoneStartTime: String { String(localized: "onboarding.zone_start_time", bundle: .module) }
        public static var zoneEndTime: String { String(localized: "onboarding.zone_end_time", bundle: .module) }
        public static var zoneOverlapError: String { String(localized: "onboarding.zone_overlap_error", bundle: .module) }
        public static var addZoneTitle: String { String(localized: "onboarding.add_zone_title", bundle: .module) }
    }
    
    public enum Login {
        public static var appTitle: String { String(localized: "login.app_title", bundle: .module) }
        public static var subtitle: String { String(localized: "login.subtitle", bundle: .module) }
        public static var sending: String { String(localized: "login.sending", bundle: .module) }
        public static func sendCodeTimer(_ seconds: String) -> String { String(format: String(localized: "login.send_code_timer", bundle: .module), seconds) }
        public static var sendCode: String { String(localized: "login.send_code", bundle: .module) }
        public static var or: String { String(localized: "login.or", bundle: .module) }
        public static var signInWithApple: String { String(localized: "login.sign_in_apple", bundle: .module) }
        public static var continueWithGoogle: String { String(localized: "login.continue_google", bundle: .module) }
        public static var footerTermsPrefix: String { String(localized: "login.footer.terms_prefix", bundle: .module) }
        public static var terms: String { String(localized: "login.footer.terms", bundle: .module) }
        public static var and: String { String(localized: "login.footer.and", bundle: .module) }
        public static var privacy: String { String(localized: "login.footer.privacy", bundle: .module) }
        public static var dot: String { String(localized: "login.footer.dot", bundle: .module) }
        public static var emailLabel: String { String(localized: "login.email_label", bundle: .module) }
        public static var emailPrompt: String { String(localized: "login.email_prompt", bundle: .module) }
        public static var offlineError: String { String(localized: "login.error.offline", bundle: .module) }
    }
    
    public enum OtpVerification {
        public static var title: String { String(localized: "otp.title", bundle: .module) }
        public static var subtitle: String { String(localized: "otp.subtitle", bundle: .module) }
        public static var verified: String { String(localized: "otp.verified", bundle: .module) }
        public static var offlineError: String { String(localized: "otp.error.offline", bundle: .module) }
        public static func resendTimer(_ time: String) -> String { String(format: String(localized: "otp.resend_timer", bundle: .module), time) }
        public static var resend: String { String(localized: "otp.resend", bundle: .module) }
        public static var keypadHint: String { String(localized: "otp.keypad_hint", bundle: .module) }
        public static func digitAccessibility(_ index: Int) -> String { String(format: String(localized: "otp.digit_accessibility", bundle: .module), index) }
    }
    
    public enum Schedule {
        public static var questsTitle: String { String(localized: "schedule.quests_title", bundle: .module) }
        public static var streakAccessibility: String { String(localized: "schedule.streak_accessibility", bundle: .module) }
        public static var questChain: String { String(localized: "schedule.quest_chain", bundle: .module) }
        public static var todaysAdventure: String { String(localized: "schedule.todays_adventure", bundle: .module) }
        public static func minutesScheduled(_ minutes: Int) -> String { String(format: String(localized: "schedule.minutes_scheduled", bundle: .module), minutes) }
        public static var thisWeek: String { String(localized: "schedule.this_week", bundle: .module) }
        public static var emptyTitle: String { String(localized: "schedule.empty_title", bundle: .module) }
        public static var emptySubtitle: String { String(localized: "schedule.empty_subtitle", bundle: .module) }
        public static var yourTime: String { String(localized: "schedule.your_time", bundle: .module) }
        public static var dragHintAccessibility: String { String(localized: "schedule.drag_hint_accessibility", bundle: .module) }
        public static var questName: String { String(localized: "schedule.quest_name", bundle: .module) }
        public static var questNamePlaceholder: String { String(localized: "schedule.quest_name_placeholder", bundle: .module) }
        public static var duration: String { String(localized: "schedule.duration", bundle: .module) }
        public static func durationMinutes(_ minutes: Int) -> String { String(format: String(localized: "schedule.duration_minutes", bundle: .module), minutes) }
        public static var zone: String { String(localized: "schedule.zone", bundle: .module) }
        public static var standalone: String { String(localized: "schedule.standalone", bundle: .module) }
        public static var chooseZone: String { String(localized: "schedule.choose_zone", bundle: .module) }
        public static var canSplit: String { String(localized: "schedule.can_split", bundle: .module) }
        public static var keepFixed: String { String(localized: "schedule.keep_fixed", bundle: .module) }
        public static var createQuest: String { String(localized: "schedule.create_quest", bundle: .module) }
        public static var saveChanges: String { String(localized: "schedule.save_changes", bundle: .module) }
        public static var deleteQuest: String { String(localized: "schedule.delete_quest", bundle: .module) }
        public static var newQuest: String { String(localized: "schedule.new_quest", bundle: .module) }
        public static var tuneQuest: String { String(localized: "schedule.tune_quest", bundle: .module) }
        public static var buildQuestTitle: String { String(localized: "schedule.build_quest_title", bundle: .module) }
        public static var buildQuestSubtitle: String { String(localized: "schedule.build_quest_subtitle", bundle: .module) }
        public static var goalName: String { String(localized: "schedule.goal_name", bundle: .module) }
        public static var eachStep: String { String(localized: "schedule.each_step", bundle: .module) }
        public static var startQuest: String { String(localized: "schedule.start_quest", bundle: .module) }
        public static var errorTitle: String { String(localized: "schedule.error_title", bundle: .module) }
        public static var addTask: String { String(localized: "schedule.add_task", bundle: .module) }
        public static var addGoal: String { String(localized: "schedule.add_goal", bundle: .module) }
    }
}
