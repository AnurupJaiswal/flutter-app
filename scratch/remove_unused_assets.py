import os

icons_dir = r"d:\flutter-app\assets\icons"
images_dir = r"d:\flutter-app\assets\images"

keep_icons = {
    "home.png",
    "img_instagram.png",
    "img_youtube.png",
    "instagram_icon.png",
    "right.png",
    "whatsapp.png"
}

keep_images = {
    "img_clock_illustration.png",
    "img_draft_illustration.png",
    "img_notifcation_illustration.png"
}

removed_icons = []
for f in os.listdir(icons_dir):
    p = os.path.join(icons_dir, f)
    if os.path.isfile(p):
        if f not in keep_icons:
            os.remove(p)
            removed_icons.append(f)

removed_images = []
for f in os.listdir(images_dir):
    p = os.path.join(images_dir, f)
    if os.path.isfile(p):
        if f not in keep_images:
            os.remove(p)
            removed_images.append(f)

print(f"Successfully deleted {len(removed_icons)} unused icons from assets/icons.")
print(f"Successfully deleted {len(removed_images)} unused images from assets/images.")
