import Foundation

public enum L10n {
    public static var currentBundle: Bundle {
        let savedValue = UserDefaults.standard.string(forKey: "app_language") ?? "en"
        let prefix = savedValue.starts(with: "ar") ? "ar" : "en"
        if let path = Bundle.module.path(forResource: prefix, ofType: "lproj"),
           let bundle = Bundle(path: path) {
            return bundle
        }
        return .module
    }

    public enum Common {
        public static var save: String { L10n.currentBundle.localizedString(forKey: "common.save", value: nil, table: "Localizable") }
        public static var cancel: String { L10n.currentBundle.localizedString(forKey: "common.cancel", value: nil, table: "Localizable") }
        public static var `continue`: String {
            L10n.currentBundle.localizedString(forKey: "common.continue", value: nil, table: "Localizable")
        }
        public static var gotIt: String { L10n.currentBundle.localizedString(forKey: "common.got_it", value: nil, table: "Localizable") }
        public static var pleaseTryAgain: String {
            L10n.currentBundle.localizedString(forKey: "common.please_try_again", value: nil, table: "Localizable")
        }
        public static var close: String { L10n.currentBundle.localizedString(forKey: "common.close", value: nil, table: "Localizable") }
        public static var edit: String { L10n.currentBundle.localizedString(forKey: "common.edit", value: nil, table: "Localizable") }
    }

    public enum Onboarding {
        public static var welcomeTitle: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.welcome_title", value: nil, table: "Localizable")
        }
        public static var welcomeSubtitle: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.welcome_subtitle", value: nil, table: "Localizable")
        }
        public static var letsGo: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.lets_go", value: nil, table: "Localizable")
        }
        public static var skipSetup: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.skip_setup", value: nil, table: "Localizable")
        }
        public static var nameTitle: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.name_title", value: nil, table: "Localizable")
        }
        public static var nameSubtitle: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.name_subtitle", value: nil, table: "Localizable")
        }
        public static var firstNameLabel: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.first_name_label", value: nil, table: "Localizable")
        }
        public static var firstNamePlaceholder: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.first_name_placeholder", value: nil, table: "Localizable")
        }
        public static var lastNameLabel: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.last_name_label", value: nil, table: "Localizable")
        }
        public static var lastNamePlaceholder: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.last_name_placeholder", value: nil, table: "Localizable")
        }
        public static var previewLabel: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.preview_label", value: nil, table: "Localizable")
        }
        public static var wakeSleepTitle: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.wake_sleep_title", value: nil, table: "Localizable")
        }
        public static var wakeLabel: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.wake_label", value: nil, table: "Localizable")
        }
        public static var sleepLabel: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.sleep_label", value: nil, table: "Localizable")
        }
        public static var midnightNote: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.midnight_note", value: nil, table: "Localizable")
        }
        public static var zonesTitle: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.zones_title", value: nil, table: "Localizable")
        }
        public static var setManually: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.set_manually", value: nil, table: "Localizable")
        }
        public static var useThis: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.use_this", value: nil, table: "Localizable")
        }
        public static var changeAnytime: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.change_anytime", value: nil, table: "Localizable")
        }
        public static var addZone: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.add_zone", value: nil, table: "Localizable")
        }
        public static var yourDayLabel: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.your_day_label", value: nil, table: "Localizable")
        }
        public static func openSkyHours(_ hours: Int) -> String {
            String(format: L10n.currentBundle.localizedString(forKey: "onboarding.open_sky_hours", value: nil, table: "Localizable"), hours)
        }
        public static var zonesFillNext: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.zones_fill_next", value: nil, table: "Localizable")
        }
        public static var skip: String { L10n.currentBundle.localizedString(forKey: "onboarding.skip", value: nil, table: "Localizable") }
        public static var addZoneTitle: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.add_zone_title", value: nil, table: "Localizable")
        }
        public static var editZone: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.edit_zone", value: nil, table: "Localizable")
        }
        public static var saveZone: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.save_zone", value: nil, table: "Localizable")
        }
        public static var clearSkies: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.clear_skies", value: nil, table: "Localizable")
        }
        public static var nothingScheduled: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.nothing_scheduled", value: nil, table: "Localizable")
        }
        public static var addFirstTask: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.add_first_task", value: nil, table: "Localizable")
        }
        public static func goodMorningName(_ name: String) -> String {
            String(format: L10n.currentBundle.localizedString(forKey: "onboarding.good_morning_name", value: nil, table: "Localizable"), name)
        }
        public static func skySetupZones(_ count: Int) -> String {
            String(format: L10n.currentBundle.localizedString(forKey: "onboarding.sky_setup_zones", value: nil, table: "Localizable"), count)
        }
        public static var outOfBoundsWarning: String { L10n.currentBundle.localizedString(forKey: "onboarding.out_of_bounds_warning", value: nil, table: "Localizable") }
        public static var shortDayWarning: String { L10n.currentBundle.localizedString(forKey: "onboarding.short_day_warning", value: nil, table: "Localizable") }
        public static var zoneStartTime: String { L10n.currentBundle.localizedString(forKey: "onboarding.zone_start_time", value: nil, table: "Localizable") }
        public static var zoneEndTime: String { L10n.currentBundle.localizedString(forKey: "onboarding.zone_end_time", value: nil, table: "Localizable") }
        public static var taskSimulationTitle: String { L10n.currentBundle.localizedString(forKey: "onboarding.task_simulation_title", value: nil, table: "Localizable") }
        public static var taskSimulationSubtitle: String { L10n.currentBundle.localizedString(forKey: "onboarding.task_simulation_subtitle", value: nil, table: "Localizable") }
        public static var taskSimulationPlaceholder: String { L10n.currentBundle.localizedString(forKey: "onboarding.task_simulation_placeholder", value: nil, table: "Localizable") }
        public static var addIt: String { L10n.currentBundle.localizedString(forKey: "onboarding.add_it", value: nil, table: "Localizable") }
        public static var skipForNow: String { L10n.currentBundle.localizedString(forKey: "onboarding.skip_for_now", value: nil, table: "Localizable") }
        public static var zoneNameLabel: String { L10n.currentBundle.localizedString(forKey: "onboarding.zone_name_label", value: nil, table: "Localizable") }
        public static var zoneNamePlaceholder: String { L10n.currentBundle.localizedString(forKey: "onboarding.zone_name_placeholder", value: nil, table: "Localizable") }
        public static func aboutMinutes(_ minutes: Int) -> String {
            String(format: L10n.currentBundle.localizedString(forKey: "onboarding.about_minutes", value: nil, table: "Localizable"), minutes)
        }
        public static func aboutHours(_ hours: Double) -> String {
            String(format: L10n.currentBundle.localizedString(forKey: "onboarding.about_hours", value: nil, table: "Localizable"), hours)
        }
        public static var taskLengthExplanationPrefix: String { L10n.currentBundle.localizedString(forKey: "onboarding.task_length_explanation_prefix", value: nil, table: "Localizable") }
        public static var splitIntoSessions: String { L10n.currentBundle.localizedString(forKey: "onboarding.split_into_sessions", value: nil, table: "Localizable") }
        public static var zoneOverlapError: String { L10n.currentBundle.localizedString(forKey: "onboarding.zone_overlap_error", value: nil, table: "Localizable") }
        public static var howBlocksFeel: String { L10n.currentBundle.localizedString(forKey: "onboarding.how_blocks_feel", value: nil, table: "Localizable") }
        public static var howLongToFocus: String { L10n.currentBundle.localizedString(forKey: "onboarding.how_long_to_focus", value: nil, table: "Localizable") }
        public static var feelBalanced: String { L10n.currentBundle.localizedString(forKey: "onboarding.feel_balanced", value: nil, table: "Localizable") }
        public static var feelDeepFew: String { L10n.currentBundle.localizedString(forKey: "onboarding.feel_deep_few", value: nil, table: "Localizable") }
        public static var feelShortLight: String { L10n.currentBundle.localizedString(forKey: "onboarding.feel_short_light", value: nil, table: "Localizable") }
        public static var preferredFocusBlock: String { L10n.currentBundle.localizedString(forKey: "onboarding.preferred_focus_block", value: nil, table: "Localizable") }
        public static var previewBounce: String { L10n.currentBundle.localizedString(forKey: "onboarding.preview_bounce", value: nil, table: "Localizable") }
        public static var previewLandsInDay: String { L10n.currentBundle.localizedString(forKey: "onboarding.preview_lands_in_day", value: nil, table: "Localizable") }
        public static var previewNew: String { L10n.currentBundle.localizedString(forKey: "onboarding.preview_new", value: nil, table: "Localizable") }
        public static var previewStudy: String { L10n.currentBundle.localizedString(forKey: "onboarding.preview_study", value: nil, table: "Localizable") }
        public static var previewStudyDuration: String { L10n.currentBundle.localizedString(forKey: "onboarding.preview_study_duration", value: nil, table: "Localizable") }
        public static var previewStudyTime: String { L10n.currentBundle.localizedString(forKey: "onboarding.preview_study_time", value: nil, table: "Localizable") }
        public static var zoneColorLabel: String { L10n.currentBundle.localizedString(forKey: "onboarding.zone_color_label", value: nil, table: "Localizable") }
    }

    public enum Login {
        public static var appTitle: String { L10n.currentBundle.localizedString(forKey: "login.app_title", value: nil, table: "Localizable") }
        public static var subtitle: String { L10n.currentBundle.localizedString(forKey: "login.subtitle", value: nil, table: "Localizable") }
        public static var sending: String { L10n.currentBundle.localizedString(forKey: "login.sending", value: nil, table: "Localizable") }
        public static func sendCodeTimer(_ seconds: String) -> String {
            String(format: L10n.currentBundle.localizedString(forKey: "login.send_code_timer", value: nil, table: "Localizable"), seconds)
        }
        public static var sendCode: String { L10n.currentBundle.localizedString(forKey: "login.send_code", value: nil, table: "Localizable") }
        public static var or: String { L10n.currentBundle.localizedString(forKey: "login.or", value: nil, table: "Localizable") }
        public static var signInWithApple: String {
            L10n.currentBundle.localizedString(forKey: "login.sign_in_apple", value: nil, table: "Localizable")
        }
        public static var continueWithGoogle: String {
            L10n.currentBundle.localizedString(forKey: "login.continue_google", value: nil, table: "Localizable")
        }
        public static var footerTermsPrefix: String {
            L10n.currentBundle.localizedString(forKey: "login.footer.terms_prefix", value: nil, table: "Localizable")
        }
        public static var terms: String { L10n.currentBundle.localizedString(forKey: "login.footer.terms", value: nil, table: "Localizable") }
        public static var and: String { L10n.currentBundle.localizedString(forKey: "login.footer.and", value: nil, table: "Localizable") }
        public static var privacy: String {
            L10n.currentBundle.localizedString(forKey: "login.footer.privacy", value: nil, table: "Localizable")
        }
        public static var dot: String { L10n.currentBundle.localizedString(forKey: "login.footer.dot", value: nil, table: "Localizable") }
        public static var emailLabel: String {
            L10n.currentBundle.localizedString(forKey: "login.email_label", value: nil, table: "Localizable")
        }
        public static var emailPrompt: String {
            L10n.currentBundle.localizedString(forKey: "login.email_prompt", value: nil, table: "Localizable")
        }
        public static var offlineError: String {
            L10n.currentBundle.localizedString(forKey: "login.error.offline", value: nil, table: "Localizable")
        }
    }

    public enum OtpVerification {
        public static var title: String { L10n.currentBundle.localizedString(forKey: "otp.title", value: nil, table: "Localizable") }
        public static var subtitle: String { L10n.currentBundle.localizedString(forKey: "otp.subtitle", value: nil, table: "Localizable") }
        public static var verified: String { L10n.currentBundle.localizedString(forKey: "otp.verified", value: nil, table: "Localizable") }
        public static var offlineError: String {
            L10n.currentBundle.localizedString(forKey: "otp.error.offline", value: nil, table: "Localizable")
        }
        public static func resendTimer(_ time: String) -> String {
            String(format: L10n.currentBundle.localizedString(forKey: "otp.resend_timer", value: nil, table: "Localizable"), time)
        }
        public static var resend: String { L10n.currentBundle.localizedString(forKey: "otp.resend", value: nil, table: "Localizable") }
        public static var keypadHint: String {
            L10n.currentBundle.localizedString(forKey: "otp.keypad_hint", value: nil, table: "Localizable")
        }
        public static func digitAccessibility(_ index: Int) -> String {
            String(format: L10n.currentBundle.localizedString(forKey: "otp.digit_accessibility", value: nil, table: "Localizable"), index)
        }
    }

    public enum Schedule {
        public static var questsTitle: String {
            L10n.currentBundle.localizedString(forKey: "schedule.quests_title", value: nil, table: "Localizable")
        }
        public static var streakAccessibility: String {
            L10n.currentBundle.localizedString(forKey: "schedule.streak_accessibility", value: nil, table: "Localizable")
        }
        public static var questChain: String {
            L10n.currentBundle.localizedString(forKey: "schedule.quest_chain", value: nil, table: "Localizable")
        }
        public static var todaysAdventure: String {
            L10n.currentBundle.localizedString(forKey: "schedule.todays_adventure", value: nil, table: "Localizable")
        }
        public static func minutesScheduled(_ minutes: Int) -> String {
            String(
                format: L10n.currentBundle.localizedString(forKey: "schedule.minutes_scheduled", value: nil, table: "Localizable"), minutes)
        }
        public static var thisWeek: String {
            L10n.currentBundle.localizedString(forKey: "schedule.this_week", value: nil, table: "Localizable")
        }
        public static var emptyTitle: String {
            L10n.currentBundle.localizedString(forKey: "schedule.empty_title", value: nil, table: "Localizable")
        }
        public static var emptySubtitle: String {
            L10n.currentBundle.localizedString(forKey: "schedule.empty_subtitle", value: nil, table: "Localizable")
        }
        public static var yourTime: String {
            L10n.currentBundle.localizedString(forKey: "schedule.your_time", value: nil, table: "Localizable")
        }
        public static var dragHintAccessibility: String {
            L10n.currentBundle.localizedString(forKey: "schedule.drag_hint_accessibility", value: nil, table: "Localizable")
        }
        public static var questName: String {
            L10n.currentBundle.localizedString(forKey: "schedule.quest_name", value: nil, table: "Localizable")
        }
        public static var questNamePlaceholder: String {
            L10n.currentBundle.localizedString(forKey: "schedule.quest_name_placeholder", value: nil, table: "Localizable")
        }
        public static var duration: String {
            L10n.currentBundle.localizedString(forKey: "schedule.duration", value: nil, table: "Localizable")
        }
        public static func durationMinutes(_ minutes: Int) -> String {
            String(format: L10n.currentBundle.localizedString(forKey: "schedule.duration_minutes", value: nil, table: "Localizable"), minutes)
        }
        public static var zone: String { L10n.currentBundle.localizedString(forKey: "schedule.zone", value: nil, table: "Localizable") }
        public static var standalone: String {
            L10n.currentBundle.localizedString(forKey: "schedule.standalone", value: nil, table: "Localizable")
        }
        public static var chooseZone: String {
            L10n.currentBundle.localizedString(forKey: "schedule.choose_zone", value: nil, table: "Localizable")
        }
        public static var canSplit: String {
            L10n.currentBundle.localizedString(forKey: "schedule.can_split", value: nil, table: "Localizable")
        }
        public static var keepFixed: String {
            L10n.currentBundle.localizedString(forKey: "schedule.keep_fixed", value: nil, table: "Localizable")
        }
        public static var createQuest: String {
            L10n.currentBundle.localizedString(forKey: "schedule.create_quest", value: nil, table: "Localizable")
        }
        public static var saveChanges: String {
            L10n.currentBundle.localizedString(forKey: "schedule.save_changes", value: nil, table: "Localizable")
        }
        public static var deleteQuest: String {
            L10n.currentBundle.localizedString(forKey: "schedule.delete_quest", value: nil, table: "Localizable")
        }
        public static var newQuest: String {
            L10n.currentBundle.localizedString(forKey: "schedule.new_quest", value: nil, table: "Localizable")
        }
        public static var tuneQuest: String {
            L10n.currentBundle.localizedString(forKey: "schedule.tune_quest", value: nil, table: "Localizable")
        }
        public static var buildQuestTitle: String {
            L10n.currentBundle.localizedString(forKey: "schedule.build_quest_title", value: nil, table: "Localizable")
        }
        public static var buildQuestSubtitle: String {
            L10n.currentBundle.localizedString(forKey: "schedule.build_quest_subtitle", value: nil, table: "Localizable")
        }
        public static var goalName: String {
            L10n.currentBundle.localizedString(forKey: "schedule.goal_name", value: nil, table: "Localizable")
        }
        public static var eachStep: String {
            L10n.currentBundle.localizedString(forKey: "schedule.each_step", value: nil, table: "Localizable")
        }
        public static var startQuest: String {
            L10n.currentBundle.localizedString(forKey: "schedule.start_quest", value: nil, table: "Localizable")
        }
        public static var errorTitle: String {
            L10n.currentBundle.localizedString(forKey: "schedule.error_title", value: nil, table: "Localizable")
        }
        public static var addTask: String {
            L10n.currentBundle.localizedString(forKey: "schedule.add_task", value: nil, table: "Localizable")
        }
        public static var addGoal: String {
            L10n.currentBundle.localizedString(forKey: "schedule.add_goal", value: nil, table: "Localizable")
        }
    }

    public enum Home {
        public static var addTask: String { L10n.currentBundle.localizedString(forKey: "home.add_task", value: nil, table: "Localizable") }
        public static var addGoal: String { L10n.currentBundle.localizedString(forKey: "home.add_goal", value: nil, table: "Localizable") }
        public static var goodMorning: String {
            L10n.currentBundle.localizedString(forKey: "home.good_morning", value: nil, table: "Localizable")
        }
        public static var goodAfternoon: String {
            L10n.currentBundle.localizedString(forKey: "home.good_afternoon", value: nil, table: "Localizable")
        }
        public static var goodEvening: String {
            L10n.currentBundle.localizedString(forKey: "home.good_evening", value: nil, table: "Localizable")
        }
        public static var todaysPlan: String {
            L10n.currentBundle.localizedString(forKey: "home.todays_plan", value: nil, table: "Localizable")
        }
        public static func taskScheduleSummary(_ tasks: Int, _ duration: String) -> String {
            String(
                format: L10n.currentBundle.localizedString(
                    forKey: tasks == 1 ? "home.task_schedule_summary_one" : "home.task_schedule_summary",
                    value: nil,
                    table: "Localizable"
                ),
                tasks,
                duration
            )
        }
        public static func completionSummary(_ completed: Int, _ total: Int) -> String {
            String(
                format: L10n.currentBundle.localizedString(forKey: "home.completion_summary", value: nil, table: "Localizable"),
                completed,
                total
            )
        }
        public static func minutesShort(_ minutes: Int) -> String {
            String(format: L10n.currentBundle.localizedString(forKey: "home.minutes_short", value: nil, table: "Localizable"), minutes)
        }
        public static func hoursShort(_ hours: Int) -> String {
            String(format: L10n.currentBundle.localizedString(forKey: "home.hours_short", value: nil, table: "Localizable"), hours)
        }
        public static func hoursMinutesShort(_ hours: Int, _ minutes: Int) -> String {
            String(
                format: L10n.currentBundle.localizedString(forKey: "home.hours_minutes_short", value: nil, table: "Localizable"),
                hours,
                minutes
            )
        }
        public static var fixed: String { L10n.currentBundle.localizedString(forKey: "home.fixed", value: nil, table: "Localizable") }
        public static var emptyTimelineSubtitle: String {
            L10n.currentBundle.localizedString(forKey: "home.empty_timeline_subtitle", value: nil, table: "Localizable")
        }
        public static var errorTitle: String {
            L10n.currentBundle.localizedString(forKey: "home.error_title", value: nil, table: "Localizable")
        }
        public static var loadFailed: String {
            L10n.currentBundle.localizedString(forKey: "home.load_failed", value: nil, table: "Localizable")
        }
        public static var retry: String { L10n.currentBundle.localizedString(forKey: "home.retry", value: nil, table: "Localizable") }
        public static var startTime: String {
            L10n.currentBundle.localizedString(forKey: "home.start_time", value: nil, table: "Localizable")
        }
        public static var reschedule: String {
            L10n.currentBundle.localizedString(forKey: "home.reschedule", value: nil, table: "Localizable")
        }
        public static var lockSession: String {
            L10n.currentBundle.localizedString(forKey: "home.lock_session", value: nil, table: "Localizable")
        }
        public static var unlockSession: String {
            L10n.currentBundle.localizedString(forKey: "home.unlock_session", value: nil, table: "Localizable")
        }
        public static var deleteSession: String {
            L10n.currentBundle.localizedString(forKey: "home.delete_session", value: nil, table: "Localizable")
        }
        public static var deleteSessionConfirmation: String {
            L10n.currentBundle.localizedString(forKey: "home.delete_session_confirmation", value: nil, table: "Localizable")
        }
        public static var taskDetails: String {
            L10n.currentBundle.localizedString(forKey: "home.task_details", value: nil, table: "Localizable")
        }
        public static var description: String {
            L10n.currentBundle.localizedString(forKey: "home.description", value: nil, table: "Localizable")
        }
        public static var status: String {
            L10n.currentBundle.localizedString(forKey: "home.status", value: nil, table: "Localizable")
        }
        public static var duration: String {
            L10n.currentBundle.localizedString(forKey: "home.duration", value: nil, table: "Localizable")
        }
        public static var points: String {
            L10n.currentBundle.localizedString(forKey: "home.points", value: nil, table: "Localizable")
        }
        public static func pointsValue(_ points: Int) -> String {
            String(
                format: L10n.currentBundle.localizedString(
                    forKey: "home.points_value",
                    value: nil,
                    table: "Localizable"
                ),
                points
            )
        }
        public static var mandatory: String {
            L10n.currentBundle.localizedString(forKey: "home.mandatory", value: nil, table: "Localizable")
        }
        public static var canSplit: String {
            L10n.currentBundle.localizedString(forKey: "home.can_split", value: nil, table: "Localizable")
        }
        public static var yes: String {
            L10n.currentBundle.localizedString(forKey: "home.yes", value: nil, table: "Localizable")
        }
        public static var no: String {
            L10n.currentBundle.localizedString(forKey: "home.no", value: nil, table: "Localizable")
        }
        public static var statusPending: String {
            L10n.currentBundle.localizedString(forKey: "home.status_pending", value: nil, table: "Localizable")
        }
        public static var statusInProgress: String {
            L10n.currentBundle.localizedString(forKey: "home.status_in_progress", value: nil, table: "Localizable")
        }
        public static var statusCompleted: String {
            L10n.currentBundle.localizedString(forKey: "home.status_completed", value: nil, table: "Localizable")
        }
        public static var statusCancelled: String {
            L10n.currentBundle.localizedString(forKey: "home.status_cancelled", value: nil, table: "Localizable")
        }
        public static var today: String { L10n.currentBundle.localizedString(forKey: "home.today", value: nil, table: "Localizable") }
        public static var calendar: String { L10n.currentBundle.localizedString(forKey: "home.calendar", value: nil, table: "Localizable") }
        public static var rewards: String { L10n.currentBundle.localizedString(forKey: "home.rewards", value: nil, table: "Localizable") }
        public static var you: String { L10n.currentBundle.localizedString(forKey: "home.you", value: nil, table: "Localizable") }
    }

    public enum Profile {
        public static var title: String { L10n.currentBundle.localizedString(forKey: "profile.title", value: nil, table: "Localizable") }
        public static var personalInfo: String {
            L10n.currentBundle.localizedString(forKey: "profile.personal_info", value: nil, table: "Localizable")
        }
        public static var dailyZones: String {
            L10n.currentBundle.localizedString(forKey: "profile.daily_zones", value: nil, table: "Localizable")
        }
        public static var setRhythm: String {
            L10n.currentBundle.localizedString(forKey: "profile.set_rhythm", value: nil, table: "Localizable")
        }
        public static func zonesToday(_ count: Int) -> String {
            String(format: L10n.currentBundle.localizedString(forKey: "profile.zones_today", value: nil, table: "Localizable"), count)
        }
        public static var preferences: String {
            L10n.currentBundle.localizedString(forKey: "profile.preferences", value: nil, table: "Localizable")
        }
        public static var appearanceTitle: String {
            L10n.currentBundle.localizedString(forKey: "profile.appearance", value: "Appearance", table: "Localizable")
        }
        public static var appearanceLight: String {
            L10n.currentBundle.localizedString(forKey: "profile.appearance_light", value: "Light", table: "Localizable")
        }
        public static var appearanceDark: String {
            L10n.currentBundle.localizedString(forKey: "profile.appearance_dark", value: "Dark", table: "Localizable")
        }
        public static var appearanceSystem: String {
            L10n.currentBundle.localizedString(forKey: "profile.appearance_system", value: "System", table: "Localizable")
        }
        public static var sessionTime: String {
            L10n.currentBundle.localizedString(forKey: "profile.session_time", value: nil, table: "Localizable")
        }
        public static var timeZone: String {
            L10n.currentBundle.localizedString(forKey: "profile.time_zone", value: nil, table: "Localizable")
        }
        public static var sleepSchedule: String {
            L10n.currentBundle.localizedString(forKey: "profile.sleep_schedule", value: nil, table: "Localizable")
        }
        public static var languageAndAppearance: String {
            L10n.currentBundle.localizedString(forKey: "profile.language_and_appearance", value: nil, table: "Localizable")
        }
        public static var language: String {
            L10n.currentBundle.localizedString(forKey: "profile.language", value: nil, table: "Localizable")
        }
        public static var languageEnglish: String {
            L10n.currentBundle.localizedString(forKey: "profile.language.english", value: nil, table: "Localizable")
        }
        public static var languageArabic: String {
            L10n.currentBundle.localizedString(forKey: "profile.language.arabic", value: nil, table: "Localizable")
        }
        public static var languageSelectionTitle: String {
            L10n.currentBundle.localizedString(forKey: "profile.language_selection_title", value: nil, table: "Localizable")
        }
        public static var theme: String { L10n.currentBundle.localizedString(forKey: "profile.theme", value: nil, table: "Localizable") }
        public static var light: String { L10n.currentBundle.localizedString(forKey: "profile.light", value: nil, table: "Localizable") }
        public static var dark: String { L10n.currentBundle.localizedString(forKey: "profile.dark", value: nil, table: "Localizable") }
        public static var system: String { L10n.currentBundle.localizedString(forKey: "profile.system", value: nil, table: "Localizable") }
        

        public static var dummySessionTime: String { L10n.currentBundle.localizedString(forKey: "profile.dummy_session_time", value: nil, table: "Localizable") }
        public static var dummyTimeZone: String { L10n.currentBundle.localizedString(forKey: "profile.dummy_time_zone", value: nil, table: "Localizable") }
        public static var dummySleepSchedule: String { L10n.currentBundle.localizedString(forKey: "profile.dummy_sleep_schedule", value: nil, table: "Localizable") }
        public static var ready: String { L10n.currentBundle.localizedString(forKey: "profile.ready", value: nil, table: "Localizable") }
    }
}
