-- ======================================================================
-- College Management System (MySQL 8.0+)
-- Schema, sample data, queries, views, routines, triggers, transactions.
-- Usage:  mysql -u <user> -p < college_management.sql
-- WARNING: drops and recreates the `college_management` database.
-- ======================================================================

DROP DATABASE IF EXISTS college_management;
CREATE DATABASE college_management
  CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE college_management;

-- ======================================================================
-- 1. TABLES
-- ======================================================================

CREATE TABLE Departments (
    department_id INT AUTO_INCREMENT PRIMARY KEY,
    department_name VARCHAR(100) NOT NULL UNIQUE,
    office_location VARCHAR(100) NOT NULL
) ENGINE=InnoDB;

CREATE TABLE Students (
    student_id INT AUTO_INCREMENT PRIMARY KEY,
    student_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    date_of_birth DATE,
    gender ENUM('Female','Male','Other','Prefer not to say') DEFAULT 'Prefer not to say',
    admission_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    department_id INT NOT NULL,
    CONSTRAINT fk_students_department FOREIGN KEY (department_id)
      REFERENCES Departments(department_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_students_department (department_id)
) ENGINE=InnoDB;

CREATE TABLE Teachers (
    teacher_id INT AUTO_INCREMENT PRIMARY KEY,
    teacher_name VARCHAR(100) NOT NULL,
    email VARCHAR(150) NOT NULL UNIQUE,
    phone VARCHAR(20),
    department_id INT NOT NULL,
    CONSTRAINT fk_teachers_department FOREIGN KEY (department_id)
      REFERENCES Departments(department_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    INDEX idx_teachers_department (department_id)
) ENGINE=InnoDB;

CREATE TABLE Courses (
    course_id INT AUTO_INCREMENT PRIMARY KEY,
    course_name VARCHAR(120) NOT NULL,
    credits TINYINT UNSIGNED NOT NULL,
    department_id INT NOT NULL,
    teacher_id INT,
    CONSTRAINT chk_course_credits CHECK (credits BETWEEN 1 AND 6),
    CONSTRAINT fk_courses_department FOREIGN KEY (department_id)
      REFERENCES Departments(department_id)
      ON UPDATE CASCADE ON DELETE RESTRICT,
    CONSTRAINT fk_courses_teacher FOREIGN KEY (teacher_id)
      REFERENCES Teachers(teacher_id)
      ON UPDATE CASCADE ON DELETE SET NULL,
    INDEX idx_courses_department (department_id),
    INDEX idx_courses_teacher (teacher_id)
) ENGINE=InnoDB;

CREATE TABLE Enrollments (
    enrollment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    enrollment_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    CONSTRAINT uq_student_course UNIQUE (student_id, course_id),
    CONSTRAINT fk_enrollments_student FOREIGN KEY (student_id)
      REFERENCES Students(student_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_enrollments_course FOREIGN KEY (course_id)
      REFERENCES Courses(course_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX idx_enrollments_course (course_id)
) ENGINE=InnoDB;

CREATE TABLE Attendance (
    attendance_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    course_id INT NOT NULL,
    attendance_date DATE NOT NULL,
    status ENUM('Present','Absent','Late','Excused') NOT NULL DEFAULT 'Present',
    CONSTRAINT uq_attendance_session UNIQUE (student_id, course_id, attendance_date),
    CONSTRAINT fk_attendance_student FOREIGN KEY (student_id)
      REFERENCES Students(student_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_attendance_course FOREIGN KEY (course_id)
      REFERENCES Courses(course_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX idx_attendance_course_date (course_id, attendance_date)
) ENGINE=InnoDB;

CREATE TABLE Examinations (
    exam_id INT AUTO_INCREMENT PRIMARY KEY,
    course_id INT NOT NULL,
    exam_name VARCHAR(100) NOT NULL,
    exam_date DATE NOT NULL,
    maximum_marks DECIMAL(6,2) NOT NULL,
    CONSTRAINT chk_exam_max_marks CHECK (maximum_marks > 0),
    CONSTRAINT fk_exams_course FOREIGN KEY (course_id)
      REFERENCES Courses(course_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX idx_exams_course (course_id)
) ENGINE=InnoDB;

CREATE TABLE Results (
    result_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    exam_id INT NOT NULL,
    marks_obtained DECIMAL(6,2) NOT NULL,
    grade VARCHAR(2),
    CONSTRAINT uq_student_exam UNIQUE (student_id, exam_id),
    CONSTRAINT chk_result_nonnegative CHECK (marks_obtained >= 0),
    CONSTRAINT fk_results_student FOREIGN KEY (student_id)
      REFERENCES Students(student_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
    CONSTRAINT fk_results_exam FOREIGN KEY (exam_id)
      REFERENCES Examinations(exam_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX idx_results_exam (exam_id)
) ENGINE=InnoDB;

CREATE TABLE Fee_Payments (
    payment_id INT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    amount_paid DECIMAL(10,2) NOT NULL,
    payment_date DATE NOT NULL DEFAULT (CURRENT_DATE),
    payment_method ENUM('Cash','UPI','Card','Bank Transfer','Cheque') NOT NULL,
    payment_status ENUM('Paid','Pending','Failed','Refunded') NOT NULL DEFAULT 'Paid',
    CONSTRAINT chk_payment_amount CHECK (amount_paid >= 0),
    CONSTRAINT fk_payments_student FOREIGN KEY (student_id)
      REFERENCES Students(student_id)
      ON UPDATE CASCADE ON DELETE CASCADE,
    INDEX idx_payments_student_date (student_id, payment_date)
) ENGINE=InnoDB;

CREATE TABLE Student_Audit_Log (
    audit_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    student_id INT NOT NULL,
    old_student_name VARCHAR(100),
    new_student_name VARCHAR(100),
    old_email VARCHAR(150),
    new_email VARCHAR(150),
    changed_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    changed_by VARCHAR(288) NOT NULL
) ENGINE=InnoDB;

-- ======================================================================
-- 2. SAMPLE DATA
-- ======================================================================

INSERT INTO Departments (department_id, department_name, office_location) VALUES
(1,'Computer Science','Block A, Room 101'),
(2,'Business Studies','Block B, Room 204'),
(3,'Mathematics','Block C, Room 110'),
(4,'Electronics','Block D, Room 305');

INSERT INTO Students
(student_id, student_name, email, phone, date_of_birth, gender, admission_date, department_id) VALUES
(1,'Aarav Sharma','aarav.sharma@example.edu','9876501001','2005-02-14','Male','2024-07-15',1),
(2,'Diya Verma','diya.verma@example.edu','9876501002','2005-09-22','Female','2024-07-15',1),
(3,'Kabir Singh','kabir.singh@example.edu','9876501003','2004-12-03','Male','2024-07-16',1),
(4,'Meera Patel','meera.patel@example.edu','9876501004','2005-04-18','Female','2024-07-16',1),
(5,'Ishaan Gupta','ishaan.gupta@example.edu','9876501005','2005-06-29','Male','2024-07-17',1),
(6,'Anaya Das','anaya.das@example.edu','9876501006','2005-01-11','Female','2024-07-17',1),
(7,'Rohan Joshi','rohan.joshi@example.edu','9876501007','2004-11-08','Male','2024-07-18',2),
(8,'Sara Khan','sara.khan@example.edu','9876501008','2005-03-27','Female','2024-07-18',2),
(9,'Vivaan Rao','vivaan.rao@example.edu','9876501009','2005-08-16','Male','2024-07-19',2),
(10,'Tara Nair','tara.nair@example.edu','9876501010','2005-10-01','Female','2024-07-19',2),
(11,'Arjun Mehta','arjun.mehta@example.edu','9876501011','2004-07-25','Male','2024-07-20',3),
(12,'Ira Kapoor','ira.kapoor@example.edu','9876501012','2005-05-13','Female','2024-07-20',3),
(13,'Neel Roy','neel.roy@example.edu','9876501013','2005-12-09','Male','2024-07-21',4),
(14,'Myra Jain','myra.jain@example.edu','9876501014','2005-02-02','Female','2024-07-21',4),
(15,'Dev Malhotra','dev.malhotra@example.edu','9876501015','2005-07-19','Male','2024-07-22',1),
(16,'Nisha Sen','nisha.sen@example.edu','9876501016','2005-11-30','Female','2024-07-22',2),
(17,'Om Prakash','om.prakash@example.edu','9876501017','2005-03-03','Male','2024-07-23',3),
(18,'Riya Bansal','riya.bansal@example.edu','9876501018','2005-09-05','Female','2024-07-23',4);

INSERT INTO Teachers (teacher_id, teacher_name, email, phone, department_id) VALUES
(1,'Dr. Kavita Rao','kavita.rao@example.edu','9811102001',1),
(2,'Prof. Manish Khanna','manish.khanna@example.edu','9811102002',1),
(3,'Dr. Pooja Sethi','pooja.sethi@example.edu','9811102003',2),
(4,'Prof. Anil Menon','anil.menon@example.edu','9811102004',3),
(5,'Dr. Farah Ali','farah.ali@example.edu','9811102005',4),
(6,'Prof. Nitin Bose','nitin.bose@example.edu','9811102006',2);

INSERT INTO Courses (course_id, course_name, credits, department_id, teacher_id) VALUES
(1,'Database Management Systems',4,1,1),
(2,'Programming Fundamentals',4,1,2),
(3,'Data Analytics',3,1,1),
(4,'Principles of Management',3,2,3),
(5,'Business Communication',2,2,6),
(6,'Discrete Mathematics',4,3,4),
(7,'Applied Statistics',3,3,4),
(8,'Digital Electronics',4,4,5),
(9,'Computer Networks',3,1,2),
(10,'Introduction to Marketing',3,2,3);

INSERT INTO Enrollments (student_id, course_id, enrollment_date) VALUES
(1,1,'2024-08-01'),(1,2,'2024-08-01'),(1,3,'2024-08-02'),(1,9,'2024-08-02'),
(2,1,'2024-08-01'),(2,2,'2024-08-01'),(2,3,'2024-08-02'),(2,9,'2024-08-02'),
(3,1,'2024-08-01'),(3,2,'2024-08-01'),(3,9,'2024-08-02'),
(4,1,'2024-08-01'),(4,3,'2024-08-02'),
(5,1,'2024-08-01'),(5,2,'2024-08-01'),
(6,1,'2024-08-01'),(6,3,'2024-08-02'),
(7,4,'2024-08-03'),(7,5,'2024-08-03'),(7,10,'2024-08-04'),
(8,4,'2024-08-03'),(8,5,'2024-08-03'),
(9,4,'2024-08-03'),(9,10,'2024-08-04'),
(10,4,'2024-08-03'),(10,5,'2024-08-03'),
(11,6,'2024-08-05'),(11,7,'2024-08-05'),
(12,6,'2024-08-05'),(12,7,'2024-08-05'),
(13,8,'2024-08-06'),(14,8,'2024-08-06'),
(15,1,'2024-08-07'),(15,2,'2024-08-07'),(15,9,'2024-08-07'),
(16,4,'2024-08-07'),(16,5,'2024-08-07'),
(17,6,'2024-08-08'),(17,7,'2024-08-08'),
(18,8,'2024-08-08');

INSERT INTO Attendance (student_id, course_id, attendance_date, status) VALUES
(1,1,'2024-09-02','Present'),(1,1,'2024-09-04','Present'),(1,1,'2024-09-06','Late'),
(2,1,'2024-09-02','Present'),(2,1,'2024-09-04','Absent'),(2,1,'2024-09-06','Present'),
(3,1,'2024-09-02','Absent'),(3,1,'2024-09-04','Present'),(3,1,'2024-09-06','Present'),
(4,1,'2024-09-02','Present'),(4,1,'2024-09-04','Present'),
(5,2,'2024-09-03','Present'),(5,2,'2024-09-05','Late'),
(6,3,'2024-09-03','Present'),(6,3,'2024-09-05','Excused'),
(7,4,'2024-09-03','Present'),(8,4,'2024-09-03','Absent'),
(9,4,'2024-09-03','Present'),(10,5,'2024-09-05','Present'),
(11,6,'2024-09-04','Present'),(12,6,'2024-09-04','Present'),
(13,8,'2024-09-05','Present'),(14,8,'2024-09-05','Late'),
(15,1,'2024-09-09','Present'),(16,4,'2024-09-09','Present'),
(17,7,'2024-09-09','Absent'),(18,8,'2024-09-09','Present');

INSERT INTO Examinations (exam_id, course_id, exam_name, exam_date, maximum_marks) VALUES
(1,1,'DBMS Midterm','2024-10-10',100),
(2,2,'Programming Test','2024-10-12',100),
(3,3,'Data Analytics Test','2024-10-14',100),
(4,4,'Management Midterm','2024-10-15',100),
(5,6,'Mathematics Midterm','2024-10-16',100),
(6,8,'Electronics Midterm','2024-10-18',100),
(7,9,'Networks Quiz','2024-10-20',50);

INSERT INTO Results (student_id, exam_id, marks_obtained, grade) VALUES
(1,1,88,'A'),(2,1,92,'A+'),(3,1,67,'B'),(4,1,81,'A'),(5,1,74,'B'),(6,1,95,'A+'),(15,1,79,'B'),
(1,2,84,'A'),(2,2,90,'A+'),(3,2,71,'B'),(5,2,66,'B'),(15,2,82,'A'),
(1,3,86,'A'),(2,3,89,'A'),(4,3,77,'B'),(6,3,91,'A+'),
(7,4,78,'B'),(8,4,87,'A'),(9,4,69,'B'),(10,4,93,'A+'),(16,4,82,'A'),
(11,5,75,'B'),(12,5,94,'A+'),(17,5,68,'B'),
(13,6,88,'A'),(14,6,73,'B'),(18,6,91,'A+'),
(1,7,44,'A'),(2,7,46,'A+'),(3,7,37,'B'),(15,7,40,'A');

INSERT INTO Fee_Payments (student_id, amount_paid, payment_date, payment_method, payment_status) VALUES
(1,25000,'2024-08-01','UPI','Paid'),(1,15000,'2024-09-01','Bank Transfer','Paid'),
(2,30000,'2024-08-02','Card','Paid'),(2,10000,'2024-09-02','UPI','Paid'),
(3,20000,'2024-08-03','Cash','Paid'),(3,5000,'2024-09-03','UPI','Pending'),
(4,25000,'2024-08-04','Bank Transfer','Paid'),(5,22000,'2024-08-05','UPI','Paid'),
(6,30000,'2024-08-06','Card','Paid'),(7,18000,'2024-08-07','UPI','Paid'),
(7,12000,'2024-09-07','Cash','Paid'),(8,24000,'2024-08-08','Bank Transfer','Paid'),
(9,19000,'2024-08-09','UPI','Pending'),(10,27000,'2024-08-10','Card','Paid'),
(11,21000,'2024-08-11','UPI','Paid'),(12,26000,'2024-08-12','Bank Transfer','Paid'),
(13,23000,'2024-08-13','Cash','Paid'),(14,25000,'2024-08-14','UPI','Paid'),
(15,28000,'2024-08-15','Card','Paid'),(15,7000,'2024-09-15','UPI','Paid'),
(16,22000,'2024-08-16','Bank Transfer','Paid'),(17,18000,'2024-08-17','UPI','Paid'),
(18,24000,'2024-08-18','Card','Paid');

-- ======================================================================
-- 3. BASIC CRUD (INSERT / SELECT / UPDATE / DELETE)
-- ======================================================================

INSERT INTO Students (student_name,email,phone,date_of_birth,gender,admission_date,department_id)
VALUES ('Test Student','test.student@example.edu','9876501099','2005-05-05','Other','2025-07-01',1);
INSERT INTO Teachers (teacher_name,email,phone,department_id)
VALUES ('Test Teacher','test.teacher@example.edu','9811102099',1);
INSERT INTO Courses (course_name,credits,department_id,teacher_id)
VALUES ('SQL Lab Practice',2,1,2);

SELECT * FROM Students;
SELECT student_id, student_name, email FROM Students ORDER BY student_id;

UPDATE Students SET phone='9876501999' WHERE student_id=1;

DELETE FROM Courses WHERE course_name='SQL Lab Practice';

-- ======================================================================
-- 4. JOINS
-- ======================================================================

SELECT s.student_id,s.student_name,d.department_name
FROM Students s INNER JOIN Departments d ON s.department_id=d.department_id
ORDER BY s.student_id;

SELECT t.teacher_name,d.department_name
FROM Teachers t INNER JOIN Departments d ON t.department_id=d.department_id;

SELECT c.course_name,d.department_name,t.teacher_name
FROM Courses c
JOIN Departments d ON c.department_id=d.department_id
LEFT JOIN Teachers t ON c.teacher_id=t.teacher_id;

SELECT s.student_name,c.course_name,e.enrollment_date
FROM Enrollments e
JOIN Students s ON e.student_id=s.student_id
JOIN Courses c ON e.course_id=c.course_id
ORDER BY c.course_name,s.student_name;

SELECT s.student_id,s.student_name
FROM Students s LEFT JOIN Enrollments e ON s.student_id=e.student_id
WHERE e.enrollment_id IS NULL;

SELECT d.department_name,s.student_name
FROM Students s RIGHT JOIN Departments d ON s.department_id=d.department_id
ORDER BY d.department_name,s.student_name;

SELECT s1.student_name AS student_1,s2.student_name AS student_2,d.department_name
FROM Students s1
JOIN Students s2 ON s1.department_id=s2.department_id AND s1.student_id<s2.student_id
JOIN Departments d ON d.department_id=s1.department_id
ORDER BY d.department_name,student_1,student_2;

SELECT s.student_name,c.course_name,x.exam_name,r.marks_obtained,x.maximum_marks,r.grade
FROM Results r
JOIN Students s ON r.student_id=s.student_id
JOIN Examinations x ON r.exam_id=x.exam_id
JOIN Courses c ON x.course_id=c.course_id
ORDER BY s.student_name,x.exam_date;

-- ======================================================================
-- 5. AGGREGATE FUNCTIONS & GROUP BY
-- ======================================================================

SELECT d.department_name,COUNT(s.student_id) AS student_count
FROM Departments d LEFT JOIN Students s ON d.department_id=s.department_id
GROUP BY d.department_id,d.department_name;

SELECT AVG(marks_obtained) AS average_marks FROM Results;
SELECT MAX(marks_obtained) AS highest_marks, MIN(marks_obtained) AS lowest_marks FROM Results;
SELECT SUM(amount_paid) AS total_recorded_payments FROM Fee_Payments;
SELECT payment_status,SUM(amount_paid) AS amount_by_status
FROM Fee_Payments GROUP BY payment_status;

SELECT c.course_name,COUNT(e.enrollment_id) AS enrolled_students
FROM Courses c LEFT JOIN Enrollments e ON c.course_id=e.course_id
GROUP BY c.course_id,c.course_name;

SELECT d.department_name,COUNT(*) AS student_count
FROM Students s JOIN Departments d ON s.department_id=d.department_id
GROUP BY d.department_id,d.department_name;

-- ======================================================================
-- 6. HAVING & SUBQUERIES
-- ======================================================================

SELECT c.course_name,COUNT(e.student_id) AS enrolled_students
FROM Courses c JOIN Enrollments e ON c.course_id=e.course_id
GROUP BY c.course_id,c.course_name
HAVING COUNT(e.student_id)>5;

SELECT d.department_name,COUNT(*) AS student_count
FROM Departments d JOIN Students s ON d.department_id=s.department_id
GROUP BY d.department_id,d.department_name
HAVING COUNT(*)>10;

SELECT s.student_id,s.student_name,AVG(r.marks_obtained) AS average_marks
FROM Students s JOIN Results r ON s.student_id=r.student_id
GROUP BY s.student_id,s.student_name
HAVING AVG(r.marks_obtained)>80;

SELECT s.student_name,r.marks_obtained
FROM Results r JOIN Students s ON s.student_id=r.student_id
WHERE r.marks_obtained>(SELECT AVG(marks_obtained) FROM Results)
ORDER BY r.marks_obtained DESC;

SELECT student_name FROM Students
WHERE student_id IN (
  SELECT e.student_id FROM Enrollments e
  JOIN Courses c ON c.course_id=e.course_id
  WHERE c.course_name='Database Management Systems'
);

SELECT DISTINCT s.student_id,s.student_name,r.marks_obtained
FROM Results r JOIN Students s ON s.student_id=r.student_id
WHERE r.marks_obtained=(SELECT MAX(marks_obtained) FROM Results);

SELECT c.course_name,COUNT(e.enrollment_id) AS enrollment_count
FROM Courses c LEFT JOIN Enrollments e ON c.course_id=e.course_id
GROUP BY c.course_id,c.course_name
HAVING COUNT(e.enrollment_id) > (
  SELECT AVG(course_count)
  FROM (
    SELECT COUNT(e2.enrollment_id) AS course_count
    FROM Courses c2 LEFT JOIN Enrollments e2 ON c2.course_id=e2.course_id
    GROUP BY c2.course_id
  ) AS course_counts
);

-- ======================================================================
-- 7. VIEWS
-- ======================================================================

CREATE OR REPLACE VIEW Student_Details_View AS
SELECT s.student_id,s.student_name,s.email,s.phone,s.date_of_birth,s.gender,
       s.admission_date,d.department_name,d.office_location
FROM Students s JOIN Departments d ON s.department_id=d.department_id;

CREATE OR REPLACE VIEW Course_Details_View AS
SELECT c.course_id,c.course_name,c.credits,d.department_name,t.teacher_name
FROM Courses c JOIN Departments d ON c.department_id=d.department_id
LEFT JOIN Teachers t ON c.teacher_id=t.teacher_id;

CREATE OR REPLACE VIEW Student_Result_View AS
SELECT s.student_id,s.student_name,c.course_name,x.exam_name,x.exam_date,
       r.marks_obtained,x.maximum_marks,r.grade
FROM Results r JOIN Students s ON r.student_id=s.student_id
JOIN Examinations x ON r.exam_id=x.exam_id
JOIN Courses c ON x.course_id=c.course_id;

CREATE OR REPLACE VIEW Attendance_Report_View AS
SELECT a.attendance_id,s.student_id,s.student_name,c.course_name,
       a.attendance_date,a.status
FROM Attendance a JOIN Students s ON a.student_id=s.student_id
JOIN Courses c ON a.course_id=c.course_id;

CREATE OR REPLACE VIEW Fee_Report_View AS
SELECT p.payment_id,s.student_id,s.student_name,p.amount_paid,p.payment_date,
       p.payment_method,p.payment_status
FROM Fee_Payments p JOIN Students s ON p.student_id=s.student_id;

SELECT * FROM Student_Details_View;
SELECT * FROM Course_Details_View;
SELECT * FROM Student_Result_View;
SELECT * FROM Attendance_Report_View;
SELECT * FROM Fee_Report_View WHERE student_id=1;

-- ======================================================================
-- 8. FUNCTION, STORED PROCEDURES & TRIGGERS
-- ======================================================================

DELIMITER $$

CREATE FUNCTION fn_student_average_marks(p_student_id INT)
RETURNS DECIMAL(6,2)
READS SQL DATA
BEGIN
    DECLARE v_average DECIMAL(6,2);
    SELECT AVG(marks_obtained) INTO v_average
    FROM Results WHERE student_id=p_student_id;
    RETURN v_average;
END$$

CREATE PROCEDURE sp_get_student_details(IN p_student_id INT)
BEGIN
    SELECT * FROM Student_Details_View WHERE student_id=p_student_id;
END$$

CREATE PROCEDURE sp_students_by_department(IN p_department_id INT)
BEGIN
    SELECT student_id,student_name,email,department_name
    FROM Student_Details_View
    WHERE EXISTS (SELECT 1 FROM Students s
                  WHERE s.student_id=Student_Details_View.student_id
                    AND s.department_id=p_department_id)
    ORDER BY student_name;
END$$

CREATE PROCEDURE sp_student_average_marks(IN p_student_id INT)
BEGIN
    SELECT s.student_id,s.student_name,fn_student_average_marks(p_student_id) AS average_marks
    FROM Students s WHERE s.student_id=p_student_id;
END$$

CREATE PROCEDURE sp_student_fee_history(IN p_student_id INT)
BEGIN
    SELECT payment_id,amount_paid,payment_date,payment_method,payment_status
    FROM Fee_Payments WHERE student_id=p_student_id
    ORDER BY payment_date,payment_id;
END$$

CREATE TRIGGER trg_validate_result_before_insert
BEFORE INSERT ON Results
FOR EACH ROW
BEGIN
    DECLARE v_maximum DECIMAL(6,2);
    SELECT maximum_marks INTO v_maximum
    FROM Examinations WHERE exam_id=NEW.exam_id;
    IF NEW.marks_obtained < 0 OR NEW.marks_obtained > v_maximum THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT='Marks must be between zero and the examination maximum';
    END IF;
END$$

CREATE TRIGGER trg_validate_result_before_update
BEFORE UPDATE ON Results
FOR EACH ROW
BEGIN
    DECLARE v_maximum DECIMAL(6,2);
    SELECT maximum_marks INTO v_maximum
    FROM Examinations WHERE exam_id=NEW.exam_id;
    IF NEW.marks_obtained < 0 OR NEW.marks_obtained > v_maximum THEN
        SIGNAL SQLSTATE '45000'
          SET MESSAGE_TEXT='Marks must be between zero and the examination maximum';
    END IF;
END$$

CREATE TRIGGER trg_student_update_audit
AFTER UPDATE ON Students
FOR EACH ROW
BEGIN
    INSERT INTO Student_Audit_Log
      (student_id,old_student_name,new_student_name,old_email,new_email,changed_by)
    VALUES
      (OLD.student_id,OLD.student_name,NEW.student_name,OLD.email,NEW.email,CURRENT_USER());
END$$

DELIMITER ;

-- ======================================================================
-- 9. TESTING ROUTINES & AUDIT TRIGGER
-- ======================================================================

CALL sp_get_student_details(1);
CALL sp_students_by_department(1);
CALL sp_student_average_marks(1);
CALL sp_student_fee_history(1);
SELECT fn_student_average_marks(1) AS student_average_marks;

UPDATE Students SET phone='9876501888' WHERE student_id=1;
SELECT * FROM Student_Audit_Log ORDER BY audit_id DESC;

-- ======================================================================
-- 10. TRANSACTIONS (COMMIT / ROLLBACK / SAVEPOINT)
-- ======================================================================

START TRANSACTION;
INSERT INTO Fee_Payments (student_id,amount_paid,payment_date,payment_method,payment_status)
VALUES (1,1000,'2024-10-01','UPI','Paid');
COMMIT;

START TRANSACTION;
INSERT INTO Fee_Payments (student_id,amount_paid,payment_date,payment_method,payment_status)
VALUES (2,999,'2024-10-02','Cash','Pending');
ROLLBACK;

START TRANSACTION;
INSERT INTO Fee_Payments (student_id,amount_paid,payment_date,payment_method,payment_status)
VALUES (3,500,'2024-10-03','UPI','Paid');
SAVEPOINT after_first_payment;
INSERT INTO Fee_Payments (student_id,amount_paid,payment_date,payment_method,payment_status)
VALUES (3,600,'2024-10-03','Cash','Pending');
ROLLBACK TO SAVEPOINT after_first_payment;
COMMIT;

-- ======================================================================
-- 11. VERIFICATION
-- ======================================================================

SHOW INDEX FROM Students;
SHOW CREATE TABLE Students;
SHOW CREATE TABLE Results;

SELECT COUNT(*) AS total_departments FROM Departments;
SELECT COUNT(*) AS total_students FROM Students;
SELECT COUNT(*) AS total_teachers FROM Teachers;
SELECT COUNT(*) AS total_courses FROM Courses;
SELECT COUNT(*) AS total_enrollments FROM Enrollments;
SELECT COUNT(*) AS total_attendance_records FROM Attendance;
SELECT COUNT(*) AS total_examinations FROM Examinations;
SELECT COUNT(*) AS total_results FROM Results;
SELECT COUNT(*) AS total_fee_payments FROM Fee_Payments;
