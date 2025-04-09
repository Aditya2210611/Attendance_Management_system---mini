

# 📘 Attendance Management System

A Flutter-based mini project designed to streamline and manage student attendance for teachers and students within an academic setting. This system runs entirely on **localhost** using **static credentials** and offers features such as real-time attendance marking, Excel/PDF report generation, dashboards, and student-wise analytics.

🚀 Features

 👨‍🏫 Teacher Module
- Secure login with static credentials.
- Create and manage multiple classes.
- Record attendance with auto-generated Excel reports.
- Edit and view attendance history.
- Manually add students if required.
- Filter students with attendance below 75% and generate special reports.

👨‍🎓 Student Module
- Login with predefined credentials.
- View overall and subject-wise attendance statistics.

📊 Dashboard
- Quick access to:
  - Recent attendance logs
  - Upcoming class schedules
  - Attendance summaries

📑 Reports
- Generate **Daily**, **Weekly**, and **Monthly** attendance reports.
- Export reports as **PDF**.
- Filter reports by date, class, or student.

 🧑‍🏫 Class & Student Management
- Add, Edit, and Delete classes.
- Assign students to classes.
- View individual student attendance history.

 🌗 UI & User Experience
- Responsive design with smooth animations.
- Light/Dark mode toggle.
- Clean UI with names only (no photos or profile images).

 🛠️ Tech Stack

- **Frontend:** Flutter (Dart)
- **Local Storage:** JSON & File System
- **Export Libraries:** `excel`, `pdf` (Flutter plugins)
- **Platform:** Runs entirely on localhost

📂 Static Credentials

All user login details are stored in a `.txt` file.  
Includes:
- **1 Teacher Account**
- **20 Student Accounts**

🧪 How to Run

1. Get Flutter packages:

   •  flutter pub get
   
3. Run the app:

   •  flutter run -d chrome

