import os
import glob
import re

def main():
    lib_dir = os.path.join(os.getcwd(), 'lib')
    all_dart_files = glob.glob(os.path.join(lib_dir, '**', '*.dart'), recursive=True)
    all_dart_files = [f.replace('\\', '/') for f in all_dart_files]
    
    file_contents = {}
    for f in all_dart_files:
        try:
            with open(f, 'r', encoding='utf-8') as file:
                file_contents[f] = file.read()
        except Exception as e:
            pass

    unused_files = []
    
    for target_file in all_dart_files:
        if target_file.endswith('/main.dart'):
            continue
            
        # Get filename and relative path parts
        filename = os.path.basename(target_file)
        
        # Check if filename is mentioned in any other file
        is_used = False
        for other_file, content in file_contents.items():
            if target_file == other_file:
                continue
            
            # Simple check if the filename exists in the content
            if filename in content:
                is_used = True
                break
                
        if not is_used:
            unused_files.append(target_file)
            
    for f in unused_files:
        print(f)

if __name__ == '__main__':
    main()
