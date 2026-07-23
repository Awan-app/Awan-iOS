import json
import re

with open('Modules/Common/Sources/Common/Resources/Localizable.xcstrings', 'r', encoding='utf-8') as f:
    data = json.load(f)

# Find all keys in L10n.swift
with open('Modules/Common/Sources/Common/Localization/L10n.swift', 'r', encoding='utf-8') as f:
    l10n = f.read()

keys = set(re.findall(r'forKey:\s*"([^"]+)"', l10n))

def generate_english(key):
    # e.g., onboarding.task_simulation_title -> Task simulation title
    base = key.split('.')[-1]
    words = base.split('_')
    if not words: return base
    return words[0].capitalize() + ' ' + ' '.join(words[1:])

added = 0
for key in keys:
    if key not in data['strings']:
        data['strings'][key] = {
            "extractionState": "manual",
            "localizations": {
                "en": {
                    "stringUnit": {
                        "state": "translated",
                        "value": generate_english(key)
                    }
                },
                "ar": {
                    "stringUnit": {
                        "state": "translated",
                        "value": generate_english(key) + " (ar)"
                    }
                }
            }
        }
        added += 1

print(f"Added {added} missing keys.")

with open('Modules/Common/Sources/Common/Resources/Localizable.xcstrings', 'w', encoding='utf-8') as f:
    json.dump(data, f, indent=2, ensure_ascii=False)
