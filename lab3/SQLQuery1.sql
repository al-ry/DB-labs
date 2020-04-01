-- 1. INSERT
	--  1. Без указания списка полей
	INSERT INTO recipient VALUES ('Ivan', 'Ivanov', '89023235688', '1488 166679');
	INSERT INTO recipient VALUES ('Alexey', 'Pertov', '89065532337', '0833 169943');
	INSERT INTO post VALUES ('424000', '56-67-65', '08:00:00', '21:00:00', 'Pavlenko 3');
	--2. С указанием списка полей
	INSERT INTO post(post_index, phone_number, work_schedule_start, work_schedule_end, adress_name)
	VALUES ('424158', '45-45-66', '08:00:00', '21:00:00', 'Pushkina 10');
	--  3. С чтением значения из другой таблицы
	INSERT INTO letter (id_adress) SELECT (id_adress) FROM adress;

-- 2. DELETE
	--  1. Всех записей
	DELETE recipient;
	DELETE letter;
	--  2. По условию
	DELETE post WHERE post_index = '424000';
	--	3. Очистить таблицу
	TRUNCATE TABLE notification;

-- 3. UPDATE
	--	1. Всех записей
	UPDATE recipient SET name = 'Victor';
	--	2. По условию обновляя один атрибут
	UPDATE recipient SET passport = '1465 887390' WHERE name = 'Victor' AND surname = 'Sidorov';
	--	3. По условию обновляя несколько атрибутов
	UPDATE post SET work_schedule_start =  '10:00:00', work_schedule_end = '20:00:00' WHERE post_index = '424158';

-- 4. SELECT
	--	1. С определенным набором извлекаемых атрибутов (SELECT atr1, atr2 FROM...)
	 SELECT post_index, adress_name FROM post;
	--	2. Со всеми атрибутами (SELECT * FROM...)
	SELECT * FROM recipient;
	--	3. С условием по атрибуту (SELECT * FROM ... WHERE atr1 = "")
	select * FROM notification WHERE id_letter = 5;

-- 5. SELECT ORDER BY + TOP (LIMIT)
	--  1. С сортировкой по возрастанию ASC + ограничение вывода количества записей
	SELECT TOP 5 * FROM recipient ORDER BY recipient.surname ASC;
	--  2. С сортировкой по убыванию DESC
	SELECT TOP 10 * FROM recipient ORDER BY name DESC;
	--  3. С сортировкой по двум атрибутам + ограничение вывода количества записей
	SELECT TOP 3 * FROM post ORDER BY post_index, adress_name DESC;
	--  4. С сортировкой по первому атрибуту, из списка извлекаемых
	SELECT TOP 2 * FROM adress ORDER BY name;

-- 6. Работа с датами. Необходимо, чтобы одна из таблиц содержала атрибут с типом DATETIME.
	--  1. WHERE по дате
	SELECT * FROM letter WHERE arrival_date = '2020-04-20 05:24:00';
	--  2. Извлечь из таблицы не всю дату, а только год. Например, год рождения автора.
	SELECT id_adress, YEAR(return_date) AS date FROM letter;


-- 7. SELECT GROUP BY с функциями агрегации
	--  1. MIN
	SELECT reason, MIN(cost) AS min_cost_payments FROM notification GROUP BY reason;
	--  2. MAX
	SELECT reason, MAX(cost) AS max_cost_service FROM notification GROUP BY reason;
	--  3. AVG
	SELECT reason, AVG(cost) AS avg_cost_service FROM notification GROUP BY reason;
	--  4. SUM
	SELECT reason, SUM(cost) AS sum_cost_service FROM notification GROUP BY reason;
	--  5. COUNT
	SELECT reason, COUNT(cost) AS count_service FROM notification GROUP BY reason;


-- 8. SELECT GROUP BY + HAVING
	--  1. Написать 3 разных запроса с использованием GROUP BY + HAVING
	SELECT arrival_date FROM letter GROUP BY arrival_date HAVING YEAR(arrival_date)  > 2016;

	SELECT reason, cost FROM notification GROUP BY reason, cost HAVING sum(cost) > 200;

	SELECT adress_name, post_index, phone_number FROM post GROUP BY adress_name, post_index, phone_number
	HAVING MIN(DATEPART(hour, work_schedule_end)) < 21;

-- 9. SELECT JOIN
	--  1. LEFT JOIN двух таблиц и WHERE по одному из атрибутов
	SELECT * FROM recipient LEFT JOIN adress ON recipient.id_recipient = adress.id_recipient WHERE recipient.name = 'Cemen';
	--  2. RIGHT JOIN. Получить такую же выборку, как и в 5.1
	SELECT TOP 5 * FROM recipient LEFT JOIN adress ON recipient.id_recipient = adress.id_recipient ORDER BY recipient.surname ASC;
    --  3. LEFT JOIN трех таблиц + WHERE по атрибуту из каждой таблицы
	SELECT adress.id_recipient, adress.id_adress, adress.name,
		   letter.id_adress, letter.arrival_date, letter.return_date,
		   notification.id_letter, notification.reason, notification.cost
    FROM adress LEFT JOIN letter ON adress.id_adress = letter.id_adress
	LEFT JOIN notification ON letter.id_letter = notification.id_letter
	WHERE adress.id_adress = 8 AND reason = 'tax payments' AND arrival_date = '2020-04-20 05:24:00.000';
    --  4. FULL OUTER JOIN двух таблиц
	SELECT * FROM post FULL OUTER JOIN recipient ON post.id_post = recipient.id_recipient;

-- 10. Подзапросы
	--  1. Написать запрос с WHERE IN (подзапрос)
	SELECT * FROM letter WHERE id_adress IN (8, 9);
	--  2. Написать запрос SELECT atr1, atr2, (подзапрос) FROM ...    
	SELECT id_post, 
		   post_index, 
		  (SELECT name FROM adress WHERE post.id_post = adress.id_post) AS adress_relation
	FROM post;
