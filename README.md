# Najd Volunteer

Volunteer coordination mobile app (Flutter + Supabase) for iOS and Android.

## Where are the files?

All project files are under your **najd** folder:

```
najd/
├── lib/
│   ├── main.dart                 ← App entry
│   ├── config/                   ← app_config.dart, theme.dart
│   ├── models/                   ← volunteer, task_model, app_notification
│   ├── services/                 ← auth, volunteer, task, notification, user_profile
│   ├── providers/                ← auth_provider
│   └── screens/                  ← All UI screens
│       ├── auth/                 ← login, signup
│       ├── volunteers/           ← list, profile, add
│       ├── tasks/                ← list, create, details
│       ├── splash_screen.dart
│       ├── dashboard_screen.dart
│       ├── notifications_screen.dart
│       ├── settings_screen.dart
│       └── my_profile_screen.dart
├── supabase/
│   └── schema.sql                ← Database schema
├── pubspec.yaml
└── README.md
```

**In Cursor/VS Code:** Open the **Explorer** (left sidebar, file icon). Your workspace root is the **najd** folder. Expand `lib` to see `main.dart`, `config`, `models`, `services`, `providers`, and `screens`.

If you don’t see them:
1. **File → Open Folder** and choose `c:\Users\mo3az\OneDrive\Desktop\najd`.
2. Or use **Ctrl+K Ctrl+O** (Open Folder) and select the **najd** folder.

## Run and test the app

### Option 1: Double‑click run script (Windows)

1. In File Explorer, go to the **najd** folder.
2. Double‑click **`run_app.bat`**.
   - If Flutter is in your PATH, it will add platform folders (if needed), run `flutter pub get`, then `flutter run`.
   - If you see “Flutter not found”, install Flutter and add it to PATH, then try again.

### Option 2: Terminal

1. Open a terminal (PowerShell or CMD) where Flutter works.
2. Go to the project folder:
   ```bash
   cd c:\Users\mo3az\OneDrive\Desktop\najd
   ```
3. If `android` and `ios` folders are missing:
   ```bash
   flutter create . --project-name najd_volunteer
   ```
4. Then:
   ```bash
   flutter pub get
   flutter run
   ```
5. Pick a device when prompted. **If you see a “NeverType” / postgrest compile error on Chrome**, run on **Windows** instead:  
   `flutter run -d windows`  
   (This is a known Flutter Web + postgrest bug; Windows and Android are unaffected.)

6. **Windows desktop:** If you get “symlink support”, enable **Developer Mode** in Settings → For developers.  
   If you get **“Unable to find suitable Visual Studio toolchain”**:  
   - Open **Visual Studio Installer** → **Modify** your VS 2022 install.  
   - Enable the workload **“Desktop development with C++”**.  
   - In the right-hand details, also select: **MSVC v142** (or latest) **C++ x64/x86 build tools**, **C++ CMake tools for Windows**, **Windows 10 SDK**.  
   - Install, then run `flutter run -d windows` again.

7. **No Windows toolchain?** Use an **Android emulator**: run `flutter emulators` to list, then `flutter emulators --launch <emulator_id>` to start one, then `flutter run -d android`.

### Option 3: Docker Dev Container

Use a containerized Flutter development environment with all dependencies pre-installed.

**Prerequisites:**
- Docker Desktop installed and running
- VS Code with Remote - Containers extension

**Setup:**
1. Clone or open the project:
   ```bash
   cd /path/to/najd
   ```

2. In VS Code, open the command palette (`Cmd+Shift+P` on Mac) and run:
   ```
   Dev Containers: Reopen in Container
   ```

3. VS Code will build the container and install all Flutter/Dart dependencies automatically.

4. Once ready, run:
   ```bash
   flutter pub get
   flutter run
   ```

**Available Make commands:**
```bash
make dev      # Set up dev environment
make analyze  # Analyze code
make test     # Run tests
make clean    # Clean build artifacts
make help     # Show all commands
```

### Supabase (for full sign-in and data)

- The app will **start and show the UI** even without Supabase.
- To **sign in and use data**, create a project at [supabase.com](https://supabase.com), run **`supabase/schema.sql`** in the SQL Editor, then in **`lib/config/app_config.dart`** replace `YOUR_PROJECT_REF` and `YOUR_ANON_KEY` with your Project URL and anon key (from Project Settings → API).
