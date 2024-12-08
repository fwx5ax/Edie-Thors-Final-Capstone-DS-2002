use sakila;

#CREATE FACT TABLE
# dropped a column - last update

CREATE TABLE `fact_rentals` (
  `rental_id` int(11) NOT NULL AUTO_INCREMENT,
  `rental_date` datetime NOT NULL,
  `inventory_id` mediumint(8) unsigned NOT NULL,
  `customer_id` smallint(5) unsigned NOT NULL,
  `return_date` datetime DEFAULT NULL,
  `staff_id` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`rental_id`),
  UNIQUE KEY `rental_date` (`rental_date`,`inventory_id`,`customer_id`),
  KEY `idx_fk_inventory_id` (`inventory_id`),
  KEY `idx_fk_customer_id` (`customer_id`),
  KEY `idx_fk_staff_id` (`staff_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16050 DEFAULT CHARSET=utf8mb4;
INSERT INTO `sakila`.`fact_rentals`
(`rental_id`,
`rental_date`,
`inventory_id`,
`customer_id`,
`return_date`,
`staff_id`)
SELECT `rental`.`rental_id`,
    `rental`.`rental_date`,
    `rental`.`inventory_id`,
    `rental`.`customer_id`,
    `rental`.`return_date`,
    `rental`.`staff_id`
FROM `sakila`.`rental`;

SELECT COUNT(*) from fact_rentals;
#16044 total rows in fact_rentals, 16044/3 is 5348 each

# DIVIDE FACT RENTALS INTO 3
# First Third
SELECT *
FROM sakila.fact_rentals
ORDER BY rental_id
LIMIT 5348;

# Middle third is between 5350 and 
SELECT *
FROM sakila.fact_rentals
WHERE rental_id >= 5351 and rental_id <= 10699
ORDER BY rental_id;

# Last third
SELECT *
FROM sakila.fact_rentals
WHERE rental_id >= 10700
ORDER BY rental_id;

# CREATE DIMENSION TABLE CUSTOMER
# dropped one column - active
 use sakila;
CREATE TABLE `dim_customer` (
   `customer_id` smallint unsigned NOT NULL AUTO_INCREMENT,
   `store_id` tinyint unsigned NOT NULL,
   `first_name` varchar(45) NOT NULL,
   `last_name` varchar(45) NOT NULL,
   `email` varchar(50) DEFAULT NULL,
   `address_id` smallint unsigned NOT NULL,
   `create_date` datetime NOT NULL,
   `last_update` timestamp NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
	PRIMARY KEY (`customer_id`),
	KEY `idx_fk_store_id` (`store_id`),
   KEY `idx_fk_address_id` (`address_id`),
   KEY `idx_last_name` (`last_name`)
 ) ENGINE=InnoDB AUTO_INCREMENT=600 DEFAULT CHARSET=utf8mb4;
 INSERT INTO `sakila`.`dim_customer`
 (`customer_id`,
 `store_id`,
 `first_name`,
 `last_name`,
 `email`,
 `address_id`,
 `create_date`,
 `last_update`)
 SELECT `customer`.`customer_id`,
     `customer`.`store_id`,
     `customer`.`first_name`,
     `customer`.`last_name`,
     `customer`.`email`,
     `customer`.`address_id`,
     `customer`.`create_date`,
     `customer`.`last_update`
 FROM `sakila`.`customer`;

-- #EXPORT USING SELECT
 SELECT * from sakila.dim_customer

# CREATE FILM DIMENSION TABLE
# dropped two columns - original_language_id and last_update

CREATE TABLE `dim_film` (
  `film_id` smallint unsigned NOT NULL AUTO_INCREMENT,
  `title` varchar(128) NOT NULL,
  `description` text,
  `release_year` year DEFAULT NULL,
  `language_id` tinyint unsigned NOT NULL,
  `rental_duration` tinyint unsigned NOT NULL DEFAULT '3',
  `rental_rate` decimal(4,2) NOT NULL DEFAULT '4.99',
  `length` smallint unsigned DEFAULT NULL,
  `replacement_cost` decimal(5,2) NOT NULL DEFAULT '19.99',
  `rating` enum('G','PG','PG-13','R','NC-17') DEFAULT 'G',
  `special_features` set('Trailers','Commentaries','Deleted Scenes','Behind the Scenes') DEFAULT NULL,
  PRIMARY KEY (`film_id`),
  KEY `idx_title` (`title`)
) ENGINE=InnoDB AUTO_INCREMENT=1001 DEFAULT CHARSET=utf8mb4;
INSERT INTO `sakila`.`dim_film`
(`film_id`,
`title`,
`description`,
`release_year`,
`language_id`,
`rental_duration`,
`rental_rate`,
`length`,
`replacement_cost`,
`rating`,
`special_features`)
SELECT `film`.`film_id`,
    `film`.`title`,
    `film`.`description`,
    `film`.`release_year`,
    `film`.`language_id`,
    `film`.`rental_duration`,
    `film`.`rental_rate`,
    `film`.`length`,
    `film`.`replacement_cost`,
    `film`.`rating`,
    `film`.`special_features`
FROM `sakila`.`film`;

#TO EXPORT 
SELECT * from sakila.dim_film;

# CREATE INVENTORY DIMENSION TABLE
# DROPPED COLUMN LAST UPDATE
CREATE TABLE `dim_inventory` (
  `inventory_id` mediumint(8) unsigned NOT NULL AUTO_INCREMENT,
  `film_id` smallint(5) unsigned NOT NULL,
  `store_id` tinyint(3) unsigned NOT NULL,
  PRIMARY KEY (`inventory_id`),
  KEY `idx_fk_film_id` (`film_id`),
  KEY `idx_store_id_film_id` (`store_id`,`film_id`)
) ENGINE=InnoDB AUTO_INCREMENT=4582 DEFAULT CHARSET=utf8mb4;
INSERT INTO `sakila`.`dim_inventory`
(`inventory_id`,
`film_id`,
`store_id`)
SELECT `inventory`.`inventory_id`,
    `inventory`.`film_id`,
    `inventory`.`store_id`
FROM `sakila`.`inventory`;
# TO EXPORT
SELECT * FROM sakila.dim_inventory;

# CREATE PAYMENT DIMENSION TABLE
# DROPPED COLUMN LAST UPDATE
CREATE TABLE `dim_payment` (
  `payment_id` smallint(5) unsigned NOT NULL AUTO_INCREMENT,
  `customer_id` smallint(5) unsigned NOT NULL,
  `staff_id` tinyint(3) unsigned NOT NULL,
  `rental_id` int(11) DEFAULT NULL,
  `amount` decimal(5,2) NOT NULL,
  `payment_date` datetime NOT NULL,
  PRIMARY KEY (`payment_id`),
  KEY `idx_fk_staff_id` (`staff_id`),
  KEY `idx_fk_customer_id` (`customer_id`),
  KEY `fk_payment_rental` (`rental_id`)
) ENGINE=InnoDB AUTO_INCREMENT=16050 DEFAULT CHARSET=utf8mb4;
INSERT INTO `sakila`.`dim_payment`
(`payment_id`,
`customer_id`,
`staff_id`,
`rental_id`,
`amount`,
`payment_date`)
SELECT `payment`.`payment_id`,
    `payment`.`customer_id`,
    `payment`.`staff_id`,
    `payment`.`rental_id`,
    `payment`.`amount`,
    `payment`.`payment_date`
FROM `sakila`.`payment`;
# TO EXPORT
SELECT * FROM sakila.dim_payment;






