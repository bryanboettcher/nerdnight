-- Generated CREATE TABLE statement for: customers
-- Source: customers.xlsx
-- Generated on: 2025-09-24 15:30:45

CREATE TABLE [customers] (
    [customer_id] INT NULL,
    [first_name] NVARCHAR(50) NULL,
    [last_name] NVARCHAR(50) NULL,
    [email] NVARCHAR(255) NULL,
    [phone] NVARCHAR(20) NULL,
    [address] NVARCHAR(500) NULL,
    [city] NVARCHAR(50) NULL,
    [state] NVARCHAR(50) NULL,
    [zip_code] NVARCHAR(10) NULL,
    [country] NVARCHAR(100) NULL,
    [registration_date] DATE NULL,
    [status] NVARCHAR(50) NULL
);

/*
Column Analysis:
-- [customer_id]: INT (Max observed length: 4)
-- [first_name]: NVARCHAR(50) (Max observed length: 11)
-- [last_name]: NVARCHAR(50) (Max observed length: 9)
-- [email]: NVARCHAR(255) (Max observed length: 28)
-- [phone]: NVARCHAR(20) (Max observed length: 12)
-- [address]: NVARCHAR(500) (Max observed length: 14)
-- [city]: NVARCHAR(50) (Max observed length: 11)
-- [state]: NVARCHAR(50) (Max observed length: 2)
-- [zip_code]: NVARCHAR(10) (Max observed length: 5)
-- [country]: NVARCHAR(100) (Max observed length: 3)
-- [registration_date]: DATE (Max observed length: 10)
-- [status]: NVARCHAR(50) (Max observed length: 8)
*/

-- Sample INSERT statement template:
-- INSERT INTO [customers] (
--     customer_id,
--     first_name,
--     last_name,
--     email,
--     phone,
--     address,
--     city,
--     state,
--     zip_code,
--     country,
--     registration_date,
--     status
-- ) VALUES (
--     -- Add your values here
-- );

-- Example INSERT with sample data:
INSERT INTO [customers] (customer_id, first_name, last_name, email, phone, address, city, state, zip_code, country, registration_date, status)
VALUES (1001, 'John', 'Smith', 'john.smith@email.com', '555-123-4567', '123 Main St', 'Springfield', 'IL', '62701', 'USA', '2024-01-15', 'Active');
