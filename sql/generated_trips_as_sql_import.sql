BEGIN TRANSACTION;

DROP VIEW IF EXISTS domestic_trips_by_zone;

DROP TABLE IF EXISTS full_generated_trips;
CREATE TABLE full_generated_trips ( 
tripId 		integer primary key, 
personId	integer,
international	boolean,
trip_purpose	varchar,
trip_state	varchar,
trip_origin_zone	integer,
trip_origin_type	varchar,
number_of_nights	integer,
hh_adults_travel_party	integer, 
hh_kids_travel_party	integer,
non_hh_travel_party	integer,
person_age	 	integer,
person_gender		varchar(1),
person_education		integer,
person_work_status	integer,
person_income	 	integer,
adults_in_hh	 	integer,
kids_in_hh		integer
);


COPY full_generated_trips from 'C:/mto_longDistanceTravel/tripGeneration/trips.csv' csv header;

CREATE VIEW domestic_trips_by_zone AS
select *, visit_trips + business_trips + leisure_trips as trips
from (
	select 
		trip_origin_zone as zone_id,
		--trip_origin_type, 
		--trip_purpose, 
		sum(
			case when trip_purpose = 'visit' and trip_state = 'inout' then 0.5 
			when trip_purpose = 'visit' and trip_state = 'daytrip' then 1 
			else 0 end
		) as visit_trips, 
		sum(
			case when trip_purpose = 'business' and trip_state = 'inout' then 0.5 
			when trip_purpose = 'business' and trip_state = 'daytrip' then 1 
			else 0 end
		) as business_trips, 
		sum(
			case when trip_purpose = 'leisure' and trip_state = 'inout' then 0.5 
			when trip_purpose = 'leisure' and trip_state = 'daytrip' then 1 
			else 0 end
		) as leisure_trips
	from full_generated_trips
	where trip_origin_type in ('ONTARIO', 'EXTCANADA')
	group by 
		trip_origin_zone, 
		--trip_purpose, 
		trip_origin_type
	order by trip_origin_zone
) as a;


	
END TRANSACTION;
