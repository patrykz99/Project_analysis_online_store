-- Clearing data
-- ( customers table for correctness email)

SELECT COUNT(*) AS incorrect_amount
FROM public.customers
WHERE   email IS NULL
        OR TRIM(email) IN ('','N/A','-9','0')
        OR email NOT LIKE '%@%.%';

-- Check email duplicates
SELECT email, COUNT(*) as amount
FROM public.customers
GROUP BY email
HAVING COUNT(*) >1
ORDER BY amount DESC;

-- Result: none duplicates

SELECT COUNT(*)
FROM customers
WHERE customers.first_name IS NULL
    OR TRIM(customers.first_name) IN ('','N/A','-9','0')
    OR customers.last_name IS NULL
    OR TRIM(customers.last_name) IN ('','N/A','-9','0')
    OR customers.email IS NULL
    OR customers.email IN ('','N/A','-9','0')
    OR customers.email NOT LIKE '%@%.%'
    OR customers.phone_number IS NULL
    OR TRIM(customers.phone_number) IN ('','N/A','-9','0')
    OR customers.address IS NULL
    OR TRIM(customers.address) IN ('','N/A','-9','0')

-- Validation of phone number
SELECT count(*)
FROM customers
WHERE customers.phone_number ~ '\+48 [0-9]{3} [0-9]{3} [0-9]{3}';

--Transformating data

-- CREATE EXTENSION unaccent; - added extension to remove diacritic signs

-- Preparing new column voivodeship to further analyse sales for individual voiveodeship
ALTER TABLE customers
ADD COLUMN voivodeship VARCHAR(20);

/*UPDATE customers c
SET voivodeship = cvp.c2
FROM city_voivodeship_poland cvp
WHERE TRIM(SPLIT_PART(c.address,',',2)) LIKE cvp.c1;*/

UPDATE customers c
SET voivodeship = cvp.c2
FROM city_voivodeship_poland cvp
WHERE unaccent(TRIM(SPLIT_PART(c.address,',',2))) LIKE unaccent(cvp.c1);

-- Adding column to order_ites with total sum price for products
ALTER TABLE order_items
ADD COLUMN sum_price NUMERIC;

UPDATE order_items
SET sum_price = quantity * unit_price;

-- Adding new column to orders in order to mark as number proper status
SELECT status FROM orders
GROUP BY status;

ALTER TABLE orders
ADD COLUMN status_number integer;

UPDATE orders
SET status_number = CASE WHEN unaccent(status) LIKE 'Zlozone' THEN 1
                    WHEN unaccent(status) LIKE 'W trakcie przygotowania' THEN 2
                    WHEN unaccent(status) LIKE 'Oczekuje na dostawe' THEN 3
                    WHEN unaccent(status) LIKE 'Zrealizowane' THEN 4
                    ELSE 0 END;

-- Adding column review_type to product_reviews table. + means positive, - means negative
ALTER TABLE product_reviews
ADD COLUMN review_type CHAR(1);

--ALTER TABLE product_reviews
--DROP COLUMN review_type;

UPDATE product_reviews
SET review_type = CASE WHEN rating <= 2 THEN '-'
                  WHEN rating > 2 THEN '+'
                  ELSE '0' END;