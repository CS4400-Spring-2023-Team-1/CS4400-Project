-- CS4400: Introduction to Database Systems: Monday, January 30, 2023
-- Flight Management Course Project Database TEMPLATE (v1.0)

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;
set @thisDatabase = 'flight_management';

drop database if exists flight_management;
create database if not exists flight_management;
use flight_management;

-- Define the database structures and enter the denormalized data

CREATE TABLE flight (
	flightID VARCHAR(10) NOT NULL UNIQUE,
    routeID VARCHAR(50) NOT NULL,
    PRIMARY KEY (flightID),
    FOREIGN KEY (routeID) REFERENCES route(routeID)
);

CREATE TABLE route (
	routeID VARCHAR(50) NOT NULL,
    PRIMARY KEY (routeID)
);

CREATE TABLE leg (
	legID VARCHAR(10) NOT NULL,
    distance decimal(5,0) NOT NULL,
    PRIMARY KEY (legID)
);

CREATE TABLE airport (
	airportID CHAR(3) NOT NULL,
    name VARCHAR(100) NOT NULL,
    
);