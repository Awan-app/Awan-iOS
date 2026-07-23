import json

with open('Modules/Common/Sources/Common/Resources/Localizable.xcstrings', 'r', encoding='utf-8') as f:
    data = json.load(f)

overrides = {
    "onboarding.task_simulation_title": "Let's simulate a task",
    "onboarding.task_simulation_subtitle": "What is a task you want to do?",
    "onboarding.task_simulation_placeholder": "E.g. Read a book",
    "onboarding.add_it": "Add it",
    "onboarding.how_long_to_focus": "How long to focus",
    "onboarding.how_blocks_feel": "How blocks feel",
    "onboarding.preferred_focus_block": "Preferred focus block",
    "onboarding.feel_balanced": "Balanced",
    "onboarding.feel_deep_few": "Deep & few",
    "onboarding.feel_short_light": "Short & light",
    "onboarding.preview_lands_in_day": "Lands in your day",
    "onboarding.preview_study": "Study",
    "onboarding.preview_study_duration": "1 hr",
    "onboarding.preview_study_time": "9:00 AM - 10:00 AM",
    "onboarding.preview_new": "New",
    "onboarding.preview_bounce": "Bounce"
}

for key, val in overrides.items():
    if key in data['strings']:
        data['strings'][key]['localizations']['en']['stringUnit']['value'] = val
        # I'll let Arabic just be val + ' (ar)' for now so they know what it is.

with open('Modules/Common/Sources/Common/Resources/Localizable.xcstrings', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
