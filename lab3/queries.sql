USE notifications;

-- 1. INSERT
	--1.Без указания списка полей
	INSERT INTO post VALUES ('424000', '56-67-65', '08:00:00', '21:00:00', 'Pavlenko 3');
	INSERT INTO post VALUES ('424034', '33-33-45', '08:00:00', '20:00:00', 'Mira 20');
	INSERT INTO address VALUES ('Pavlenko 8', '1');
	INSERT INTO address VALUES ('Pavlenko 2', '1');
	INSERT INTO address VALUES ('Lebedeva 30', '2');
	INSERT INTO address VALUES ('Mira 8', '2');
	INSERT INTO recipient VALUES ('1','Ivan', 'Ivanov', '89023235688', '1488 166679');
	INSERT INTO recipient VALUES ('1','Alexey', 'Pertov', '89065532337', '0833 169943');
	INSERT INTO recipient VALUES ('1','Victor', 'Sidorov', '89065532337', '2281 128988');
	INSERT INTO recipient VALUES ('1','Katya', 'Vailieva', '89066655837', '1565 133488');
	INSERT INTO recipient VALUES ('2','Vasilisa', 'Pushkina', '89067657667', '1567 133678');
	INSERT INTO recipient VALUES ('2','Evklid', 'Chexov', '8906677667', '1557 135578');
	INSERT INTO letter VALUES ('2020-04-25 10:28:00', '2020-05-20 05:24:00', 1, 2000);
	INSERT INTO letter VALUES ('2020-04-25 10:28:00', '2020-05-20 05:24:00', 1, 8000);
	INSERT INTO letter VALUES ('2020-04-25 10:28:00', '2020-05-20 05:24:00', 2, 5000);
	--2. С указанием списка полей
	INSERT INTO letter (arrival_date, return_date, id_address) VALUES ('2020-04-25 10:28:00', '2020-05-20 05:24:00', 1);
	INSERT INTO notification (id_letter, description) VALUES (7, 'You have debt for heating. You should pay it on time');
	INSERT INTO notification (id_letter, description) VALUES (6,'You recieved a letter.');
	INSERT INTO notification (id_letter, description) VALUES (8, 'New letter');
	INSERT INTO notification (id_letter, description) VALUES (7,'Reapeated message. You must pay for the heating');

--2. DELETE
	--1. Всех записей
	DELETE notification;
	--2. По условию
	DELETE FROM recipient WHERE name = 'Ivan';

--3. UPDATE
	--1. Всех записей
	UPDATE recipient SET phone_number = '88005553535';
	--2. По условию обновляя один атрибут
	UPDATE post SET closing_time = '20:00:00' WHERE closing_time = '21:00:00';
	--3. По условию обновляя несколько атрибутов
	UPDATE recipient SET name = 'Georg', passport = '1356 443877' WHERE passport = '2281 128988';

--4. SELECT
	--1. С определенным набором извлекаемых атрибутов (SELECT atr1, atr2 FROM...)
	 SELECT post_index, address_name FROM post;
	--2. Со всеми атрибутами (SELECT * FROM...)
	SELECT * FROM recipient;
	--3. С условием по атрибуту (SELECT * FROM ... WHERE atr1 = "")
	SELECT * FROM notification WHERE CONVERT(VARCHAR, description) = 'New letter';

-- 5. SELECT ORDER BY + TOP (LIMIT)
	--1. С сортировкой по возрастанию ASC + ограничение вывода количества записей
	SELECT TOP 5 * FROM recipient ORDER BY recipient.surname ASC
	-- 2. С сортировкой по убыванию DESC
	SELECT TOP 10 * FROM recipient ORDER BY name DESC;
	--3. С сортировкой по двум атрибутам + ограничение вывода количества записей
	SELECT TOP 3 * FROM post ORDER BY post_index, address_name DESC;
	--4. С сортировкой по первому атрибуту, из списка извлекаемых
	SELECT TOP 2 * FROM address ORDER BY name;

-- 6. Работа с датами. Необходимо, чтобы одна из таблиц содержала атрибут с типом DATETIME.
	--1. WHERE по дате
	SELECT * FROM letter WHERE arrival_date = '2020-04-25 10:28:00';
	--  2.  Извлечь из таблицы не всю дату, а только год.
	SELECT id_address, YEAR(return_date) AS date FROM letter;

-- 7. SELECT GROUP BY с функциями агрегации
	--  1. MIN
	SELECT id_address, MIN(declared_value) AS min_cost FROM letter GROUP BY id_address;
	--  2. MAX
	SELECT id_address, MAX(declared_value) AS max_cost FROM letter GROUP BY id_address;
	--  3. AVG
	SELECT id_address, AVG(declared_value) AS max_cost FROM letter GROUP BY id_address;
	--  4. SUM
	SELECT id_address, SUM(declared_value) AS max_cost FROM letter GROUP BY id_address;
	--  5. COUNT
	SELECT COUNT(id_address) AS letters_count_for_each_user FROM letter GROUP BY id_address;

		SELECT * FROM address
	SELECT * FROM post
	SELECT * FROM notification
	SELECT * FROM letter
	SELECT * FROM recipient
-- 8. SELECT GROUP BY + HAVING
	--  1. Написать 3 разных запроса с использованием GROUP BY + HAVING
	--Адреса в которых проживает больше 2 человек
	SELECT id_address FROM recipient GROUP BY id_address HAVING COUNT(id_recipient) > 2;

	--Отделения к которым относится больше 2 адресов
	SELECT id_post FROM address GROUP BY id_post HAVING COUNT(id_address) > 2;

	--Адреса на которые было отправлено больше 1 письма
	SELECT id_address FROM letter GROUP BY id_address HAVING COUNT (id_letter) > 1;

-- 9. SELECT JOIN
	--  1. LEFT JOIN двух таблиц и WHERE по одному из атрибутов
	SELECT * FROM recipient LEFT JOIN address ON recipient.id_address = address.id_address WHERE recipient.id_recipient = '1';
	-- 2. RIGHT JOIN. Получить такую же выборку, как и в 9.1
	SELECT * FROM address RIGHT JOIN recipient ON address.id_address = recipient.id_address  WHERE recipient.id_recipient = '5';
	--  3. LEFT JOIN трех таблиц + WHERE по атрибуту из каждой таблицы
	SELECT address.id_address, address.id_address, address.name,
		   letter.id_address, letter.arrival_date, letter.return_date,
		   notification.description
    FROM address LEFT JOIN letter ON address.id_address = letter.id_address
	LEFT JOIN notification ON letter.id_letter = notification.id_letter
	WHERE address.id_address = 2
	AND  (CONVERT(VARCHAR, notification.description) = 'You recieved a letter.') 
	AND YEAR(arrival_date) = '2020';
	 --  4. FULL OUTER JOIN двух таблиц
	SELECT * FROM address FULL OUTER JOIN post ON address.id_post = post.id_post;


-- 10. Подзапросы
	--  1. Написать запрос с WHERE IN (подзапрос)
	SELECT * FROM letter WHERE id_letter IN (
		SELECT id_letter FROM notification
		WHERE CONVERT(VARCHAR, description) = 'New letter')
	--  2. Написать запрос SELECT atr1, atr2, (подзапрос) FROM ...   
	SELECT id_post, 
		   post_index, 
		  (SELECT name FROM address WHERE post.id_post = address.id_post) AS adress_relation
	FROM post;
