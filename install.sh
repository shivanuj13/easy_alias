#!/bin/bash

# Step 1: Compile the Dart CLI app
echo "🔨 Compiling Dart CLI to native executable..."
dart compile exe bin/ea.dart -o ea

# Step 2: Make it executable
chmod +x ea

# Step 3: Copy to /usr/local/bin so it can be run as 'ea' globally
echo "📦 Copying binary to /usr/local/bin/ea..."
sudo cp ea /usr/local/bin/ea

# Step 4: Confirm installation
if command -v ea &> /dev/null; then
  echo "✅ 'ea' command installed successfully! You can now run it from anywhere:"
  echo "   👉 Try: ea"
else
  echo "❌ Installation failed. Make sure /usr/local/bin is in your PATH."
fi
