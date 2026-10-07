CREATE TABLE countries (
    CountryCode VARCHAR(10) PRIMARY KEY,
    CountryName VARCHAR(50),
    Continent VARCHAR(30)
);

CREATE TABLE operators (
    OperatorID INT PRIMARY KEY,
    OperatorName VARCHAR(50),
    HeadquartersCountry VARCHAR(10),
    FOREIGN KEY (HeadquartersCountry) REFERENCES countries(CountryCode)
);

CREATE TABLE fuel_types (
    FuelID INT PRIMARY KEY,
    FuelCategory VARCHAR(30),
    FuelName VARCHAR(30)
);

CREATE TABLE power_plants (
    PlantID INT PRIMARY KEY,
    PlantName VARCHAR(50),
    CountryCode VARCHAR(10),
    OperatorID INT,
    FuelID INT,
    CapacityMW INT,
    CommissionYear INT,
    FOREIGN KEY (CountryCode) REFERENCES countries(CountryCode),
    FOREIGN KEY (OperatorID) REFERENCES operators(OperatorID),
    FOREIGN KEY (FuelID) REFERENCES fuel_types(FuelID)
);

CREATE TABLE generation_records (
    plantid INT,
    year INT,
    generationgwh DECIMAL(10,2),
    PRIMARY KEY (plantid, year),
    FOREIGN KEY (plantid) REFERENCES power_plants(PlantID)
);

CREATE TABLE emission_metrics (
    plantid INT,
    year INT,
    co2emissionstonnes DECIMAL(12,2),
    PRIMARY KEY (plantid, year),
    FOREIGN KEY (plantid) REFERENCES power_plants(PlantID)
);




-- query 1
SELECT power_plants.Plantname, countries.Countryname, operators.OperatorName, 
	   fuel_types.FuelCategory, fuel_types.FuelName, power_plants.CapacityMW, power_plants.CommissionYear
FROM power_plants, countries, operators, fuel_types
WHERE power_plants.CountryCode = countries.CountryCode
AND power_plants.OperatorID = operators.OperatorID
AND power_plants.FuelID = fuel_types.FuelID
ORDER BY capacitymw DESC;

-- Query 2
SELECT 
	power_plants.PlantName, power_plants.CountryCode, generation_records.year, generation_records.generationgwh
FROM power_plants, generation_records
WHERE 
	power_plants.plantid = generation_records.plantid
AND	generation_records.year = 2024
ORDER BY generation_records.generationgwh DESC;


-- Query 3
SELECT 
	power_plants.PlantName, power_plants.CountryCode, generation_records.year, 
    generation_records.generationgwh, emission_metrics.co2emissionstonnes
FROM power_plants, generation_records, emission_metrics
WHERE 
	power_plants.plantid = generation_records.plantid
AND power_plants.PlantID = emission_metrics.plantid
AND	generation_records.year = 2024
ORDER by emission_metrics.co2emissionstonnes ASC;


-- Query 4
WITH total as(
	SELECT plantID, sum(generationgwh) AS total_generation
    FROM generation_records
    group by plantID
)

SELECT operators.OperatorName, operators.HeadquartersCountry, SUM(total.total_generation) AS cumalativepower
FROM power_plants, operators, total
WHERE total.plantID = power_plants.PlantID
AND power_plants.OperatorID = operators.OperatorID
GROUP BY operators.OperatorName, operators.HeadquartersCountry
ORDER BY cumalativepower DESC;


-- Query 5
WITH powertotal AS (
    SELECT power_plants.CountryCode, SUM(generation_records.generationgwh) AS totalgeneration
    FROM power_plants, generation_records
    WHERE power_plants.PlantID = generation_records.plantid
    GROUP BY power_plants.CountryCode
),
emission_totals AS (
    SELECT power_plants.CountryCode, SUM(emission_metrics.co2emissionstonnes) AS totalemissions
    FROM power_plants, emission_metrics
    WHERE power_plants.PlantID = emission_metrics.plantid
    GROUP BY power_plants.CountryCode
)

SELECT countries.CountryName, powertotal.totalgeneration, emission_totals.totalemissions
FROM countries, powertotal, emission_totals
WHERE countries.CountryCode = powertotal.CountryCode
AND countries.CountryCode = emission_totals.CountryCode
ORDER BY powertotal.totalgeneration DESC;
