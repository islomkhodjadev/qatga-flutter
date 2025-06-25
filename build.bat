@echo off
echo 🚀 Building BoysHub for Web with Performance Optimizations...

REM Clean previous build
echo 🧹 Cleaning previous build...
flutter clean

REM Get dependencies
echo 📦 Getting dependencies...
flutter pub get

REM Build for web with optimizations
echo 🔨 Building for web...
flutter build web ^
  --release ^
  --web-renderer canvaskit ^
  --pwa-strategy offline-first ^
  --base-href "/"

echo ✅ Build completed successfully!
echo 📁 Build output: build/web/
echo 🚀 Deploy the contents of build/web/ to your web server

pause 