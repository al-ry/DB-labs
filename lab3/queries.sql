USE notificationsV2;

-- 1. INSERT
	--1.Без указания списка полей
	INSERT INTO recipient VALUES ('Ivan', 'Ivanov', '89023235688', '1488 166679');
	INSERT INTO recipient VALUES ('Alexey', 'Pertov', '89065532337', '0833 169943');
	INSERT INTO recipient VALUES ('Victor', 'Sidorov', '89065532337', '2281 128988');
	INSERT INTO recipient VALUES ('Katya', 'Vailieva', '89066655837', '1565 133488');
	INSERT INTO post VALUES ('424000', '56-67-65', '08:00:00', '21:00:00', 'Pavlenko 3');
	INSERT INTO adress VALUES ('Pavlenko 4', '1', '5');
	INSERT INTO letter VALUES ('2020-04-25 10:28:00', '2020-05-20 05:24:00', 5, 5);
	--2. С указанием списка полей
	INSERT INTO notification (title, action, content) VALUES ('Ivite', 'wedding', 'We would like you to come to the wedding');
	INSERT INTO notification (title, action, content) VALUES ('Notification', 'Appearance to court', 'You must come to the court');
	INSERT INTO notification (title, action, content, cost) VALUES ('JKX', 'Payment', 'Payment for heating should be paid on time', '2200');
	INSERT INTO notification (title, action, content, cost) VALUES ('JKX', 'Payment', 'Garbage collection', '500');


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
	 SELECT post_index, adress_name FROM post;
	--2. Со всеми атрибутами (SELECT * FROM...)
	SELECT * FROM recipient;
	--3. С условием по атрибуту (SELECT * FROM ... WHERE atr1 = "")
	SELECT * FROM notification WHERE title = 'JKX';

-- 5. SELECT ORDER BY + TOP (LIMIT)
	--1. С сортировкой по возрастанию ASC + ограничение вывода количества записей
	SELECT TOP 5 * FROM recipient ORDER BY recipient.surname ASC
	-- 2. С сортировкой по убыванию DESC
	SELECT TOP 10 * FROM recipient ORDER BY name DESC;
	--3. С сортировкой по двум атрибутам + ограничение вывода количества записей
	SELECT TOP 3 * FROM post ORDER BY post_index, adress_name DESC;
	--4. С сортировкой по первому атрибуту, из списка извлекаемых
	SELECT TOP 2 * FROM adress ORDER BY name;

-- 6. Работа с датами. Необходимо, чтобы одна из таблиц содержала атрибут с типом DATETIME.
	--1. WHERE по дате
	SELECT * FROM letter WHERE arrival_date = '2020-04-25 10:28:00';
	--  2.  Извлечь из таблицы не всю дату, а только год.
	SELECT id_adress, YEAR(return_date) AS date FROM letter;

-- 7. SELECT GROUP BY с функциями агрегации
	--  1. MIN
	SELECT title, MIN(cost) AS min_cost FROM notification GROUP BY title;
	--  2. MAX
	SELECT title, MAX(cost) AS max_cost FROM notification GROUP BY title;
	--  3. AVG
	SELECT title, AVG(cost) AS max_cost FROM notification GROUP BY title;
	--  4. SUM
	SELECT title, SUM(cost) AS max_cost FROM notification GROUP BY title;
	--  5. COUNT
	SELECT COUNT(id_adress) AS letters_count_for_each_user FROM letter GROUP BY id_adress;

-- 8. SELECT GROUP BY + HAVING
	--  1. Написать 3 разных запроса с использованием GROUP BY + HAVING
	SELECT arrival_date FROM letter GROUP BY arrival_date HAVING YEAR(arrival_date)  > 2016;

	SELECT title, cost FROM notification GROUP BY title, cost HAVING sum(cost) > 200;

	SELECT adress_name, post_index, phone_number FROM post GROUP BY adress_name, post_index, phone_number
	HAVING MIN(DATEPART(hour, closing_time)) < 21;

-- 9. SELECT JOIN
	--  1. LEFT JOIN двух таблиц и WHERE по одному из атрибутов
	SELECT * FROM recipient LEFT JOIN adress ON recipient.id_recipient = adress.id_recipient WHERE recipient.id_recipient = '5';
	-- 2. RIGHT JOIN. Получить такую же выборку, как и в 9.1
	SELECT * FROM adress RIGHT JOIN recipient ON adress.id_recipient = recipient.id_recipient  WHERE recipient.id_recipient = '5';
	--  3. LEFT JOIN трех таблиц + WHERE по атрибуту из каждой таблицы
	SELECT adress.id_recipient, adress.id_adress, adress.name,
		   letter.id_adress, letter.arrival_date, letter.return_date,
		   notification.title, notification.content
    FROM adress LEFT JOIN letter ON adress.id_adress = letter.id_adress
	LEFT JOIN notification ON letter.id_notification = notification.id_notification
	WHERE adress.id_adress = 5 AND notification.title = 'Ivite' AND YEAR(arrival_date) = '2020';
	 --  4. FULL OUTER JOIN двух таблиц
	SELECT * FROM adress FULL OUTER JOIN post ON adress.id_post = post.id_post;


-- 10. Подзапросы
	--  1. Написать запрос с WHERE IN (подзапрос)
	SELECT * FROM letter WHERE id_letter IN (
		SELECT id_letter FROM notification
		WHERE title = 'JKX')
	--  2. Написать запрос SELECT atr1, atr2, (подзапрос) FROM ...   
	SELECT id_post, 
		   post_index, 
		  (SELECT name FROM adress WHERE post.id_post = adress.id_post) AS adress_relation
	FROM post;
