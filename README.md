# 📁 Folder2Text

**Folder2Text** is a Flutter-based **Windows desktop application** that extracts the complete contents of a folder — including **file paths and file contents** — into a clean, readable text format **without modifying indentation or code structure**.

It is designed for developers, code reviewers, AI prompts, documentation, and backups.

---

## ✨ Features

* 📂 **Drag & Drop Folder Support**
* 📁 **Browse & Select Folder**
* 🧾 **Extract Full File Paths + Content**
* 🧠 **Preserves Original Code Indentation**
* 🌳 **Generate Folder Structure (Tree View)**
* 👁️ **Preview Large Outputs Safely**
* 📋 **Copy Output to Clipboard**
* 💾 **Export Output to `.txt` or `.md`**
* ⚙️ **Option to Include Hidden Files**
* 🚀 **Handles Large Projects Efficiently (Isolates)**

---

## 🖥️ Platform Support

| Platform   | Status      |
| ---------- | ----------- |
| Windows 10 | ✅ Supported |
| Windows 11 | ✅ Supported |
| macOS      | 🚧 Planned  |
| Linux      | 🚧 Planned  |

> ⚠️ Currently distributed as a **Windows desktop app**

---

## 📸 App Overview

### File Content View

* Displays extracted file paths and file content
* Syntax-friendly monospace viewer
* Optimized for large outputs

### File Structure View

* Generates a tree-style folder structure
* Shows file sizes
* Useful for documentation & audits

---

## 🛠️ Built With

* **Flutter (Windows Desktop)**
* **Dart**
* **Isolates (for performance)**
* **Inno Setup (Installer)**

---

## 📦 Installation (Windows)

### 🔹 Option 1: Installer (Recommended)

1. Download `Folder2TextSetup.exe` from **GitHub Releases**
2. Run the installer
3. Launch from Start Menu or Desktop
4. Drag & drop a folder or click **Browse**

### 🔹 Option 2: Portable (Advanced)

(Planned for future release)

---

## 🚀 How to Use

1. Launch **Folder2Text**
2. Drag & drop a folder **or** click **Browse**
3. Choose options:

   * Include hidden files (optional)
4. View:

   * **File Content** tab → full text output
   * **File Structure** tab → tree view
5. Export or copy output

---

## 📂 Example Output

```
folder2text/lib/main.dart
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}
```

```
📁 folder2text
├── 📁 lib/
│   ├── 📄 main.dart (2.1 KB)
│   └── 📄 app.dart (4.3 KB)
└── 📄 pubspec.yaml (1.2 KB)
```

---

## ⚡ Performance Notes

* Uses **Flutter isolates** for scanning large folders
* Prevents UI freezing
* Automatically limits preview size for safety
* Full output can still be loaded on demand

---

## 🔐 Privacy & Security

* ❌ No internet access
* ❌ No analytics
* ❌ No tracking
* ✅ Works fully offline
* ✅ All processing is local

---

## 🧪 Development Setup (For Contributors)

### Requirements

* Flutter SDK (latest stable)
* Windows 10/11 (64-bit)

### Run Locally

```bash
flutter pub get
flutter run -d windows
```

### Build Release

```bash
flutter build windows --release
```

---

## 📁 Project Structure

```
lib/
 ├── core/
 │   ├── utils/
 │   └── theme/
 ├── services/
 └── ui/
     ├── screens/
     └── widgets/
```

---

## ⭐ Support

If you find this project useful:

* ⭐ Star the repository
* 🐛 Report issues
* 💡 Suggest features

---