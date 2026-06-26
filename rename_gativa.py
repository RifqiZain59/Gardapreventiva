import os

base_dir = r"d:\STARTUP\GARDA\aplikasi\garda\lib"

# Recursively rename files and content
for root, dirs, files in os.walk(base_dir, topdown=False):
    # Rename files
    for name in files:
        if "garda" in name:
            new_name = name.replace("garda", "gativa")
            old_path = os.path.join(root, name)
            new_path = os.path.join(root, new_name)
            os.rename(old_path, new_path)

    # Rename dirs
    for name in dirs:
        if "garda" in name:
            new_name = name.replace("garda", "gativa")
            old_path = os.path.join(root, name)
            new_path = os.path.join(root, new_name)
            os.rename(old_path, new_path)

# Update contents
for root, dirs, files in os.walk(base_dir):
    for name in files:
        if name.endswith(".dart"):
            file_path = os.path.join(root, name)
            with open(file_path, "r", encoding="utf-8") as f:
                content = f.read()

            new_content = content.replace("Garda", "Gativa")
            new_content = new_content.replace("garda", "gativa")
            new_content = new_content.replace("GARDA", "GATIVA")

            if new_content != content:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(new_content)
                print(f"Updated content in {file_path}")

print("Renaming complete.")
