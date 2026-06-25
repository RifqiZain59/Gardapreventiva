import os

# Define the paths
base_dir = r"d:\STARTUP\GARDA\aplikasi\garda\lib"

# Mappings
directory_renames = {
    "nakes_pasien_grada": "nakes_pasien_garda",
    "nakes_detail_pasien_grada": "nakes_detail_pasien_garda"
}

# Recursively rename files and content
for root, dirs, files in os.walk(base_dir, topdown=False):
    # Rename files
    for name in files:
        if "grada" in name:
            new_name = name.replace("grada", "garda")
            old_path = os.path.join(root, name)
            new_path = os.path.join(root, new_name)
            os.rename(old_path, new_path)

    # Rename dirs
    for name in dirs:
        if "grada" in name:
            new_name = name.replace("grada", "garda")
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

            new_content = content.replace("Grada", "Garda")
            new_content = new_content.replace("grada", "garda")
            new_content = new_content.replace("GRADA", "GARDA")

            if new_content != content:
                with open(file_path, "w", encoding="utf-8") as f:
                    f.write(new_content)
                print(f"Updated content in {file_path}")

print("Renaming complete.")
