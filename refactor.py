import os
import re

lib_dir = r'D:\STARTUP\GARDA\aplikasi\garda\lib\app\modules'
auth_import_pattern = r'import .*auth_service\.dart'

for root, dirs, files in os.walk(lib_dir):
    for file in files:
        if file.endswith('.dart'):
            filepath = os.path.join(root, file)
            with open(filepath, 'r', encoding='utf-8') as f:
                content = f.read()

            # We need to look for FirebaseFirestore.instance.collection('mobile').doc(user.uid)
            # but sometimes it's split across lines. Let's do a regex.
            # Also, some use collection('mobile') without doc(user.uid). Wait, let's find all collection('mobile') 
            if 'collection(\'mobile\')' in content:
                # Replace FirebaseFirestore.instance.collection('mobile').doc(user.uid) -> Get.find<AuthService>().getUserReference(user.uid)
                new_content = re.sub(r'FirebaseFirestore\.instance\s*\.collection\(\'mobile\'\)\s*\.doc\((.*?)\)', r'Get.find<AuthService>().getUserReference(\1)', content)
                
                # Replace FirebaseFirestore.instance.collection('mobile') -> Get.find<AuthService>().getUserCollectionReference()
                # for queries like collection('mobile').where(...)
                new_content = re.sub(r'FirebaseFirestore\.instance\s*\.collection\(\'mobile\'\)', r'Get.find<AuthService>().getUserCollectionReference()', new_content)

                if new_content != content:
                    # Add import if missing
                    if 'AuthService' in new_content and not re.search(auth_import_pattern, new_content):
                        # Determine relative path back to lib/app/services
                        # current is something like lib\app\modules\anggota\controllers\anggota_controller.dart
                        # depth is root.replace(lib_dir, '').count(os.sep) + 2
                        rel_path = root.replace(lib_dir, '')
                        depth = rel_path.strip(os.sep).count(os.sep) + 2 if rel_path.strip(os.sep) else 2
                        import_stmt = f"import '{'../' * depth}services/auth_service.dart';"
                        
                        # Insert after last import
                        imports = re.findall(r'^import .*;$', new_content, re.MULTILINE)
                        if imports:
                            last_import = imports[-1]
                            new_content = new_content.replace(last_import, last_import + '\n' + import_stmt, 1)
                        else:
                            new_content = import_stmt + '\n' + new_content

                    with open(filepath, 'w', encoding='utf-8') as f:
                        f.write(new_content)
                    print(f"Updated {filepath}")
