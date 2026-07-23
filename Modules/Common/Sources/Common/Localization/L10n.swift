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
        public static var splitIntoSessions: String { String(localized: "onboarding.split_into_sessions", bundle: .module) }
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
        public static var taskSimulationTitle: String { String(localized: "onboarding.task_simulation_title", bundle: .module) }
        public static var taskSimulationSubtitle: String { String(localized: "onboarding.task_simulation_subtitle", bundle: .module) }
        public static var taskSimulationPlaceholder: String { String(localized: "onboarding.task_simulation_placeholder", bundle: .module) }
        public static var skipForNow: String { String(localized: "onboarding.skip_for_now", bundle: .module) }
        public static var addIt: String { String(localized: "onboarding.add_it", bundle: .module) }
        
        public static var previewLandsInDay: String { String(localized: "onboarding.preview_lands_in_day", bundle: .module) }
        public static var previewStudy: String { String(localized: "onboarding.preview_study", bundle: .module) }
        public static var previewStudyTime: String { String(localized: "onboarding.preview_study_time", bundle: .module) }
        public static var previewStudyDuration: String { String(localized: "onboarding.preview_study_duration", bundle: .module) }
        public static var previewNew: String { String(localized: "onboarding.preview_new", bundle: .module) }
        public static var previewBounce: String { String(localized: "onboarding.preview_bounce", bundle: .module) }

        public static var outOfBoundsWarning: String { String(localized: "onboarding.out_of_bounds_warning", bundle: .module) }
        public static var shortDayWarning: String { String(localized: "onboarding.short_day_warning", bundle: .module) }
        public static var editZone: String { String(localized: "onboarding.edit_zone", bundle: .module) }
        
        public static var clearSkies: String { String(localized: "onboarding.clear_skies", bundle: .module) }
        public static var nothingScheduled: String { String(localized: "onboarding.nothing_scheduled", bundle: .module) }
        public static var preferredFocusBlock: String { String(localized: "onboarding.preferred_focus_block", bundle: .module) }
        
        public static func goodMorningName(_ name: String) -> String { String(format: String(localized: "onboarding.good_morning_name", bundle: .module), name) }
        public static func skySetupZones(_ count: Int) -> String { String(format: String(localized: "onboarding.sky_setup_zones", bundle: .module), count) }
        
        public static var howBlocksFeel: String { String(localized: "onboarding.how_blocks_feel", bundle: .module) }
        public static var howLongToFocus: String { String(localized: "onboarding.how_long_to_focus", bundle: .module) }
        public static var takeLargerTasks: String { String(localized: "onboarding.take_larger_tasks", bundle: .module) }
        public static var taskLengthExplanationPrefix: String { String(localized: "onboarding.task_length_explanation_prefix", bundle: .module) }
        public static func aboutMinutes(_ minutes: Int) -> String { String(format: String(localized: "onboarding.about_minutes", bundle: .module), minutes) }
        public static func aboutHours(_ hours: Double) -> String { String(format: String(localized: "onboarding.about_hours", bundle: .module), hours) }
        
        public static var addFirstTask: String { String(localized: "onboarding.add_first_task", bundle: .module) }
        public static var saveZone: String { String(localized: "onboarding.save_zone", bundle: .module) }
        public static var feelShortLight: String { String(localized: "onboarding.feel_short_light", bundle: .module) }
        public static var feelBalanced: String { String(localized: "onboarding.feel_balanced", bundle: .module) }
        public static var feelDeepFew: String { String(localized: "onboarding.feel_deep_few", bundle: .module) }
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

    public enum Home {
        public static var addTask: String { String(localized: "home.add_task", bundle: .module) }
        public static var addGoal: String { String(localized: "home.add_goal", bundle: .module) }
        public static var goodMorning: String { String(localized: "home.good_morning", bundle: .module) }
        public static var goodAfternoon: String { String(localized: "home.good_afternoon", bundle: .module) }
        public static var goodEvening: String { String(localized: "home.good_evening", bundle: .module) }
        public static var todaysPlan: String { String(localized: "home.todays_plan", bundle: .module) }
        public static func taskScheduleSummary(_ tasks: Int, _ duration: String) -> String {
            String(
                format: String(
                    localized: tasks == 1
                        ? "home.task_schedule_summary_one"
                        : "home.task_schedule_summary",
                    bundle: .module
                ),
                tasks,
                duration
            )
        }
        public static func completionSummary(_ completed: Int, _ total: Int) -> String {
            String(
                format: String(localized: "home.completion_summary", bundle: .module),
                completed,
                total
            )
        }
        public static func minutesShort(_ minutes: Int) -> String {
            String(format: String(localized: "home.minutes_short", bundle: .module), minutes)
        }
        public static func hoursShort(_ hours: Int) -> String {
            String(format: String(localized: "home.hours_short", bundle: .module), hours)
        }
        public static func hoursMinutesShort(_ hours: Int, _ minutes: Int) -> String {
            String(
                format: String(localized: "home.hours_minutes_short", bundle: .module),
                hours,
                minutes
            )
        }
        public static var fixed: String { String(localized: "home.fixed", bundle: .module) }
        public static var emptyTimelineSubtitle: String { String(localized: "home.empty_timeline_subtitle", bundle: .module) }
        public static var errorTitle: String { String(localized: "home.error_title", bundle: .module) }
        public static var loadFailed: String { String(localized: "home.load_failed", bundle: .module) }
        public static var retry: String { String(localized: "home.retry", bundle: .module) }
        public static var startTime: String { String(localized: "home.start_time", bundle: .module) }
        public static var reschedule: String { String(localized: "home.reschedule", bundle: .module) }
        public static var lockSession: String { String(localized: "home.lock_session", bundle: .module) }
        public static var unlockSession: String { String(localized: "home.unlock_session", bundle: .module) }
        public static var deleteSession: String { String(localized: "home.delete_session", bundle: .module) }
        public static var deleteSessionConfirmation: String { String(localized: "home.delete_session_confirmation", bundle: .module) }
        public static var today: String { String(localized: "home.today", bundle: .module) }
        public static var calendar: String { String(localized: "home.calendar", bundle: .module) }
        public static var rewards: String { String(localized: "home.rewards", bundle: .module) }
        public static var you: String { String(localized: "home.you", bundle: .module) }
    }
}
