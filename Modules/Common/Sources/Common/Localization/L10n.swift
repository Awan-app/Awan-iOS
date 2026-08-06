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
        public static var wakeSleepSameTimeError: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.wake_sleep_same_time_error", value: nil, table: "Localizable")
        }
        public static var shortActiveDayWarning: String {
            L10n.currentBundle.localizedString(forKey: "onboarding.short_active_day_warning", value: nil, table: "Localizable")
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
        public static var category: String {
            L10n.currentBundle.localizedString(forKey: "schedule.category", value: nil, table: "Localizable")
        }
        public static var standalone: String {
            L10n.currentBundle.localizedString(forKey: "schedule.standalone", value: nil, table: "Localizable")
        }
        public static var chooseZone: String {
            L10n.currentBundle.localizedString(forKey: "schedule.choose_zone", value: nil, table: "Localizable")
        }
        public static var chooseCategory: String {
            L10n.currentBundle.localizedString(forKey: "schedule.choose_category", value: nil, table: "Localizable")
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

    public enum GoalCreation {
        public static var header: String {
            L10n.currentBundle.localizedString(
                forKey: "goal_creation.header",
                value: nil,
                table: "Localizable"
            )
        }

        public static var headline: String {
            L10n.currentBundle.localizedString(
                forKey: "goal_creation.headline",
                value: nil,
                table: "Localizable"
            )
        }

        public static var caption: String {
            L10n.currentBundle.localizedString(
                forKey: "goal_creation.caption",
                value: nil,
                table: "Localizable"
            )
        }

        public static var promptPlaceholder: String {
            L10n.currentBundle.localizedString(
                forKey: "goal_creation.prompt_placeholder",
                value: nil,
                table: "Localizable"
            )
        }

        public static var sendPrompt: String {
            L10n.currentBundle.localizedString(
                forKey: "goal_creation.send_prompt",
                value: nil,
                table: "Localizable"
            )
        }

        public static var planning: String {
            value("goal_creation.planning")
        }

        public static var scheduling: String {
            value("goal_creation.scheduling")
        }

        public static var replyPlaceholder: String {
            value("goal_creation.reply_placeholder")
        }

        public static var modifyPlaceholder: String {
            value("goal_creation.modify_placeholder")
        }

        public static var sessions: String {
            value("goal_creation.sessions")
        }

        public static var oneSession: String {
            value("goal_creation.one_session")
        }

        public static var confirm: String {
            value("goal_creation.confirm")
        }

        private static func value(_ key: String) -> String {
            L10n.currentBundle.localizedString(
                forKey: key,
                value: nil,
                table: "Localizable"
            )
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
        public static var addTaskTitle: String {
            L10n.currentBundle.localizedString(forKey: "home.add_task_title", value: nil, table: "Localizable")
        }

        public static var tabWithAwan: String {
            L10n.currentBundle.localizedString(forKey: "home.tab_with_awan", value: nil, table: "Localizable")
        }

        public static var tabManual: String {
            L10n.currentBundle.localizedString(forKey: "home.tab_manual", value: nil, table: "Localizable")
        }

        public static var quickAddHeader: String {
            L10n.currentBundle.localizedString(forKey: "home.quick_add_header", value: nil, table: "Localizable")
        }

        public static var quickAddHeadline: String {
            L10n.currentBundle.localizedString(forKey: "home.quick_add_headline", value: nil, table: "Localizable")
        }

        public static var quickAddCaption: String {
            L10n.currentBundle.localizedString(forKey: "home.quick_add_caption", value: nil, table: "Localizable")
        }

        public static var manualAddHeader: String {
            L10n.currentBundle.localizedString(forKey: "home.manual_add_header", value: nil, table: "Localizable")
        }

        public static var manualAddHeadline: String {
            L10n.currentBundle.localizedString(forKey: "home.manual_add_headline", value: nil, table: "Localizable")
        }

        public static var manualAddCaption: String {
            L10n.currentBundle.localizedString(forKey: "home.manual_add_caption", value: nil, table: "Localizable")
        }

        public static var fieldTask: String {
            L10n.currentBundle.localizedString(forKey: "home.field_task", value: nil, table: "Localizable")
        }

        public static var orSeparator: String {
            L10n.currentBundle.localizedString(forKey: "home.or_separator", value: nil, table: "Localizable")
        }

        public static var tellAwan: String {
            L10n.currentBundle.localizedString(forKey: "home.tell_awan", value: nil, table: "Localizable")
        }

        public static var tapToSpeak: String {
            L10n.currentBundle.localizedString(forKey: "home.tap_to_speak", value: nil, table: "Localizable")
        }

        public static var listeningState: String {
            L10n.currentBundle.localizedString(forKey: "home.listening_state", value: nil, table: "Localizable")
        }

        public static var chipSmartDuration: String {
            L10n.currentBundle.localizedString(forKey: "home.chip_smart_duration", value: nil, table: "Localizable")
        }

        public static var chipBestZone: String {
            L10n.currentBundle.localizedString(forKey: "home.chip_best_zone", value: nil, table: "Localizable")
        }

        public static var chipAutoScheduled: String {
            L10n.currentBundle.localizedString(forKey: "home.chip_auto_scheduled", value: nil, table: "Localizable")
        }

        public static var btnPlanItForMe: String {
            L10n.currentBundle.localizedString(forKey: "home.btn_plan_it_for_me", value: nil, table: "Localizable")
        }

        public static var fieldDescription: String {
            L10n.currentBundle.localizedString(forKey: "home.field_description", value: nil, table: "Localizable")
        }

        public static var fieldDescriptionPlaceholder: String {
            L10n.currentBundle.localizedString(forKey: "home.field_description_placeholder", value: nil, table: "Localizable")
        }

        public static var fieldStartsAt: String {
            L10n.currentBundle.localizedString(forKey: "home.field_starts_at", value: nil, table: "Localizable")
        }

        public static var fieldStartsAtHint: String {
            L10n.currentBundle.localizedString(forKey: "home.field_starts_at_hint", value: nil, table: "Localizable")
        }

        public static func stepperHours(_ hours: Int) -> String {
            String(
                format: L10n.currentBundle.localizedString(
                    forKey: "home.stepper_hours",
                    value: nil,
                    table: "Localizable"
                ),
                hours
            )
        }

        public static var toggleMandatory: String {
            L10n.currentBundle.localizedString(forKey: "home.toggle_mandatory", value: nil, table: "Localizable")
        }

        public static var toggleAllowSplitting: String {
            L10n.currentBundle.localizedString(forKey: "home.toggle_allow_splitting", value: nil, table: "Localizable")
        }

        public static var btnAddManualTask: String {
            L10n.currentBundle.localizedString(forKey: "home.btn_add_manual_task", value: nil, table: "Localizable")
        }

        public static var aiCreatingTask: String {
            L10n.currentBundle.localizedString(forKey: "home.ai_creating_task", value: nil, table: "Localizable")
        }

        public static var aiTaskCreated: String {
            L10n.currentBundle.localizedString(forKey: "home.ai_task_created", value: nil, table: "Localizable")
        }

        public static var aiTaskError: String {
            L10n.currentBundle.localizedString(forKey: "home.ai_task_error", value: nil, table: "Localizable")
        }

        public static var aiTaskResultTitle: String {
            L10n.currentBundle.localizedString(forKey: "home.ai_task_result_title", value: nil, table: "Localizable")
        }

        public static var aiTaskCategory: String {
            L10n.currentBundle.localizedString(forKey: "home.ai_task_category", value: nil, table: "Localizable")
        }

        public static var imageToTasksTitle: String {
            L10n.currentBundle.localizedString(forKey: "home.image_to_tasks_title", value: nil, table: "Localizable")
        }

        public static var imageSourceSummaryTitle: String {
            L10n.currentBundle.localizedString(forKey: "home.image_source_summary_title", value: nil, table: "Localizable")
        }

        public static var imageUploading: String {
            L10n.currentBundle.localizedString(forKey: "home.image_uploading", value: nil, table: "Localizable")
        }

        public static var imageReading: String {
            L10n.currentBundle.localizedString(forKey: "home.image_reading", value: nil, table: "Localizable")
        }

        public static var imageAnalyzing: String {
            L10n.currentBundle.localizedString(forKey: "home.image_analyzing", value: nil, table: "Localizable")
        }

        public static var imageNoTasks: String {
            L10n.currentBundle.localizedString(forKey: "home.image_no_tasks", value: nil, table: "Localizable")
        }

        public static var proposedTasksConfirm: String {
            L10n.currentBundle.localizedString(forKey: "home.proposed_tasks_confirm", value: nil, table: "Localizable")
        }

        public static var proposedTaskFixedSession: String {
            L10n.currentBundle.localizedString(forKey: "home.proposed_task_fixed_session", value: nil, table: "Localizable")
        }

        public static var proposedTaskAiSession: String {
            L10n.currentBundle.localizedString(forKey: "home.proposed_task_ai_session", value: nil, table: "Localizable")
        }

        public static var proposedTaskReason: String {
            L10n.currentBundle.localizedString(forKey: "home.proposed_task_reason", value: nil, table: "Localizable")
        }

        public static var proposedTaskUnassigned: String {
            L10n.currentBundle.localizedString(forKey: "home.proposed_task_unassigned", value: nil, table: "Localizable")
        }

        public static var pickImageFromLibrary: String {
            L10n.currentBundle.localizedString(forKey: "home.pick_image_from_library", value: nil, table: "Localizable")
        }

        public static var pickImageFromCamera: String {
            L10n.currentBundle.localizedString(forKey: "home.pick_image_from_camera", value: nil, table: "Localizable")
        }

        public static var imageToTasksNotePlaceholder: String {
            L10n.currentBundle.localizedString(forKey: "home.image_to_tasks_note_placeholder", value: nil, table: "Localizable")
        }

        public static var addToInbox: String {
            L10n.currentBundle.localizedString(forKey: "home.add_to_inbox", value: nil, table: "Localizable")
        }

        public static var addSchedule: String {
            L10n.currentBundle.localizedString(forKey: "home.add_schedule", value: nil, table: "Localizable")
        }

        public static var editSessionSchedule: String {
            L10n.currentBundle.localizedString(forKey: "home.edit_session_schedule", value: nil, table: "Localizable")
        }

        public static var invalidSessionTimeRange: String {
            L10n.currentBundle.localizedString(forKey: "home.invalid_session_time_range", value: nil, table: "Localizable")
        }

        public static func scheduleSelectedCount(_ count: Int) -> String {
            String(
                format: L10n.currentBundle.localizedString(
                    forKey: "home.schedule_selected_count",
                    value: nil,
                    table: "Localizable"
                ),
                count
            )
        }

        public static var sessionStart: String {
            L10n.currentBundle.localizedString(forKey: "home.session_start", value: nil, table: "Localizable")
        }

        public static var sessionEnd: String {
            L10n.currentBundle.localizedString(forKey: "home.session_end", value: nil, table: "Localizable")
        }

        public static var sessionDay: String {
            L10n.currentBundle.localizedString(forKey: "home.session_day", value: nil, table: "Localizable")
        }

        public static func sessionTodayAt(_ time: String) -> String {
            String(
                format: L10n.currentBundle.localizedString(
                    forKey: "home.session_today_at",
                    value: nil,
                    table: "Localizable"
                ),
                time
            )
        }

        public static func sessionTomorrowAt(_ time: String) -> String {
            String(
                format: L10n.currentBundle.localizedString(
                    forKey: "home.session_tomorrow_at",
                    value: nil,
                    table: "Localizable"
                ),
                time
            )
        }

        public static var setSchedule: String {
            L10n.currentBundle.localizedString(forKey: "home.set_schedule", value: nil, table: "Localizable")
        }

        public static var time: String {
            L10n.currentBundle.localizedString(forKey: "home.time", value: nil, table: "Localizable")
        }

        public static func confirmAcceptCount(_ count: Int) -> String {
            String(format: L10n.currentBundle.localizedString(forKey: "home.confirm_accept_count", value: nil, table: "Localizable"), count)
        }

        public static var endTime: String {
            L10n.currentBundle.localizedString(forKey: "home.end_time", value: nil, table: "Localizable")
        }

        public static var buildItYourWay: String {
            L10n.currentBundle.localizedString(forKey: "home.build_it_your_way", value: nil, table: "Localizable")
        }
        public static var bedtime: String {
            L10n.currentBundle.localizedString(forKey: "home.bedtime", value: nil, table: "Localizable")
        }

        public static var estimatedDuration: String {
            L10n.currentBundle.localizedString(forKey: "home.estimated_duration", value: nil, table: "Localizable")
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
        public static var wakeUp: String {
            L10n.currentBundle.localizedString(forKey: "home.wake_up", value: nil, table: "Localizable")
        }
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

    public enum CalendarScreen {
        public static var activeGoals: String {
            L10n.currentBundle.localizedString(
                forKey: "calendar.active_goals",
                value: nil,
                table: "Localizable"
            )
        }
        public static var back: String {
            L10n.currentBundle.localizedString(
                forKey: "calendar.back",
                value: nil,
                table: "Localizable"
            )
        }
        public static var emptyTitle: String {
            L10n.currentBundle.localizedString(
                forKey: "calendar.empty_title",
                value: nil,
                table: "Localizable"
            )
        }
        public static var emptyMessage: String {
            L10n.currentBundle.localizedString(
                forKey: "calendar.empty_message",
                value: nil,
                table: "Localizable"
            )
        }
        public static var hasDeadline: String {
            L10n.currentBundle.localizedString(
                forKey: "calendar.has_deadline",
                value: nil,
                table: "Localizable"
            )
        }
        public static var dueToday: String {
            L10n.currentBundle.localizedString(
                forKey: "calendar.due_today",
                value: nil,
                table: "Localizable"
            )
        }
        public static var oneDayLeft: String {
            L10n.currentBundle.localizedString(
                forKey: "calendar.one_day_left",
                value: nil,
                table: "Localizable"
            )
        }
        public static func daysLeft(_ formattedCount: String) -> String {
            String(
                format: L10n.currentBundle.localizedString(
                    forKey: "calendar.days_left",
                    value: nil,
                    table: "Localizable"
                ),
                formattedCount
            )
        }
        public static var noDeadline: String {
            L10n.currentBundle.localizedString(
                forKey: "calendar.no_deadline",
                value: nil,
                table: "Localizable"
            )
        }
        public static var jumpToPresent: String {
            L10n.currentBundle.localizedString(
                forKey: "calendar.jump_to_present",
                value: nil,
                table: "Localizable"
            )
        }
        public static var previousMonth: String {
            L10n.currentBundle.localizedString(
                forKey: "calendar.previous_month",
                value: nil,
                table: "Localizable"
            )
        }
        public static var nextMonth: String {
            L10n.currentBundle.localizedString(
                forKey: "calendar.next_month",
                value: nil,
                table: "Localizable"
            )
        }
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
        public static var logout: String { L10n.currentBundle.localizedString(forKey: "profile.logout", value: nil, table: "Localizable") }
        public static var logoutConfirmationMessage: String { L10n.currentBundle.localizedString(forKey: "profile.logout_confirmation_message", value: nil, table: "Localizable") }
        
        public static var dummySessionTime: String { L10n.currentBundle.localizedString(forKey: "profile.dummy_session_time", value: nil, table: "Localizable") }
        public static var dummyTimeZone: String { L10n.currentBundle.localizedString(forKey: "profile.dummy_time_zone", value: nil, table: "Localizable") }
        public static var dummySleepSchedule: String { L10n.currentBundle.localizedString(forKey: "profile.dummy_sleep_schedule", value: nil, table: "Localizable") }
        public static var ready: String { L10n.currentBundle.localizedString(forKey: "profile.ready", value: nil, table: "Localizable") }
    }

    public enum UserInfo {
        public static var title: String { L10n.currentBundle.localizedString(forKey: "user_info.title", value: nil, table: "Localizable") }
        public static var subtitle: String { L10n.currentBundle.localizedString(forKey: "user_info.subtitle", value: nil, table: "Localizable") }
        public static var personalInfo: String { L10n.currentBundle.localizedString(forKey: "user_info.personal_info", value: nil, table: "Localizable") }
        public static var firstName: String { L10n.currentBundle.localizedString(forKey: "user_info.first_name", value: nil, table: "Localizable") }
        public static var lastName: String { L10n.currentBundle.localizedString(forKey: "user_info.last_name", value: nil, table: "Localizable") }
        public static var email: String { L10n.currentBundle.localizedString(forKey: "user_info.email", value: nil, table: "Localizable") }
        public static var dateOfBirth: String { L10n.currentBundle.localizedString(forKey: "user_info.date_of_birth", value: nil, table: "Localizable") }
        public static func mascotMessage(_ name: String) -> String { String(format: L10n.currentBundle.localizedString(forKey: "user_info.mascot_message", value: nil, table: "Localizable"), name) }
    }

    public enum Templates {
        public static var dailyZonesTitle: String { L10n.currentBundle.localizedString(forKey: "templates.daily_zones_title", value: nil, table: "Localizable") }
        public static func saveDay(_ day: String) -> String { String(format: L10n.currentBundle.localizedString(forKey: "templates.save_day", value: nil, table: "Localizable"), day) }
        public static var day: String { L10n.currentBundle.localizedString(forKey: "templates.day", value: nil, table: "Localizable") }
        public static var sectionTitle: String { L10n.currentBundle.localizedString(forKey: "templates.section_title", value: nil, table: "Localizable") }
        public static var newButton: String { L10n.currentBundle.localizedString(forKey: "templates.new_button", value: nil, table: "Localizable") }
        public static var selectedBadge: String { L10n.currentBundle.localizedString(forKey: "templates.selected_badge", value: nil, table: "Localizable") }
        public static var activeDaysTitle: String { L10n.currentBundle.localizedString(forKey: "templates.active_days_title", value: nil, table: "Localizable") }
        public static var activeDaysSubtitle: String { L10n.currentBundle.localizedString(forKey: "templates.active_days_subtitle", value: nil, table: "Localizable") }
        public static var scheduleTitle: String { L10n.currentBundle.localizedString(forKey: "templates.schedule_title", value: nil, table: "Localizable") }
        public static func zonesCount(_ count: Int) -> String { String(format: L10n.currentBundle.localizedString(forKey: "templates.zones_count", value: nil, table: "Localizable"), count) }
        public static func activeDaysCount(_ count: Int) -> String { String(format: L10n.currentBundle.localizedString(forKey: "templates.active_days_count", value: nil, table: "Localizable"), count) }
        public static var saveTemplate: String { L10n.currentBundle.localizedString(forKey: "templates.save_template", value: nil, table: "Localizable") }
        public static var weeklyRoutine: String { text("templates.weekly_routine") }
        public static var dateOverride: String { text("templates.date_override") }
        public static var dateOverridesTitle: String { text("templates.date_overrides_title") }
        public static var noWeeklyTemplates: String { text("templates.no_weekly_templates") }
        public static var noWeeklyTemplatesMessage: String { text("templates.no_weekly_templates_message") }
        public static var createTemplate: String { text("templates.create_template") }
        public static var oneDayOverride: String { text("templates.one_day_override") }
        public static var overrideExplanation: String { text("templates.override_explanation") }
        public static var useWeeklyRoutine: String { text("templates.use_weekly_routine") }
        public static var usingWeeklyRoutine: String { text("templates.using_weekly_routine") }
        public static var noWeeklyCoverage: String { text("templates.no_weekly_coverage") }
        public static var followsWeeklyRoutine: String { text("templates.follows_weekly_routine") }
        public static var createDateOverride: String { text("templates.create_date_override") }
        public static var noZonesYet: String { text("templates.no_zones_yet") }
        public static var addFirstZone: String { text("templates.add_first_zone") }
        public static var saveChanges: String { text("templates.save_changes") }
        public static var loadingSchedules: String { text("templates.loading_schedules") }
        public static var loadFailure: String { text("templates.load_failure") }
        public static var retry: String { text("templates.retry") }
        public static var unableToUpdate: String { text("templates.unable_to_update") }
        public static var newSchedule: String { text("templates.new_schedule") }
        public static var editOverride: String { text("templates.edit_override") }
        public static var weeklyTemplate: String { text("templates.weekly_template") }
        public static var templateName: String { text("templates.template_name") }
        public static var templateNamePlaceholder: String { text("templates.template_name_placeholder") }
        public static var overrideName: String { text("templates.override_name") }
        public static var overrideNamePlaceholder: String { text("templates.override_name_placeholder") }
        public static var overrideNameRequired: String { text("templates.override_name_required") }
        public static var freeDaysHint: String { text("templates.free_days_hint") }
        public static var overrideDate: String { text("templates.override_date") }
        public static var saveOverride: String { text("templates.save_override") }
        public static var createSchedule: String { text("templates.create_schedule") }
        public static var saveTemplateDetails: String { text("templates.save_template_details") }
        public static var deleteTemplate: String { text("templates.delete_template") }
        public static var editTemplate: String { text("templates.edit_template") }
        public static var edit: String { text("templates.edit") }
        public static var delete: String { text("templates.delete") }
        public static var applyChanges: String { text("templates.apply_changes") }
        public static var unsavedChanges: String { text("templates.unsaved_changes") }
        public static var discardChanges: String { text("templates.discard_changes") }
        public static var confirm: String { text("templates.confirm") }
        public static var noFreeDays: String { text("templates.no_free_days") }
        public static var selectNameAndDay: String { text("templates.select_name_and_day") }
        public static var chooseFutureDate: String { text("templates.choose_future_date") }
        public static var duplicateOverride: String { text("templates.duplicate_override") }
        public static var zoneOverlap: String { text("templates.zone_overlap") }
        public static var authenticationError: String { text("templates.error_authentication") }
        public static var dayAlreadyAssignedError: String { text("templates.error_day_already_assigned") }
        public static var invalidZoneTimeRangeError: String { text("templates.error_invalid_zone_time_range") }
        public static var scheduleNotFoundError: String { text("templates.error_schedule_not_found") }
        public static var networkError: String { text("templates.error_network") }
        public static var invalidResponseError: String { text("templates.error_invalid_response") }
        public static var daysAssignedElsewhere: String { text("templates.days_assigned_elsewhere") }
        public static var daysNowUnavailable: String { text("templates.days_now_unavailable") }
        public static var applyZoneChangesConfirmation: String { text("templates.apply_zone_changes_confirmation") }
        public static var zoneRemovalMessage: String { text("templates.zone_removal_message") }
        public static var unsavedZoneChangesMessage: String { text("templates.unsaved_zone_changes_message") }
        public static var deleteTemplateMessage: String { text("templates.delete_template_message") }
        public static var useWeeklyRoutineConfirmation: String { text("templates.use_weekly_routine_confirmation") }
        public static var useWeeklyRoutineMessage: String { text("templates.use_weekly_routine_message") }
        public static var accessibilitySelected: String { text("templates.accessibility_selected") }
        public static var accessibilityAvailable: String { text("templates.accessibility_available") }
        public static var accessibilityUsed: String { text("templates.accessibility_used") }
        public static var zoneSummaryColor: String { text("templates.zone_summary_color") }
        public static var dragZoneHint: String { text("templates.drag_zone_hint") }
        public static func deleteZoneConfirmation(_ name: String) -> String {
            String(format: text("templates.delete_zone_confirmation"), name)
        }
        public static func deleteTemplateConfirmation(_ name: String) -> String {
            String(format: text("templates.delete_template_confirmation"), name)
        }
        public static func zoneTimeRange(_ start: String, _ end: String) -> String {
            String(format: text("templates.zone_time_range"), start, end)
        }
        public static func overrideShortcutAccessibility(_ name: String, date: String) -> String {
            String(format: text("templates.override_shortcut_accessibility"), name, date)
        }
        public static func zoneSummaryName(from original: String, to updated: String) -> String {
            String(format: text("templates.zone_summary_name"), original, updated)
        }
        public static func zoneSummaryTime(from original: String, to updated: String) -> String {
            String(format: text("templates.zone_summary_time"), original, updated)
        }
        public static func occupiedDay(_ day: String, template: String) -> String {
            String(format: text("templates.occupied_day"), day, template)
        }
        public static func conflictingTemplates(_ names: String) -> String {
            String(format: text("templates.conflicting_templates"), names)
        }

        private static func text(_ key: String) -> String {
            L10n.currentBundle.localizedString(forKey: key, value: nil, table: "Localizable")
        }
    }

    public enum Inbox {
        public static var title: String { text("inbox.title") }
        public static var tabInbox: String { text("inbox.tab_inbox") }
        public static var tabGoals: String { text("inbox.tab_goals") }
        public static var subtitle: String { text("inbox.subtitle") }
        public static var searchPlaceholder: String { text("inbox.search_placeholder") }
        public static var filterAll: String { text("inbox.filter_all") }
        public static var filterDrafted: String { text("inbox.filter_drafted") }
        public static var filterActive: String { text("inbox.filter_active") }
        public static var filterCompleted: String { text("inbox.filter_completed") }
        public static var filterCancelled: String { text("inbox.filter_cancelled") }
        public static var sessionsLabel: String { text("inbox.sessions_label") }
        public static var sessionsAny: String { text("inbox.sessions_any") }
        public static var sessionsActiveNow: String { text("inbox.sessions_active_now") }
        public static var sessionsMissed: String { text("inbox.sessions_missed") }
        public static var sessionsScheduled: String { text("inbox.sessions_scheduled") }
        public static var sectionTitle: String { text("inbox.section_title") }
        public static var noSessions: String { text("inbox.no_sessions") }
        public static var oneSession: String { text("inbox.one_session") }
        public static var derivedExplanation: String { text("inbox.derived_explanation") }
        public static var emptyTitle: String { text("inbox.empty_title") }
        public static var emptySubtitle: String { text("inbox.empty_subtitle") }
        public static var errorTitle: String { text("inbox.error_title") }
        public static var loadFailed: String { text("inbox.load_failed") }

        public static func nSessions(_ count: Int) -> String {
            String(format: text("inbox.n_sessions"), count)
        }

        private static func text(_ key: String) -> String {
            L10n.currentBundle.localizedString(forKey: key, value: nil, table: "Localizable")
        }
    }
}

