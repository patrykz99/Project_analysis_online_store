-- Adding new column about customer's sex
ALTER TABLE public.customers
ADD COLUMN sex VARCHAR(5);

UPDATE customers
SET sex =
    CASE WHEN first_name ILIKE '%a' THEN 'Woman'
         ELSE 'Man' END;


-- Create views to further analysis
CREATE OR REPLACE VIEW sales_rating_by_sex
AS
    SELECT c.sex,
           SUM(oi.sum_price) as total_sales,
           SUM(oi.quantity) as total_volume,
           TRUNC(AVG(pr.rating),2) as avg_rating
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    INNER JOIN product_reviews pr ON c.customer_id = pr.customer_id
    WHERE o.status_number = 4
    GROUP BY c.sex
    ORDER BY total_sales DESC;

CREATE OR REPLACE VIEW sales_rating_by_voivodeship
AS
WITH ReviewsTotal AS (SELECT customer_id, AVG(rating) as avg_rating FROM product_reviews GROUP BY customer_id)
    SELECT c.voivodeship,
           SUM(oi.sum_price) as total_sales,
           SUM(oi.quantity) as total_volume,
           TRUNC(AVG(rt.avg_rating),2) as avg_rating
    FROM customers c
    INNER JOIN orders o ON c.customer_id = o.customer_id
    INNER JOIN order_items oi ON o.order_id = oi.order_id
    LEFT JOIN ReviewsTotal rt ON c.customer_id = rt.customer_id
    GROUP BY c.voivodeship
    ORDER BY total_sales DESC;

CREATE OR REPLACE VIEW sales_rating_products_by_date
AS
    SELECT to_char(pr.review_date,'yyyy-mm') as date,
           SUM(sum_price) as total_price,
           SUM(oi.quantity) as total_volume,
           ROUND(AVG(pr.rating),2) as average_rating,
           SUM(CASE WHEN pr.review_type = '+' THEN 1 END) AS positive_reviews,
           SUM(CASE WHEN pr.review_type = '-' THEN 1 END) AS negative_reviews
    FROM products p
    INNER JOIN product_reviews pr ON p.product_id = pr.product_id
    INNER JOIN order_items oi ON p.product_id = oi.product_id
    INNER JOIN orders o ON oi.order_id = o.order_id
    WHERE o.status_number = 4
    GROUP BY date
    ORDER BY date;

CREATE OR REPLACE VIEW sales_rating_products_by_category
AS
    SELECT p.category,
           SUM(oi.sum_price) as total_price,
           SUM(oi.quantity) as total_volume,
           ROUND(AVG(pr.rating),2) as average_rating
    FROM products p
    INNER JOIN order_items oi ON p.product_id = oi.product_id
    INNER JOIN orders o ON oi.order_id = o.order_id
    INNER JOIN product_reviews pr ON p.product_id = pr.product_id
    WHERE o.status_number = 4
    GROUP BY p.category
    ORDER BY total_price DESC;

