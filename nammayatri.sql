create database nammayatri;
use nammayatri;
SELECT * FROM assembly;
SELECT * FROM duration;
SELECT * FROM payment;
SELECT * FROM trips;
SELECT * FROM trip_details;
-- Category 1: Revenue & Pricing Analysis

-- Total Revenue by Payment Method: Calculate the total fare collected for each payment method (Cash, UPI, etc.).
select p.method, sum(t.fare) as total_revenue from trips t 
join payment p on t.faremethod = p.id group by p.method;

-- Average Fare per Area: Which Assembly area (loc_from) has the highest average fare per trip?
select a.assembly as assembly_name, avg(t.fare) as avg_fare from trips t join assembly a 
on t.loc_from = a.id group by a.assembly order by avg_fare desc limit 1;

-- High-Value Trips: Find the total number of trips where the fare was greater than 500 and the payment method was 'Credit Card'.
SELECT COUNT(*) AS high_value_trips FROM trips t JOIN payment p 
ON t.faremethod = p.id WHERE t.fare > 500 AND p.method = 'credit card';

-- Fare per Distance Efficiency: Calculate the average fare-per-distance (fare / distance) for each payment method.
SELECT p.method, AVG(t.fare / NULLIF(t.distance, 0)) AS avg_fare_per_km
FROM trips t JOIN payment p ON t.faremethod = p.id GROUP BY p.method;

-- Earnings by Duration: Which duration range (from the Duration table, e.g., "0-1", "1-2") generates the highest total revenue?
SELECT d.duration, SUM(t.fare) AS total_revenue FROM trips t JOIN duration d 
ON t.duration = d.id GROUP BY d.duration ORDER BY total_revenue DESC LIMIT 1;

-- Category 2: Driver & Customer Performance

-- Top 5 Earners: Identify the top 5 drivers (driverid) based on total earnings.
SELECT driverid, SUM(fare) AS total_earnings FROM trips
GROUP BY driverid ORDER BY total_earnings DESC LIMIT 5;

-- Frequent Travelers: Find the top 5 customers (custid) who have taken the most number of rides.
SELECT custid, COUNT(*) AS ride_count FROM trips
GROUP BY custid ORDER BY ride_count DESC LIMIT 5;

-- Driver Utilization: List drivers who have completed more than 30 trips.
SELECT driverid, COUNT(*) AS trip_count FROM trips 
GROUP BY driverid HAVING trip_count > 30;

-- Single Trip High Spenders: Identify customers who have taken exactly 1 trip, but that trip cost more than 500.
SELECT custid, fare FROM trips WHERE custid IN (SELECT custid 
FROM trips GROUP BY custid HAVING COUNT(*) = 1) AND fare > 500;

-- Driver Average Distance: Calculate the average distance traveled per trip for each driver, sorted in descending order.
SELECT driverid, AVG(distance) AS avg_distance FROM trips
GROUP BY driverid ORDER BY avg_distance DESC;

-- Category 3: Operational Funnel (Conversion & Cancellations)

-- Search to Estimate Rate: For each assembly area, calculate the percentage of searches that resulted in an estimate (searches_got_estimate / searches).
SELECT a.assembly AS assembly_area, ROUND(SUM(td.searches_got_quotes) / NULLIF(SUM(td.searches), 0) * 100, 2) 
AS estimate_rate_pct FROM trip_details td JOIN assembly a ON td.loc_from = a.id GROUP BY a.assembly;

-- Driver Cancellation Hotspots: Which assembly area has the highest number of driver cancellations (where driver_not_cancelled = 0)?
SELECT a.assembly AS assembly_area, COUNT(*) AS driver_cancellations FROM trip_details td JOIN assembly a ON 
td.loc_from = a.id WHERE td.driver_not_cancelled = 0 GROUP BY a.assembly ORDER BY driver_cancellations DESC LIMIT 1;

-- Customer Cancellation Hotspots: Which assembly area has the highest number of customer cancellations (where customer_not_cancelled = 0)?
SELECT a.assembly AS assembly_area, COUNT(*) AS customer_cancellations FROM trip_details td JOIN assembly a ON 
td.loc_from = a.id WHERE td.customer_not_cancelled = 0 GROUP BY a.assembly ORDER BY customer_cancellations DESC LIMIT 1;

-- OTP Drop-offs: Find the total number of trips where an OTP was entered (otp_entered = 1) but the ride was not completed (end_ride = 0).
SELECT COUNT(*) AS otp_dropoffs FROM trip_details WHERE otp_entered = 1 AND end_ride = 0;

-- End-to-End Conversion: Calculate the overall conversion rate from 'search' to 'end_ride' (Total Completed Rides / Total Searches) for the entire dataset.
SELECT ROUND(SUM(end_ride) / NULLIF(SUM(searches), 0) * 100, 2) AS conversion_rate_pct FROM trip_details;

-- Category 4: Location & Route Analysis

-- Most Popular Pickup Locations: List the top 3 Assembly names (e.g., "Jayanagar") that generated the most trip requests (searches).
SELECT a.assembly AS assembly_area, SUM(td.searches) AS total_searches FROM trip_details td JOIN 
assembly a ON td.loc_from = a.id GROUP BY a.assembly ORDER BY total_searches DESC LIMIT 3;

-- Top Routes: Identify the most frequent route (combination of loc_from and loc_to).
SELECT t.loc_from, t.loc_to, COUNT(*) AS route_count FROM trips t
GROUP BY t.loc_from, t.loc_to ORDER BY route_count DESC LIMIT 1;

-- Long Distance Connections: Find the pair of Assembly areas (loc_from and loc_to) with the longest average distance.
SELECT t.loc_from, t.loc_to, AVG(t.distance) AS avg_distance FROM trips t
GROUP BY t.loc_from, t.loc_to ORDER BY avg_distance DESC LIMIT 1;

-- Demand vs. Supply (Quotes): Which Assembly area has the lowest "Quote Acceptance" rate (ratio of searches_got_quotes to searches_for_quotes)?
SELECT a.assembly AS assembly_area, ROUND(SUM(td.searches_got_quotes) / NULLIF(SUM(td.searches_for_quotes),
0) * 100, 2) AS quote_acceptance_rate FROM trip_details td JOIN assembly a ON td.loc_from = a.id 
GROUP BY a.assembly ORDER BY quote_acceptance_rate ASC LIMIT 1;
 
-- Payment Preference by Location: For a specific area (e.g., 'Hebbal'), what is the most commonly used payment method?
SELECT p.method, COUNT(*) AS usage_count FROM trips t JOIN payment p ON t.faremethod = p.id JOIN 
assembly a ON t.loc_from = a.id WHERE a.assembly = 'Hebbal' GROUP BY p.method ORDER BY usage_count DESC LIMIT 1;
