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


CREATE TABLE location (
	locID VARCHAR(15) NOT NULL UNIQUE,
    PRIMARY KEY (locID)
);

CREATE TABLE airport (
	airportID CHAR(3) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    city VARCHAR(20) NOT NULL,
    state CHAR(2) NOT NULL,
    locID VARCHAR(15) NOT NULL,
    PRIMARY KEY (airportID),
    FOREIGN KEY (locID) REFERENCES location(locID) ON DELETE SET NULL
);

CREATE TABLE leg (
	legID VARCHAR(10) NOT NULL UNIQUE,
    distance decimal(5,0) NOT NULL,
    airportID CHAR(3) NOT NULL,
    PRIMARY KEY (legID),
    FOREIGN KEY (airportID) REFERENCES airport(airportID) ON DELETE CASCADE
);

CREATE TABLE route (
	routeID VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY (routeID)
);

CREATE TABLE flight (
	flightID VARCHAR(10) NOT NULL UNIQUE,
    routeID VARCHAR(50) NOT NULL,
    PRIMARY KEY (flightID),
    FOREIGN KEY (routeID) REFERENCES route(routeID) ON DELETE SET NULL
);

CREATE TABLE airplane (
	airlineID VARCHAR(20) NOT NULL,
    tail_num CHAR(6) NOT NULL,
    seat_cap INT NOT NULL,
    speed INT NOT NULL,
    flightID VARCHAR(10),
    progress VARCHAR(15), -- What are we using this for?
    status VARCHAR(15), -- What are we using this for?
    next_time VARCHAR(15), -- What are we using this for?
    airplane_type VARCHAR(4),
    locID VARCHAR(15),

    FOREIGN KEY (airlineID) REFERENCES airline(airlineID) ON DELETE CASCADE,
    FOREIGN KEY (flightID) REFERENCES flight(flightID) ON DELETE SET NULL,
    FOREIGN KEY (locID) REFERENCES location(locID) ON DELETE SET NULL
);

CREATE TABLE prop (
	airlineID VARCHAR(20) NOT NULL,
    tail_num CHAR(6) NOT NULL,
    props INT NOT NULL,
    skids INT NOT NULL,
    
    FOREIGN KEY (airlineID, tail_num) REFERENCES airplane(airlineID, tail_num) 
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

CREATE TABLE jet (
	airlineID VARCHAR(20) NOT NULL,
    tail_num CHAR(6) NOT NULL,
    engines INT NOT NULL,
	FOREIGN KEY (airlineID, tail_num) REFERENCES airplane(airlineID, tail_num) 
		ON UPDATE CASCADE
		ON DELETE CASCADE
);

# Need help with prop and jet

CREATE TABLE airline (
	airlineID VARCHAR(20) NOT NULL UNIQUE,
    revenue INT NOT NULL,
    PRIMARY KEY (airlineID)
);

CREATE TABLE person (
	personID VARCHAR(5) NOT NULL UNIQUE,
    first_name VARCHAR(15) NOT NULL,
    last_name VARCHAR(15) NOT NULL,
    person_type VARCHAR(15) NOT NULL, -- Should we do it this way?
    locID VARCHAR(15) NOT NULL,
    PRIMARY KEY (personID)
);

CREATE TABLE ticket (
	ticketID VARCHAR(15) NOT NULL UNIQUE,
    cost INT NOT NULL,
    flightID VARCHAR(10) NOT NULL,
    airportID CHAR(3) NOT NULL,
    personID VARCHAR(5) NOT NULL, 
    PRIMARY KEY (ticketID),
    FOREIGN KEY (flightID) REFERENCES flight(flightID) ON DELETE CASCADE,
    FOREIGN KEY (airportID) REFERENCES airport(airportID) ON DELETE CASCADE,
    FOREIGN KEY (personID) REFERENCES person(personID) ON DELETE CASCADE
);

CREATE TABLE contains(
	routeID VARCHAR(50) NOT NULL,
    legID VARCHAR(10) NOT NULL,
    sequence INT NOT NULL,
    FOREIGN KEY (routeID) REFERENCES route(routeID),
    FOREIGN KEY (legID) REFERENCES leg(legID)
);
CREATE TABLE seat (
	seat_num INT NOT NULL UNIQUE,
    ticketID VARCHAR(15) NOT NULL,
    PRIMARY KEY (seat_num),
    FOREIGN KEY (ticketID) REFERENCES ticket(ticketID) ON DELETE CASCADE
);

CREATE TABLE license (
    taxID CHAR(11) NOT NULL,
    license VARCHAR(10) NOT NULL,
    FOREIGN KEY (taxID) REFERENCES pilot(taxID)
);

