
````
# Universal React/Next/Expo Project Setup Script

This script allows you to **quickly create React, Next.js, or Expo React Native projects** with optional features:

- Tailwind CSS  
- PWA support (web projects only)  
- docs folder with templates  
- components/hooks folders  
- README generation  
- metadata tracking  

It is **cross-platform** and works on **Linux, macOS, and Windows** (via Git Bash or WSL).

---

## Usage

### Run interactively directly from GitHub

You can execute the script **without cloning the repo locally**:

```bash
curl -s https://raw.githubusercontent.com/triodigitech-dev1/universal-setup-script/main/setup-project.sh | bash
# or
wget -qO- https://raw.githubusercontent.com/triodigitech-dev1/universal-setup-script/main/setup-project.sh | bash
````

Follow the **interactive yes/no prompts** to set up your project.

---

## Interactive Prompts

When running the script, you will be asked:

1. **Project type**:

   ```
   1) React (Web)
   2) Next.js (Web)
   3) React Native (Expo)
   ```
2. **Project name**
3. **Project description / goal**
4. **Install Tailwind?** (y/n)
5. **Enable PWA support?** (y/n — only for web projects)
6. **Create docs/ folder with templates?** (y/n)
7. **Create components/ folder?** (y/n)
8. **Create hooks/ folder?** (y/n)
9. **Auto-start dev server?** (y/n)

---

## CLI Flags Reference

The script also shows these flags at startup for reference:

```
--react [project_name]    # Create React web project
--next [project_name]     # Create Next.js web project
--expo [project_name]     # Create Expo React Native project
--tailwind                # Install Tailwind
--pwa                     # Enable PWA (web only)
--docs                    # Create docs/ folder with templates
--components              # Create components/ folder
--hooks                   # Create hooks/ folder
--autostart               # Auto-start dev server
```

> ⚠️ Currently, the script runs interactively. Flags are displayed for future automation or reference.

---

## Features

* Detects **OS automatically** (Linux/macOS/Windows via Git Bash or WSL)
* Supports **React, Next.js, and Expo React Native projects**
* Optional **Tailwind installation**
* Optional **PWA setup** (web projects only)
* Creates **docs/ folder** with templates:

  * `setup.md`
  * `todo.md`
  * `architecture.md`
* Creates **components/** and **hooks/** folders
* Generates **README.md** based on project name and description
* Saves **metadata file** (`project_metadata.json`) with project info
* Optionally **auto-starts dev server**

---

## Example Workflow

1. Run the script:

```bash
curl -s https://raw.githubusercontent.com/triodigitech-dev1/universal-setup-script/main/setup-project.sh | bash
```

2. Follow prompts:

```
Choose project type: 1) React, 2) Next.js, 3) Expo
Enter project name: MyApp
Enter project description / goal: Example app to demonstrate setup
Do you want to install Tailwind? (y/n)
Do you want to enable PWA support? (y/n)
Do you want to create docs/ folder with templates? (y/n)
Do you want to create components/ folder? (y/n)
Do you want to create hooks/ folder? (y/n)
Do you want to auto-start the dev server? (y/n)
```

3. Project will be created with all selected options. Tailwind, PWA (if selected), docs folder, components/hooks folders, README, and metadata will be set up automatically.

---

## Notes

* On **Windows**, use **Git Bash** or **WSL** to run the script. Native cmd/powershell cannot execute bash scripts directly.
* Tailwind and PWA setups may require minor manual configuration after installation:

  * React (CRA): enable service worker manually
  * Next.js: configure `next.config.js` for `next-pwa`
* Git setup (repo, commits, remotes) is left to the user. The script does not modify Git.

---



