USE notifications

CREATE TABLE recipient
(
	id_recipient INT PRIMARY KEY IDENTITY,
	id_address INT REFERENCES address(id_address),
	name  nvarchar(50) NOT NULL,
	surname nvarchar(50) NOT NULL,
	phone_number nvarchar(12) NOT NULL,
	passport nvarchar(12) NOT NULL
);

CREATE TABLE post
(
	id_post INT PRIMARY KEY IDENTITY,
	post_index nvarchar(20) NOT NULL,
	phone_number nvarchar(12) NOT NULL,
	opening_time time NOT NULL,
	closing_time time NOT NULL,
	adress_name nvarchar(50) NOT NULL
);

CREATE TABLE address
(
	id_address INT PRIMARY KEY IDENTITY,
	name nvarchar(50),
	id_post INT REFERENCES post(id_post),
);

ALTER TABLE address
ALTER COLUMN name nvarchar(50) NOT NULL;

CREATE TABLE notification
(
	id_notification INT PRIMARY KEY IDENTITY,
	id_letter INT REFERENCES letter(id_letter),
	title nvarchar (50) NOT NULL,
	action nvarchar (50) NOT NULL,
	content text NOT NULL,
	cost money
);

ALTER TABLE notification DROP COLUMN title;
ALTER TABLE notification DROP COLUMN action;
ALTER TABLE notification DROP COLUMN content;
ALTER TABLE notification DROP COLUMN cost;
ALTER TABLE notification
ADD description TEXT NOT NULL;

CREATE TABLE letter
(
	id_letter INT PRIMARY KEY IDENTITY,
	arrival_date datetime NOT NULL,
	return_date datetime NOT NULL,
	id_address INT REFERENCES address(id_address)
);
ALTER TABLE letter
ALTER COLUMN declared_value money NULL;

ALTER TABLE letter
ADD cost money NULL;

ALTER TABLE letter DROP COLUMN content;


