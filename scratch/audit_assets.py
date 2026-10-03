import os
import re

lib_dir = r"d:\flutter-app\lib"
icons_dir = r"d:\flutter-app\assets\icons"
images_dir = r"d:\flutter-app\assets\images"

# Read all Dart files
dart_files = []
dart_text = ""
for root, _, files in os.walk(lib_dir):
    for f in files:
        if f.endswith(".dart"):
            p = os.path.join(root, f)
            dart_files.append(p)
            with open(p, "r", encoding="utf-8", errors="ignore") as file:
                dart_text += file.read() + "\n"

pubspec_path = r"d:\flutter-app\pubspec.yaml"
if os.path.exists(pubspec_path):
    with open(pubspec_path, "r", encoding="utf-8", errors="ignore") as file:
        dart_text += file.read() + "\n"

def is_used(filename):
    # Check exact filename
    if filename in dart_text:
        return True
    # Check filename without extension
    stem = os.path.splitext(filename)[0]
    if len(stem) > 3 and stem in dart_text:
        return True
    return False

used_icons = []
unused_icons = []
for f in os.listdir(icons_dir):
    p = os.path.join(icons_dir, f)
    if os.path.isfile(p):
        if is_used(f):
            used_icons.append(f)
        else:
            unused_icons.append(f)

used_images = []
unused_images = []
for f in os.listdir(images_dir):
    p = os.path.join(images_dir, f)
    if os.path.isfile(p):
        if is_used(f):
            used_images.append(f)
        else:
            unused_images.append(f)

print("=== USED ICONS ===")
for f in used_icons:
    print("USED ICON:", f)

print("\n=== USED IMAGES ===")
for f in used_images:
    print("USED IMAGE:", f)

print(f"\nTotal Icons: {len(os.listdir(icons_dir))}, Used: {len(used_icons)}, Unused: {len(unused_icons)}")
print(f"Total Images: {len(os.listdir(images_dir))}, Used: {len(used_images)}, Unused: {len(unused_images)}")
