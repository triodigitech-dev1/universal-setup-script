#!/bin/bash

# ==================================================
# UNIVERSAL REACT / NEXT / EXPO SETUP SCRIPT
# FULL VERSION: Webpack + PWA + Tailwind + Manifest + Icons
# ==================================================

echo "🚀 Welcome to the Project Setup Script!"

# ----------- OS Detection -----------
OS_TYPE=$(uname -s)
case "$OS_TYPE" in
  Darwin*) PLATFORM="mac" ;;
  Linux*) PLATFORM="linux" ;;
  MINGW*|CYGWIN*|MSYS*) PLATFORM="windows" ;;
  *) PLATFORM="unknown" ;;
esac
echo "🌐 Detected platform: $PLATFORM"

# ----------- Helpers -----------
normalize() { echo "$1" | tr -d '\r' | tr '[:upper:]' '[:lower:]'; }
run_tailwind_init() { echo "⚡ Initializing Tailwind CSS..."; npm exec --yes tailwindcss init -p || echo "⚠️ Tailwind init failed"; }
clean_next_dev() { [[ -f .next/dev/lock ]] && rm -f .next/dev/lock; }

# ----------- User Input -----------
echo ""
echo "📂 Select project type:"
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
  read -p "Enable PWA support? (y/n): " INSTALL_PWA
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

echo ""
echo "⏳ Creating project '$PROJECT_NAME'..."

# ----------- Tailwind / PWA Functions -----------

install_tailwind_react() {
  echo "🌈 Installing Tailwind for React..."
  npm install -D tailwindcss postcss autoprefixer
  run_tailwind_init
  echo "✅ Tailwind setup complete"
}

install_tailwind_rn() {
  echo "🌈 Installing Tailwind for React Native..."
  npm install tailwindcss-react-native
  run_tailwind_init
  echo "✅ Tailwind setup complete"
}

check_tailwind_next() {
  echo "🔍 Checking Tailwind for Next.js..."
  if npm list tailwindcss >/dev/null 2>&1; then
    VERSION=$(npm list tailwindcss --depth=0 2>/dev/null | grep tailwindcss | sed 's/.*@//')
    echo "✅ Tailwind detected (v$VERSION)"
    if [[ -f tailwind.config.js || -f tailwind.config.ts ]]; then
      echo "✅ Tailwind config already exists, skipping init"
    else
      echo "⚠️ Tailwind installed but config missing"
      read -p "Do you want to generate tailwind.config.js now? (y/n): " CONFIRM
      CONFIRM=$(normalize "$CONFIRM")
      [[ "$CONFIRM" == "y" ]] && run_tailwind_init
    fi
  else
    echo "⚠️ Tailwind not found"
    read -p "Install Tailwind for Next.js? (y/n): " CONFIRM
    CONFIRM=$(normalize "$CONFIRM")
    [[ "$CONFIRM" == "y" ]] && { npm install -D tailwindcss postcss autoprefixer; run_tailwind_init; }
  fi
}

install_pwa_next() {
  echo "📦 Installing next-pwa..."
  npm install next-pwa
  clean_next_dev
  echo "🔧 Writing dev-safe next.config.js with PWA support..."
  cat > next.config.js <<EOF
/** @type {import('next').NextConfig} */
const withPWA = require('next-pwa')({
  dest: 'public',
  disable: process.env.NODE_ENV === 'development' // disables SW in dev
});

const nextConfig = {
  reactStrictMode: true
};

module.exports = withPWA(nextConfig);
EOF

  echo "✅ PWA configured (SW disabled in dev)"

  # ----------- Generate default manifest.json -----------
  mkdir -p public
  cat > public/manifest.json <<EOF
{
  "name": "$PROJECT_NAME",
  "short_name": "PWA",
  "start_url": "/",
  "display": "standalone",
  "background_color": "#ffffff",
  "theme_color": "#0d9488",
  "icons": [
    {
      "src": "/icon-192.png",
      "sizes": "192x192",
      "type": "image/png"
    },
    {
      "src": "/icon-512.png",
      "sizes": "512x512",
      "type": "image/png"
    }
  ]
}
EOF
  # ----------- Create placeholder icons -----------
  if ! command -v convert >/dev/null 2>&1; then
    echo "⚠️ ImageMagick not found. Please add icons manually to public/."
  else
    convert -size 192x192 xc:gray public/icon-192.png
    convert -size 512x512 xc:gray public/icon-512.png
    echo "✅ Default PWA icons created in public/"
  fi
}

# ----------- Folder & Metadata Functions -----------
create_docs_folder() {
  echo "📄 Creating docs folder..."
  mkdir -p docs
  echo "# Setup" > docs/setup.md
  echo "# Todo" > docs/todo.md
  echo "# Architecture" > docs/architecture.md
  echo "✅ docs/ folder created"
}

create_components_folder() { mkdir -p src/components; echo "✅ components/ folder created"; }
create_hooks_folder() { mkdir -p src/hooks; echo "✅ hooks/ folder created"; }

create_metadata() {
  cat > project_metadata.json <<EOF
{
  "project_name": "$PROJECT_NAME",
  "description": "$PROJECT_DESC",
  "platform": "$PLATFORM",
  "created_at": "$(date)"
}
EOF
  echo "📝 project_metadata.json created"
}

update_readme() {
  if [[ ! -f README.md ]]; then
    cat > README.md <<EOF
# $PROJECT_NAME

## Description
$PROJECT_DESC

## Setup
- npm install
- npm start / npm run dev / npx expo start
- Production PWA: npm run build && npm run start
EOF
    echo "📘 README.md created"
  fi
}

# ----------- Project Creation -----------
if [[ "$PROJECT_CHOICE" == "1" ]]; then
  npx create-react-app "$PROJECT_NAME"
elif [[ "$PROJECT_CHOICE" == "2" ]]; then
  npx create-next-app@latest "$PROJECT_NAME"
elif [[ "$PROJECT_CHOICE" == "3" ]]; then
  npx create-expo-app "$PROJECT_NAME"
else
  echo "❌ Invalid project type"; exit 1
fi

# ----------- Enter Project Folder -----------
cd "$PROJECT_NAME" || { echo "❌ Failed to enter project folder"; exit 1; }
echo "📂 Entered project folder: $(pwd)"

# ----------- Post-creation Tasks -----------
if [[ "$PROJECT_CHOICE" == "1" ]]; then
  [[ "$INSTALL_TAILWIND" == "y" ]] && install_tailwind_react
elif [[ "$PROJECT_CHOICE" == "2" ]]; then
  [[ "$INSTALL_TAILWIND" == "y" ]] && check_tailwind_next
  [[ "$INSTALL_PWA" == "y" ]] && install_pwa_next
elif [[ "$PROJECT_CHOICE" == "3" ]]; then
  [[ "$INSTALL_TAILWIND" == "y" ]] && install_tailwind_rn
fi

[[ "$CREATE_DOCS" == "y" ]] && create_docs_folder
[[ "$CREATE_COMPONENTS" == "y" ]] && create_components_folder
[[ "$CREATE_HOOKS" == "y" ]] && create_hooks_folder
create_metadata
update_readme

# ----------- Force Webpack for dev and build (Next.js) -----------
if [[ "$PROJECT_CHOICE" == "2" ]]; then
  echo "🔧 Overwriting package.json scripts to force Webpack for dev and build..."
  npm pkg set scripts.dev="next dev --webpack"
  npm pkg set scripts.build="next build --webpack"
  npm pkg set scripts.start="next start"
fi

# ----------- Auto Start Dev Server -----------
if [[ "$AUTO_START" == "y" ]]; then
  echo ""
  echo "⚡ Starting dev server..."
  if [[ "$PROJECT_CHOICE" == "2" ]]; then
    echo "🌐 Next.js dev server (Webpack mode)"
    npm run dev
  elif [[ "$PROJECT_CHOICE" == "1" ]]; then
    echo "🌐 React (CRA) dev server"
    npm start
  else
    echo "🌐 Expo dev server"
    npx expo start
  fi
fi

echo ""
echo "🎉 Project setup complete! Ready for development."
echo "💡 To test production PWA: npm run build && npm run start"
echo "💡 After production start, open DevTools → Application → Service Workers → Install App button should appear"
