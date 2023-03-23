DROP DATABASE IF EXISTS company_lecture;
CREATE DATABASE IF NOT EXISTS company_lecture;
USE company_lecture;

-- Create Employee Table
drop table if exists employee;
create table employee (
	fname char(20) not null,
    minit char(1) default null,
    lname char(20) not null,
    ssn decimal(9, 0) not null,
    bdate date not null,
    address char(50) not null,
    sex char(1) not null,
    salary decimal(8, 2) not null,
    superssn decimal(9, 0) not null,
    dno decimal(3, 0) not null,
    primary key (ssn)
) ENGINE=InnoDB;
-- FK2: dno -> department(dnumber)
-- FK7: superssn --> employee(ssn)

-- Create department table
drop table if exists department;
create table department (
	dname char(20) not null,
    dnumber decimal(3, 0) not null,
    manager_ssn decimal(9, 0) not null,
    manager_start_date date not null,
    primary key (dnumber),
    unique key (dname)
) ENGINE=InnoDB;
-- FK4: manager_ssn --> employee(ssn)

-- Create project table
drop table if exists project;
create table project (
	pname char(20) not null,
    pnumber decimal(3, 0) not null,
    plocation char(30) not null,
    dnum decimal(3, 0) not null,
    primary key (pnumber),
    unique key(pname)
) ENGINE=InnoDB;
-- FK3: dnum -> department(dnumber)

-- Create table dpendent
drop table if exists dependent;
create table dependent (
	essn decimal(9, 0) not null,
    dependent_name char(20) not null,
    sex char(1) not null,
    bdate date not null,
    relationship char(30) not null,
    primary key (essn, dependent_name)
) ENGINE=InnoDB;
-- FK1: essn --> employee(ssn)

-- Create works_on table
drop table if exists works_on;
create table works_on (
	essn decimal(9, 0) not null,
    pno decimal(3, 0) not null,
	hours_worked decimal(3, 1) not null,
    primary key (essn, pno)
) ENGINE=InnoDB;
-- FK5: essn --> employee(ssn)
-- FK6: pno --> project(pnumber)

-- Department locations
drop table if exists department_locations;
create table department_locations (
	dnumber decimal(3, 0) not null,
    dlocation char(30) not null,
    primary key (dnumber, dlocation)
) ENGINE=InnoDB;
-- FK8: dnumber --> department(dnumber)

-- add foreign keys
-- alter table fk_table add constraint fkn foreign key (key_name) references referencing_table(key_name)
-- FK2: dno -> department(dnumber)
alter table employee add constraint fk2 foreign key (dno) references department(dnumber);
-- FK7: superssn --> employee(ssn)
alter table employee add constraint fk7 foreign key (superssn) references employee(ssn);
-- FK4: manager_ssn --> employee(ssn)
alter table department add constraint fk4 foreign key (manager_ssn) references employee(ssn);
-- FK3: dnum -> department(dnumber)
alter table project add constraint fk3 foreign key (dnum) references department(dnumber);
-- FK1: essn --> employee(ssn)
alter table dependent add constraint fk1 foreign key (essn) references employee(ssn);
-- FK5: essn --> employee(ssn)
alter table works_on add constraint fk5 foreign key (essn) references employee(ssn);
-- FK6: pno --> project(pnumber)
alter table works_on add constraint fk6 foreign key (pno) references project(pnumber);
-- FK8: dnumber --> department(number)
alter table department_locations add constraint fk8 foreign key (dnumber) references department(dnumber);


