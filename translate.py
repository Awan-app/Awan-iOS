import json

file_path = "Modules/Common/Sources/Common/Resources/Localizable.xcstrings"

with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

translations = {
    "common.save": "حفظ",
    "common.cancel": "إلغاء",
    "common.continue": "متابعة",
    "common.got_it": "حسنًا",
    "common.please_try_again": "الرجاء المحاولة مرة أخرى.",
    "common.close": "إغلاق",
    "common.edit": "تعديل",
    "onboarding.welcome_title": "مرحباً، أنا أوان.\nالسماء ملكك اليوم.",
    "onboarding.welcome_subtitle": "أخبرني قليلاً عن يومك وسأقوم\nببناء جدول يتعافى بهدوء\nعندما تتغير ظروف الحياة.",
    "onboarding.lets_go": "لننطلق",
    "onboarding.skip_setup": "تخطي الإعداد",
    "onboarding.name_title": "ماذا تحب أن أناديك؟",
    "onboarding.name_subtitle": "فقط اسمك — سأستخدمه لتحيتك كل صباح.",
    "onboarding.first_name_label": "الاسم الأول",
    "onboarding.first_name_placeholder": "سام",
    "onboarding.last_name_label": "الاسم الأخير",
    "onboarding.last_name_placeholder": "ريفيرا",
    "onboarding.preview_label": "معاينة",
    "onboarding.wake_sleep_title": "متى يبدأ يومك وينتهي؟",
    "onboarding.wake_label": "أستيقظ عادة في",
    "onboarding.sleep_label": "أنام عادة في",
    "onboarding.midnight_note": "تنام بعد منتصف الليل؟ سأرتب الليل لك.",
    "onboarding.zones_title": "إليك يوماً رسمته لك",
    "onboarding.set_manually": "إعداد يدوي",
    "onboarding.use_this": "استخدم هذا",
    "onboarding.change_anytime": "يمكنك تغيير هذا في أي وقت",
    "onboarding.add_zone": "إضافة فترة",
    "onboarding.your_day_label": "يومك",
    "onboarding.open_sky_hours": "%lld ساعات من السماء الصافية",
    "onboarding.zones_fill_next": "ستملأ الفترات هذا لاحقاً",
    "onboarding.skip": "تخطي",
    "login.app_title": "أوان",
    "login.subtitle": "يومك، مرسوم كسماء.\nسجل الدخول — وسنرسل لك رمزاً.",
    "login.sending": "جاري الإرسال...",
    "login.send_code_timer": "إرسال الرمز • 0:%@",
    "login.send_code": "إرسال الرمز",
    "login.or": "أو",
    "login.sign_in_apple": "تسجيل الدخول باستخدام Apple",
    "login.continue_google": "المتابعة باستخدام Google",
    "login.footer.terms_prefix": "لا كلمات مرور أبدًا. بمتابعتك، أنت توافق على ",
    "login.footer.terms": "شروط أوان",
    "login.footer.and": " و ",
    "login.footer.privacy": "الخصوصية",
    "login.footer.dot": ".",
    "login.email_label": "البريد الإلكتروني",
    "login.email_prompt": "أدخل بريدك الإلكتروني",
    "login.error.offline": "أنت غير متصل بالإنترنت — سنرسل الرمز عندما تعاود الاتصال.",
    "otp.title": "أنت في الداخل! ☀️",
    "otp.subtitle": "أدخل الرمز الذي أرسلناه إلى",
    "otp.verified": "تم التحقق — جاري دخولك",
    "otp.error.offline": "أنت غير متصل بالإنترنت — عاود الاتصال للتحقق أو أعد إرسال رمزك.",
    "otp.resend_timer": "إعادة إرسال الرمز • %@",
    "otp.resend": "إعادة إرسال الرمز",
    "otp.keypad_hint": "لوحة مفاتيح رقمية · يتم الإرسال التلقائي عند الرقم السادس",
    "otp.digit_accessibility": "الرقم %lld من رمز التحقق",
    "home.good_morning": "صباح الخير",
    "home.add_goal": "إضافة هدف",
    "home.add_task": "إضافة مهمة",
    "home.good_afternoon": "مساء الخير",
    "home.good_evening": "طاب مساؤك",
    "home.todays_plan": "خطة اليوم",
    "home.task_schedule_summary": "%lld مهام • %@",
    "home.task_schedule_summary_one": "%lld مهمة • %@",
    "home.completion_summary": "%lld من %lld مكتملة",
    "home.minutes_short": "%lld دقيقة",
    "home.hours_short": "%lld ساعة",
    "home.hours_minutes_short": "%lld ساعة %lld دقيقة",
    "home.fixed": "ثابت",
    "home.empty_timeline_subtitle": "أضف مهمة أو هدفاً لتبدأ خطتك.",
    "home.error_title": "تعذر تحديث يومك",
    "home.load_failed": "لم نتمكن من تحميل خطتك.",
    "home.retry": "حاول مرة أخرى",
    "home.start_time": "وقت البدء",
    "home.reschedule": "إعادة الجدولة والتثبيت",
    "home.lock_session": "تثبيت الجلسة",
    "home.unlock_session": "إلغاء تثبيت الجلسة",
    "home.delete_session": "حذف الجلسة",
    "home.delete_session_confirmation": "هل تريد حذف هذه الجلسة المجدولة؟ ستبقى المهمة متاحة.",
    "home.today": "اليوم",
    "home.calendar": "التقويم",
    "home.rewards": "المكافآت",
    "home.you": "أنت",
    "schedule.quests_title": "مهام أوان",
    "schedule.streak_accessibility": "سلسلة من سبعة أيام",
    "schedule.quest_chain": "سلسلة المهام",
    "schedule.todays_adventure": "مغامرة اليوم",
    "schedule.minutes_scheduled": "%lld دقيقة",
    "schedule.this_week": "هذا الأسبوع",
    "schedule.empty_title": "يومك جاهز للمغامرة",
    "schedule.empty_subtitle": "أنشئ مهمة أو جرب مختبر التعارض أعلاه.",
    "schedule.your_time": "وقتك",
    "schedule.drag_hint_accessibility": "اسحب عمودياً لتغيير الوقت بخطوات من ١٥ دقيقة",
    "schedule.quest_name": "اسم المهمة",
    "schedule.quest_name_placeholder": "ماذا ستقهر؟",
    "schedule.duration": "المدة",
    "schedule.duration_minutes": "%lld دقيقة",
    "schedule.zone": "الفترة",
    "schedule.standalone": "مستقل",
    "schedule.choose_zone": "اختر الفترة",
    "schedule.can_split": "يمكن تقسيمه إلى جلسات",
    "schedule.keep_fixed": "إبقاء الوقت المجدول ثابتاً",
    "schedule.create_quest": "إنشاء مهمة",
    "schedule.save_changes": "حفظ التغييرات",
    "schedule.delete_quest": "حذف المهمة",
    "schedule.new_quest": "مهمة يومية جديدة",
    "schedule.tune_quest": "تعديل مهمتك",
    "schedule.build_quest_title": "بناء مهمة لـ ٧ أيام",
    "schedule.build_quest_subtitle": "خطوة واحدة مركزة كل يوم",
    "schedule.goal_name": "اسم الهدف",
    "schedule.each_step": "كل خطوة",
    "schedule.start_quest": "ابدأ مهمة ٧ أيام",
    "schedule.error_title": "اعترض شيء طريقنا",
    "schedule.add_task": "إضافة مهمة",
    "schedule.add_goal": "هدف من ٧ مهام",
    "profile.dummy_name": "سام ريفيرا",
    "profile.dummy_email": "sam@awan.app",
    "profile.dummy_session_time": "٦٠ دقيقة",
    "profile.dummy_time_zone": "القاهرة · GMT+3",
    "profile.dummy_sleep_schedule": "١١:٠٠ م – ٧:٠٠ ص",
    "profile.ready": "جاهز"
}

en_translations = {
    "common.edit": "Edit",
    "profile.dummy_name": "Sam Rivera",
    "profile.dummy_email": "sam@awan.app",
    "profile.dummy_session_time": "60 min",
    "profile.dummy_time_zone": "Cairo · GMT+3",
    "profile.dummy_sleep_schedule": "11:00 PM – 7:00 AM",
    "profile.ready": "READY"
}

for key, ar_val in translations.items():
    if key not in data["strings"]:
        data["strings"][key] = {
            "extractionState": "manual",
            "localizations": {
                "en": {
                    "stringUnit": {
                        "state": "translated",
                        "value": en_translations.get(key, key)
                    }
                }
            }
        }
    data["strings"][key]["localizations"]["ar"] = {
        "stringUnit": {
            "state": "translated",
            "value": ar_val
        }
    }

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, ensure_ascii=False, indent=2)

print("Done")
