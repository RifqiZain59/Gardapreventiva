import os
import re

routes_file = 'lib/app/routes/app_routes.dart'
pages_file = 'lib/app/routes/app_pages.dart'

with open(routes_file, 'r', encoding='utf-8') as f:
    routes_content = f.read()

with open(pages_file, 'r', encoding='utf-8') as f:
    pages_content = f.read()

path_matches = re.findall(r'static const (\w+) = \'(.*?)\';', routes_content)

missing_imports = []
missing_pages = []

for name, path in path_matches:
    if f"_Paths.{name}" not in pages_content:
        module_name = name.lower()
        words = module_name.split('_')
        camel_case = ''.join(word.title() for word in words)
        
        binding_class = f'{camel_case}Binding'
        view_class = f'{camel_case}View'
        
        import_stmt_1 = f"import '../modules/{module_name}/bindings/{module_name}_binding.dart';"
        import_stmt_2 = f"import '../modules/{module_name}/views/{module_name}_view.dart';"
        
        binding_path = f'lib/app/modules/{module_name}/bindings/{module_name}_binding.dart'
        view_path = f'lib/app/modules/{module_name}/views/{module_name}_view.dart'
        
        if os.path.exists(binding_path) and os.path.exists(view_path):
            missing_imports.append(import_stmt_1)
            missing_imports.append(import_stmt_2)
            missing_pages.append(f'''    GetPage(
      name: _Paths.{name},
      page: () => const {view_class}(),
      binding: {binding_class}(),
    ),''')

if missing_imports:
    pages_content = pages_content.replace("part 'app_routes.dart';", '\n'.join(missing_imports) + "\n\npart 'app_routes.dart';")
    pages_content = pages_content.replace('  ];\n}', '\n' + '\n'.join(missing_pages) + '\n  ];\n}')
    
    with open(pages_file, 'w', encoding='utf-8') as f:
        f.write(pages_content)
    print('Fixed app_pages.dart')
else:
    print('Nothing to fix')
