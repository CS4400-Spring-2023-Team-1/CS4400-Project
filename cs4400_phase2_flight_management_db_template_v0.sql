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
    FOREIGN KEY (locID) REFERENCES location(locID) 
		ON DELETE RESTRICT
);

CREATE TABLE leg (
	legID VARCHAR(10) NOT NULL UNIQUE,
    distance decimal(5,0) NOT NULL,
    airportID CHAR(3) NOT NULL,
    PRIMARY KEY (legID),
    FOREIGN KEY (airportID) REFERENCES airport(airportID) 
		ON DELETE RESTRICT
);

CREATE TABLE route (
	routeID VARCHAR(50) NOT NULL UNIQUE,
    PRIMARY KEY (routeID)
);

CREATE TABLE flight (
	flightID VARCHAR(10) NOT NULL UNIQUE,
    routeID VARCHAR(50) NOT NULL,
    PRIMARY KEY (flightID),
    FOREIGN KEY (routeID) REFERENCES route(routeID) 
		ON DELETE RESTRICT
);

CREATE TABLE airline (
	airlineID VARCHAR(20) NOT NULL UNIQUE,
    revenue INT NOT NULL,
    PRIMARY KEY (airlineID)
);

CREATE TABLE airplane (
	airlineID VARCHAR(20) NOT NULL,
    tail_num CHAR(6) NOT NULL,
    seat_cap INT NOT NULL,
    speed INT NOT NULL,
    flightID VARCHAR(10),
    progress INT, -- What are we using this for?
    status VARCHAR(15), -- What are we using this for?
    next_time VARCHAR(15), -- What are we using this for?
    airplane_type VARCHAR(4),
    locID VARCHAR(15),
    
    PRIMARY KEY (airlineID, tail_num),

    FOREIGN KEY (airlineID) REFERENCES airline(airlineID)
		ON DELETE RESTRICT,
    FOREIGN KEY (flightID) REFERENCES flight(flightID) 
		ON DELETE SET NULL,
    FOREIGN KEY (locID) REFERENCES location(locID) 
		ON DELETE RESTRICT
);

CREATE TABLE prop (
	airlineID VARCHAR(20) NOT NULL,
    tail_num CHAR(6) NOT NULL,
    props INT,
    skids INT,
    
    CONSTRAINT airplaneID FOREIGN KEY (airlineID, tail_num) REFERENCES airplane(airlineID, tail_num) 
		ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE jet (
	airlineID VARCHAR(20) NOT NULL,
    tail_num CHAR(6) NOT NULL,
    engines INT,
	FOREIGN KEY (airlineID, tail_num) REFERENCES airplane(airlineID, tail_num) 
		ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE person (
	personID VARCHAR(5) NOT NULL UNIQUE,
    first_name VARCHAR(15) NOT NULL,
    last_name VARCHAR(15) NOT NULL,
    locID VARCHAR(15) NOT NULL,
    PRIMARY KEY (personID),
    FOREIGN KEY (locID) REFERENCES location(locID)
		ON DELETE RESTRICT
);

CREATE TABLE pilot (
	personID VARCHAR(5) NOT NULL,
	taxID CHAR(11) NOT NULL,
    experience INT,
    airlineID VARCHAR(20),
    tail_num VARCHAR(6),
    
    PRIMARY KEY (taxID),
    
    FOREIGN KEY (personID) REFERENCES person(personID)
		ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (airlineID, tail_num) REFERENCES airplane (airlineID, tail_num)
		ON DELETE SET NULL
        ON UPDATE CASCADE
    
);

CREATE TABLE passenger (
	personID VARCHAR(5) NOT NULL,
    miles INT,
    
    FOREIGN KEY (personID) REFERENCES person(personID)
		ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE ticket (
	ticketID VARCHAR(15) NOT NULL UNIQUE,
    cost INT NOT NULL,
    flightID VARCHAR(10) NOT NULL,
    airportID CHAR(3) NOT NULL,
    personID VARCHAR(5) NOT NULL, 
    PRIMARY KEY (ticketID),
    FOREIGN KEY (flightID) REFERENCES flight(flightID) 
        ON UPDATE CASCADE,
    FOREIGN KEY (airportID) REFERENCES airport(airportID) 
        ON UPDATE CASCADE,
    FOREIGN KEY (personID) REFERENCES person(personID)
        ON UPDATE CASCADE
);

CREATE TABLE contains(
	routeID VARCHAR(50) NOT NULL,
    legID VARCHAR(10) NOT NULL,
    sequence INT NOT NULL,
    FOREIGN KEY (routeID) REFERENCES route(routeID)
		ON DELETE CASCADE
        ON UPDATE CASCADE,
    FOREIGN KEY (legID) REFERENCES leg(legID)
		ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE seat (
	seat_num INT NOT NULL UNIQUE,
    ticketID VARCHAR(15) NOT NULL,
    PRIMARY KEY (seat_num),
    FOREIGN KEY (ticketID) REFERENCES ticket(ticketID) 
		ON DELETE CASCADE
        ON UPDATE CASCADE
);

CREATE TABLE license (
    taxID CHAR(11) NOT NULL,
    license VARCHAR(10) NOT NULL,
    FOREIGN KEY (taxID) REFERENCES pilot(taxID) 
		ON DELETE CASCADE
        ON UPDATE CASCADE
);

insert into person (personID, first_name, last_name, locID) values
('p1', 'Jeanne', 'Nelson', 'plane_1'),
('p10', 'Lawrence', 'Morgan', 'plane_9'),
('p11', 'Sandra', 'Cruz', 'plane_9'),
('p12', 'Dan', 'Ball', 'plane_11'),
('p13', 'Bryant', 'Figueroa', 'plane_2'),
('p14', 'Dana', 'Perry', 'plane_2'),
('p15', 'Matt', 'Hunt', 'plane_2'),
('p16', 'Edna', 'Brown', 'plane_15'),
('p17', 'Ruby', 'Burgess', 'plane_15'),
('p18', 'Esther', 'Pittman', 'port_2'),
('p19', 'Doug', 'Fowler', 'port_4'),
('p2', 'Roxanne', 'Byrd', 'plane_1'),
('p20', 'Thomas', 'Olson', 'port_3'),
('p21', 'Mona', 'Harrison', 'port_4'),
('p22', 'Arlene', 'Massey', 'port_2'),
('p23', 'Judith', 'Patrick', 'port_3'),
('p24', 'Reginald', 'Rhodes', 'plane_1'),
('p25', 'Vincent', 'Garcia', 'plane_1'),
('p26', 'Cheryl', 'Moore', 'plane_4'),
('p27', 'Michael', 'Rivera', 'plane_7'),
('p28', 'Luther', 'Matthews', 'plane_8'),
('p29', 'Moses', 'Parks', 'plane_8'),
('p3', 'Tanya', 'Nguyen', 'plane_4'),
('p30', 'Ora', 'Steele', 'plane_9'),
('p31', 'Antonio', 'Flores', 'plane_9'),
('p32', 'Glenn', 'Ross', 'plane_11'),
('p33', 'Irma', 'Thomas', 'plane_11'),
('p34', 'Ann', 'Maldonado', 'plane_2'),
('p35', 'Jeffrey', 'Cruz', 'plane_2'),
('p36', 'Sonya', 'Price', 'plane_15'),
('p37', 'Tracy', 'Hale', 'plane_15'),
('p38', 'Albert', 'Simmons', 'port_1'),
('p39', 'Karen', 'Terry', 'port_9'),
('p4', 'Kendra', 'Jacobs', 'plane_4'),
('p40', 'Glen', 'Kelley', 'plane_4'),
('p41', 'Brooke', 'Little', 'port_4'),
('p42', 'Daryl', 'Nguyen', 'port_3'),
('p43', 'Judy', 'Willis', 'port_1'),
('p44', 'Marco', 'Klein', 'port_2'),
('p45', 'Angelica', 'Hampton', 'port_5'),
('p5', 'Jeff', 'Burton', 'plane_4'),
('p6', 'Randal', 'Parks', 'plane_7'),
('p7', 'Sonya', 'Owens', 'plane_7'),
('p8', 'Bennie', 'Palmer', 'plane_8'),
('p9', 'Marlene', 'Warner', 'plane_8');

insert into pilot (personID, taxID, experience, airlineID, tail_num) values
('p1', '330-12-6907', 31, 'Delta', 'n106js'),
('p10', '769-60-1266', 15, 'Southwest', 'n401fj'),
('p11', '369-22-9505', 22, 'Southwest', 'n401fj'),
('p12', '680-92-5329', 24, 'Southwest', 'n118fm'),
('p13', '513-40-4168', 24, 'Delta', 'n110jn'),
('p14', '454-71-7847', 13, 'Delta', 'n110jn'),
('p15', '153-47-8101', 30, 'Delta', 'n110jn'),
('p16', '598-47-5172', 28, 'Spirit', 'n256ap'),
('p17', '865-71-6800', 36, 'Spirit', 'n256ap'),
('p18', '250-86-2784', 23, NULL, NULL),
('p19', '386-39-7881', 2, NULL, NULL),
('p2', '842-88-1257', 9, 'Delta', 'n106js'),
('p20', '522-44-3098', 28, NULL, NULL),
('p21', '621-34-5755', 2, NULL, NULL),
('p22', '177-47-9877', 3, NULL, NULL),
('p23', '528-64-7912', 12, NULL, NULL),
('p24', '803-30-1789', 34, NULL, NULL),
('p25', '986-76-1587', 13, NULL, NULL),
('p26', '584-77-5105', 20, NULL, NULL),
('p3', '750-24-7616', 11, 'American', 'n330ss'),
('p4', '776-21-8098', 24, 'American', 'n330ss'),
('p5', '933-93-2165', 27, 'American', 'n330ss'),
('p6', '707-84-4555', 38, 'United', 'n517ly'),
('p7', '450-25-5617', 13, 'United', 'n517ly'),
('p8', '701-38-2179', 12, 'United', 'n620la'),
('p9', '936-44-6941', 13, 'United', 'n620la');

insert into passenger (personID, miles) values
('p21', 771),
('p22', 374),
('p23', 414),
('p24', 292),
('p25', 390),
('p26', 302),
('p27', 470),
('p28', 208),
('p29', 292),
('p30', 686),
('p31', 547),
('p32', 257),
('p33', 564),
('p34', 211),
('p35', 233),
('p36', 293),
('p37', 552),
('p38', 812),
('p39', 541),
('p40', 441),
('p41', 875),
('p42', 691),
('p43', 572),
('p44', 572),
('p45', 663);

insert into license (taxID, license) values
('153-47-8101', 'testing'),
('803-30-1789', 'testing'),
('936-44-6941', 'testing');

insert into airport (airportID, name, city, state, locID) values
('ABQ', 'Albuquerque International Sunport', 'Albuquerque', 'NM', NULL),
('ANC', 'Ted Stevens Anchorage International Airport', 'Anchorage', 'AK', NULL),
('ATL', 'Hartsfield-Jackson Atlanta International Airport', 'Atlanta', 'GA', 'port_1'),
('BDL', 'Bradley International Airport', 'Hartford', 'CT', NULL),
('BFI', 'King County International Airport', 'Seattle', 'WA', 'port_10'),
('BHM', 'Birmingham‚ÄìShuttlesworth International Airport', 'Birmingham', 'AL', NULL),
('BNA', 'Nashville International Airport', 'Nashville', 'TN', NULL),
('BOI', 'Boise Airport ', 'Boise', 'ID', NULL),
('BOS', 'General Edward Lawrence Logan International Airport', 'Boston', 'MA', NULL),
('BTV', 'Burlington International Airport', 'Burlington', 'VT', NULL),
('BWI', 'Baltimore_Washington International Airport', 'Baltimore', 'MD', NULL),
('BZN', 'Bozeman Yellowstone International Airport', 'Bozeman', 'MT', NULL),
('CHS', 'Charleston International Airport', 'Charleston', 'SC', NULL),
('CLE', 'Cleveland Hopkins International Airport', 'Cleveland', 'OH', NULL),
('CLT', 'Charlotte Douglas International Airport', 'Charlotte', 'NC', NULL),
('CRW', 'Yeager Airport', 'Charleston', 'WV', NULL),
('DAL', 'Dallas Love Field', 'Dallas', 'TX', 'port_7'),
('DCA', 'Ronald Reagan Washington National Airport', 'Washington', 'DC', 'port_9'),
('DEN', 'Denver International Airport', 'Denver', 'CO', 'port_3'),
('DFW', 'Dallas-Fort Worth International Airport', 'Dallas', 'TX', 'port_2'),
('DSM', 'Des Moines International Airport', 'Des Moines', 'IA', NULL),
('DTW', 'Detroit Metro Wayne County Airport', 'Detroit', 'MI', NULL),
('EWR', 'Newark Liberty International Airport', 'Newark', 'NJ', NULL),
('FAR', 'Hector International Airport', 'Fargo', 'ND', NULL),
('FSD', 'Joe Foss Field', 'Sioux Falls', 'SD', NULL),
('GSN', 'Saipan International Airport', 'Obyan Saipan Island', 'MP', NULL),
('GUM', 'Antonio B_Won Pat International Airport', 'Agana Tamuning', 'GU', NULL),
('HNL', 'Daniel K. Inouye International Airport', 'Honolulu Oahu', 'HI', NULL),
('HOU', 'William P_Hobby Airport', 'Houston', 'TX', 'port_18'),
('IAD', 'Washington Dulles International Airport', 'Washington', 'DC', 'port_11'),
('IAH', 'George Bush Intercontinental Houston Airport', 'Houston', 'TX', 'port_13'),
('ICT', 'Wichita Dwight D_Eisenhower National Airport ', 'Wichita', 'KS', NULL),
('ILG', 'Wilmington Airport', 'Wilmington', 'DE', NULL),
('IND', 'Indianapolis International Airport', 'Indianapolis', 'IN', NULL),
('ISP', 'Long Island MacArthur Airport', 'New York Islip', 'NY', 'port_14'),
('JAC', 'Jackson Hole Airport', 'Jackson', 'WY', NULL),
('JAN', 'Jackson_Medgar Wiley Evers International Airport', 'Jackson', 'MS', NULL),
('JFK', 'John F_Kennedy International Airport ', 'New York', 'NY', 'port_15'),
('LAS', 'Harry Reid International Airport', 'Las Vegas', 'NV', NULL),
('LAX', 'Los Angeles International Airport', 'Los Angeles', 'CA', 'port_5'),
('LGA', 'LaGuardia Airport', 'New York', 'NY', NULL),
('LIT', 'Bill and Hillary Clinton National Airport', 'Little Rock', 'AR', NULL),
('MCO', 'Orlando International Airport', 'Orlando', 'FL', NULL),
('MDW', 'Chicago Midway International Airport', 'Chicago', 'IL', NULL),
('MHT', 'Manchester_Boston Regional Airport', 'Manchester', 'NH', NULL),
('MKE', 'Milwaukee Mitchell International Airport', 'Milwaukee', 'WI', NULL),
('MRI', 'Merrill Field', 'Anchorage', 'AK', NULL),
('MSP', 'Minneapolis_St_Paul International Wold_Chamberlain Airport', 'Minneapolis Saint Paul', 'MN', NULL),
('MSY', 'Louis Armstrong New Orleans International Airport', 'New Orleans', 'LA', NULL),
('OKC', 'Will Rogers World Airport', 'Oklahoma City', 'OK', NULL),
('OMA', 'Eppley Airfield', 'Omaha', 'NE', NULL),
('ORD', 'O_Hare International Airport', 'Chicago', 'IL', 'port_4'),
('PDX', 'Portland International Airport', 'Portland', 'OR', NULL),
('PHL', 'Philadelphia International Airport', 'Philadelphia', 'PA', NULL),
('PHX', 'Phoenix Sky Harbor International Airport', 'Phoenix', 'AZ', NULL),
('PVD', 'Rhode Island T_F_Green International Airport', 'Providence', 'RI', NULL),
('PWM', 'Portland International Jetport', 'Portland', 'ME', NULL),
('SDF', 'Louisville International Airport', 'Louisville', 'KY', NULL),
('SEA', 'Seattle‚ÄìTacoma International Airport', 'Seattle Tacoma', 'WA', 'port_17'),
('SJU', 'Luis Munoz Marin International Airport', 'San Juan Carolina', 'PR', NULL),
('SLC', 'Salt Lake City International Airport', 'Salt Lake City', 'UT', NULL),
('STL', 'St_Louis Lambert International Airport', 'Saint Louis', 'MO', NULL),
('STT', 'Cyril E_King Airport', 'Charlotte Amalie Saint Thomas', 'VI', NULL),



