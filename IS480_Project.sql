set echo on
set serveroutput on

spool d:\IS480_Project.txt

drop table enrollments;
drop table prereq;
drop table schclasses;
drop table courses;
drop table students;
drop table majors;

-----
-----


create table MAJORS
	(major varchar2(3) Primary key,
	mdesc varchar2(30));
insert into majors values ('ACC','Accounting');
insert into majors values ('FIN','Finance');
insert into majors values ('IS','Information Systems');
insert into majors values ('MKT','Marketing');

create table STUDENTS 
	(snum varchar2(3) primary key,
	sname varchar2(10),
	standing number(1),
	major varchar2(3) constraint fk_students_major references majors(major),
	gpa number(2,1),
	major_gpa number(2,1));

insert into students values ('101','Andy',3,'IS',2.8,3.2);
insert into students values ('102','Betty',2,null,3.2,null);
insert into students values ('103','Cindy',3,'IS',2.5,3.5);
insert into students values ('104','David',2,'FIN',3.3,3.0);
insert into students values ('105','Ellen',1,null,2.8,null);
insert into students values ('106','Frank',3,'MKT',3.1,2.9);

create table COURSES
	(dept varchar2(3) constraint fk_courses_dept references majors(major),
	cnum varchar2(3),
	ctitle varchar2(30),
	crhr number(3),
	standing number(1),
	primary key (dept,cnum));

insert into courses values ('IS','300','Intro to MIS',3,2);
insert into courses values ('IS','301','Business Communicatons',3,2);
insert into courses values ('IS','310','Statistics',3,2);
insert into courses values ('IS','340','Programming',3,3);
insert into courses values ('IS','380','Database',3,3);
insert into courses values ('IS','385','Systems',3,3);
insert into courses values ('IS','480','Adv Database',3,4);

create table SCHCLASSES (
	callnum number(5) primary key,
	year number(4),
	semester varchar2(3),
	dept varchar2(3),
	cnum varchar2(3),
	section number(2),
	capacity number(3));

alter table schclasses 
	add constraint fk_schclasses_dept_cnum foreign key 
	(dept, cnum) references courses (dept,cnum);

insert into schclasses values (10110,2014,'Fa','IS','300',1,45);
insert into schclasses values (10115,2014,'Fa','IS','300',2,118);
insert into schclasses values (10120,2014,'Fa','IS','300',3,35);
insert into schclasses values (10125,2014,'Fa','IS','301',1,35);
insert into schclasses values (10130,2014,'Fa','IS','301',2,35);
insert into schclasses values (10135,2014,'Fa','IS','310',1,35);
insert into schclasses values (10140,2014,'Fa','IS','310',2,35);
insert into schclasses values (10145,2014,'Fa','IS','340',1,30);
insert into schclasses values (10150,2014,'Fa','IS','380',1,33);
insert into schclasses values (10155,2014,'Fa','IS','385',1,35);
insert into schclasses values (10160,2014,'Fa','IS','480',1,35);

create table PREREQ
	(dept varchar2(3),
	cnum varchar2(3),
	pdept varchar2(3),
	pcnum varchar2(3),
	primary key (dept, cnum, pdept, pcnum));
alter table Prereq 
	add constraint fk_prereq_dept_cnum foreign key 
	(dept, cnum) references courses (dept,cnum);
alter table Prereq 
	add constraint fk_prereq_pdept_pcnum foreign key 
	(pdept, pcnum) references courses (dept,cnum);

insert into prereq values ('IS','380','IS','300');
insert into prereq values ('IS','380','IS','301');
insert into prereq values ('IS','380','IS','310');
insert into prereq values ('IS','385','IS','310');
insert into prereq values ('IS','340','IS','300');
insert into prereq values ('IS','480','IS','380');

create table ENROLLMENTS (
	snum varchar2(3) constraint fk_enrollments_snum references students(snum),
	callnum number(5) constraint fk_enrollments_callnum references schclasses(callnum),
	grade varchar2(2),
	primary key (snum, callnum));

insert into enrollments values (101,10110,'A');
insert into enrollments values (102,10110,'B');
insert into enrollments values (103,10120,'A');
insert into enrollments values (101,10125,null);
insert into enrollments values (102,10130,null);

create table WAITLIST 
	(snum varchar2(10),
	callnum varchar2(5),
	reqtime timestamp);

commit;
--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
--Declare Enroll Package Procedures 
Create or Replace Package Enroll is

procedure ValidateSNum(
	p_snum in varchar2,
	p_errormsg out varchar2);

procedure ValidateCNum(
	p_callnum in number,
	p_errormsg out varchar2);

procedure ValidateCourseCap(
	p_snum in varchar2,
	p_callnum in number,
	p_errormsg out varchar2);

procedure ValidateCreditCap(
	p_snum in varchar2,
	p_callnum in number,
	p_errormsg out varchar2);

Procedure ValidateRepeatEnroll(
	p_snum in number,
	p_callnum in number,
	p_errormsg out varchar2);

Procedure ValidateDoubleEnroll(
	p_snum in number,
	p_callnum in number,
	p_errormsg out varchar2);

Procedure ValidateStanding(
	p_snum in number,
	p_callnum in number,
	p_errormsg out varchar2);

Procedure DisqStudent(
	p_snum in number,
	p_errormsg out varchar2);

Procedure GetWaiting(
	p_snum in number,
	p_callnum number,
	p_errormsg out varchar2);

Procedure RepeatWaitlist(
	p_snum in number,
	p_callnum number,
	p_errormsg out varchar2);

procedure AddMe(
	p_snum in varchar2,
	p_callnum in number);

procedure NotEnrolled(
	p_snum in varchar2,
	p_callnum in number,
	p_errormsg out varchar2);

procedure GradeCheck(
	p_snum in varchar2,
	p_callnum in number,
	p_errormsg out varchar2);

Procedure DropMe(
	p_snum in students.snum%type, 
	p_CallNum in schclasses.callnum%type);
end Enroll;
/

--Package Body 
Create or Replace Package Body Enroll is

Procedure ValidateSNum(
	p_snum in varchar2,
	p_errormsg out varchar2) as
	v_count number(3);

	begin
		select count(*) into v_count
		from Students
		where snum=p_snum;

		if v_count = 1 then
			p_errormsg := null;
		else
			p_errormsg := 'Student Number '||p_snum||'is Invalid. ';
		end if;
end;

Procedure ValidateCNum(
	p_callnum in number,
	p_errormsg out varchar2) as
	v_count number(3);

	begin
		select count(*) into v_count
		from schclasses
		where callnum=p_callnum;

		if v_count = 1 then
			p_errormsg := null;
		else
			p_errormsg := 'Call Number '||p_callnum||'is Invalid. ';
		end if;
end;

Procedure ValidateCourseCap(
	p_snum in varchar2,
	p_callnum in number,
	p_errormsg out varchar2) as
	v_count_s number;
	v_count_c number;
	v_studentcap number;

	begin

		select count(*) into v_count_s
		from students
		where p_snum=snum;

		select count(*) into v_count_c
		from enrollments
		where p_callnum=callnum;

		select capacity into v_studentcap
		from schclasses
		where p_callnum=callnum;

		if v_count_s + v_count_c <= v_studentcap then
			p_errormsg := null;
		else
			p_errormsg := ('Class is full');
		end if;
end;

Procedure ValidateCreditCap(
	p_snum in varchar2,
	p_callnum in number,
	p_errormsg out varchar2) as
	v_credit_Add number;
	v_credit_Count integer;
	v_credit_Cap integer := 15;

	begin
		select nvl(sum(crhr),0) into v_credit_Count
		from enrollments e, schclasses sc, courses c
		where e.snum=p_snum and e.callnum=sc.callnum 
		and sc.dept=c.dept and sc.cnum=c.cnum;

		select crhr into v_credit_Add
		from schclasses sc, courses c
		where sc.callnum=p_callnum and sc.dept=c.dept and sc.cnum=c.cnum;

		if v_credit_Count + v_credit_Add <= v_credit_Cap then
			p_errormsg := null;
		else
			p_errormsg := ('Credit Limit Exceeded');
		end if;
end;

Procedure ValidateRepeatEnroll(
	p_snum in number,
	p_callnum in number,
	p_errormsg out varchar2) as
	v_count number;

begin

	select count(*) into v_count
	from enrollments
	where snum=p_snum
	and callnum=p_callnum;

	if v_count=1 then
		p_errormsg := 'Student enrolled twice';
	else
		p_errormsg := null;
	end if;
end; 


Procedure ValidateDoubleEnroll(
	p_snum in number,
	p_callnum in number,
	p_errormsg out varchar2) as
	v_count number;
	v_section number;
	v_dept varchar2(10);
	v_cnum number;
begin

	select count(*) into v_count
	from enrollments e, schclasses sch
	where e.callnum = sch.callnum
	and dept=v_dept
	and cnum=v_cnum
	and snum=p_snum;

	select section into v_section
	from schclasses sch , enrollments e
	where e.callnum = sch.callnum
	and p_snum = e.snum
	and v_dept = sch.dept
	and v_cnum = sch.cnum;


	if v_count != 0 then
		p_errormsg := 'Student enrolled in another section';
	else
		p_errormsg := null;
	end if;

	exception
	when others then
	null;
end;


Procedure ValidateStanding(
	p_snum in number,
	p_callnum in number,
	p_errormsg out varchar2) as
	v_stand number;
	v_reqstand number;

begin 
	
	select standing into v_stand
	from students 
	where snum = p_snum;

	if v_stand < v_reqstand then
		p_errormsg := 'Student does not meet standing requirements';
	else 
		p_errormsg := null;
	end if;
end;



Procedure DisqStudent(
	p_snum in number,
	p_errormsg out varchar2) as
	v_stand number;
	v_gpa number;

begin 
	
	select standing into v_stand
	from students 
	where snum = p_snum;

	select gpa into v_gpa
	from students
	where snum = p_snum;

	if v_stand = 1 then
		p_errormsg := null;
	else 
		if v_gpa < 2 then
			p_errormsg := 'Student does not meet GPA requirements';
		else
			p_errormsg := null;
		end if;
	end if;
end;


Procedure GetWaiting(
	p_snum in number,
	p_callnum number,
	p_errormsg out varchar2) as

begin
	insert into waitlist values(p_snum, p_callnum,Systimestamp);

	p_errormsg := ('Student number '|| p_snum || ' is now on the waiting list for class number '|| p_callnum );
end;


Procedure RepeatWaitlist(
	p_snum in number,
	p_callnum number,
	p_errormsg out varchar2) as
	v_count number(5);

begin 
	select count(*) into v_count
	from waitlist
	where snum = p_snum
	and callnum = p_callnum;

	if v_count != 0 then 
		p_errormsg := 'Student already in the waitlist';
	else
		p_errormsg := null;
	end if;
end;


Procedure AddMe (
	p_snum in varchar2, 
	p_callnum in number) as
	p_errormsg varchar2(200);
	p_add_err varchar2(200);

	begin
		ValidateSNum (p_snum,p_errormsg);
		p_add_err := p_errormsg;

		ValidateCNum (p_callnum,p_errormsg);
		p_add_err := p_errormsg;

		if p_add_err is null then
			ValidateCourseCap (p_snum,p_callnum,p_errormsg);
			p_add_err := p_add_err||p_errormsg;

			ValidateCreditCap (p_snum,p_callnum,p_errormsg);
			p_add_err := p_add_err||p_errormsg;

			ValidateStanding(p_snum,p_callnum,p_errormsg);
			p_add_err := p_add_err||p_errormsg;

			DisqStudent(p_snum,p_errormsg);
			p_add_err := p_add_err||p_errormsg;

			ValidateRepeatEnroll(p_snum,p_callnum,p_errormsg);
			p_add_err := p_add_err||p_errormsg;

			ValidateDoubleEnroll (p_snum,p_callnum,p_errormsg);
			p_add_err := p_add_err||p_errormsg;

				if p_add_err is not null then
					dbms_output.put_line(p_errormsg);
				else
					insert into enrollments values (p_snum,p_callnum,null);
					dbms_output.put_line('Student '||p_snum||' added');
				end if;
		else
			dbms_output.put_line(p_add_err); 
		end if;
end;

Procedure NotEnrolled(
	p_snum in varchar2,
	p_callnum in number,
	p_errormsg out varchar2) as
	v_count number;

begin
	select count(*) into v_count
	from enrollments
	where snum = p_snum
	and callnum = p_callnum;

	if v_count = 1 then
		p_errormsg := null;
	else
		p_errormsg := 'Student currently not enrolled';
	end if;
end;

procedure GradeCheck(
	p_snum in varchar2,
	p_callnum in number,
	p_errormsg out varchar2) as
	v_count number;

begin 
	select count(*) into v_count
	from enrollments
	where p_snum=snum
	and p_callnum=callnum;

	if v_count = 1 then
		p_errormsg := 'Student already assigned a grade';
	else 
		p_errormsg := null;
	end if;
end;

Procedure DropMe(
	p_snum in students.snum%type, 
	p_CallNum in schclasses.callnum%type) as

	p_errormsg varchar2(300);
	p_drop_err varchar2(300);
	v_all number;
	v_withdrawal varchar2 (3);

begin
	ValidateSNum (p_snum,p_errormsg);
	p_drop_err := p_errormsg;

	ValidateCNum (p_callnum,p_errormsg);
	p_drop_err := p_errormsg||p_drop_err;

	if p_drop_err is null then
		NotEnrolled(p_snum,p_callnum,p_errormsg);
		p_drop_err:=p_drop_err;

		if p_drop_err is not null then 
			dbms_output.put_line('Student not enrolled.');
		else
			select count(*) into v_all
			from enrollments
			where snum=p_snum
			and callnum=p_callnum;

			v_withdrawal :='W';

			if v_all >0 then

				update Enrollments
				set grade = v_withdrawal
				where p_snum = snum
				and p_callnum = callnum;
				p_errormsg := 'Student dropped.';
				dbms_output.put_line(p_errormsg);
			else
				p_errormsg := 'Student cannot be dropped.';
			end if;
		end if;
	else
		dbms_output.put_line(p_drop_err);
	end if;
end;

end Enroll;
/

show err
pause

spool off
