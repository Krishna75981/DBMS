/* Retrieve the mission name, rocket name, organization name, launch site name, 
 destination, launch year, and outcome for all space missions without using table aliases. 
Sort the results in descending order by launch year and ascending order by mission name 
*/
CREATE TABLE countries(
	CountryCode VARCHAR(4) PRIMARY KEY,
    CountryName VARCHAR(40),
    Continent VARCHAR(20)
);

CREATE TABLE organizations(
	OrgID INT PRIMARY KEY,
    OrgName VARCHAR(40),
    HeadquartersCountry VARCHAR(40),
    OrgType VARCHAR(40)
);

CREATE TABLE launch_sites(
	SiteID INT PRIMARY KEY,
    SiteName VARCHAR(40),
    CountryCode VARCHAR(4),
    Status VARCHAR(40),
    FOREIGN KEY (CountryCode) REFERENCES countries(CountryCode)
);

CREATE TABLE rockets(
	RocketID INT PRIMARY KEY,
RocketName VARCHAR(40),
OrgID INT,
PayloadCapacityKg INT,
OperationalStatus VARCHAR(40),
	FOREIGN KEY(OrgID) REFERENCES organizations(OrgID)
);

CREATE TABLE missions(
	MissionID INT PRIMARY KEY,
    MissionName VARCHAR(40),
    RocketID INT,
    SiteID INT,
    Destination VARCHAR(40),
    LaunchYear INT,
    Outcome VARCHAR(40),
    FOREIGN KEY (RocketID) REFERENCES rockets(RocketID),
    FOREIGN KEY (SiteID) REFERENCES launch_sites(SiteID)
);

CREATE TABLE payloads(
	PayloadID INT PRIMARY KEY,
    MissionID INT,
    PayloadName VARCHAR(40),
    PayloadType VARCHAR(40),
    MassKg DOUBLE,
    FOREIGN KEY(MissionID) REFERENCES missions(MissionID)
);

#Query 1
SELECT MissionName, RocketName, OrgName, SiteName, Destination, LaunchYear, Outcome
FROM launch_sites, missions, organizations, rockets
WHERE missions.RocketID = rockets.RocketID AND
rockets.OrgID = organizations.OrgID AND
missions.SiteID = launch_sites.SiteID
ORDER BY LaunchYear desc, MissionName asc;

/*Retrieve the mission name, rocket name, payload name, payload type, and payload mass (in kg) for all 
payloads launched in 2024 without using table aliases. Sort the results in descending order by payload mass.
*/

#Query 2
SELECT MissionName, RocketName, PayloadName, PayloadType, MassKg
FROM missions, rockets, payloads
WHERE missions.MissionID = payloads.MissionID AND
missions.RocketID = rockets.RocketID AND
LaunchYear = 2024
ORDER BY MassKg desc;

/*Retrieve all launch sites along with their matching mission names, rockets, and launch years for 
missions that took place in 2024 without using table aliases, ensuring that launch sites with 
no recorded 2024 missions still appear in the results with null values for the mission fields. 
Sort the results in alphabetical order by launch site name. */

#Query 3
SELECT SiteName, MissionName, RocketName, LaunchYear
FROM launch_sites
LEFT JOIN missions ON launch_sites.SiteID = missions.SiteID AND
missions.LaunchYear = 2024
LEFT JOIN rockets ON missions.RocketID = rockets.RocketID
ORDER BY SiteName ASC;

/*Write a SQL query using a Common Table Expression (CTE) to calculate the total payload mass (in kg) 
deployed by each organization across all missions without using table aliases. 
Retrieve the organization name, headquarters country, organization type, and total payload mass, 
and sort the results in descending order by total payload mass.*/
# Query 4
WITH orgTotals AS (
    SELECT rockets.OrgID, SUM(payloads.MassKg) AS TotalPayloadMassKg
    FROM payloads
    INNER JOIN missions ON payloads.MissionID = missions.MissionID
    INNER JOIN rockets ON missions.RocketID = rockets.RocketID
    GROUP BY rockets.OrgID
)
SELECT OrgName, HeadquartersCountry, OrgType, TotalPayloadMassKg
FROM organizations
INNER JOIN orgTotals ON organizations.OrgID = orgTotals.OrgID
ORDER BY TotalPayloadMassKg DESC;

#Query 5
WITH missionCounts AS (
    SELECT launch_sites.CountryCode, COUNT(missions.MissionID) AS TotalMissions
    FROM missions
    INNER JOIN launch_sites ON missions.SiteID = launch_sites.SiteID
    GROUP BY launch_sites.CountryCode
),
payloadTotals AS (
    SELECT launch_sites.CountryCode, SUM(payloads.MassKg) AS TotalPayloadMassKg
    FROM payloads
    INNER JOIN missions ON payloads.MissionID = missions.MissionID
    INNER JOIN launch_sites ON missions.SiteID = launch_sites.SiteID
    GROUP BY launch_sites.CountryCode
)
SELECT CountryName, TotalMissions, TotalPayloadMassKg
FROM countries
INNER JOIN missionCounts ON countries.CountryCode = missionCounts.CountryCode
INNER JOIN payloadTotals ON countries.CountryCode = payloadTotals.CountryCode
ORDER BY TotalPayloadMassKg DESC;


