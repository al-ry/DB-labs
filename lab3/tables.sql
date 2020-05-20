USE notificationsV2

CREATE TABLE recipient
(
	id_recipient INT PRIMARY KEY IDENTITY,
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

CREATE TABLE adress
(
	id_adress INT PRIMARY KEY IDENTITY,
	name nvarchar(50),
	id_post INT REFERENCES post(id_post),
	id_recipient INT REFERENCES recipient(id_recipient)
);

ALTER TABLE adress
ALTER COLUMN name nvarchar(50) NOT NULL;

CREATE TABLE notification
(
	id_notification INT PRIMARY KEY IDENTITY,
	title nvarchar (50) NOT NULL,
	action nvarchar (50) NOT NULL,
	content text NOT NULL,
	cost money
);


CREATE TABLE letter
(
	id_letter INT PRIMARY KEY IDENTITY,
	arrival_date datetime NOT NULL,
	return_date datetime NOT NULL,
	id_notification INT REFERENCES notification(id_notification),
	id_adress INT REFERENCES adress(id_adress)
);

