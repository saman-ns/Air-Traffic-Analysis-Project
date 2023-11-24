/* Question 1.1: How many flights were there in 2018 and 2019 separately? 

# year, flightCount
'2018', '3218653'
'2019', '3302708'

 there was 3218653 flights on 2018 and 3302708 flights on 2019

 */
 -- query explanation: the case finction seperates the 2018 and 2019 flights that are counted by the count funcion
 
select 
	case
		when year(flightdate) = 2018 then '2018'
        when year(flightdate) = 2019 then '2019'
        else 'other'
	end as year,
    count(*) as flightCount
from flights 
group by year;


/* Question 1.2: In total, how many flights were cancelled or departed late over both years? 

# FLIGHT_STATUS, FLIGHT_COUNT
'ONTIME', '3888124'
'DELAYED', '2540874'
'Cancelled', '92363'

a totall of 2633237 were cancelled or delayed

*/

-- this qurey gives seperated rows for delayed and cancelled flights
SELECT 
	CASE
		WHEN CANCELLED != 0 THEN 'Cancelled'
        WHEN DepDelay > 0 THEN 'DELAYED'
        ELSE 'ONTIME'
	END AS FLIGHT_STATUS,
	count(*) AS FLIGHT_COUNT
FROM airtraffic.flights
group by 
	CASE
		WHEN CANCELLED != 0 THEN 'Cancelled'
        WHEN DepDelay > 0 THEN 'DELAYED'
		ELSE 'ONTIME'
	END;

-- this one shows a combined column for both of cancelled/delayed flights
SELECT 
    CASE
        when CANCELLED != 0 or DepDelay > 0 THEN 'cancelled/delayed'
        ELSE 'ontime'
    END AS FLIGHT_STATUS,
    COUNT(*) AS FLIGHT_COUNT
FROM airtraffic.flights
GROUP BY 
    CASE
        when CANCELLED != 0 or DepDelay > 0 THEN 'cancelled/delayed'
        ELSE 'ontime'
    END;
    
/*Question 1.3: Show the number of flights that were cancelled broken down by the reason for cancellation.

# CancellationReason, cancellation_count
'Weather', '50225'
'unknown reason', '14196'
'Carrier', '34141'
'National Air System', '7962'
'Security', '35'

 */    

-- QUERY EXPLANATION, GROUPING THE CANCELLED AND THE DIVERTED FLIGHTS BY THE REASON AND CHANGING THE NULL RESULTS TO 'UNKOWN REASON' 
 SELECT 
COALESCE(CancellationReason, 'unknown reason') AS CancellationReason,
count(*) as 'cancellation_count'
FROM airtraffic.flights
where cancelled != 0 or
	diverted != 0
group by flights.cancellationreason 
;

/*Question 1.4:For each month in 2019, report both the total number of flights and percentage of flights cancelled. Based on your results, what might you say about the cyclic nature of airline revenue?

# MONTH, NUMBER_OF_FLIGHTS, CANCELLATION_PERCENTAGE
'1', '262165', '2.2078'
'2', '237896', '2.3128'
'3', '283648', '2.4957'
'4', '274115', '2.7102'
'5', '285094', '2.4245'
'6', '282653', '2.1836'
'7', '291955', '1.5492'
'8', '290493', '1.2475'
'9', '268625', '1.2352'
'10', '283815', '0.8072'
'11', '266878', '0.5920'
'12', '275371', '0.5073'

From the data, it appears that airline revenue tends to follow a cyclic pattern with fluctuations in the number of flights and cancellation percentages throughout the year. 
Typically, the summer months (July and August) have higher numbers of flights and lower cancellation rates, while the late fall and winter months (November and December)
 also see high flight numbers with extremely low cancellation rates. This suggests that the holiday season and summer vacations may contribute to higher airline revenue 
 and more reliable flight schedules.



*/



SELECT 
    MONTH(FlightDate) AS MONTH,
    -- TOTAL NUMBER OF FLIGHTS
    COUNT(*) AS NUMBER_OF_FLIGHTS,
    -- CANCELLATION PERCENTAGE
    (SUM(Cancelled) / COUNT(*)) * 100 AS CANCELLATION_PERCENTAGE
FROM flights
WHERE YEAR(FlightDate) = 2019
GROUP BY MONTH(FlightDate)
ORDER BY MONTH(FlightDate);

/*Question 2.1: Create two new tables, one for each year (2018 and 2019) showing the total miles traveled and number of flights broken down by airline.*/


-- Create a table for 2018 data
SELECT 
    AirlineName,
    COUNT(CASE WHEN YEAR(FlightDate) = 2018 THEN 1 else 0 END) AS NumFlights2018,
    SUM(CASE WHEN Cancelled != 0 THEN 1 ELSE 0 END) AS brokenflights,
	SUM(distance) AS TotalMiles2018
FROM flights
where year(flightdate) = 2018
GROUP BY AirlineName;

-- Create a table for 2019 data
SELECT 
    AirlineName,
    COUNT(CASE WHEN YEAR(FlightDate) = 2019 THEN 1 else 0 END) AS NumFlights2018,
    SUM(CASE WHEN Cancelled != 0 THEN 1 ELSE 0 END) AS brokenflights,
	SUM(distance) AS TotalMiles2018
FROM flights
where year(flightdate) = 2019
GROUP BY AirlineName;

/*Question 2.2: Using your new tables, find the year-over-year percent change in total flights and miles traveled for each airline.

Delta Air Lines Inc.:

Delta Air Lines has shown a positive year-over-year growth in both total miles traveled (5.56%) and total flights (4.50%).
This indicates that Delta is expanding its operations and increasing its revenue, which may be a positive sign for investors.
Consider monitoring Delta's financial performance and market position for potential investment opportunities.
American Airlines Inc.:

American Airlines has experienced a modest growth in total miles traveled (0.56%) and a slightly larger increase in total flights (3.27%).
While the growth is positive, it's not as significant as some other airlines.
Investors may want to assess American Airlines' competitive position and financial stability before making investment decisions.
Southwest Airlines Co.:

Southwest Airlines has seen a slight decrease in total miles traveled (-0.12%), but its total flights have remained relatively stable (0.84% increase).
While the decrease in miles is marginal, investors should consider Southwest's strategies for maintaining profitability in a competitive market.
Look into Southwest's cost control measures and market strategies for potential investment insights.


*/

-- Calculate total flights and miles traveled for each airline in 2018
WITH Flights2018 AS (
    SELECT
        AirlineName,
        SUM(distance) AS TotalMiles2018,
        COUNT(*) AS NumFlights2018
    FROM flights
    WHERE YEAR(FlightDate) = 2018
    GROUP BY AirlineName
),

-- Calculate total flights and miles traveled for each airline in 2019
Flights2019 AS (
    SELECT
        AirlineName,
        SUM(distance) AS TotalMiles2019,
        COUNT(*) AS NumFlights2019
    FROM flights
    WHERE YEAR(FlightDate) = 2019
    GROUP BY AirlineName
)

-- Calculate year-over-year percent change
SELECT
    F18.AirlineName,
    F18.TotalMiles2018,
    F18.NumFlights2018,
    F19.TotalMiles2019,
    F19.NumFlights2019,
    ((F19.TotalMiles2019 - F18.TotalMiles2018) / F18.TotalMiles2018) * 100 AS PercentChangeMiles,
    ((F19.NumFlights2019 - F18.NumFlights2018) / F18.NumFlights2018) * 100 AS PercentChangeFlights
FROM Flights2018 F18
JOIN Flights2019 F19 ON F18.AirlineName = F19.AirlineName;

/*Question 3.1: What are the names of the 10 most popular destination airports overall? For this question, generate a SQL query that first joins flights and airports then does the necessary aggregation.

here is the results of the query:
# AirportName, AirportID, NumFlights
'Hartsfield-Jackson Atlanta International', '10397', '595527'
'Dallas/Fort Worth International', '11298', '314423'
'Phoenix Sky Harbor International', '14107', '253697'
'Los Angeles International', '12892', '238092'
'Charlotte Douglas International', '11057', '216389'
'Harry Reid International', '12889', '200121'
'Denver International', '11292', '184935'
'Baltimore/Washington International Thurgood Marshall', '10821', '168334'
'Minneapolis-St Paul International', '13487', '165367'
'Chicago Midway International', '13232', '165007'



*/

SELECT 
    airports.AirportName,
    airports.AirportID,
    COUNT(flights.DestAirportID) AS NumFlights
FROM
    airports
        LEFT JOIN
    airtraffic.flights ON airports.AirportID = flights.DestAirportID
GROUP BY airports.AirportName , airports.AirportID
ORDER BY NumFlights DESC
LIMIT 10;

/*Question 3.2: Answer the same question but using a subquery to aggregate & limit the flight data before your join with the airport information, hence optimizing your query runtime

The second query, which utilized a subquery to pre-aggregate flight counts before joining with airport data, executed significantly faster at approximately 6.921 seconds.
In contrast, the first query, which directly joined flight and airport data and then performed aggregation, 
took much longer at approximately 16.406 seconds. This substantial difference in execution times highlights the efficiency of optimizing 
queries by minimizing unnecessary data processing, particularly when dealing with larger datasets

*/
SELECT
    airports.AirportName,
    airports.AirportID,
    flightnum.numflights
FROM
    (
    SELECT
        DestAirportID,
        COUNT(*) AS numflights
    FROM
        flights
    GROUP BY
        DestAirportID
    ) AS flightnum
RIGHT JOIN
    airports ON airports.AirportID = flightnum.DestAirportID
GROUP BY
    airports.AirportName,
    airports.AirportID,
    numflights
ORDER BY
    numflights DESC
LIMIT 10;

/*Question 4.1: How many planes the airline operates in total. Using this information, determine the number of unique aircrafts each airline operated in total over 2018-2019.

# AirlineName, UniqueAircraftCount
'American Airlines Inc.', '993'
'Delta Air Lines Inc.', '988'
'Southwest Airlines Co.', '754'


*/
   
-- Calculate the number of unique aircraft per airline
SELECT 
    AirlineName,
    COUNT(DISTINCT Tail_Number) AS UniqueAircraftCount
FROM 
    airtraffic.flights
WHERE 
    YEAR(FlightDate) BETWEEN 2018 AND 2019
GROUP BY 
    AirlineName;
    
/*Question 4.2: Similarly, the total miles traveled by each airline gives an idea of total fuel costs and the distance traveled per plane gives an approximation of total equipment costs.
 What is the average distance traveled per aircraft for each of the three airlines?
 
 # AirlineName, AvgDistancePerAircraft
'Delta Air Lines Inc.', '1142.4142052483535'
'American Airlines Inc.', '1148.801185679002'
'Southwest Airlines Co.', '772.4449996777873'

 
 
 */
 
 
 -- Calculate the average distance traveled per aircraft for each airline
SELECT 
    AirlineName,
    AVG(AvgDistance) AS AvgDistancePerAircraft
FROM (
    SELECT 
        AirlineName,
        Tail_Number,
        AVG(Distance) AS AvgDistance
    FROM 
        airtraffic.flights
    WHERE 
        YEAR(FlightDate) BETWEEN 2018 AND 2019
    GROUP BY 
        AirlineName,
        Tail_Number
) AS Subquery
GROUP BY 
    AirlineName;
    
/*Question 5.1: Next, we will look into on-time performance more granularly in relation to the time of departure. We can break up the departure times into three categories as follows:
   
# Time_of_Day, Average_Delay
'2-afternoon', '29.9219'
'1-morning', '25.8731'
'4-night', '29.5602'
'3-evening', '35.9136'

  The pattern in the average departure delay across different times of the day shows that morning and afternoon flights tend to have shorter delays,
  while evening and nighttime flights experience longer delays on average. This indicates that travelers may experience more on-time departures in the morning and afternoon.  
*/
    
    WITH delayedflights AS (
    SELECT
        id,
        CASE
            WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN '1-morning'
            WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN '2-afternoon'
            WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN '3-evening'
            ELSE '4-night'
        END AS 'time_of_day',
        DepDelay
    FROM airtraffic.flights
    WHERE DepDelay > 0
)

SELECT
    time_of_day AS 'Time_of_Day',
    AVG(DepDelay) AS 'Average_Delay'
FROM delayedflights
GROUP BY time_of_day;

/* Question 5.2: Now, find the average departure delay for each airport and time-of-day combination.

Here is the first 5 rows:
# AirportName, time_of_day, average_delay
'Akron-Canton Regional', '1-morning', '10.1818'
'Akron-Canton Regional', '2-afternoon', '46.5469'
'Akron-Canton Regional', '3-evening', '32.0000'
'Akron-Canton Regional', '4-night', '33.7143'
'Albany International', '1-morning', '24.2548'
'Albany International', '2-afternoon', '27.0562'
'Albany International', '3-evening', '32.9729'
'Albany International', '4-night', '29.2936'

*/

WITH delayedflights AS (
    SELECT
        id,
        OriginAirportID,
        CASE
            WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
            WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN "2-afternoon"
            WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN "3-evening"
            ELSE "4-night"
        END AS time_of_day,
        DepDelay
    FROM airtraffic.flights
    WHERE DepDelay > 0
)

SELECT
    airports.AirportName,
    time_of_day,
    AVG(DepDelay) AS average_delay
FROM
    delayedflights
JOIN airtraffic.airports ON delayedflights.OriginAirportID = airports.AirportID
GROUP BY
    airports.AirportName,
    time_of_day
ORDER BY
    airports.AirportName,
    time_of_day;

/*Next, limit your average departure delay analysis to morning delays and airports with at least 10,000 flights.

# AirportName, time_of_day, average_delay, number_of_flights
'Albuquerque International Sunport', '1-morning', '22.6215', '3511'
'Austin - Bergstrom International', '1-morning', '27.5190', '6634'
'Baltimore/Washington International Thurgood Marshall', '1-morning', '21.8510', '15890'
'Birmingham-Shuttlesworth International', '1-morning', '27.4155', '1184'
'Bob Hope', '1-morning', '17.9696', '5126'
'Bradley International', '1-morning', '29.0317', '2115'
'Buffalo Niagara International', '1-morning', '24.2928', '1144'


*/

WITH delayedflights AS (
    SELECT
        id,
        OriginAirportID,
        CASE
            WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN "1-morning"
            WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN "2-afternoon"
            WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN "3-evening"
            ELSE "4-night"
        END AS time_of_day,
        DepDelay
    FROM airtraffic.flights
    WHERE DepDelay > 0
)

SELECT
    airports.AirportName,
    time_of_day,
    AVG(DepDelay) AS average_delay,
    COUNT(delayedflights.id) AS number_of_flights
FROM
    delayedflights
JOIN airtraffic.airports ON delayedflights.OriginAirportID = airports.AirportID
WHERE
    time_of_day = '1-morning'
GROUP BY
    airports.AirportName,
    time_of_day
having 
	count(delayedflights.id) > 1000
ORDER BY
    airports.AirportName,
    time_of_day;
    
    /*By extending the query from the previous question, name the top-10 airports (with >10000 flights) with the highest average morning delay. In what cities are these airports located?
    
# AirportName, City, average_morning_delay, number_of_flights
'Chicago O\'Hare International', 'Chicago, IL', '33.6865', '17267'
'LaGuardia', 'New York, NY', '33.6838', '10567'
'Philadelphia International', 'Philadelphia, PA', '31.7330', '10341'
'Dallas/Fort Worth International', 'Dallas/Fort Worth, TX', '31.5933', '36222'
'Seattle/Tacoma International', 'Seattle, WA', '28.8792', '12451'
'Minneapolis-St Paul International', 'Minneapolis, MN', '28.4931', '11445'
'Los Angeles International', 'Los Angeles, CA', '26.8112', '33158'
'Salt Lake City International', 'Salt Lake City, UT', '25.7589', '13544'
'Orlando International', 'Orlando, FL', '25.6610', '15042'
'San Diego International', 'San Diego, CA', '24.3445', '13291'

    
    
    */
    
    WITH delayedflights AS (
    SELECT
		id,
        OriginAirportID,
        CASE
            WHEN HOUR(CRSDepTime) BETWEEN 7 AND 11 THEN '1-morning'
            WHEN HOUR(CRSDepTime) BETWEEN 12 AND 16 THEN '2-afternoon'
            WHEN HOUR(CRSDepTime) BETWEEN 17 AND 21 THEN '3-evening'
            ELSE '4-night'
        END AS time_of_day,
        DepDelay
    FROM airtraffic.flights
    WHERE DepDelay > 0
)

SELECT
    airports.AirportName,
    airports.City,
    AVG(delayedflights.DepDelay) AS average_morning_delay,
    COUNT(delayedflights.id) AS number_of_flights
FROM
    delayedflights
JOIN airtraffic.airports ON delayedflights.OriginAirportID = airports.AirportID
WHERE
    time_of_day = '1-morning'
GROUP BY
    airports.AirportName,
    airports.City
HAVING
    COUNT(delayedflights.id) > 10000
ORDER BY
    average_morning_delay DESC
LIMIT 10;

