#!/bin/bash

# ===========================
# Universal React / Next / Expo Setup Script
# (Safe, Non-Hanging Version)
# ===========================

set -e

# ----------- Detect OS -----------
OS_TYPE=$(uname)
if [[ "$OS_TYPE" == "Darwin" ]]; then
  PLATFORM="mac"
elif [[ "$OS_TYPE" == "Linux" ]]; then
  PLATFORM="linux"
else
  PLATFORM="windows"
fi
echo "Detected OS: $PLATFORM"

clean_next_dev() {
  [[ -f .next/dev/lock ]] && rm -f .next/dev/lock
}

find_free_port() {
  local port=3000
  while :; do
    if [[ "$PLATFORM" == "windows" ]]; then
      powershell.exe -Command "(Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue)" >/dev/null 2>&1 || {
        echo $port; return;
      }
    else
      lsof -i:$port >/dev/null 2>&1 || {
        echo $port; return;
      }
    fi
    port=$((port + 1))
  done
}

# ----------- UI -----------
echo "Choose project type:"
echo "1) React (Web)"
echo "2) Next.js (Web)"
echo "3) React Native (Expo)"
read -p "Enter number: " PROJECT_CHOICE
PROJECT_CHOICE=$(normalize "$PROJECT_CHOICE")

read -p "Enter project name: " PROJECT_NAME
PROJECT_NAME=$(normalize "$PROJECT_NAME")

read -p "Enter project description: " PROJECT_DESC

read -p "Install Tailwind? (y/n): " INSTALL_TAILWIND
INSTALL_TAILWIND=$(normalize "$INSTALL_TAILWIND")

INSTALL_PWA="n"
if [[ "$PROJECT_CHOICE" == "1" || "$PROJECT_CHOICE" == "2" ]]; then
  read -p "Enable PWA? (y/n): " INSTALL_PWA
  INSTALL_PWA=$(normalize "$INSTALL_PWA")
fi

# ----------- Docs / Components / Hooks -----------
read -p "Create docs/ folder? (y/n) " CREATE_DOCS
read -p "Create components/ folder? (y/n) " CREATE_COMPONENTS
read -p "Create hooks/ folder? (y/n) " CREATE_HOOKS
read -p "Auto-start dev server? (y/n) " AUTO_START

normalize() {
  echo "$1" | tr -d '\r' | tr '[:upper:]' '[:lower:]'
}

CREATE_DOCS=$(normalize "$CREATE_DOCS")
CREATE_COMPONENTS=$(normalize "$CREATE_COMPONENTS")
CREATE_HOOKS=$(normalize "$CREATE_HOOKS")
AUTO_START=$(normalize "$AUTO_START")

# ----------- Helpers -----------

clean_next_dev() {
  [[ -f .next/dev/lock ]] && rm -f .next/dev/lock
}

find_free_port() {
  local port=3000
  while :; do
    if [[ "$PLATFORM" == "windows" ]]; then
      powershell.exe -Command "(Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue)" >/dev/null 2>&1 || {
        echo $port; return;
      }
    else
      lsof -i:$port >/dev/null 2>&1 || {
        echo $port; return;
      }
    fi
    port=$((port + 1))
  done
}

# ----------- Tailwind / PWA -----------

install_tailwind_react() {
  npm install -D tailwindcss postcss autoprefixer
  npx tailwindcss init -p
}

install_tailwind_next() {
  npm install -D tailwindcss postcss autoprefixer
  npx tailwindcss init -p
}

install_tailwind_rn() {
  npm install tailwindcss-react-native
  npx tailwindcss init
}

install_pwa_next() {
  npm install next-pwa
  clean_next_dev
  grep -q "next-pwa" next.config.js 2>/dev/null || cat >> next.config.js <<EOF

const withPWA = require('next-pwa')({
  dest: 'public'
});

module.exports = withPWA({
  reactStrictMode: true,
});
EOF
}

install_pwa_react() {
  echo "Enable service worker manually in CRA."
}

# ----------- Folders -----------

create_docs_folder() {
  mkdir -p docs
  echo "# Setup" > docs/setup.md
  echo "# Todo" > docs/todo.md
  echo "# Architecture" > docs/architecture.md
}

create_components_folder() {
  mkdir -p src/components
}

create_hooks_folder() {
  mkdir -p src/hooks
}

# ----------- Metadata -----------

create_metadata() {
  cat > project_metadata.json <<EOF
{
  "project_name": "$PROJECT_NAME",
  "description": "$PROJECT_DESC",
  "type": "$PROJECT_CHOICE",
  "tailwind": "$INSTALL_TAILWIND",
  "pwa": "$INSTALL_PWA",
  "created": "$(date)"
}
EOF
}

# ----------- README (NON-BLOCKING) -----------

update_readme() {
  if [[ ! -f README.md ]]; then
    {
      echo "# $PROJECT_NAME"
      echo ""
      echo "## Description"
      echo "$PROJECT_DESC"
      echo ""
      echo "## Setup"
      echo "- npm install"
      echo "- npm start / npm run dev / npx expo start"
    } > README.md
  else
    grep -q "## Setup" README.md || {
      echo ""
      echo "## Setup"
      echo "- npm install"
      echo "- npm start / npm run dev / npx expo start"
    } >> README.md
  fi
}

# ----------- Project Setup -----------

if [[ "$PROJECT_CHOICE" == "1" ]]; then
  npx create-react-app "$PROJECT_NAME"
  cd "$PROJECT_NAME"
  [[ "$INSTALL_TAILWIND" == "y" ]] && install_tailwind_react

elif [[ "$PROJECT_CHOICE" == "2" ]]; then
  npx create-next-app@latest "$PROJECT_NAME"
  cd "$PROJECT_NAME"
  [[ "$INSTALL_TAILWIND" == "y" ]] && install_tailwind_next
  [[ "$INSTALL_PWA" == "y" ]] && install_pwa_next

elif [[ "$PROJECT_CHOICE" == "3" ]]; then
  npx create-expo-app "$PROJECT_NAME"
  cd "$PROJECT_NAME"
  [[ "$INSTALL_TAILWIND" == "y" ]] && install_tailwind_rn
else
  echo "Invalid choice"
  exit 1
fi

# ----------- Extras -----------

[[ "$CREATE_DOCS" == "y" ]] && create_docs_folder
[[ "$CREATE_COMPONENTS" == "y" ]] && create_components_folder
[[ "$CREATE_HOOKS" == "y" ]] && create_hooks_folder

create_metadata
update_readme

# ----------- Auto-start -----------

if [[ "$AUTO_START" == "y" ]]; then
  if [[ "$PROJECT_CHOICE" == "2" ]]; then
    clean_next_dev
    PORT=$(find_free_port)
    PORT=$PORT npm run dev
  elif [[ "$PROJECT_CHOICE" == "1" ]]; then
    npm start
  else
    npx expo start
  fi
fi

echo "✅ Project setup complete"
