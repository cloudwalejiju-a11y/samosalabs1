import os
import re

def update_markdown_files(directory):
    # Regex to find the target URL
    # It starts with the repository base URL and captures the rest of the URL until it hits a whitespace or backtick/quote
    url_pattern = re.compile(r'(https://raw\.githubusercontent\.com/cloudwalejiju-a11y/samosalabs1/[^\s`"\']*)')
    
    updated_files_count = 0
    
    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith('.md'):
                file_path = os.path.join(root, file)
                
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                except UnicodeDecodeError:
                    # Fallback to other encoding if utf-8 fails
                    try:
                        with open(file_path, 'r', encoding='latin-1') as f:
                            content = f.read()
                    except Exception as e:
                        print(f"Could not read file {file_path}: {e}")
                        continue
                
                # Find all URLs matching the pattern
                urls = url_pattern.findall(content)
                modified = False
                new_content = content
                
                for url in urls:
                    # If the URL contains '%3A' or '%3a', replace it with '_'
                    if '%3A' in url or '%3a' in url:
                        # Replace case-insensitively
                        updated_url = re.sub(r'%3[Aa]', '_', url)
                        new_content = new_content.replace(url, updated_url)
                        modified = True
                        print(f"Updated URL in {file}:\n  Old: {url}\n  New: {updated_url}\n")
                
                if modified:
                    try:
                        with open(file_path, 'w', encoding='utf-8') as f:
                            f.write(new_content)
                        updated_files_count += 1
                    except Exception as e:
                        print(f"Could not write to file {file_path}: {e}")
                        
    print(f"Task completed! Updated {updated_files_count} markdown file(s).")

if __name__ == "__main__":
    # Run the script starting from the current directory (workspace root)
    workspace_dir = os.path.dirname(os.path.abspath(__file__))
    print(f"Scanning markdown files in: {workspace_dir}...\n")
    update_markdown_files(workspace_dir)
