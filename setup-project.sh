#!/bin/bash

# ==================================================
# Universal React / Next / Expo Setup Script
# FINAL – OS AWARE – TOOLCHAIN AWARE
# ==================================================

# ----------- OS Detection (Git Bash Safe) -----------
OS_TYPE=$(uname -s)

case "$OS_TYPE" in
  Darwin*) PLATFORM="mac" ;;
  Linux*) PLATFORM="linux" ;;
  MINGW*|CYGWIN*|MSYS*) PLATFORM="windows" ;;
  *) PLATFORM="unknown" ;;
esac

echo "Detected platform: $PLATFORM"

# ----------- Helpers -----------
normalize() {
  echo "$1" | tr -d '\r' | tr '[:upper:]' '[:lower:]'
}

run_tailwind_init() {
  npm exec --yes tailwindcss init -p || return 1
}

clean_next_dev() {
  [[ -f .next/dev/lock ]] && rm -f .next/dev/lock
}

# ----------- UI -----------
echo "Choose project type:"
echo "1) React (Web)"
echo "2) Next.js (Web)"
echo "3) React Native (Expo)"
read -p "Enter number: " PROJECT_CHOICE
PROJECT_CHOICE=$(normalize "$PROJECT_CHOICE")

read -p "Enter project name: " PROJECT_NAME
read -p "Enter project description: " PROJECT_DESC

read -p "Use Tailwind CSS? (y/n): " INSTALL_TAILWIND
INSTALL_TAILWIND=$(normalize "$INSTALL_TAILWIND")

INSTALL_PWA="n"
if [[ "$PROJECT_CHOICE" == "2" ]]; then
  read -p "Enable PWA? (y/n): " INSTALL_PWA
  INSTALL_PWA=$(normalize "$INSTALL_PWA")
fi

read -p "Create docs folder? (y/n): " CREATE_DOCS
read -p "Create components folder? (y/n): " CREATE_COMPONENTS
read -p "Create hooks folder? (y/n): " CREATE_HOOKS
read -p "Auto-start dev server? (y/n): " AUTO_START

CREATE_DOCS=$(normalize "$CREATE_DOCS")
CREATE_COMPONENTS=$(normalize "$CREATE_COMPONENTS")
CREATE_HOOKS=$(normalize "$CREATE_HOOKS")
AUTO_START=$(normalize "$AUTO_START")

# ----------- Tailwind Logic -----------

install_tailwind_react() {
  npm install -D tailwindcss postcss autoprefixer
  run_tailwind_init || echo "⚠️ Tailwind init failed"
}

install_tailwind_rn() {
  npm install tailwindcss-react-native
  run_tailwind_init || echo "⚠️ Tailwind init failed"
}

check_tailwind_next() {
  echo "Checking Tailwind setup for Next.js..."

  if npm list tailwindcss >/dev/null 2>&1; then
    VERSION=$(npm list tailwindcss --depth=0 2>/dev/null | grep tailwindcss | sed 's/.*@//')
    echo "✅ Tailwind detected (v$VERSION)"

    if [[ -f tailwind.config.js || -f tailwind.config.ts ]]; then
      echo "✅ Tailwind config present"
    else
      echo "⚠️ Tailwind installed but config missing"
      echo "Generating config..."
      run_tailwind_init || echo "⚠️ Could not generate Tailwind config"
    fi
  else
    echo "❌ Tailwind not found"
    read -p "Install Tailwind for this Next.js project? (y/n): " CONFIRM
    CONFIRM=$(normalize "$CONFIRM")

    if [[ "$CONFIRM" == "y" ]]; then
      npm install -D tailwindcss postcss autoprefixer
      run_tailwind_init || echo "⚠️ Tailwind init failed"
    else
      echo "Skipping Tailwind setup"
    fi
  fi
}

# ----------- PWA (Next.js only) -----------
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

# ----------- Structure -----------

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

create_metadata() {
  cat > project_metadata.json <<EOF
{
  "project_name": "$PROJECT_NAME",
  "description": "$PROJECT_DESC",
  "platform": "$PLATFORM",
  "created_at": "$(date)"
}
EOF
}

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
  fi
}

# ----------- Project Setup -----------

if [[ "$PROJECT_CHOICE" == "1" ]]; then
  npx create-react-app "$PROJECT_NAME"
  cd "$PROJECT_NAME" || exit 1
  [[ "$INSTALL_TAILWIND" == "y" ]] && install_tailwind_react

elif [[ "$PROJECT_CHOICE" == "2" ]]; then
  npx create-next-app@latest "$PROJECT_NAME"
  cd "$PROJECT_NAME" || exit 1
  [[ "$INSTALL_TAILWIND" == "y" ]] && check_tailwind_next
  [[ "$INSTALL_PWA" == "y" ]] && install_pwa_next

elif [[ "$PROJECT_CHOICE" == "3" ]]; then
  npx create-expo-app "$PROJECT_NAME"
  cd "$PROJECT_NAME" || exit 1
  [[ "$INSTALL_TAILWIND" == "y" ]] && install_tailwind_rn

else
  echo "Invalid project type"
  exit 1
fi

# ----------- Extras (ALWAYS RUN) -----------

[[ "$CREATE_DOCS" == "y" ]] && create_docs_folder
[[ "$CREATE_COMPONENTS" == "y" ]] && create_components_folder
[[ "$CREATE_HOOKS" == "y" ]] && create_hooks_folder

create_metadata
update_readme

# ----------- Auto Start -----------

if [[ "$AUTO_START" == "y" ]]; then
  if [[ "$PROJECT_CHOICE" == "2" ]]; then
    npm run dev
  elif [[ "$PROJECT_CHOICE" == "1" ]]; then
    npm start
  else
    npx expo start
  fi
fi

echo "✅ Project setup complete"
