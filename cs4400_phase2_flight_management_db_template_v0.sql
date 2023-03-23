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

DROP TABLE IF EXISTS location;
CREATE TABLE location (
	locID VARCHAR(15) UNIQUE NOT NULL,
    PRIMARY KEY (locID)
) ENGINE=InnoDB;

INSERT INTO location(locID) VALUES
('plane_1'),
('plane_11'),
('plane_15'),
('plane_2'),
('plane_4'),
('plane_7'),
('plane_8'),
('plane_9'),
('port_1'),
('port_10'),
('port_11'),
('port_13'),
('port_14'),
('port_15'),
('port_17'),
('port_18'),
('port_2'),
('port_3'),
('port_4'),
('port_5'),
('port_7'),
('port_9');

DROP TABLE IF EXISTS airport;
CREATE TABLE airport (
	airportID CHAR(3) UNIQUE NOT NULL,
    airport_name VARCHAR(100) UNIQUE NOT NULL,
    city VARCHAR(40) NOT NULL,
    state CHAR(2) NOT NULL,
    locID VARCHAR(15) DEFAULT NULL,
    PRIMARY KEY (airportID),
    FOREIGN KEY (locID) REFERENCES location(locID)
) ENGINE=InnoDB;

INSERT INTO airport (airportID, airport_name, city, state, locID) VALUES
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
('STT', 'Cyril E_King Airport', 'Charlotte Amalie Saint Thomas', 'VI', NULL);

DROP TABLE IF EXISTS leg;
CREATE TABLE leg (
	legID VARCHAR(10) NOT NULL,
    distance decimal(5,0) NOT NULL,
    departure CHAR(3) NOT NULL,
    arrival CHAR(3) NOT NULL,
    PRIMARY KEY (legID),
    FOREIGN KEY (departure) REFERENCES airport(airportID),
    FOREIGN KEY (arrival) REFERENCES airport(airportID) 
) ENGINE=InnoDB;

# route_legs
INSERT INTO leg (legID, distance, departure, arrival) VALUES
('leg_4', 600, 'ATL', 'ORD'),
('leg_20', 600, 'ORD', 'DCA'),
('leg_7', 600, 'DCA', 'ATL'),
('leg_18', 1200, 'LAX', 'DFW'),
('leg_10', 800, 'DFW', 'ORD'),
('leg_22', 800, 'ORD', 'LAX'),
('leg_24', 1800, 'SEA', 'ORD'),
('leg_8', 200, 'DCA', 'JFK'),
('leg_23', 2400, 'SEA', 'JFK'),
('leg_9', 800, 'DFW', 'ATL'),
('leg_1', 600, 'ATL', 'IAD'),
('leg_25', 600, 'ORD', 'ATL'),
('leg_26', 800, 'LAX', 'ORD'),
('leg_12', 200, 'IAH', 'DAL'),
('leg_6', 200, 'DAL', 'HOU'),
('leg_3', 800, 'ATL', 'JFK'),
('leg_19', 1000, 'LAX', 'SEA'),
('leg_21', 800, 'ORD', 'DFW'),
('leg_16', 800, 'JFK', 'ORD'),
('leg_17', 2400, 'JFK', 'SEA'),
('leg_27', 1600, 'ATL', 'LAX');

# extra_legs
INSERT INTO leg (legID, distance, departure, arrival) VALUES
('leg_11', 600, 'IAD', 'ORD'),
('leg_13', 1400, 'IAH', 'LAX'),
('leg_14', 2400, 'ISP', 'BFI'),
('leg_15', 800, 'JFK', 'ATL'),
('leg_2', 600, 'ATL', 'IAH'),
('leg_5', 1000, 'BFI', 'LAX');

DROP TABLE IF EXISTS route;
CREATE TABLE route (
	routeID VARCHAR(50) NOT NULL,
    PRIMARY KEY (routeID)
) ENGINE=InnoDB;

INSERT INTO route (routeID) VALUES
('circle_east_coast'),
('circle_west_coast'),
('eastbound_north_milk_run'),
('eastbound_north_nonstop'),
('eastbound_south_milk_run'),
('hub_xchg_southeast'),
('hub_xchg_southwest'),
('local_texas'),
('northbound_east_coast'),
('northbound_west_coast'),
('southbound_midwest'),
('westbound_north_milk_run'),
('westbound_north_nonstop'),
('westbound_south_nonstop');

DROP TABLE IF EXISTS contains_table;
CREATE TABLE contains_table (
	routeID VARCHAR(50) NOT NULL,
    legID VARCHAR(10) NOT NULL,
    sequence decimal(1, 0) NOT NULL,
    PRIMARY KEY (routeID, legID, sequence),
    FOREIGN KEY (routeID) REFERENCES route(routeID),
    FOREIGN KEY (legID) REFERENCES leg(legID)
) ENGINE=InnoDB;

INSERT INTO contains_table (routeID, legID, sequence) VALUES
('circle_east_coast', 'leg_4', 1),
('circle_east_coast', 'leg_20', 2),
('circle_east_coast', 'leg_7', 3),
('circle_west_coast', 'leg_18', 1),
('circle_west_coast', 'leg_10', 2),
('circle_west_coast', 'leg_22', 3),
('eastbound_north_milk_run', 'leg_24', 1),
('eastbound_north_milk_run', 'leg_20', 2),
('eastbound_north_milk_run', 'leg_8', 3),
('eastbound_north_nonstop', 'leg_23', 1),
('eastbound_south_milk_run', 'leg_18', 1),
('eastbound_south_milk_run', 'leg_9', 2),
('eastbound_south_milk_run', 'leg_1', 3),
('hub_xchg_southeast', 'leg_25', 1),
('hub_xchg_southeast', 'leg_4', 2),
('hub_xchg_southwest', 'leg_22', 1),
('hub_xchg_southwest', 'leg_26', 2),
('local_texas', 'leg_12', 1),
('local_texas', 'leg_6', 2),
('northbound_east_coast', 'leg_3', 1),
('northbound_west_coast', 'leg_19', 1),
('southbound_midwest', 'leg_21', 1),
('westbound_north_milk_run', 'leg_16', 1),
('westbound_north_milk_run', 'leg_22', 2),
('westbound_north_milk_run', 'leg_19', 3),
('westbound_north_nonstop', 'leg_17', 1),
('westbound_south_nonstop', 'leg_27', 1);

DROP TABLE IF EXISTS flight;
CREATE TABLE flight (
	flightID VARCHAR(10) NOT NULL,
    routeID VARCHAR(50) NOT NULL,
    PRIMARY KEY (flightID),
    FOREIGN KEY (routeID) REFERENCES route(routeID) 
) ENGINE=InnoDB;

INSERT INTO flight (flightID, routeID) VALUES
('AM_1523', 'circle_west_coast'),
('DL_1174', 'northbound_east_coast'),
('DL_1243', 'westbound_north_nonstop'),
('DL_3410', 'circle_east_coast'),
('SP_1880', 'circle_east_coast'),
('SW_1776', 'hub_xchg_southwest'),
('SW_610', 'local_texas'),
('UN_1899', 'eastbound_north_milk_run'),
('UN_523', 'hub_xchg_southeast'),
('UN_717', 'circle_west_coast');

DROP TABLE IF EXISTS airline;
CREATE TABLE airline (
	airlineID VARCHAR(20) NOT NULL,
    revenue INT NOT NULL,
    PRIMARY KEY (airlineID)
) ENGINE=InnoDB;

INSERT INTO airline(airlineID, revenue) VALUES
('Air_France', 25),
('American', 45),
('Delta', 46),
('JetBlue', 8),
('Lufthansa', 31),
('Southwest', 22),
('Spirit', 4),
('United', 40);

--
-- COMPLETE
--

DROP TABLE IF EXISTS airplane;
CREATE TABLE airplane (
	airlineID VARCHAR(20) UNIQUE NOT NULL,
    tail_num CHAR(6) NOT NULL,
    seat_cap INT NOT NULL,
    speed INT NOT NULL,
    flightID VARCHAR(10),
    locID varchar(10),
    plane_type VARCHAR(10),
    skids VARCHAR(15), 
    props INT,
    jets INT,
    progress INT DEFAULT NULL,
    airplane_status VARCHAR(15) DEFAULT NULL,
    next_time TIME DEFAULT NULL,
    PRIMARY KEY (airlineID, tail_num),
    FOREIGN KEY (airlineID) REFERENCES airline(airlineID),
    FOREIGN KEY (flightID) REFERENCES flight(flightID), 
    FOREIGN KEY (locID) REFERENCES location(locID) 
) ENGINE=InnoDB;

INSERT INTO airplane (airlineID, tail_num, seat_cap, speed, flightID, locID, plane_type, skids, props, jets, progress, airplane_status, next_time) VALUES
('American', 'n330ss', 4, 200, 'AM_1523', 'plane_4', 'jet', NULL, NULL, 2, 2, 'on_ground', '14:30:00'),
('American', 'n380sd', 5, 400, NULL, NULL, 'jet', NULL, NULL, 2, NULL, NULL, NULL),
('Delta', 'n106js', 4, 200, 'DL_1174', 'plane_1', 'jet', NULL, NULL, 2, 0, 'on_ground', '08:00:00'),
('Delta', 'n110jn', 5, 600, 'DL_1243', 'plane_2', 'jet', NULL, NULL, 4, 0, 'on_ground', '09:30:00'),
('Delta', 'n127js', 4, 800, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('Delta', 'n156sq', 8, 100, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL),
('JetBlue', 'n161fk', 4, 200, NULL, NULL, 'jet', NULL, NULL, 2, NULL, NULL, NULL),
('JetBlue', 'n337as', 5, 400, NULL, NULL, 'jet', NULL, NULL, 2, NULL, NULL, NULL),
('Southwest', 'n118fm', 4, 100, 'SW_610', 'plane_11', 'prop', 1, 1, NULL, 2, 'in_flight', '11:30:00'),
('Southwest', 'n401fj', 4, 200, 'SW_1776', 'plane_9', 'jet', NULL, NULL, 2, 2, 'in_flight','14:00:00'),
('Southwest', 'n653fk', 6, 400, NULL, NULL, 'jet', NULL, NULL, 2, NULL, NULL, NULL),
('Southwest', 'n815pw', 3, 200, NULL, NULL, 'prop', 0, 2, NULL, NULL, NULL, NULL),
('Spirit', 'n256ap', 4, 400, 'SP_1880', 'plane_15', 'jet', NULL, NULL, 2, 2, 'in_flight', '15:00:00'),
('United', 'n451fi', 5, 400, NULL, NULL, 'jet', NULL, NULL, 4, NULL, NULL, NULL),
('United', 'n517ly', 4, 400, 'UN_1899', 'plane_7', 'jet', NULL, NULL, 2, 0, 'on_ground', '09:30:00'),
('United', 'n616lt', 7, 400, NULL, NULL, 'jet', NULL, NULL, 4, NULL, NULL, NULL),
('United', 'n620la', 4, 200, 'UN_523', 'plane_8', 'prop', 0, 2, NULL, 1, 'in_flight', '11:00:00');

DROP TABLE IF EXISTS person;
CREATE TABLE person (
	personID VARCHAR(5) NOT NULL UNIQUE,
    first_name VARCHAR(15) NOT NULL,
    last_name VARCHAR(15) NOT NULL,
    locID VARCHAR(15) NOT NULL,
    isPilot BOOLEAN,
    isPassenger BOOLEAN,
    PRIMARY KEY (personID),
    FOREIGN KEY (locID) REFERENCES location(locID)
		ON DELETE RESTRICT
) ENGINE=InnoDB;

INSERT INTO person (personID, first_name, last_name, locID, isPilot, isPassenger) VALUES
('p1', 'Jeanne', 'Nelson', 'plane_1', True, False),
('p10', 'Lawrence', 'Morgan', 'plane_9', True, False),
('p11', 'Sandra', 'Cruz', 'plane_9', True, False),
('p12', 'Dan', 'Ball', 'plane_11', True, False),
('p13', 'Bryant', 'Figueroa', 'plane_2', True, False),
('p14', 'Dana', 'Perry', 'plane_2', True, False),
('p15', 'Matt', 'Hunt', 'plane_2', True, False),
('p16', 'Edna', 'Brown', 'plane_15', True, False),
('p17', 'Ruby', 'Burgess', 'plane_15', True, False),
('p18', 'Esther', 'Pittman', 'port_2', True, False),
('p19', 'Doug', 'Fowler', 'port_4', True, False),
('p2', 'Roxanne', 'Byrd', 'plane_1', True, False),
('p20', 'Thomas', 'Olson', 'port_3', True, False),
('p21', 'Mona', 'Harrison', 'port_4', True, True),
('p22', 'Arlene', 'Massey', 'port_2', True, True),
('p23', 'Judith', 'Patrick', 'port_3', True, True),
('p24', 'Reginald', 'Rhodes', 'plane_1', True, True),
('p25', 'Vincent', 'Garcia', 'plane_1', True, True),
('p26', 'Cheryl', 'Moore', 'plane_4', True, True),
('p27', 'Michael', 'Rivera', 'plane_7', False, True),
('p28', 'Luther', 'Matthews', 'plane_8', False, True),
('p29', 'Moses', 'Parks', 'plane_8', False, True),
('p3', 'Tanya', 'Nguyen', 'plane_4', True, False),
('p30', 'Ora', 'Steele', 'plane_9', False, True),
('p31', 'Antonio', 'Flores', 'plane_9', False, True),
('p32', 'Glenn', 'Ross', 'plane_11', False, True),
('p33', 'Irma', 'Thomas', 'plane_11', False, True),
('p34', 'Ann', 'Maldonado', 'plane_2', False, True),
('p35', 'Jeffrey', 'Cruz', 'plane_2', False, True),
('p36', 'Sonya', 'Price', 'plane_15', False, True),
('p37', 'Tracy', 'Hale', 'plane_15', False, True),
('p38', 'Albert', 'Simmons', 'port_1', False, True),
('p39', 'Karen', 'Terry', 'port_9', False, True),
('p4', 'Kendra', 'Jacobs', 'plane_4', True, False),
('p40', 'Glen', 'Kelley', 'plane_4', False, True),
('p41', 'Brooke', 'Little', 'port_4', False, True),
('p42', 'Daryl', 'Nguyen', 'port_3', False, True),
('p43', 'Judy', 'Willis', 'port_1', False, True),
('p44', 'Marco', 'Klein', 'port_2', False, True),
('p45', 'Angelica', 'Hampton', 'port_5', False, True),
('p5', 'Jeff', 'Burton', 'plane_4', True, False),
('p6', 'Randal', 'Parks', 'plane_7', True, False),
('p7', 'Sonya', 'Owens', 'plane_7', True, False),
('p8', 'Bennie', 'Palmer', 'plane_8', True, False),
('p9', 'Marlene', 'Warner', 'plane_8', True, False);

DROP TABLE IF EXISTS pilot;
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
	
) Engine=InnoDB;

INSERT INTO pilot (personID, taxID, experience, airlineID, tail_num) VALUES
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

DROP TABLE IF EXISTS passenger;
CREATE TABLE passenger (
	personID VARCHAR(5) NOT NULL,
    miles INT,
    FOREIGN KEY (personID) REFERENCES person(personID)
) ENGINE=InnoDB;

INSERT INTO passenger (personID, miles) VALUES
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

--
-- CONTINUE
--

DROP TABLE IF EXISTS ticket;
CREATE TABLE ticket (
	ticketID VARCHAR(15) NOT NULL,
    cost decimal(4, 0) NOT NULL,
    flightID VARCHAR(10) NOT NULL,
    airportID CHAR(3) NOT NULL,
    personID VARCHAR(5) NOT NULL, 
    PRIMARY KEY (ticketID),
    FOREIGN KEY (flightID) REFERENCES flight(flightID),
    FOREIGN KEY (airportID) REFERENCES airport(airportID),
    FOREIGN KEY (personID) REFERENCES person(personID)
) ENGINE=InnoDB;

INSERT INTO ticket (ticketID, cost, flightID, airportID, personID) VALUES
('tkt_am_17', 375, 'AM_1523', 'ORD', 'p40'),
('tkt_am_18', 275, 'AM_1523', 'LAX', 'p41'),
('tkt_am_3', 250, 'AM_1523', 'LAX', 'p26'),
('tkt_dl_1', 450, 'DL_1174', 'JFK', 'p24'),
('tkt_dl_11', 500, 'DL_1243', 'LAX', 'p34'),
('tkt_dl_12', 250, 'DL_1243', 'LAX', 'p35'),
('tkt_dl_2', 225, 'DL_1174', 'JFK', 'p25'),
('tkt_sp_13', 225, 'SP_1880', 'ATL', 'p36'),
('tkt_sp_14', 150, 'SP_1880', 'DCA', 'p37'),
('tkt_sp_16', 475, 'SP_1880', 'ATL', 'p39'),
('tkt_sw_10', 425, 'SW_610', 'HOU', 'p33'),
('tkt_sw_7', 400, 'SW_1776', 'ORD', 'p30'),
('tkt_sw_8', 175, 'SW_1776', 'ORD', 'p31'),
('tkt_sw_9', 125, 'SW_610', 'HOU', 'p32'),
('tkt_un_15', 150, 'UN_523', 'ORD', 'p38'),
('tkt_un_4', 175, 'UN_1899', 'DCA', 'p27'),
('tkt_un_5', 225, 'UN_523', 'ATL', 'p28'),
('tkt_un_6', 100, 'UN_523', 'ORD', 'p29');

DROP TABLE IF EXISTS seat;
CREATE TABLE seat (
	seat_num CHAR(2) NOT NULL,
    ticketID VARCHAR(15) NOT NULL,
    PRIMARY KEY (seat_num, ticketID),
    FOREIGN KEY (ticketID) REFERENCES ticket(ticketID) 
) ENGINE=InnoDB;

INSERT INTO seat (seat_num, ticketID) VALUES
('2B', 'tkt_am_17'),
('2A', 'tkt_am_18'),
('3B', 'tkt_am_3'),
('1C', 'tkt_dl_1'),
('2F', 'tkt_dl_1'),
('1B', 'tkt_dl_11'),
('1E', 'tkt_dl_11'),
('2F', 'tkt_dl_11'),
('2A', 'tkt_dl_12'),
('2D', 'tkt_dl_2'),
('1A', 'tkt_sp_13'),
('1D', 'tkt_sw_10'),
('3C', 'tkt_sw_7'),
('3E', 'tkt_sw_8'),
('1C', 'tkt_sw_9'),
('2B', 'tkt_un_4'),
('1A', 'tkt_un_5'),
('3B', 'tkt_un_6');

DROP TABLE IF EXISTS license;
CREATE TABLE license (
    taxID CHAR(11) NOT NULL,
    license VARCHAR(10) NOT NULL,
    FOREIGN KEY (taxID) REFERENCES pilot(taxID) 
) ENGINE=InnoDB;

INSERT INTO license (taxID, license) VALUES
('153-47-8101', 'testing'),
('803-30-1789', 'testing'),
('936-44-6941', 'testing'),
('330-12-6907', 'jet'),
('769-60-1266', 'jet'),
('369-22-9505', 'jet'),
('369-22-9505', 'jet'),
('513-40-4168', 'jet'),
('513-40-4168', 'jet'),
('153-47-8101', 'jet'),
('153-47-8101', 'jet'),
('865-71-6800', 'jet'),
('865-71-6800', 'jet'),
('386-39-7881', 'jet'),
('386-39-7881', 'jet'),
('522-44-3098', 'jet'),
('522-44-3098', 'jet'),
('177-47-9877', 'jet'),
('177-47-9877', 'jet'),
('803-30-1789', 'jet'),
('803-30-1789', 'jet'),
('584-77-5105', 'jet'),
('584-77-5105', 'jet'),
('750-24-7616', 'jet'),
('750-24-7616', 'jet'),
('933-93-2165', 'jet'),
('933-93-2165', 'jet'),
('450-25-5617', 'jet'),
('450-25-5617', 'jet'),
('936-44-6941', 'jet'),
('369-22-9505', 'prop'),
('153-47-8101', 'prop'),
('865-71-6800', 'prop'),
('842-88-1257', 'prop'),
('621-34-5755', 'prop'),
('803-30-1789', 'prop'),
('776-21-8098', 'prop'),
('707-84-4555', 'prop'),
('936-44-6941', 'prop');




