CREATE TABLE baristas (
	baristaID INT PRIMARY KEY,
    name VARCHAR(40),
    experience_level VARCHAR(40)
);

 
 CREATE TABLE shops(
	shopID  INT PRIMARY KEY,
	name VARCHAR(40),
    city VARCHAR(40)
);

CREATE TABLE employs(
	baristaID INT ,
    shopID INT,
    FOREIGN KEY(baristaID) REFERENCES baristas(baristaID),
    FOREIGN KEY(shopID) REFERENCES shops(shopID)
);

CREATE TABLE pastries(
	pastryID INT PRIMARY KEY,
    name VARCHAR(40),
    category VARCHAR(40),
    price DOUBLE
    );
    
CREATE TABLE offers(
	shopID INT,
    pastryID INT,
    date_added VARCHAR(40),
    FOREIGN KEY(shopID) REFERENCES shops(shopID),
    FOREIGN KEY(pastryID) REFERENCES pastries(pastryID)
);


-- 1
SELECT category, AVG(price)
FROM pastries
GROUP BY category;


-- 2
SELECT experience_level, COUNT(*)
FROM baristas
GROUP BY experience_level;


-- 3.
SELECT city, COUNT(*)
FROM shops
GROUP BY city;


-- 4.
SELECT category, MAX(PRICE)
FROM pastries 
GROUP BY category;


-- 5.
SELECT shopID, COUNT(*)
FROM offers
GROUP BY shopID;


-- 6.
SELECT p.name, p.category, p.price
FROM pastries p
JOIN (
    SELECT category, MAX(price) AS max_price
    FROM pastries
    GROUP BY category
) AS category_max
ON p.category = category_max.category AND p.price = category_max.max_price;


-- 7.
SELECT DISTINCT offers.shopID
FROM offers 
JOIN pastries p ON offers.pastryID = p.pastryID
WHERE p.price > (SELECT AVG(price) FROM pastries);


-- 8.
SELECT shopID, pastryID
FROM offers
WHERE date_added = (SELECT MIN(date_added) FROM offers);


-- 9.
SELECT shopID, COUNT(*) AS total_pastries
FROM offers
GROUP BY shopID
HAVING COUNT(*) = (
    SELECT MAX(shop_counts.cnt)
    FROM (
        SELECT COUNT(*) AS cnt
        FROM offers
        GROUP BY shopID
    ) AS shop_counts
);


-- 10.
SELECT name  FROM baristas
WHERE baristaID IN (
    SELECT baristaID
    FROM employs
    WHERE shopID IN (
        SELECT shopID
        FROM shops
        WHERE city = 'Seattle'
    )
);
