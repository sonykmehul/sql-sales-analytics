
-- data.sql
INSERT INTO categories (category_name)
SELECT 'Category_' || i FROM generate_series(1,20) i;

INSERT INTO customers (name, email, signup_date, city, country)
SELECT
    'Customer_' || i,
    'customer' || i || '@mail.com',
    DATE '2021-01-01' + (i % 900),
    (ARRAY['Delhi','Bangalore','Mumbai','Pune','Hyderabad'])[1 + (i % 5)],
    'India'
FROM generate_series(1,5000) i;

INSERT INTO products (product_name, category_id, launch_date, is_active)
SELECT
    'Product_' || i,
    1 + (i % 20),
    DATE '2020-01-01' + (i % 700),
    CASE WHEN i % 10 = 0 THEN FALSE ELSE TRUE END
FROM generate_series(1,1000) i;

INSERT INTO orders (customer_id, order_date, order_status, total_amount)
SELECT
    1 + (random() * 4999)::INT,
    DATE '2022-01-01' + (random() * 700)::INT,
    (ARRAY['PLACED','SHIPPED','DELIVERED','CANCELLED'])[1 + (random()*3)::INT],
    ROUND((random()*5000 + 500)::NUMERIC, 2)
FROM generate_series(1,25000);

INSERT INTO order_items (order_id, product_id, quantity, price)
SELECT
    1 + (random() * 24999)::INT,
    1 + (random() * 999)::INT,
    1 + (random() * 4)::INT,
    ROUND((random()*2000 + 200)::NUMERIC, 2)
FROM generate_series(1,70000);

INSERT INTO payments (order_id, payment_date, payment_method, payment_status)
SELECT
    order_id,
    order_date + (random()*3)::INT,
    (ARRAY['CARD','UPI','NETBANKING','WALLET'])[1 + (random()*3)::INT],
    CASE WHEN random() < 0.95 THEN 'SUCCESS' ELSE 'FAILED' END
FROM orders;

INSERT INTO returns (order_item_id, return_date, return_reason)
SELECT
    1 + (random()*69999)::INT,
    DATE '2022-01-01' + (random()*700)::INT,
    (ARRAY['Damaged','Late Delivery','Wrong Item','Not Needed'])[1 + (random()*3)::INT]
FROM generate_series(1,8000);
