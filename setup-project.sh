#!/bin/bash

# ===========================
# Universal React/Next/Expo Setup Script
# ===========================

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

# ----------- Show CLI flags help -----------
echo "Available CLI flags:"
echo "--react [project_name] --next [project_name] --expo [project_name] --tailwind --pwa --docs --components --hooks --autostart"

# ----------- Project type selection -----------
echo "Choose project type:"
echo "1) React (Web)"
echo "2) Next.js (Web)"
echo "3) React Native (Expo)"
read -p "Enter number: " PROJECT_CHOICE
PROJECT_CHOICE=$(echo "$PROJECT_CHOICE" | tr -d '\r')  # Remove Windows carriage return

read -p "Enter project name: " PROJECT_NAME
PROJECT_NAME=$(echo "$PROJECT_NAME" | tr -d '\r')

# ----------- Project description -----------
read -p "Enter project description / goal: " PROJECT_DESC
PROJECT_DESC=$(echo "$PROJECT_DESC" | tr -d '\r')

# ----------- Tailwind yes/no -----------
read -p "Do you want to install Tailwind? (y/n) " INSTALL_TAILWIND
INSTALL_TAILWIND=$(echo "$INSTALL_TAILWIND" | tr -d '\r' | tr '[:upper:]' '[:lower:]')

# ----------- PWA yes/no (web only) -----------
INSTALL_PWA="n"
if [[ "$PROJECT_CHOICE" == "1" || "$PROJECT_CHOICE" == "2" ]]; then
  read -p "Do you want to enable PWA support? (y/n) " INSTALL_PWA
  INSTALL_PWA=$(echo "$INSTALL_PWA" | tr -d '\r' | tr '[:upper:]' '[:lower:]')
fi

# ----------- Docs folder -----------
read -p "Do you want to create docs/ folder with templates? (y/n) " CREATE_DOCS
CREATE_DOCS=$(echo "$CREATE_DOCS" | tr -d '\r' | tr '[:upper:]' '[:lower:]')

# ----------- Components folder -----------
read -p "Do you want to create components/ folder? (y/n) " CREATE_COMPONENTS
CREATE_COMPONENTS=$(echo "$CREATE_COMPONENTS" | tr -d '\r' | tr '[:upper:]' '[:lower:]')

# ----------- Hooks folder -----------
read -p "Do you want to create hooks/ folder? (y/n) " CREATE_HOOKS
CREATE_HOOKS=$(echo "$CREATE_HOOKS" | tr -d '\r' | tr '[:upper:]' '[:lower:]')

# ----------- Auto-start dev server -----------
read -p "Do you want to auto-start the dev server? (y/n) " AUTO_START
AUTO_START=$(echo "$AUTO_START" | tr -d '\r' | tr '[:upper:]' '[:lower:]')

# ----------- Functions for Tailwind & PWA -----------
install_tailwind_react() {
  npm install -D tailwindcss postcss autoprefixer
  npx tailwindcss init -p
  echo "Tailwind installed for React project."
}

install_tailwind_next() {
  npm install -D tailwindcss postcss autoprefixer
  npx tailwindcss init -p
  echo "Tailwind installed for Next.js project."
}

install_tailwind_rn() {
  npm install tailwindcss-react-native
  npx tailwindcss init
  echo "Tailwind installed for React Native project."
}

install_pwa_next() {
  npm install next-pwa
  echo "Next.js PWA plugin installed."
  # Configure next.config.js automatically
  if grep -q "next.config.js" <<< "$(ls)"; then
    echo "Adding PWA config to next.config.js..."
    cat <<EOL >> next.config.js

const withPWA = require('next-pwa')({
  dest: 'public'
});

module.exports = withPWA({
  reactStrictMode: true,
});
EOL
  fi
  # Start server briefly to test and then continue
  npm run dev &
  SERVER_PID=$!
  sleep 5
  if [[ "$PLATFORM" != "windows" ]]; then
    xdg-open http://localhost:3000 || open http://localhost:3000
  else
    start http://localhost:3000
  fi
  kill $SERVER_PID
  echo "PWA test page opened and server stopped."
}

install_pwa_react() {
  echo "Enable service worker manually in CRA to complete PWA setup."
}

# ----------- Functions to create folders -----------
create_docs_folder() {
  mkdir -p docs
  [[ ! -f docs/setup.md ]] && echo "# Setup Instructions" > docs/setup.md
  [[ ! -f docs/todo.md ]] && echo "# Todo List" > docs/todo.md
  [[ ! -f docs/architecture.md ]] && echo "# Architecture" > docs/architecture.md
  echo "Docs folder created with template files."
}

create_components_folder() {
  mkdir -p src/components
  echo "Components folder created."
}

create_hooks_folder() {
  mkdir -p src/hooks
  echo "Hooks folder created."
}

# ----------- Metadata -----------
create_metadata() {
  METADATA_FILE="project_metadata.json"
  cat <<EOL > $METADATA_FILE
{
  "project_name": "$PROJECT_NAME",
  "project_description": "$PROJECT_DESC",
  "project_type": "$PROJECT_CHOICE",
  "tailwind": "$INSTALL_TAILWIND",
  "pwa": "$INSTALL_PWA",
  "created_at": "$(date)"
}
EOL
  echo "Metadata file created: $METADATA_FILE"
}

# ----------- README (append only missing parts) -----------
update_readme() {
  if [[ ! -f README.md ]]; then
    cat <<EOL > README.md
# $PROJECT_NAME

## Description
$PROJECT_DESC

## Setup
- Install dependencies: npm install
- Run dev server: npm start / npm run dev / npx expo start
EOL
    echo "README.md created."
  else
    echo "README.md exists. Appending missing sections..."
    grep -q "## Setup" README.md || cat <<EOL >> README.md

## Setup
- Install dependencies: npm install
- Run dev server: npm start / npm run dev / npx expo start
EOL
  fi
}

# ----------- Project Setup -----------
if [[ "$PROJECT_CHOICE" == "1" ]]; then
  echo "Setting up React project..."
  npx create-react-app $PROJECT_NAME
  cd $PROJECT_NAME || exit
  [[ "$INSTALL_TAILWIND" == "y" ]] && install_tailwind_react
  [[ "$INSTALL_PWA" == "y" ]] && install_pwa_react
elif [[ "$PROJECT_CHOICE" == "2" ]]; then
  echo "Setting up Next.js project..."
  npx create-next-app@latest $PROJECT_NAME
  cd $PROJECT_NAME || exit
  [[ "$INSTALL_TAILWIND" == "y" ]] && install_tailwind_next
  [[ "$INSTALL_PWA" == "y" ]] && install_pwa_next
elif [[ "$PROJECT_CHOICE" == "3" ]]; then
  echo "Setting up Expo React Native project..."
  npx create-expo-app $PROJECT_NAME
  cd $PROJECT_NAME || exit
  [[ "$INSTALL_TAILWIND" == "y" ]] && install_tailwind_rn
else
  echo "Invalid choice!"
  exit 1
fi

# ----------- Create folders & metadata -----------
[[ "$CREATE_DOCS" == "y" ]] && create_docs_folder
[[ "$CREATE_COMPONENTS" == "y" ]] && create_components_folder
[[ "$CREATE_HOOKS" == "y" ]] && create_hooks_folder
create_metadata
update_readme

# ----------- Auto-start dev server -----------
if [[ "$AUTO_START" == "y" ]]; then
  if [[ "$PROJECT_CHOICE" == "1" ]]; then
    npm start
  elif [[ "$PROJECT_CHOICE" == "2" ]]; then
    npm run dev
  elif [[ "$PROJECT_CHOICE" == "3" ]]; then
    npx expo start
  fi
fi

echo "✅ Project setup complete!"
