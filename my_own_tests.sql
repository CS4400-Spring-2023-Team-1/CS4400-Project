use flight_management;

# Procedure 6:

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

call purchase_ticket_and_seat('tkt_dl_20', 450, 'DL_1174',
'p23', 'JFK', '5A');
select * from ticket;
select * from ticket_seats;