#!/usr/bin/env python3
import os
import re

def clean_dart_comments(file_path):
    """Limpia comentarios innecesarios de archivos Dart"""

    patterns_to_remove = [
        r'// =============================================================================.*?\n',
        r'// ARCHIVO:.*?\n',
        r'// FUNCIÓN:.*?\n',
        r'//\s*ACTUALIZACIÓN:.*?\n',
        r'// ---.*?---.*?\n',
        r'// --- .*? ---.*?\n',
        r'//\s*\n(?=\s*\n)',  # Líneas de comentarios vacías duplicadas
    ]

    with open(file_path, 'r', encoding='utf-8') as file:
        content = file.read()

    original_content = content

    for pattern in patterns_to_remove:
        content = re.sub(pattern, '', content, flags=re.MULTILINE | re.DOTALL)

    # Limpiar líneas vacías múltiples
    content = re.sub(r'\n\s*\n\s*\n', '\n\n', content)

    if content != original_content:
        with open(file_path, 'w', encoding='utf-8') as file:
            file.write(content)
        print(f"Limpiado: {file_path}")

def main():
    lib_dir = 'lib'

    for root, dirs, files in os.walk(lib_dir):
        for file in files:
            if file.endswith('.dart'):
                file_path = os.path.join(root, file)
                clean_dart_comments(file_path)

    print("Limpieza completada!")

if __name__ == "__main__":
    main()