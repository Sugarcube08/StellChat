import os

def rename_in_file(filepath):
    with open(filepath, 'r', encoding='utf-8') as f:
        content = f.read()

    # Replacements
    replacements = {
        'ghost_surface.dart': 'stell_surface.dart',
        'ghost_card.dart': 'stell_card.dart',
        'ghost_button.dart': 'stell_button.dart',
        'ghost_avatar.dart': 'stell_avatar.dart',
        'ghost_badge.dart': 'stell_badge.dart',
        'ghost_input.dart': 'stell_input.dart',
        'ghost_navigation.dart': 'stell_navigation.dart',
        'ghost_theme.dart': 'stell_theme.dart',
        
        'GhostSurface': 'StellSurface',
        'GhostCard': 'StellCard',
        'GhostButton': 'StellButton',
        'GhostAvatar': 'StellAvatar',
        'GhostBadge': 'StellBadge',
        'GhostInput': 'StellInput',
        'GhostNavigationBar': 'StellNavigationBar',
        'GhostNavigationRail': 'StellNavigationRail',
        'GhostNavItem': 'StellNavItem',
        
        'GhostColorsExtension': 'StellColorsExtension',
        'GhostTheme': 'StellTheme',
        'GhostPageTransitionsBuilder': 'StellPageTransitionsBuilder',
        'ghostAccent': 'stellAccent',
    }

    modified = False
    new_content = content
    for old, new in replacements.items():
        if old in new_content:
            new_content = new_content.replace(old, new)
            modified = True

    if modified:
        with open(filepath, 'w', encoding='utf-8') as f:
            f.write(new_content)
        print(f"Updated: {filepath}")

def walk_and_rename():
    lib_path = 'lib'
    for root, dirs, files in os.walk(lib_path):
        for file in files:
            if file.endswith('.dart'):
                rename_in_file(os.path.join(root, file))

    # Rename physical files
    file_renames = [
        ('lib/design_system/components/ghost_surface.dart', 'lib/design_system/components/stell_surface.dart'),
        ('lib/design_system/components/ghost_card.dart', 'lib/design_system/components/stell_card.dart'),
        ('lib/design_system/components/ghost_button.dart', 'lib/design_system/components/stell_button.dart'),
        ('lib/design_system/components/ghost_avatar.dart', 'lib/design_system/components/stell_avatar.dart'),
        ('lib/design_system/components/ghost_badge.dart', 'lib/design_system/components/stell_badge.dart'),
        ('lib/design_system/components/ghost_input.dart', 'lib/design_system/components/stell_input.dart'),
        ('lib/design_system/components/ghost_navigation.dart', 'lib/design_system/components/stell_navigation.dart'),
        ('lib/core/theme/ghost_theme.dart', 'lib/core/theme/stell_theme.dart'),
    ]

    for old_path, new_path in file_renames:
        if os.path.exists(old_path):
            os.rename(old_path, new_path)
            print(f"Renamed file: {old_path} -> {new_path}")

if __name__ == "__main__":
    print("Starting legacy code rename...")
    walk_and_rename()
    print("Renaming complete!")
