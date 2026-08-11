import os
import re

def update_workspace(directory):
    print(f"Scanning and updating workspace: {directory}...\n")
    
    # Define replacements
    repo_old_1 = "Itsabhishek7py/GoogleCloudSkillsboost"
    repo_old_2 = "cloudwalejiju/GoogleCloudSkillsboost"
    repo_new = "cloudwalejiju-a11y/samosalabs1"
    
    yt_old_1 = "@drabhishek.5460"
    yt_old_2 = "drabhishek.5460"
    yt_old_3 = "@DrCloud Wale JijuCloud$"
    yt_new = "@cloudwalejijaji"
    
    updated_files_count = 0
    renamed_files_count = 0
    
    # First pass: Rename files containing "abhishek", "abhi", or "cloudwalejiju"
    for root, dirs, files in os.walk(directory):
        # Skip git folders
        if '.git' in root.split(os.sep):
            continue
            
        for file in files:
            file_lower = file.lower()
            # Catch old abhishek files or existing cloudwalejiju files to standardise them to cloudwalejijaji
            if ('abhishek' in file_lower or 'abhi' in file_lower or 'cloudwalejiju' in file_lower) and (file.endswith('.sh') or file.endswith('.md')):
                old_path = os.path.join(root, file)
                ext = '.md' if file.endswith('.md') else '.sh'
                
                # Determine new name
                if ext == '.sh':
                    if 'gsp' in file_lower:
                        # Keep the GSP number if present (e.g. abhiGSP758.sh -> cloudwalejijajiGSP758.sh)
                        gsp_match = re.search(r'gsp\d+', file_lower)
                        if gsp_match:
                            new_name = f"cloudwalejijaji{gsp_match.group(0).upper()}.sh"
                        else:
                            new_name = "cloudwalejijaji.sh"
                    elif '1' in file_lower:
                        new_name = "cloudwalejijaji1.sh"
                    elif '2' in file_lower:
                        new_name = "cloudwalejijaji2.sh"
                    else:
                        new_name = "cloudwalejijaji.sh"
                else:
                    new_name = "cloudwalejijaji.md"
                
                new_path = os.path.join(root, new_name)
                try:
                    # If target file already exists, remove it first to avoid conflicts
                    if os.path.exists(new_path) and old_path != new_path:
                        os.remove(new_path)
                    
                    os.rename(old_path, new_path)
                    print(f"Renamed and removed old file:\n  Old: {old_path}\n  New: {new_path}\n")
                    renamed_files_count += 1
                    
                    # Double check removal of old path if it still exists
                    if os.path.exists(old_path) and old_path != new_path:
                        os.remove(old_path)
                except Exception as e:
                    print(f"Could not process file {old_path}: {e}")

    # Second pass: Update content in markdown and shell files
    for root, dirs, files in os.walk(directory):
        if '.git' in root.split(os.sep):
            continue
            
        for file in files:
            if file.endswith('.md') or file.endswith('.sh'):
                file_path = os.path.join(root, file)
                
                try:
                    with open(file_path, 'r', encoding='utf-8') as f:
                        content = f.read()
                except UnicodeDecodeError:
                    try:
                        with open(file_path, 'r', encoding='latin-1') as f:
                            content = f.read()
                    except Exception as e:
                        print(f"Could not read file {file_path}: {e}")
                        continue
                
                original_content = content
                
                # Replace repo URLs
                content = content.replace(repo_old_1, repo_new)
                content = content.replace(repo_old_2, repo_new)
                content = content.replace("http://raw.githubusercontent.com/", "https://raw.githubusercontent.com/")
                
                # Replace YT links
                content = content.replace(yt_old_1, yt_new)
                content = content.replace(yt_old_2, yt_new)
                content = content.replace(yt_old_3, yt_new)
                
                # Replace old channel display name and references
                content = content.replace("Dr. Abhishek", "Cloud Wale Jija Ji")
                content = content.replace("Dr Abhishek", "Cloud Wale Jija Ji")
                content = content.replace("Abhishek", "Cloud Wale Jija Ji")
                content = content.replace("Welcome to Abhishek", "Welcome to Cloud Wale Jija Ji")
                
                # Normalize colons %3A or %3a in github raw URLs
                url_pattern = re.compile(r'(https://raw\.githubusercontent\.com/cloudwalejiju-a11y/samosalabs1/[^\s`"\']*)')
                urls = url_pattern.findall(content)
                for url in urls:
                    if '%3A' in url or '%3a' in url:
                        updated_url = re.sub(r'%3[Aa]', '_', url)
                        content = content.replace(url, updated_url)
                
                # Replace script names in curl commands (primarily for md files)
                if file.endswith('.md'):
                    content = re.sub(r'abhishek\d*\.sh', 'cloudwalejijaji.sh', content)
                    content = re.sub(r'drabhishek\.sh', 'cloudwalejijaji.sh', content)
                    content = re.sub(r'abhishekq\.sh', 'cloudwalejijaji.sh', content)
                    content = re.sub(r'cloudwalejiju\d*\.sh', 'cloudwalejijaji.sh', content)
                    
                    # Handle GSP number script renames
                    gsp_script_match = re.search(r'(?:abhi|cloudwalejiju)(GSP\d+)\.sh', content, re.IGNORECASE)
                    if gsp_script_match:
                        gsp_num = gsp_script_match.group(1).upper()
                        content = re.sub(r'(?:abhi|cloudwalejiju)GSP\d+\.sh', f'cloudwalejijaji{gsp_num}.sh', content, flags=re.IGNORECASE)
                    
                    content = re.sub(r'chmod \+x (?:abhishek|drabhishek|abhishekq|cloudwalejiju)\d*\.sh', 'chmod +x cloudwalejijaji.sh', content)
                    content = re.sub(r'\./(?:abhishek|drabhishek|abhishekq|cloudwalejiju)\d*\.sh', './cloudwalejijaji.sh', content)
                    
                    # Clean up all social links and containers in markdown files
                    # 1. Remove HTML anchor tag blocks for Telegram, WhatsApp, YouTube, Instagram, Facebook, Twitter, X
                    content = re.sub(r'<a href="https?://(?:t\.me|www\.whatsapp\.com|www\.youtube\.com|www\.instagram\.com|www\.facebook\.com|x\.com|twitter\.com)/.*?".*?>.*?</a>\s*', '', content, flags=re.DOTALL | re.IGNORECASE)
                    
                    # 2. Remove markdown badge/link lines for these socials
                    content = re.sub(r'\[\!\[.*?\]\(https?:\/\/img\.shields\.io\/badge\/.*?(?:Telegram|youtube|instagram|facebook|twitter|x\.com|whatsapp).*?\)\]\(https?:\/\/(?:t\.me|www\.whatsapp\.com|www\.youtube\.com|www\.instagram\.com|www\.facebook\.com|x\.com|twitter\.com)\/.*?\)\s*', '', content, flags=re.IGNORECASE)
                    content = re.sub(r'\[\!\[(?:Telegram|YouTube|Instagram|Facebook|X|Twitter|WhatsApp)\].*?\]\(https?:\/\/(?:t\.me|www\.whatsapp\.com|www\.youtube\.com|www\.instagram\.com|www\.facebook\.com|x\.com|twitter\.com)\/.*?\)\s*', '', content, flags=re.IGNORECASE)
                    
                    # 3. Remove connection headers, paragraphs and messages
                    content = re.sub(r'<h3 style="font-family: \'Segoe UI\'.*?>🌟 Connect with Cloud Enthusiasts 🌟</h3>\s*', '', content, flags=re.IGNORECASE)
                    content = re.sub(r'<p style="font-family: \'Segoe UI\'.*?>Join the community, share knowledge, and grow together!</p>\s*', '', content, flags=re.IGNORECASE)
                    content = re.sub(r'Connect with fellow cloud enthusiasts, ask questions, and share your learning journey\.\s*', '', content, flags=re.IGNORECASE)
                    content = re.sub(r'<h3>🌟 Connect with fellow cloud enthusiasts, ask questions, and share your learning journey! 🌟</h3>\s*', '', content, flags=re.IGNORECASE)
                    
                    # 4. Remove empty divs or divs containing only whitespace or Congratulations headers
                    content = re.sub(r'<div align="center">\s*</div>\s*', '', content, flags=re.IGNORECASE)
                    content = re.sub(r'<div align="center">\s*#+\s*Congratulations\s*!*\s*</div>\s*', '', content, flags=re.IGNORECASE)
                    content = re.sub(r'<div align="center">\s*</div>\s*', '', content, flags=re.IGNORECASE)
                
                if content != original_content:
                    try:
                        with open(file_path, 'w', encoding='utf-8') as f:
                            f.write(content)
                        print(f"Updated content in: {file_path}")
                        updated_files_count += 1
                    except Exception as e:
                        print(f"Could not write to file {file_path}: {e}")
                        
    print(f"\nMigration complete!")
    print(f"Renamed {renamed_files_count} file(s).")
    print(f"Updated content in {updated_files_count} file(s).")

if __name__ == "__main__":
    import sys
    workspace_dir = os.path.dirname(os.path.abspath(__file__))
    update_workspace(workspace_dir)
