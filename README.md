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

### 3. Set up Supabase

This app needs its own Supabase project — no shared credentials or data are included in this repo.

1. Create a free project at [supabase.com](https://supabase.com).
2. In your Supabase project, go to **Project Settings → API** and copy:
   - **Project URL**
   - **anon public key**
3. Create the `expenses` table by running this SQL in the Supabase SQL Editor:

   ```sql
   create table expenses (
     id uuid primary key default gen_random_uuid(),
     user_id uuid references auth.users(id) not null,
     title text not null,
     amount numeric not null,
     category text not null,
     created_at timestamptz not null default now()
   );

   alter table expenses enable row level security;

   create policy "Users can manage their own expenses"
     on expenses
     for all
     using (auth.uid() = user_id)
     with check (auth.uid() = user_id);
   ```

4. Enable **Email/Password auth** under **Authentication → Providers** (this app currently maps a user-entered ID number to an email like `idno@myapp.com` — see `login.dart`).

### 4. Add your Supabase credentials

This project currently reads credentials directly from `lib/main.dart`. **Do not commit your real keys to a public repo.** Instead:

1. Open `lib/main.dart`.
2. Replace the placeholder values with your own project's URL and anon key:

   ```dart
   await Supabase.initialize(
     url: 'YOUR_SUPABASE_PROJECT_URL',
     anonKey: 'YOUR_SUPABASE_ANON_KEY',
   );
   ```

   > The Supabase **anon key** is safe to expose in a client app *only* when Row Level Security (RLS) policies are correctly configured (as set up in step 3 above). Never use your **service_role** key in client code.

3. Alternatively (recommended for public repos), pass credentials at build time instead of hardcoding them:

   ```bash
   flutter run \
     --dart-define=SUPABASE_URL=your_supabase_project_url \
     --dart-define=SUPABASE_ANON_KEY=your_supabase_anon_key
   ```

   and read them in code via `String.fromEnvironment('SUPABASE_URL')`. This keeps secrets out of version control entirely.

### 5. Run the app

```bash
flutter run
```

Select a connected device or emulator when prompted.

---

## Project Structure

```
lib/
├── main.dart          # App entry point, Supabase init, auth state routing
├── login.dart         # Login screen (Supabase email/password auth)
├── home.dart          # Home dashboard: totals, chart, grouped expense list
├── add_expenses.dart  # Add expense form
```

---


