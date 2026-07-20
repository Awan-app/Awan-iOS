import Foundation

public enum L10n {
    public enum Common {
        public static var save: String { String(localized: "common.save", bundle: .module) }
        public static var cancel: String { String(localized: "common.cancel", bundle: .module) }
        public static var `continue`: String { String(localized: "common.continue", bundle: .module) }
        public static var gotIt: String { String(localized: "common.got_it", defaultValue: "Got it", bundle: .module) }
        public static var pleaseTryAgain: String { String(localized: "common.please_try_again", defaultValue: "Please try again.", bundle: .module) }
        public static var close: String { String(localized: "common.close", defaultValue: "Close", bundle: .module) }
    }
    
    public enum Onboarding {
        public static var welcomeTitle: String { String(localized: "onboarding.welcome_title", defaultValue: "Hi, I'm Awan.\nThe sky is yours today.", bundle: .module) }
        public static var welcomeSubtitle: String { String(localized: "onboarding.welcome_subtitle", defaultValue: "Tell me a little about your day and I'll\nbuild a schedule that quietly heals itself\nwhen life happens.", bundle: .module) }
        public static var letsGo: String { String(localized: "onboarding.lets_go", defaultValue: "LET'S GO", bundle: .module) }
        public static var skipSetup: String { String(localized: "onboarding.skip_setup", defaultValue: "Skip setup", bundle: .module) }
        public static var nameTitle: String { String(localized: "onboarding.name_title", defaultValue: "What should I call you?", bundle: .module) }
        public static var nameSubtitle: String { String(localized: "onboarding.name_subtitle", defaultValue: "Just your name — I'll use it to greet you each morning.", bundle: .module) }
        public static var firstNameLabel: String { String(localized: "onboarding.first_name_label", defaultValue: "FIRST NAME", bundle: .module) }
        public static var firstNamePlaceholder: String { String(localized: "onboarding.first_name_placeholder", defaultValue: "Sam", bundle: .module) }
        public static var lastNameLabel: String { String(localized: "onboarding.last_name_label", defaultValue: "LAST NAME", bundle: .module) }
        public static var lastNamePlaceholder: String { String(localized: "onboarding.last_name_placeholder", defaultValue: "Rivera", bundle: .module) }
        public static var previewLabel: String { String(localized: "onboarding.preview_label", defaultValue: "PREVIEW", bundle: .module) }
        public static var wakeSleepTitle: String { String(localized: "onboarding.wake_sleep_title", defaultValue: "When does your day begin and end?", bundle: .module) }
        public static var wakeLabel: String { String(localized: "onboarding.wake_label", defaultValue: "I usually wake up at", bundle: .module) }
        public static var sleepLabel: String { String(localized: "onboarding.sleep_label", defaultValue: "I usually sleep at", bundle: .module) }
        public static var midnightNote: String { String(localized: "onboarding.midnight_note", defaultValue: "Sleeps past midnight? I'll wrap the night for you.", bundle: .module) }
        public static var zonesTitle: String { String(localized: "onboarding.zones_title", defaultValue: "Here's a day I sketched for you", bundle: .module) }
        public static var setManually: String { String(localized: "onboarding.set_manually", defaultValue: "SET MANUALLY", bundle: .module) }
        public static var useThis: String { String(localized: "onboarding.use_this", defaultValue: "USE THIS", bundle: .module) }
        public static var changeAnytime: String { String(localized: "onboarding.change_anytime", defaultValue: "You can change this anytime", bundle: .module) }
        public static var addZone: String { String(localized: "onboarding.add_zone", defaultValue: "Add a zone", bundle: .module) }
        public static var yourDayLabel: String { String(localized: "onboarding.your_day_label", defaultValue: "YOUR DAY", bundle: .module) }
        public static func openSkyHours(_ hours: Int) -> String { String(localized: "onboarding.open_sky_hours", defaultValue: "\(hours) h of open sky", bundle: .module) }
        public static var zonesFillNext: String { String(localized: "onboarding.zones_fill_next", defaultValue: "Zones will fill this in next", bundle: .module) }
        public static var skip: String { String(localized: "onboarding.skip", defaultValue: "Skip", bundle: .module) }
    }
    
    public enum Login {
        public static var appTitle: String { String(localized: "login.app_title", defaultValue: "Awan", bundle: .module) }
        public static var subtitle: String { String(localized: "login.subtitle", defaultValue: "Your day, drawn as a sky.\nSign in — we'll float you a code.", bundle: .module) }
        public static var sending: String { String(localized: "login.sending", defaultValue: "SENDING...", bundle: .module) }
        public static func sendCodeTimer(_ seconds: String) -> String { String(localized: "login.send_code_timer", defaultValue: "SEND CODE • 0:\(seconds)", bundle: .module) }
        public static var sendCode: String { String(localized: "login.send_code", defaultValue: "SEND CODE", bundle: .module) }
        public static var or: String { String(localized: "login.or", defaultValue: "OR", bundle: .module) }
        public static var signInWithApple: String { String(localized: "login.sign_in_apple", defaultValue: "Sign in with Apple", bundle: .module) }
        public static var continueWithGoogle: String { String(localized: "login.continue_google", defaultValue: "Continue with Google", bundle: .module) }
        public static var footerTermsPrefix: String { String(localized: "login.footer.terms_prefix", defaultValue: "No passwords, ever. By continuing you agree to Awan's ", bundle: .module) }
        public static var terms: String { String(localized: "login.footer.terms", defaultValue: "Terms", bundle: .module) }
        public static var and: String { String(localized: "login.footer.and", defaultValue: " & ", bundle: .module) }
        public static var privacy: String { String(localized: "login.footer.privacy", defaultValue: "Privacy", bundle: .module) }
        public static var dot: String { String(localized: "login.footer.dot", defaultValue: ".", bundle: .module) }
        public static var emailLabel: String { String(localized: "login.email_label", defaultValue: "EMAIL", bundle: .module) }
        public static var emailPrompt: String { String(localized: "login.email_prompt", defaultValue: "Enter your email", bundle: .module) }
        public static var offlineError: String { String(localized: "login.error.offline", defaultValue: "You're offline — we'll send the code when you reconnect.", bundle: .module) }
    }
    
    public enum OtpVerification {
        public static var title: String { String(localized: "otp.title", defaultValue: "You're in! ☀️", bundle: .module) }
        public static var subtitle: String { String(localized: "otp.subtitle", defaultValue: "Enter the code we sent to", bundle: .module) }
        public static var verified: String { String(localized: "otp.verified", defaultValue: "Verified — drifting you in", bundle: .module) }
        public static var offlineError: String { String(localized: "otp.error.offline", defaultValue: "You're offline — reconnect to verify or resend your code.", bundle: .module) }
        public static func resendTimer(_ time: String) -> String { String(localized: "otp.resend_timer", defaultValue: "RESEND CODE • \(time)", bundle: .module) }
        public static var resend: String { String(localized: "otp.resend", defaultValue: "RESEND CODE", bundle: .module) }
        public static var keypadHint: String { String(localized: "otp.keypad_hint", defaultValue: "Numeric keypad · auto-submits on the 6th digit", bundle: .module) }
        public static func digitAccessibility(_ index: Int) -> String { String(localized: "otp.digit_accessibility", defaultValue: "Verification code digit \(index)", bundle: .module) }
    }
    
    public enum Schedule {
        public static var questsTitle: String { String(localized: "schedule.quests_title", defaultValue: "AWAN QUESTS", bundle: .module) }
        public static var streakAccessibility: String { String(localized: "schedule.streak_accessibility", defaultValue: "Seven day streak", bundle: .module) }
        public static var questChain: String { String(localized: "schedule.quest_chain", defaultValue: "Quest chain", bundle: .module) }
        public static var todaysAdventure: String { String(localized: "schedule.todays_adventure", defaultValue: "Today's adventure", bundle: .module) }
        public static func minutesScheduled(_ minutes: Int) -> String { String(localized: "schedule.minutes_scheduled", defaultValue: "\(minutes) min", bundle: .module) }
        public static var thisWeek: String { String(localized: "schedule.this_week", defaultValue: "THIS WEEK", bundle: .module) }
        public static var emptyTitle: String { String(localized: "schedule.empty_title", defaultValue: "Your day is ready for adventure", bundle: .module) }
        public static var emptySubtitle: String { String(localized: "schedule.empty_subtitle", defaultValue: "Create a quest or try the conflict lab above.", bundle: .module) }
        public static var yourTime: String { String(localized: "schedule.your_time", defaultValue: "Your time", bundle: .module) }
        public static var dragHintAccessibility: String { String(localized: "schedule.drag_hint_accessibility", defaultValue: "Drag vertically to change time in fifteen minute steps", bundle: .module) }
        public static var questName: String { String(localized: "schedule.quest_name", defaultValue: "Quest name", bundle: .module) }
        public static var questNamePlaceholder: String { String(localized: "schedule.quest_name_placeholder", defaultValue: "What will you conquer?", bundle: .module) }
        public static var duration: String { String(localized: "schedule.duration", defaultValue: "Duration", bundle: .module) }
        public static func durationMinutes(_ minutes: Int) -> String { String(localized: "schedule.duration_minutes", defaultValue: "\(minutes) minutes", bundle: .module) }
        public static var zone: String { String(localized: "schedule.zone", defaultValue: "Zone", bundle: .module) }
        public static var standalone: String { String(localized: "schedule.standalone", defaultValue: "Standalone", bundle: .module) }
        public static var chooseZone: String { String(localized: "schedule.choose_zone", defaultValue: "Choose zone", bundle: .module) }
        public static var canSplit: String { String(localized: "schedule.can_split", defaultValue: "Can split into sessions", bundle: .module) }
        public static var keepFixed: String { String(localized: "schedule.keep_fixed", defaultValue: "Keep scheduled time fixed", bundle: .module) }
        public static var createQuest: String { String(localized: "schedule.create_quest", defaultValue: "Create quest", bundle: .module) }
        public static var saveChanges: String { String(localized: "schedule.save_changes", defaultValue: "Save changes", bundle: .module) }
        public static var deleteQuest: String { String(localized: "schedule.delete_quest", defaultValue: "Delete quest", bundle: .module) }
        public static var newQuest: String { String(localized: "schedule.new_quest", defaultValue: "New daily quest", bundle: .module) }
        public static var tuneQuest: String { String(localized: "schedule.tune_quest", defaultValue: "Tune your quest", bundle: .module) }
        public static var buildQuestTitle: String { String(localized: "schedule.build_quest_title", defaultValue: "Build a 7-day quest", bundle: .module) }
        public static var buildQuestSubtitle: String { String(localized: "schedule.build_quest_subtitle", defaultValue: "One focused step every day", bundle: .module) }
        public static var goalName: String { String(localized: "schedule.goal_name", defaultValue: "Goal name", bundle: .module) }
        public static var eachStep: String { String(localized: "schedule.each_step", defaultValue: "Each step", bundle: .module) }
        public static var startQuest: String { String(localized: "schedule.start_quest", defaultValue: "Start 7-day quest", bundle: .module) }
        public static var errorTitle: String { String(localized: "schedule.error_title", defaultValue: "Something got in the way", bundle: .module) }
        public static var addTask: String { String(localized: "schedule.add_task", defaultValue: "Add task", bundle: .module) }
        public static var addGoal: String { String(localized: "schedule.add_goal", defaultValue: "7-task goal", bundle: .module) }
    }
}
