## EnrollmentProject
This is a repository for the IS480 - Advanced Databases project completed by Hoan Nguyen
## Project Description
The goal of this project is to create an enrollment database package in PL/SQL using Oracle Database 11g
that cross-checks different tables in order to ensure that students with the right prerequisites can be added or dropped from available courses. 

**Specifications:**
Create a PL/SQL package called ENROLL.

2 Procedures: AddMe and DropMe should be included in the package, whose name and parameters should be exactly specified as below:

**The AddMe Procedure**
*Enroll.AddMe(p_snum, p_callnum, p_ErrorMsg)*

This procedure is to enroll a student (SNum) to a class (callNum). The procedure has 2 IN parameters,
*p_snum* and *p_callnum* and 1 OUT parameter *p_ErrorMsg*.

1. **Valid_student number and valid_call number:** If the student number or call is invalid, the system would print an error message and does not proceed with the following checks.
2. **Repeat_Enrollment:** A student cannot enroll in the same CallNum again, The system prints an error message if there is repeat enrollment.
3. **Double_Enrollment:** A student cannot enroll in other sections of the same course. That is, if a student is already enrolled in IS380 Section 1, he cannot be enrolled in IS380 Section 2.
The system prints an error message if there is a double enrollment.
4. **15-Hour Rule:** A student can enroll in at most 15 credit hours per semester. The system prints an error message if the 15-hour rule is violated.
5. **Standing Requirement:** A student's standing must be equal or higher than the standing requirement required by the course.
6. **Disqualified_Student:** When a non-freshman(standing other than 1) student's GPA is lower than 2.0, the student is now in Disqualified status.
A Disqualified student cannot enroll in any course.
7. **Capacity:** Each class has a capacity limit. This student can enroll only when after his/her enrollment and class size is kept within the capacity limit.
8. **Wait List:** If this student has fulfilled all requirements but the class is full, then add his/her record to the waiting list.
The system then prints "Student number xxxx is now on the waiting list for class number xxxx."
9. **Repeat_waitlist:** If the student is already on the waiting list for this CallNum, you should not place the student on the wiating list again. 
Print a message to let the student know.
10. A confirmation message is printed if the student is (finally) successfully enrolled in the course.
11. Your program should check all requirements and store the error messages in *p_ErrorMsg*. If there is no error, *p_ErrorMsg* is NULL. The system should also print the error message.


**The DropMe Procedure**
*Enroll.DropMe(p_snum, p_callnum)*

This procedure is to DROP a student from a class.
1. **Valid student number and valid call number:** If the student number or call number is invalid, the system would print an error message and does not proceed with the following checks.
2. **Not Enrolled:** If the student is not enrolled in this class, we cannot drop them. The system prints an error msg.
3. **Already Graded:** If a grade is already assigned in this class, the student cannot drop. The system prints an error msg.
4. **Drop the Student:** To drop a student from a course, system updates the GRADE of the enrollment to 'W'. A confirmation message is printed.
5. Once a student drops a course, your program should proceed to check if there are any students on the waiting list. If there is, you should move the student who requested the enrollment the earliest to the enrollment list.
 - 5a. Note that a check on all enrollment requirements should be performed in this new enrollment.
 - 5b. If this new student is enrolled, he/she should be removed from the waiting list.
 - 5c. If this student cannot enroll for any reason (for instance, he/she now has too many units, etc), his/her record
 should remain on the waiting list and you shuld attempt to enroll the next student on the waiting list. Your program continues until either one student is enrolled or there is no (qualified) student on the waiting list.
## Built With
* [Oracle Database 11g](https://www.oracle.com/database/) - Relational Database Management System used to run and test project.
* [Sublime Text](https://www.sublimetext.com/) - Text Editor used to write all code in this project.
