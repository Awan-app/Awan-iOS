import json

file_path = "Modules/Common/Sources/Common/Resources/Localizable.xcstrings"
with open(file_path, "r", encoding="utf-8") as f:
    data = json.load(f)

def add_key(key, en_val, ar_val):
    data["strings"][key] = {
        "extractionState": "manual",
        "localizations": {
            "en": { "stringUnit": { "state": "translated", "value": en_val } },
            "ar": { "stringUnit": { "state": "translated", "value": ar_val } }
        }
    }

add_key("onboarding.duration_minutes", "%lld min", "%lld دقيقة")
add_key("onboarding.duration_one_hour", "1 hour", "ساعة واحدة")
add_key("onboarding.duration_hours", "%lld hr", "%lld ساعة")
add_key("onboarding.duration_hours_minutes", "%lld hr %lld min", "%lld ساعة %lld دقيقة")

with open(file_path, "w", encoding="utf-8") as f:
    json.dump(data, f, indent=2, ensure_ascii=False)

print("Updated Localizable.xcstrings")
