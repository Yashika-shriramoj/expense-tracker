# Expense Tracker (Flutter + Supabase)

A cross-platform mobile app to track daily income and expenses, categorize spending, and visualize where your money goes — built with Flutter and Supabase.

> **Status:** Actively in development. Core flows (auth, add expense, home dashboard) are functional; more features are being added incrementally.

---

## Features (so far)

- User login (Supabase Auth)
- Add expenses with title, amount, category, and date
- Home dashboard showing:
  - Total amount spent
  - Pie chart breakdown by category
  - Expense list grouped under date headers (Today / Yesterday / specific dates)
- Custom app theme with a consistent color palette and category icons
- Data stored remotely in Supabase (PostgreSQL) instead of only on-device

## Planned / In Progress

- Edit and delete existing expenses (swipe actions)
- Income tracking alongside expenses
- Filter by date range / month
- Export data (CSV/PDF)
- Dark mode

---

## Tech Stack

| Layer               | Technology                                     |
|---------------------|-------------------------------------------------|
| Framework           | Flutter (Dart)                                  |
| Backend / Auth / DB | [Supabase](https://supabase.com) (PostgreSQL)   |
| Charts              | [fl_chart](https://pub.dev/packages/fl_chart)   |

---

## Prerequisites

Before running this project, make sure you have:

- [Flutter SDK](https://docs.flutter.dev/get-started/install) (3.x or later) installed and set up (`flutter doctor` should show no blocking issues)
- A code editor (VS Code or Android Studio recommended, with the Flutter/Dart plugins)
- A free [Supabase](https://supabase.com) account and project
- Git installed

---

## Setup Instructions

### 1. Clone the repository

```bash
git clone https://github.com/<your-username>/<your-repo-name>.git
cd <your-repo-name>
```

### 2. Install dependencies

```bash
flutter pub get
```

### 3. Run the app

```bash
flutter run
```

Select a connected device or emulator when prompted.

---
This project uses Supabase for login authentication and storing the user data.
The credentials are hardcoded in main.dart
Use login id: 1002 and password: 123456789 to login and see sample user data.

## Project Structure

```
lib/
├── main.dart          # App entry point, Supabase init, auth state routing
├── login.dart         # Login screen (Supabase email/password auth)
├── home.dart          # Home dashboard: totals, chart, grouped expense list
├── add_expenses.dart  # Add expense form
```

---


