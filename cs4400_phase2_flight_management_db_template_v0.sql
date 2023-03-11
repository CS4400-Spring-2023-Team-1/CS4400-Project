/* CS 4400 Team 1 Phase 2 Code
Authors: Sean Liu, Sean Johnson, Vicente Miranda, McKenna Hall*/

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
-- mk test

CREATE TABLE flight (
	flightID VARCHAR(10) NOT NULL UNIQUE,
    routeID VARCHAR(50) NOT NULL,
    PRIMARY KEY (flightID),
    FOREIGN KEY (routeID) REFERENCES route(routeID)
);

CREATE TABLE route (
	routeID VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY (routeID)
);

CREATE TABLE leg (
	legID VARCHAR(10) NOT NULL UNIQUE,
    distance decimal(5,0) NOT NULL,
    airportID CHAR(3) NOT NULL,
    PRIMARY KEY (legID),
    FOREIGN KEY (airportID) REFERENCES airport(airportID)
);

CREATE TABLE airport (
	airportID CHAR(3) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(20) NOT NULL,
    state CHAR(2) NOT NULL,
    # Need information about location_flag ???
    locID VARCHAR(10) NOT NULL,
    PRIMARY KEY (airportID)
    #FOREIGN KEY (locID) REFERENCES 
);

CREATE TABLE airplane (
	airlineID VARCHAR(20) NOT NULL,
    tail_num CHAR(6) NOT NULL,
    seat_cap INT NOT NULL,
    speed INT NOT NULL,
    flightID VARCHAR(10) NOT NULL
    # Need help with the rest of the attributes of airplane.
);

# Need help with prop and jet

CREATE TABLE airline (
	airlineID VARCHAR(20) NOT NULL UNIQUE,
    revenue INT NOT NULL,
    PRIMARY KEY (airlineID)
);

CREATE TABLE location (
	locID VARCHAR(15) NOT NULL UNIQUE,
    PRIMARY KEY (locID)
);

CREATE TABLE ticket (
	ticketID VARCHAR(15) NOT NULL UNIQUE,
    cost INT NOT NULL,
    flightID VARCHAR(10) NOT NULL,
    airportID CHAR(3) NOT NULL
    PRIMARY KEY (ticketID),
    FOREIGN KEY (flightID) REFERENCES flight(flightID)
    FOREIGN KEY (airportID) REFERENCES airport(airportID)
    FOREIGN KEY (personID) REFERENCES person(airportID)
);

CREATE TABLE person (

);
