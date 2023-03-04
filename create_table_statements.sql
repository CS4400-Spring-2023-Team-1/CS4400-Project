# This is the starting file for the create table statements.

-- Table structure for route
DROP TABLE IF EXISTS route;
CREATE TABLE route(
  routeID VARCHAR(50) NOT NULL
);

-- Dumping data for table route
INSERT INTO route VALUES('circle_east_coast');