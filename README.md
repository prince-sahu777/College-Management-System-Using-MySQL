# College Management System (MySQL)

A relational database for managing a college: departments, students, teachers, courses, enrollments, attendance, exams, results and fee payments. Built to practice and demonstrate core SQL concepts.

## Requirements
- MySQL 8.0 or later (uses `utf8mb4_0900_ai_ci`, `CHECK` constraints and expression defaults)

## Quick start
```bash
mysql -u root -p < college_management.sql
```
> ⚠️ The script runs `DROP DATABASE IF EXISTS college_management`, so don't run it on a server holding a database with that name you want to keep.

## Database schema
| Table | Purpose |
|---|---|
| `Departments` | Academic departments |
| `Students` | Student records (linked to a department) |
| `Teachers` | Faculty (linked to a department) |
| `Courses` | Courses, each with a department and optional teacher |
| `Enrollments` | Student ↔ course (unique per pair) |
| `Attendance` | Per-session attendance status |
| `Examinations` | Exams per course with maximum marks |
| `Results` | Marks and grades per student per exam |
| `Fee_Payments` | Payment history |
| `Student_Audit_Log` | Auto-filled by trigger when a student is updated |

## What's inside
1. Tables with primary/foreign keys, `UNIQUE`, `CHECK`, `ENUM` and indexes
2. Sample data
3. CRUD operations
4. Joins (inner, left, right, self)
5. Aggregates and `GROUP BY`
6. `HAVING` and subqueries
7. Views: student details, course details, results, attendance, fees
8. Function `fn_student_average_marks`, procedures (`sp_*`) and triggers (marks validation, student audit log)
9. Routine and trigger tests
10. Transactions with `COMMIT`, `ROLLBACK`, `SAVEPOINT`
11. Row-count verification

## License
MIT
