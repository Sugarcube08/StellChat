import os
import shutil

def copy_marketing_assets():
    artifact_dir = "/home/sugarcube/.gemini/antigravity-cli/brain/3853c50f-c2c9-49c7-bc67-aad313f53af4"
    mobile_dir = "/home/sugarcube/Desktop/Documents/Code-Server/Hackathon Projects/Stellar-DH/StellChat/apps/mobile"
    repo_root = "/home/sugarcube/Desktop/Documents/Code-Server/Hackathon Projects/Stellar-DH/StellChat"
    
    target_dir = os.path.join(repo_root, "docs/brand/marketing")
    os.makedirs(target_dir, exist_ok=True)

    # File mapping from artifact filenames to clean marketing filenames
    mappings = {
        "readme_hero_1782676704694.jpg": "readme_hero.jpg",
        "opengraph_banner_1782676722329.jpg": "opengraph_banner.jpg",
        "play_store_feature_graphic_1782676738332.jpg": "play_store_feature_graphic.jpg"
    }

    for art_name, clean_name in mappings.items():
        src = os.path.join(artifact_dir, art_name)
        dst = os.path.join(target_dir, clean_name)
        if os.path.exists(src):
            shutil.copy(src, dst)
            print(f"Copied {art_name} -> {dst}")
        else:
            print(f"Source not found: {src}")

    # Copy generated App Icon PNGs to marketing folder as well
    play_icon_src = os.path.join(mobile_dir, "assets/branding/app_icons/play_store_icon.png")
    play_icon_dst = os.path.join(target_dir, "play_store_icon.png")
    if os.path.exists(play_icon_src):
        shutil.copy(play_icon_src, play_icon_dst)
        print(f"Copied Play Store Icon -> {play_icon_dst}")

    # Generate Twitter card & GitHub social preview by copying the opengraph banner
    shutil.copy(os.path.join(target_dir, "opengraph_banner.jpg"), os.path.join(target_dir, "twitter_card.jpg"))
    shutil.copy(os.path.join(target_dir, "opengraph_banner.jpg"), os.path.join(target_dir, "github_social_preview.jpg"))
    shutil.copy(os.path.join(target_dir, "readme_hero.jpg"), os.path.join(target_dir, "promo_banner.jpg"))
    
    # Create dark and light screenshots for mockup placeholders
    shutil.copy(os.path.join(target_dir, "readme_hero.jpg"), os.path.join(target_dir, "dark_screenshot.jpg"))
    shutil.copy(os.path.join(target_dir, "readme_hero.jpg"), os.path.join(target_dir, "light_screenshot.jpg"))
    
    print("Marketing assets successfully compiled in docs/brand/marketing/!")

if __name__ == "__main__":
    copy_marketing_assets()
