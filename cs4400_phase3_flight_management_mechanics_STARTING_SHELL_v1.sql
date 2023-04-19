-- CS4400: Introduction to Database Systems: Wednesday, March 8, 2023
-- Flight Management Course Project Mechanics (v1.0) STARTING SHELL
-- Views, Functions & Stored Procedures

/* This is a standard preamble for most of our scripts.  The intent is to establish
a consistent environment for the database behavior. */
set global transaction isolation level serializable;
set global SQL_MODE = 'ANSI,TRADITIONAL';
set names utf8mb4;
set SQL_SAFE_UPDATES = 0;
set @thisDatabase = 'flight_management';

use flight_management;
-- -----------------------------------------------------------------------------
-- stored procedures and views
-- -----------------------------------------------------------------------------
/* Standard Procedure: If one or more of the necessary conditions for a procedure to
be executed is false, then simply have the procedure halt execution without changing
the database state. Do NOT display any error messages, etc. */

-- [1] add_airplane()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airplane.  A new airplane must be sponsored
by an existing airline, and must have a unique tail number for that airline.
username.  An airplane must also have a non-zero seat capacity and speed. An airplane
might also have other factors depending on it's type, like skids or some number
of engines.  Finally, an airplane must have a database-wide unique location if
it will be used to carry passengers. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airplane;
delimiter //
create procedure add_airplane (in ip_airlineID varchar(50), in ip_tail_num varchar(50),
	in ip_seat_capacity integer, in ip_speed integer, in ip_locationID varchar(50),
    in ip_plane_type varchar(100), in ip_skids boolean, in ip_propellers integer,
    in ip_jet_engines integer)
sp_main: begin
    
	-- Airplane must be sponsored by an existing airline
	IF (SELECT COUNT(*) FROM airline WHERE airlineID = ip_airlineID) < 1 THEN
		LEAVE sp_main;
	END IF;

	-- Unique tail number
	IF (SELECT COUNT(*) FROM airplane WHERE tail_num = ip_tail_num) > 0 THEN
		LEAVE sp_main;
	END IF;
    
	-- Nonzero seat capacity and speed
	IF ip_seat_capacity <= 0 OR ip_speed <= 0 THEN
		LEAVE sp_main;
    END IF;

	-- For certain types, some parameters must be given
	IF ip_plane_type = 'jet' OR ip_propellers != NULL OR ip_skids != NULL THEN
		IF ip_jet_engines = NULL THEN
			LEAVE sp_main;
        END IF;
    ELSEIF ip_plane_type = 'prop' THEN
		IF ip_skids = NULL OR ip_propellers = NULL OR ip_jet_engines != NULL THEN
			LEAVE sp_main;
        END IF;
        
	END IF;

	-- Must have a unique location if it will carry passengers
	IF (SELECT COUNT(*) FROM location WHERE location.locationID = ip_locationID) > 0 THEN
		LEAVE sp_main;
    END IF;
    
	-- Must be valid to insert the airplane (thus atomic operation)
	INSERT INTO airplane(airlineID, tail_num, seat_capacity, speed, locationID, plane_type,
		skids, propellers, jet_engines) VALUES
	(ip_airlineID, ip_tail_num, ip_seat_capacity, ip_speed, ip_locationID, ip_plane_type, ip_skids, ip_propellers, ip_jet_engines);

end //
delimiter ;

-- [2] add_airport()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new airport.  A new airport must have a unique
identifier along with a database-wide unique location if it will be used to support
airplane takeoffs and landings.  An airport may have a longer, more descriptive
name.  An airport must also have a city and state designation. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_airport;
delimiter //
create procedure add_airport (in ip_airportID char(3), in ip_airport_name varchar(200),
    in ip_city varchar(100), in ip_state char(2), in ip_locationID varchar(50))
sp_main: begin

	# I don't think it's *required* to have a longer name!

	DECLARE valid BOOLEAN DEFAULT TRUE;
    
    # Must have unique airportID
	IF (SELECT COUNT(*) FROM airport WHERE airportID = ip_airportID) > 0 THEN
		LEAVE sp_main;
	END IF;
    
    # Must have unique locationID
    IF (SELECT COUNT(*) FROM location WHERE locationID = ip_locationID) > 0 THEN
		LEAVE sp_main;
	END IF;
    
    # Must have a city, state
    IF ip_city = NULL OR ip_state = NULL THEN
		LEAVE sp_main;
	END IF;
    
    
	INSERT INTO airport (airportID, airport_name, city, state, locationID) VALUES
		(ip_airportID, ip_airport_name, ip_city, ip_state, ip_locationID);

end //
delimiter ;

-- [3] add_person()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new person.  A new person must reference a unique
identifier along with a database-wide unique location used to determine where the
person is currently located: either at an airport, or on an airplane, at any given
time.  A person may have a first and last name as well.

Also, a person can hold a pilot role, a passenger role, or both roles.  As a pilot,
a person must have a tax identifier to receive pay, and an experience level.  Also,
a pilot might be assigned to a specific airplane as part of the flight crew.  As a
passenger, a person will have some amount of frequent flyer miles. */
-- -----------------------------------------------------------------------------
drop procedure if exists add_person;
delimiter //
create procedure add_person (in ip_personID varchar(50), in ip_first_name varchar(100),
    in ip_last_name varchar(100), in ip_locationID varchar(50), in ip_taxID varchar(50),
    in ip_experience integer, in ip_flying_airline varchar(50), in ip_flying_tail varchar(50),
    in ip_miles integer)
sp_main: begin

	# First and last name NOT required!

	DECLARE valid BOOLEAN DEFAULT TRUE;
    DECLARE isPilot BOOLEAN DEFAULT FALSE;
    DECLARE	isPassenger BOOLEAN DEFAULT TRUE;

	# Must have unique personID
    IF (SELECT COUNT(*) FROM person WHERE personID = ip_personID) > 0 THEN
		LEAVE sp_main;
    END IF;
    
    # Must have a valid locationID
    IF (SELECT COUNT(*) FROM location WHERE locationID = ip_locationID) = 0 THEN
		LEAVE sp_main;
	END IF;
    
    # Pilots will have a taxID (that's not used before), experience level
    IF ip_taxID != NULL OR ip_experience != NULL THEN
		# If there's only one of the pilot values, then this is invalid input
		IF ip_taxID = NULL OR ip_experience = NULL THEN
			SET isPilot = FALSE;
		ELSE
			# Cannot have just one of the flight info (but CAN have none)
			IF ip_flying_airline != NULL OR ip_flying_tail != NULL THEN
				IF ip_flying_airline = NULL OR ip_flying_tail = NULL THEN
					SET isPilot = FALSE;
				END IF;
			END IF;
			# TaxID must not already be used!
			IF (SELECT COUNT(*) FROM pilot WHERE taxID = ip_taxID) > 0 THEN
				SET isPilot = FALSE;
			ELSE
				SET isPilot = TRUE;
			END IF;
        END IF;
    END IF;
    
	# Passengers will have a given number of flight miles
	IF ip_miles != NULL THEN
		SET isPassenger = TRUE;
	END IF;

	# Add to the person, pilot, and passenger tables!
	INSERT INTO person (personID, first_name, last_name, locationID) VALUES
		(ip_personID, ip_first_name, ip_last_name, ip_locationID);
	IF isPassenger = TRUE THEN
		INSERT INTO passenger (personID, miles) VALUES
		(ip_personID, ip_miles);
	END IF;
	IF isPilot = TRUE THEN
		INSERT INTO pilot (personID, taxID, experience, flying_airline, flying_tail) VALUE
			(ip_personID, ip_taxID, ip_experience, ip_flying_airline, ip_flying_tail);
	END IF;

end //
delimiter ;

-- [4] grant_pilot_license()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new pilot license.  The license must reference
a valid pilot, and must be a new/unique type of license for that pilot. */
-- -----------------------------------------------------------------------------
drop procedure if exists grant_pilot_license;
delimiter //
create procedure grant_pilot_license (in ip_personID varchar(50), in ip_license varchar(100))
sp_main: begin

    # Must be a pilot
	IF (SELECT COUNT(*) FROM pilot WHERE personID = ip_personID) < 1 THEN
		LEAVE sp_main;
    END IF;
    
    # The license cannot already exist for that pilot
    IF (SELECT COUNT(*) FROM pilot_licenses WHERE personID = ip_personID AND license = ip_license) > 0 THEN
		LEAVE sp_main;
	END IF;
    
    # Insert into pilot_licenses table
	INSERT INTO pilot_licenses (personID, license) VALUES
		(ip_personID, ip_license);

end //
delimiter ;

-- [5] offer_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new flight.  The flight can be defined before
an airplane has been assigned for support, but it must have a valid route.  Once
an airplane has been assigned, we must also track where the airplane is along
the route, whether it is in flight or on the ground, and when the next action -
takeoff or landing - will occur. */
-- -----------------------------------------------------------------------------
drop procedure if exists offer_flight;
delimiter //
create procedure offer_flight (in ip_flightID varchar(50), in ip_routeID varchar(50),
    in ip_support_airline varchar(50), in ip_support_tail varchar(50), in ip_progress integer,
    in ip_airplane_status varchar(100), in ip_next_time time)
sp_main: begin

	# Not required to have a support airplane!
    
    # Must have progress, status, and next_time if airplane is assigned
	IF ip_support_airline != NULL OR ip_support_tail != NULL THEN
		# If support_airline or support_tail is given, then its not valid if the rest isnt given
		IF ip_support_airline = NULL OR ip_support_tail = NULL OR ip_progress = NULL OR ip_airplane_status = NULL OR ip_next_time THEN
			LEAVE sp_main;
        END IF;
    END IF;
    
	# FlightID cannot already exist
    IF (SELECT COUNT(*) FROM flight WHERE flightID = ip_flightID) > 0 THEN
        LEAVE sp_main;
    END IF;
    
    # Must have a valid routeID
    IF (SELECT COUNT(*) FROM route WHERE routeID = ip_routeID) = 0 THEN
		LEAVE sp_main;
    END IF;

	# Insert into flights!
	INSERT INTO flight (flightID, routeID, support_airline, support_tail, progress, airplane_status, next_time) VALUES
		(ip_flightID, ip_routeID, ip_support_airline, ip_support_tail, ip_progress, ip_airplane_status, ip_next_time);

end //
delimiter ;

-- [6] purchase_ticket_and_seat()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new ticket.  The cost of the flight is optional
since it might have been a gift, purchased with frequent flyer miles, etc.  Each
flight must be tied to a valid person for a valid flight.  Also, we will make the
(hopefully simplifying) assumption that the departure airport for the ticket will
be the airport at which the traveler is currently located.  The ticket must also
explicitly list the destination airport, which can be an airport before the final
airport on the route.  Finally, the seat must be unoccupied. */
-- -----------------------------------------------------------------------------
drop procedure if exists purchase_ticket_and_seat;
delimiter //
create procedure purchase_ticket_and_seat (in ip_ticketID varchar(50), in ip_cost integer,
	in ip_carrier varchar(50), in ip_customer varchar(50), in ip_deplane_at char(3),
    in ip_seat_number varchar(50))
sp_main: begin
	# Check if arguments are valid.
	# The seat must be unoccupied.
   if (select count(*) from (ticket join ticket_seats on ticket.ticketID = ticket_seats.ticketID) where ip_seat_number = seat_number and ip_carrier = carrier) > 0 then
		leave sp_main;
	end if;
	
	insert into ticket (ticketID, cost, carrier, customer, deplane_at) values
		(ip_ticketID, ip_cost, ip_carrier, ip_customer, ip_deplane_at);
    insert into ticket_seats (ticketID, seat_number) values
		(ip_ticketID, ip_seat_number);
end //
delimiter ;

-- [7] add_update_leg()
-- -----------------------------------------------------------------------------
/* This stored procedure creates a new leg as specified.  However, if a leg from
the departure airport to the arrival airport already exists, then don't create a
new leg - instead, update the existence of the current leg while keeping the existing
identifier.  Also, all legs must be symmetric.  If a leg in the opposite direction
exists, then update the distance to ensure that it is equivalent.   */
-- -----------------------------------------------------------------------------
drop procedure if exists add_update_leg;
delimiter //
create procedure add_update_leg (in ip_legID varchar(50), in ip_distance integer,
    in ip_departure char(3), in ip_arrival char(3))
sp_main: begin
	# Check if arguments are valid
    # Check if a leg from the departure airport to the arrival airport already exists. 
    if (select count(*) from leg where leg.departure = ip_departure and leg.arrival = ip_arrival) > 0 then
		# If such leg already exists then do not create a new leg. Instead update the current leg found.
        update leg
        set leg.distance = ip_distance # update leg's distance but NOT ID
        where leg.legID = ip_legID;
        # If a leg in the opposite direction exists, also updates its distance to maintain symmetry.
        if (select count(*) from leg where leg.departure = ip_arrival and leg.arrival = ip_departure) > 0 then
			update leg
            set leg.distance = ip_distance
            where leg.departure = ip_arrival and leg.arrival = ip_departure;
        end if;
		leave sp_main;
	end if;
	insert into leg (legID, distance, departure, arrival) values
		(ip_legID, ip_distance, ip_departure, ip_arrival);
end //
delimiter ;

-- [8] start_route()
-- -----------------------------------------------------------------------------
/* This stored procedure creates the first leg of a new route.  Routes in our
system must be created in the sequential order of the legs.  The first leg of
the route can be any valid leg. */
-- -----------------------------------------------------------------------------
drop procedure if exists start_route;
delimiter //
create procedure start_route (in ip_routeID varchar(50), in ip_legID varchar(50))
sp_main: begin
    if (select count(*) from route_path where route_path.legID = ip_legID) = 0 then
		leave sp_main;
	end if;
    
	if (select count(*) from route_path where route_path.legID = ip_legID) = 0 then
		leave sp_main;
	end if;
    
	insert into route (routeID) values
		(ip_routeID);
	insert into route_path (routeID, legID, sequence) values
		(ip_routeID, ip_legID, 1);
end //
delimiter ;

-- [9] extend_route()
-- -----------------------------------------------------------------------------
/* This stored procedure adds another leg to the end of an existing route.  Routes
in our system must be created in the sequential order of the legs, and the route
must be contiguous: the departure airport of this leg must be the same as the
arrival airport of the previous leg. */
-- -----------------------------------------------------------------------------
drop procedure if exists extend_route;
delimiter //
create procedure extend_route (in ip_routeID varchar(50), in ip_legID varchar(50))
sp_main: begin

	declare last_airport_rp char(3) default null;
    declare departing_airport_new_leg char(3) default null;
    declare last_leg_num integer default 0;
    declare last_legID varchar(50) default null;
	
    # Route must already exist
	if (select count(*) from route_path rp where rp.routeID = ip_routeID) = 0 then leave sp_main; end if;
    
    # Leg must exist
    if (select count(*) from leg l where l.legID = ip_legID) = 0 then leave sp_main; end if;
    
    set last_leg_num = (select count(*) from route_path rp where rp.routeID = ip_routeID);
    set last_legID = (select rp.legID from route_path rp where rp.routeID = ip_routeID and rp.sequence = last_leg_num);
    set last_airport_rp = (select l.arrival from leg l where l.legID = last_legID);
    set departing_airport_new_leg = (select l.departure from leg l where l.legID = ip_legID);
    
    # Current arrival airport for end route_path must be departing airport of new leg
    if (last_airport_rp != departing_airport_new_leg) then leave sp_main; end if;
    
    insert into route_path values (ip_routeID, ip_legID, last_leg_num + 1);

end //
delimiter ;

-- [10] flight_landing()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight landing at the next airport
along it's route.  The time for the flight should be moved one hour into the future
to allow for the flight to be checked, refueled, restocked, etc. for the next leg
of travel.  Also, the pilots of the flight should receive increased experience, and
the passengers should have their frequent flyer miles updated. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_landing;
delimiter //
create procedure flight_landing (in ip_flightID varchar(50))
sp_main: begin

	declare current_leg integer default 0;
    declare current_status varchar(100) default null;
    declare curr_next_time time default null;
    declare new_airplane_status varchar(100) default null;
    declare new_next_time time default null;

    declare supp_airline varchar(50) default null;
    declare supp_tail varchar(50) default null;
    declare num_miles integer default 0;
    declare plane_num varchar(50) default null;
                
	# Make sure that the flightID exists
	if (select count(*) from flight f where f.flightID = ip_flightID) < 1 then leave sp_main; end if;
    
    set current_leg = (select progress from flight f where f.flightID = ip_flightID);
	set curr_next_time = (select next_time from flight f where f.flightID = ip_flightID);
    set current_status = (select airplane_status from flight f where f.flightID = ip_flightID);

	# Make sure that the flight has made any amount of progress
    if (current_leg < 1) then leave sp_main; end if;
    
    # Make sure that the flight is not on the ground
    if (current_status = 'on_ground') then leave sp_main; end if;
    
    set new_airplane_status = 'on_ground';
    set new_next_time = ADDTIME(curr_next_time, MAKETIME(1, 0, 0));
    
    update flight f set f.airplane_status = new_airplane_status, f.next_time = new_next_time
			where f.flightID = ip_flightID;
            
	set supp_airline = (select support_airline from flight f where f.flightID = ip_flightID);
    set supp_tail = (select support_tail from flight f where f.flightID = ip_flightID);
	
    update pilot p set p.experience = p.experience + 1 where p.flying_airline = supp_airline
			and p.flying_tail = supp_tail;
            
	set num_miles = (select l.distance from (leg l join route_path rp on l.legID = rp.legID) 
                         join flight f on rp.routeID = f.routeID and rp.sequence = f.progress where f.flightID = ip_flightID);
	set plane_num = (select locationID from airplane a where a.airlineID = supp_airline and a.tail_num = supp_tail);
            
	update passenger p set p.miles = p.miles + num_miles where p.personID in 
			(select pe.personID from person pe where pe.locationID = plane_num);

end //
delimiter ;

-- [11] flight_takeoff()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for a flight taking off from its current
airport towards the next airport along it's route.  The time for the next leg of
the flight must be calculated based on the distance and the speed of the airplane.
And we must also ensure that propeller driven planes have at least one pilot
assigned, while jets must have a minimum of two pilots. If the flight cannot take
off because of a pilot shortage, then the flight must be delayed for 30 minutes. */
-- -----------------------------------------------------------------------------
drop procedure if exists flight_takeoff;
delimiter //
create procedure flight_takeoff (in ip_flightID varchar(50))
sp_main: begin

    declare current_leg integer default 0;
    declare current_status varchar(100) default null;
    declare num_legs integer default 0;
    declare curr_next_time time default null;
    declare plane_type varchar(100) default null;
	declare num_pilots integer default 0;
	declare flight_shortage boolean default false;
	declare new_progress integer default 0;
    declare new_airplane_status varchar(100) default null;
    declare add_time time default null;
    declare new_next_time time default null;
    declare airplane_speed integer default 0;
    declare distance integer default 0;
                
	# Make sure that the flightID exists
	if (select count(*) from flight f where f.flightID = ip_flightID) < 1 then leave sp_main; end if;
    
    set current_leg = (select progress from flight f where f.flightID = ip_flightID);
    set num_legs = (select count(*) from flight f join route_path rp on f.routeID = rp.routeID where f.flightID = ip_flightID);
	set curr_next_time = (select next_time from flight f where f.flightID = ip_flightID);
    set current_status = (select airplane_status from flight f where f.flightID = ip_flightID);
    
    # Make sure that the flight can take off (i.e. not on last leg)
	if current_leg >= num_legs then leave sp_main; end if;

    # Make sure that the flight is not already in the air
    if current_status = 'in_flight' then leave sp_main; end if;
    
    set plane_type = (select a.plane_type from airplane a join flight f on a.airlineID = f.support_airline 
					and a.tail_num = f.support_tail where f.flightID = ip_flightID);
    set num_pilots = (select count(*) from (pilot p join flight f on p.flying_airline = f.support_airline 
					and p.flying_tail = f.support_tail) where f.flightID = ip_flightID); 
    
	# Propellor driven airplanes should have at least one pilot assigned
    # Jet driven airplanes should have at least two pilots assigned
	if (plane_type = 'prop' and num_pilots < 1) or (plane_type = 'jet' and num_pilots < 2) then set flight_shortage = true; end if;
    
    # Compute next_time with airplane_speed and distance
    set airplane_speed = (select a.speed from airplane a join flight f on a.airlineID = f.support_airline
						 and a.tail_num = f.support_tail where f.flightID = ip_flightID);
 	set distance = (select l.distance from (leg l join route_path rp on l.legID = rp.legID) 
                         join flight f on rp.routeID = f.routeID and rp.sequence = f.progress + 1 where f.flightID = ip_flightID);
    
    if flight_shortage then
		# Delay by 30 min
		set add_time = MAKETIME(0, 30, 0);
        set new_progress = current_leg;
        set new_airplane_status = 'on_ground';
	else 
		set add_time = MAKETIME(distance / airplane_speed, 0, 0);
        set new_progress = current_leg + 1;
        set new_airplane_status = 'in_flight';
    end if;
    
    set new_next_time = ADDTIME(curr_next_time, add_time);
        
	update flight f set f.progress = new_progress, f.airplane_status = new_airplane_status, 
		f.next_time = new_next_time where f.flightID = ip_flightID;
end //
delimiter ;

-- [12] passengers_board()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting on a flight at
its current airport.  The passengers must be at the airport and hold a valid ticket
for the flight. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_board;
delimiter //
create procedure passengers_board (in ip_flightID varchar(50))
sp_main: begin

	DECLARE current_leg INTEGER DEFAULT 0;
    DECLARE current_status VARCHAR(100) DEFAULT NULL;
    DECLARE num_legs INTEGER DEFAULT 0;
    DECLARE current_next_time TIME DEFAULT NULL;
    
    DECLARE route_id VARCHAR(50);
    DECLARE departing_airport CHAR(3);
    DECLARE arriving_airport CHAR(3);
    DECLARE plane VARCHAR(50) DEFAULT NULL;
    DECLARE current_port VARCHAR(50) DEFAULT NULL;
    DECLARE supp_airline VARCHAR(50) DEFAULT NULL;
    DECLARE supp_tail VARCHAR(50) DEFAULT NULL;
    
	# Make sure that the flightID exists
	IF (SELECT COUNT(*) FROM flight WHERE flight.flightID = ip_flightID) < 1 THEN
		LEAVE sp_main;
	END IF;
    
    SET current_leg = (SELECT progress FROM flight WHERE flight.flightID = ip_flightID);
    SET num_legs = (SELECT COUNT(*) FROM flight JOIN route_path ON flight.routeID = route_path.routeID
					WHERE flight.flightID = ip_flightID);
                    
	SET current_next_time = (SELECT next_time FROM flight WHERE flight.flightID = ip_flightID);
    SET current_status = (SELECT airplane_status FROM flight WHERE flight.flightID = ip_flightID);
    
	# Passengers cannot board a plane in flight
    IF current_status = 'in_flight' THEN
		LEAVE sp_main;
	END IF;
    
    # Passengers cannot board a plane on its last leg
	IF current_leg >= num_legs THEN
		LEAVE sp_main;
	END IF;
    
    SET route_id = (SELECT route_id FROM flight WHERE flightID = ip_flightID);
    
    # In form 'ATL'
    SET departing_airport = (SELECT leg.departure FROM (leg JOIN route_path ON leg.legID = route_path.legID)
							JOIN flight ON route_path.routeID = flight.routeID AND route_path.sequence = current_leg + 1
                            WHERE flight.flightID = ip_flightID);
                            
    # In form 'ATL'
	SET arriving_airport = (SELECT leg.arrival FROM (leg JOIN route_path ON leg.legID = route_path.legID)
							JOIN flight ON route_path.routeID = flight.routeID AND route_path.sequence = current_leg + 1
                            WHERE flight.flightID = ip_flightID);
	
    # In form port_1
    SET current_port = (SELECT airport.locationID FROM airport WHERE airport.airportID = departing_airport);
    
    SET supp_airline = (SELECT support_airline FROM flight WHERE flightID = ip_flightID);
    SET supp_tail = (SELECT support_tail FROM flight WHERE flightID = ip_flightID);
    # In form plane_1
	SET plane = (SELECT airplane.locationID FROM airplane WHERE airplane.airlineID = supp_airline AND airplane.tail_num = supp_tail);
    
    
    # Update where person is located (from port x -> plane y) if valid location and ticket
    UPDATE person SET person.locationID = plane 
			WHERE person.locationID = current_port
            AND personID IN (SELECT ticket.customer FROM ticket 
							WHERE ticket.carrier = ip_flightID
                            AND ticket.deplane_at = arriving_airport);

end //
delimiter ;

-- [13] passengers_disembark()
-- -----------------------------------------------------------------------------
/* This stored procedure updates the state for passengers getting off of a flight
at its current airport.  The passengers must be on that flight, and the flight must
be located at the destination airport as referenced by the ticket. */
-- -----------------------------------------------------------------------------
drop procedure if exists passengers_disembark;
delimiter //
create procedure passengers_disembark (in ip_flightID varchar(50))
sp_main: begin
declare arouteID varchar(50);
declare alegID varchar (50) ;
declare curprog varchar(50);
declare aairportID varchar (50);
declare location varchar(50);
if not exists(select routeID from flight where airplane_status = 'on_ground' and flightID = ip_flightID) then leave sp_main; end if;
set curprog = (select progress from flight where flightID = ip_flightID);
set arouteID = (select routeID from flight where flightID = ip_flightID);
set alegID = (select legID from route_path where routeID = arouteID and sequence = curprog) ;
set aairportID = (select arrival from leg where legID = alegID);
set location = (select locationID from airport where airportID = aairportID);

update person set
locationID = location where personID in (select customer from ticket where carrier
= ip_flightID and deplane_at = aairportID );
end //
delimiter ;

-- [14] assign_pilot()
-- -----------------------------------------------------------------------------
/* This stored procedure assigns a pilot as part of the flight crew for a given
airplane.  The pilot being assigned must have a license for that type of airplane,
and must be at the same location as the flight.  Also, a pilot can only support
one flight (i.e. one airplane) at a time.  The pilot must be assigned to the flight
and have their location updated for the appropriate airplane. */
-- -----------------------------------------------------------------------------
drop procedure if exists assign_pilot;
delimiter //
create procedure assign_pilot (in ip_flightID varchar(50), ip_personID varchar(50))
sp_main: begin

	declare plane_location varchar(50) default null;
    declare pilot_location varchar(50) default null;
    declare plane_type varchar(100) default null;
    declare supp_airline varchar(50) default null;
    declare supp_tail varchar(50) default null;
    declare routeID varchar(50) default null;
    declare current_leg_num integer default 0;
    declare current_legID varchar(50) default null;
    declare num_legs integer default 0;
    declare airportID char(3) default null;
    declare current_status varchar(100) default null;
    declare plane_num varchar(50) default null;
    
    # Make sure that the flightID exists
	if (select count(*) from flight f where f.flightID = ip_flightID) < 1 then leave sp_main; end if;
    
    # Make sure that personID exists
    if (select count(*) from person p where p.personID = ip_personID) < 1 then leave sp_main; end if;
    
    set supp_airline = (select f.support_airline from flight f where f.flightID = ip_flightID);
    set supp_tail = (select f.support_tail from flight f where f.flightID = ip_flightID);
    set plane_type = (select a.plane_type from airplane a where a.airlineID = supp_airline and a.tail_num = supp_tail);
    set routeID = (select f.routeID from flight f where f.flightID = ip_flightID);
    set current_status = (select f.airplane_status from flight f where f.flightID = ip_flightID);
    
    # Make sure that the flight is not already in the air
    if current_status = 'in_flight' then leave sp_main; end if;
    
    # Make sure that person has valid license for plane_type (i.e. by extension is pilot)
    if (select count(*) from pilot_licenses pl where pl.personID = ip_personID and pl.license = plane_type) < 1 then leave sp_main; end if;
    
    set current_leg_num = (select f.progress from flight f where f.flightID = ip_flightID);
    set num_legs = (select count(*) from flight f join route_path rp on f.routeID = rp.routeID where f.flightID = ip_flightID);
    
    # Cannot assign pilot if flight on last leg 
    if (current_leg_num = num_legs) then leave sp_main; end if;
    
    # If plane has not made any progress, use departing airport, otherwise use arriving
    if (current_leg_num = 0) then
		set current_legID = (select rp.legID from route_path rp where rp.routeID = routeID and rp.sequence = current_leg_num + 1);
        set airportID = (select l.departure from leg l where l.legID = current_legID);
	else 
		set current_legID = (select rp.legID from route_path rp where rp.routeID = routeID and rp.sequence = current_leg_num);
        set airportID = (select l.arrival from leg l where l.legID = current_legID);
    end if;
    
    # In form port_1
    set plane_location = (select a.locationID from airport a where a.airportID = airportID);
    set pilot_location = (select p.locationID from person p where p.personID = ip_personID);
    
    # In form plane_1
    set plane_num = (select a.locationID from airplane a where a.airlineID = supp_airline and a.tail_num = supp_tail);
    
    if (plane_location != pilot_location) then leave sp_main; end if;
    
    # Pilot can not already be assigned to flight
    if (select count(*) from pilot p where p.personID = ip_personID and p.flying_airline is null and p.flying_tail is null) = 0 then leave sp_main; end if;
    
	#select supp_airline;
    #select supp_tail;
    #select current_leg_num;
    #select routeID;
    #select plane_location;
    #select pilot_location;
    
    update pilot p set p.flying_airline = supp_airline, p.flying_tail = supp_tail where p.personID = ip_personID;
    update person p set p.locationID = plane_num where p.personID = ip_personID;

end //
delimiter ;

-- [15] recycle_crew()
-- -----------------------------------------------------------------------------
/* This stored procedure releases the assignments for a given flight crew.  The
flight must have ended, and all passengers must have disembarked. */
-- -----------------------------------------------------------------------------
drop procedure if exists recycle_crew;
delimiter //
create procedure recycle_crew (in ip_flightID varchar(50))
sp_main: begin

	declare current_leg_num integer default 0;
    declare num_legs integer default 0;
    declare current_status varchar(100) default null;
    declare supp_airline varchar(50) default null;
    declare supp_tail varchar(50) default null;
    declare plane_num varchar(50) default null;
    declare num_passengers_on integer default 0;
    declare routeID varchar(50) default null;
    declare current_legID varchar(50) default null;
    declare airportID char(3) default null;
    declare portID varchar(50) default null;
    
    # Make sure that the flightID exists
	if (select count(*) from flight f where f.flightID = ip_flightID) < 1 then leave sp_main; end if;
    
    set current_leg_num = (select f.progress from flight f where f.flightID = ip_flightID);
    set num_legs = (select count(*) from flight f join route_path rp on f.routeID = rp.routeID where f.flightID = ip_flightID);
    set current_status = (select f.airplane_status from flight f where f.flightID = ip_flightID);
    set supp_airline = (select f.support_airline from flight f where f.flightID = ip_flightID);
    set supp_tail = (select f.support_tail from flight f where f.flightID = ip_flightID);
    
    # Cannot relieve crew if not on last leg (i.e. flight has not ended)
    if (current_leg_num != num_legs) then leave sp_main; end if;
    
    # Cannot relieve crew if in flight
    if current_status = 'in_flight' then leave sp_main; end if;
    
    set plane_num = (select a.locationID from airplane a where a.airlineID = supp_airline and a.tail_num = supp_tail);
    set num_passengers_on = (select count(*) from person p where p.locationID = plane_num and p.personID in 
			(select personID from passenger));
    
    select current_leg_num;
    select num_legs;
    select current_status;
    select supp_airline;
    select supp_tail;
    select plane_num;
    select num_passengers_on;
    
    if num_passengers_on > 0 then leave sp_main; end if;
            
	set routeID = (select f.routeID from flight f where f.flightID = ip_flightID);
	set current_legID = (select rp.legID from route_path rp where rp.routeID = routeID and rp.sequence = current_leg_num);
	set airportID = (select l.arrival from leg l where l.legID = current_legID);
    set portID = (select a.locationID from airport a where a.airportID = airportID);
	
    update person p set p.locationID = portID where p.personID in (select pi.personID from pilot pi 
			where pi.flying_airline = supp_airline and pi.flying_tail = supp_tail);
            
    update pilot p set p.flying_airline = null, p.flying_tail = null where p.flying_airline = supp_airline
			and p.flying_tail = supp_tail;  

end //
delimiter ;

-- [16] retire_flight()
-- -----------------------------------------------------------------------------
/* This stored procedure removes a flight that has ended from the system.  The
flight must be on the ground, and either be at the start its route, or at the
end of its route.  */
-- -----------------------------------------------------------------------------
drop procedure if exists retire_flight;
delimiter //
create procedure retire_flight (in ip_flightID varchar(50))
sp_main: begin
drop table if exists route_length;
	create table route_length as select routeID, max(sequence) as 'max'  from route_path natural join flight group by routeID ;
	delete from flight 
	where  flightID = ip_flightID 
	and airplane_status = 'on_ground' 
    and ( progress = 0 
		or flightID in 
			(select * from (select flightID from flight join route_length on flight.routeID = route_length.routeID where progress = max)tblTmp));
	drop table route_length;

end //
delimiter ;

-- [17] remove_passenger_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes the passenger role from person.  The passenger
must be on the ground at the time; and, if they are on a flight, then they must
disembark the flight at the current airport.  If the person had both a pilot role
and a passenger role, then the person and pilot role data should not be affected.
If the person only had a passenger role, then all associated person data must be
removed as well. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_passenger_role;
delimiter //
create procedure remove_passenger_role (in ip_personID varchar(50))
sp_main: begin
delete from ticket  
	where customer = ip_personID; 
   
	
	delete from passenger  
	where personID = ip_personID; 
    
	
	delete from person  
	where person.personID = ip_personID
    and personID not in
	(select * from (select pilot.personID from  passenger join pilot on passenger.personID = pilot.personID) tblTmp);

end //
delimiter ;

-- [18] remove_pilot_role()
-- -----------------------------------------------------------------------------
/* This stored procedure removes the pilot role from person.  The pilot must not
be assigned to a flight; or, if they are assigned to a flight, then that flight
must either be at the start or end of its route.  If the person had both a pilot
role and a passenger role, then the person and passenger role data should not be
affected.  If the person only had a pilot role, then all associated person data
must be removed as well. */
-- -----------------------------------------------------------------------------
drop procedure if exists remove_pilot_role;
delimiter //
create procedure remove_pilot_role (in ip_personID varchar(50))
sp_main: begin
	/*drop table if exists route_length;
	create table route_length as select routeID, max(sequence) as 'max'  from route_path natural join flight group by routeID ;
	drop table if exists temp1 ;
	create temporary table temp1 as select * from route_length as rp natural join flight ;
	
    delete from pilot_licenses 
	where personID = ip_personID
    and personID in
    (select * from (
		(select personID from pilot join temp1 on support_tail = flying_tail where airplane_status like 'on_ground'and (progress = max or progress =0)) union (select personID from pilot where flying_tail is null) 
    )tblTmp) ;
    
    delete from pilot  
	where personID = ip_personID and personID in 
    (select * from (
		(select personID from pilot join temp1 on support_tail = flying_tail where airplane_status like 'on_ground'and (progress = max or progress =0)) union (select personID from pilot where flying_tail is null) 
    )tblTmp) ;
    
	
    
	delete from person  
	where person.personID = ip_personID
    and personID not in
	(select * from 
		(select passenger.personID from passenger join pilot on passenger.personID = pilot.personID) 
	tblTmp);

	drop table route_length;
	drop table temp1;*/

end //
delimiter ;

-- [19] flights_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_in_the_air (departing_from, arriving_at, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as
    
SELECT flight_grouping.departing_from,
	flight_grouping.arriving_at,
	num_flights_grouping.num_flights, 
    flightID AS flight_list, 
    arrival_grouping.earliest_arrival, 
    arrival_grouping.latest_arrival, 
    locID AS airplane_list
FROM 
(SELECT dep.airportID AS departing_from, arr.airportID AS arriving_at, flightID, airplane.locationID AS locID FROM 
	flight_management.flight JOIN flight_management.airplane 
		ON (flight.support_airline, flight.support_tail) = (airplane.airlineID, airplane.tail_num)
	CROSS JOIN flight_management.airport AS dep
    CROSS JOIN flight_management.airport AS arr
	WHERE flight.airplane_status = 'in_flight' 
    # Only take the flights that start at (depart from) the matching arport
    # routeID of route_path where the first leg departs from the matching airport
	AND flight.routeID IN (SELECT routeID FROM route_path WHERE sequence = flight.progress 
		AND legID IN (SELECT legID FROM leg WHERE arrival = arr.airportID))
	AND flight.routeID IN (SELECT routeID FROM route_path WHERE sequence = flight.progress 
        AND legID IN (SELECT legID FROM leg WHERE departure = dep.airportID))       
) AS flight_grouping
JOIN
(SELECT dep.airportID AS departing_from,
	arr.airportID AS arriving_at,
	COUNT(*) AS num_flights
FROM flight_management.airport AS dep CROSS JOIN flight_management.airport AS arr CROSS JOIN flight_management.flight
	WHERE flight.airplane_status = 'in_flight'
	AND flight.routeID IN (SELECT routeID FROM route_path WHERE sequence = flight.progress 
		AND legID IN (SELECT legID FROM leg WHERE arrival = arr.airportID))
	AND flight.routeID IN (SELECT routeID FROM route_path WHERE sequence = flight.progress 
        AND legID IN (SELECT legID FROM leg WHERE departure = dep.airportID))
GROUP BY dep.airportID, arr.airportID) AS num_flights_grouping
ON flight_grouping.departing_from = num_flights_grouping.departing_from AND flight_grouping.arriving_at = num_flights_grouping.arriving_at
JOIN
(SELECT dep.airportID AS departing_from,
	arr.airportID AS arriving_at,
	MIN(next_time) AS earliest_arrival,
    MAX(next_time) AS latest_arrival
FROM flight_management.airport AS dep CROSS JOIN flight_management.airport AS arr CROSS JOIN flight_management.flight
	WHERE flight.airplane_status = 'in_flight'
	AND flight.routeID IN (SELECT routeID FROM route_path WHERE sequence = flight.progress 
		AND legID IN (SELECT legID FROM leg WHERE arrival = arr.airportID))
	AND flight.routeID IN (SELECT routeID FROM route_path WHERE sequence = flight.progress 
        AND legID IN (SELECT legID FROM leg WHERE departure = dep.airportID))
GROUP BY dep.airportID, arr.airportID) AS arrival_grouping
ON arrival_grouping.departing_from = num_flights_grouping.departing_from AND arrival_grouping.arriving_at = num_flights_grouping.arriving_at;




-- [20] flights_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where flights that are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view flights_on_the_ground (departing_from, num_flights,
	flight_list, earliest_arrival, latest_arrival, airplane_list) as

-- We are naturally joining together all info about the flight and all group (COUNT, MIN, MAX) info about each airport



-- 1 1 on ground
-- 2 2 in flight
-- 2 2 on ground
-- 3 3 on ground



-- # If progress and sequence are equal and on ground, it's at the arrival airport of the leg
-- # UNION
-- # Another case where sequence will always be 1, progress will always be 0 and the departure will always be location id;

SELECT airportID AS departing_from, 
	num_flights_grouping.num_flights, 
    flightID AS flight_list, 
    arrival_grouping.earliest_arrival, 
    arrival_grouping.latest_arrival, 
    locID AS airplane_list 
FROM 
(SELECT airportID, flightID, airplane.locationID AS locID FROM 
	flight_management.flight JOIN flight_management.airplane 
		ON (flight.support_airline, flight.support_tail) = (airplane.airlineID, airplane.tail_num)
	CROSS JOIN flight_management.airport
	WHERE flight.airplane_status = 'on_ground' 
    # Only take the flights that start at (depart from) the matching arport
    # routeID of route_path where the first leg departs from the matching airport
    AND flight.routeID IN (SELECT routeID FROM route_path WHERE sequence = flight.progress + 1 AND legID IN
		(SELECT legID FROM leg WHERE departure = airport.airportID))
) AS flight_grouping
LEFT OUTER JOIN
(SELECT airportID AS departing_from,
	COUNT(*) AS num_flights
FROM flight_management.airport CROSS JOIN flight_management.flight
	WHERE flight.airplane_status = 'on_ground'
	AND flight.routeID IN (SELECT routeID FROM route_path WHERE sequence = flight.progress + 1 AND legID IN
			(SELECT legID FROM leg WHERE departure = airportID))
GROUP BY airportID) AS num_flights_grouping
ON flight_grouping.airportID = num_flights_grouping.departing_from
LEFT OUTER JOIN
(SELECT airportID AS departing_from,
	MIN(next_time) AS earliest_arrival,
    MAX(next_time) AS latest_arrival
FROM flight_management.airport CROSS JOIN flight_management.flight
	WHERE flight.airplane_status = 'on_ground'
	AND (flight.routeID IN (SELECT routeID FROM route_path WHERE flight.progress != 0 AND sequence = flight.progress AND legID IN
		(SELECT legID FROM leg WHERE arrival = airportID))
	OR flight.routeID IN (SELECT routeID FROM route_path WHERE flight.progress = 0 AND sequence = 1 AND legID IN
		(SELECT legID FROM leg WHERE departure = airportID)))
GROUP BY airportID) AS arrival_grouping
ON arrival_grouping.departing_from = num_flights_grouping.departing_from;

-- [21] people_in_the_air()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently airborne are located. */
-- -----------------------------------------------------------------------------
create or replace view route_summ  as
select route_path.routeID as route,
count( distinct legID) as num_legs, 
GROUP_CONCAT( distinct  route_path.legID order by sequence) as leg_sequence, 
round(sum(distance)/greatest(1,count(distinct flightID))) as route_length,
count(Distinct flightID)as num_flights, group_concat(distinct flight.flightID) as flight_list, 
group_concat(distinct concat( leg.departure, '->', leg.arrival) order by sequence) as 'airport_sequence'
from route_path natural join leg left outer join flight on flight.routeID = route_path.routeID group by route_path.routeID;


create or replace view table1 as
select  count(*) as num_airplanes, group_concat(distinct locationID) as 'airplane_list', flightID, min(next_time) as 'earliest_arrival', max(next_time) as 'latest_arrival'  from airplane join flight 
on airlineID = support_airline and support_tail = tail_num where tail_num in (select support_tail from flight where airplane_status like '%in_flight') group by flightID;

create or replace view people as
SELECT

  p.personid,
  p.locationID,
  pi.personid AS pilot_personid,
  pa.personid AS passenger_personid
FROM person p
LEFT JOIN pilot as pi ON p.personid = pi.personID
LEFT JOIN passenger as pa ON p.personid = pa.personID;

create or replace view view2 as
select * from flight, airplane where support_tail = tail_num;

create or replace view view3 as
select people.locationID, flightID as fID, sum(case when pilot_personid is not null then 1 else 0 end) as num_pilots, sum(case when passenger_personid is not null then 1 else 0 end) as num_passengers, count(distinct personID) as joint_pilots_passengers , group_concat(personID) as person_list from people join view2 where people.locationID = view2.locationID and tail_num in (select support_tail from flight where airplane_status like '%in_flight') group by people.locationID, flightID;

create or replace view view4 as
select departure, arrival,num_airplanes, airplane_list, earliest_arrival,latest_arrival from table1, leg, flight, route_path, route_summ
where flight.flightID = table1.flightID 
and route_path.routeID = flight.routeID 
and route_summ.route = flight.routeID 
and leg.legID = route_path.legID 
and route_path.sequence = flight.progress;
				
create or replace view people_in_the_air (departing_from, arriving_at, num_airplanes,
	airplane_list, flight_list, earliest_arrival, latest_arrival, num_pilots,
	num_passengers, joint_pilots_passengers, person_list) as
select departure,arrival,num_airplanes,airplane_list,fID as flight_list, earliest_arrival,latest_arrival,num_pilots,num_passengers,joint_pilots_passengers,person_list from view4 join view3 on airplane_list = locationID;

-- [22] people_on_the_ground()
-- -----------------------------------------------------------------------------
/* This view describes where people who are currently on the ground are located. */
-- -----------------------------------------------------------------------------
create or replace view people as
SELECT

  p.personid,
  p.locationID,
  pi.personid AS pilot_personid,
  pa.personid AS passenger_personid
FROM (person p
LEFT JOIN pilot as pi ON p.personid = pi.personID
LEFT JOIN passenger as pa ON p.personid = pa.personID)
;
create or replace view people_on_the_ground (departing_from, airport, airport_name,
	city, state, num_pilots, num_passengers, joint_pilots_passengers, person_list) as
select airport.airportID as 'departing_from', airport.locationID as 'airport', airport_name, city, state, 

sum(case when pilot_personid is not null then 1 else 0 end) as num_pilots, 
sum(case when passenger_personid is not null then 1 else 0 end) as num_passengers, 
count(distinct personID) as joint_pilots_passengers , group_concat(personID) 
as person_list from people left join airport on airport.locationID = people.locationID where people.locationID not like 'plane%' group by airportID ,airport.locationID;

-- [23] route_summary()
-- -----------------------------------------------------------------------------
/* This view describes how the routes are being utilized by different flights. */
-- -----------------------------------------------------------------------------
create or replace view route_summary (route, num_legs, leg_sequence, route_length,
	num_flights, flight_list, airport_sequence) as
select route_path.routeID as route,
count( distinct legID) as num_legs, 
GROUP_CONCAT( distinct  route_path.legID order by sequence) as leg_sequence, 
round(sum(distance)/greatest(1,count(distinct flightID))) as route_length,
count(Distinct flightID)as num_flights, group_concat(distinct flight.flightID) as flight_list, 
group_concat(distinct concat( leg.departure, '->', leg.arrival) order by sequence) as 'airport_sequence'
from route_path natural join leg left outer join flight on flight.routeID = route_path.routeID group by route_path.routeID;


-- [24] alternative_airports()
-- -----------------------------------------------------------------------------
/* This view displays airports that share the same city and state. */
-- -----------------------------------------------------------------------------
create or replace view alternative_airports (city, state, num_airports,
	airport_code_list, airport_name_list) as
select city, state, 
count(*) as num_airports, 
GROUP_CONCAT( distinct airportID) as airport_code_list, 
group_concat(distinct airport_name order by airportID) as airport_name_list
from airport 
group by city,state 
having count(*) >1;
-- [25] simulation_cycle()
-- -----------------------------------------------------------------------------
/* This stored procedure executes the next step in the simulation cycle.  The flight
with the smallest next time in chronological order must be identified and selected.
If multiple flights have the same time, then flights that are landing should be
preferred over flights that are taking off.  Similarly, flights with the lowest
identifier in alphabetical order should also be preferred.

If an airplane is in flight and waiting to land, then the flight should be allowed
to land, passengers allowed to disembark, and the time advanced by one hour until
the next takeoff to allow for preparations.

If an airplane is on the ground and waiting to takeoff, then the passengers should
be allowed to board, and the time should be advanced to represent when the airplane
will land at its next location based on the leg distance and airplane speed.

If an airplane is on the ground and has reached the end of its route, then the
flight crew should be recycled to allow rest, and the flight itself should be
retired from the system. */
-- -----------------------------------------------------------------------------
drop procedure if exists simulation_cycle;
delimiter //
create procedure simulation_cycle ()
sp_main: begin

end //
delimiter ;
