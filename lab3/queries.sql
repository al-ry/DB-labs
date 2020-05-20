USE notificationsV2;

-- 1. INSERT
	--1. ��� �������� ������ �����
	INSERT INTO recipient VALUES ('Ivan', 'Ivanov', '89023235688', '1488 166679');
	INSERT INTO recipient VALUES ('Alexey', 'Pertov', '89065532337', '0833 169943');
	INSERT INTO recipient VALUES ('Victor', 'Sidorov', '89065532337', '2281 128988');
	INSERT INTO recipient VALUES ('Katya', 'Vailieva', '89066655837', '1565 133488');
	INSERT INTO post VALUES ('424000', '56-67-65', '08:00:00', '21:00:00', 'Pavlenko 3');
	INSERT INTO adress VALUES ('Pavlenko 4', '1', '5');
	INSERT INTO letter VALUES ('2020-04-25 10:28:00', '2020-05-20 05:24:00', 5, 5);
	--2. � ��������� ������ �����
	INSERT INTO notification (title, action, content) VALUES ('Ivite', 'wedding', 'We would like you to come to the wedding');
	INSERT INTO notification (title, action, content) VALUES ('Notification', 'Appearance to court', 'You must come to the court');
	INSERT INTO notification (title, action, content, cost) VALUES ('JKX', 'Payment', 'Payment for heating should be paid on time', '2200');
	INSERT INTO notification (title, action, content, cost) VALUES ('JKX', 'Payment', 'Garbage collection', '500');


--2. DELETE
	--1. ���� �������
	DELETE notification;
	--2. �� �������
	DELETE FROM recipient WHERE name = 'Ivan';


--3. UPDATE
	--1. ���� �������
	UPDATE recipient SET phone_number = '88005553535';
	--2. �� �������
	UPDATE post SET closing_time = '20:00:00' WHERE closing_time = '21:00:00';
	--3. �� ������� �������� ��������� ���������
	UPDATE recipient SET name = 'Georg', passport = '1356 443877' WHERE passport = '2281 128988';

--4. SELECT
	--1. � ������������ ������� ����������� ��������� (SELECT atr1, atr2 FROM...)
	 SELECT post_index, adress_name FROM post;
	--2. �� ����� ���������� (SELECT * FROM...)
	SELECT * FROM recipient;
	--3. � �������� �� �������� (SELECT * FROM ... WHERE atr1 = "")
	SELECT * FROM notification WHERE title = 'JKX';

-- 5. SELECT ORDER BY + TOP (LIMIT)
	--1. � ����������� �� ����������� ASC + ����������� ������ ���������� �������
	SELECT TOP 5 * FROM recipient ORDER BY recipient.surname ASC
	-- 2. � ����������� �� �������� DESC
	SELECT TOP 10 * FROM recipient ORDER BY name DESC;
	--3. � ����������� �� ���� ��������� + ����������� ������ ���������� �������
	SELECT TOP 3 * FROM post ORDER BY post_index, adress_name DESC;
	--4. � ����������� �� ������� ��������, �� ������ �����������
	SELECT TOP 2 * FROM adress ORDER BY name;

-- 6. ������ � ������. ����������, ����� ���� �� ������ ��������� ������� � ����� DATETIME.
	--  1. WHERE �� ����
	SELECT * FROM letter WHERE arrival_date = '2020-04-25 10:28:00';
	--  2. ������� �� ������� �� ��� ����, � ������ ���. ��������, ��� �������� ������.
	SELECT id_adress, YEAR(return_date) AS date FROM letter;

-- 7. SELECT GROUP BY � ��������� ���������
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
	--  1. �������� 3 ������ ������� � �������������� GROUP BY + HAVING
	SELECT arrival_date FROM letter GROUP BY arrival_date HAVING YEAR(arrival_date)  > 2016;

	SELECT title, cost FROM notification GROUP BY title, cost HAVING sum(cost) > 200;

	SELECT adress_name, post_index, phone_number FROM post GROUP BY adress_name, post_index, phone_number
	HAVING MIN(DATEPART(hour, closing_time)) < 21;

-- 9. SELECT JOIN
	--  1. LEFT JOIN ���� ������ � WHERE �� ������ �� ���������
	SELECT * FROM recipient LEFT JOIN adress ON recipient.id_recipient = adress.id_recipient WHERE recipient.id_recipient = '5';
	-- 2. RIGHT JOIN. �������� ����� �� �������, ��� � � 9.1
	SELECT * FROM recipient RIGHT JOIN adress ON adress.id_recipient = recipient.id_recipient  WHERE recipient.id_recipient = '5';
	--  3. LEFT JOIN ���� ������ + WHERE �� �������� �� ������ �������
	SELECT adress.id_recipient, adress.id_adress, adress.name,
		   letter.id_adress, letter.arrival_date, letter.return_date,
		   notification.title, notification.content
    FROM adress LEFT JOIN letter ON adress.id_adress = letter.id_adress
	LEFT JOIN notification ON letter.id_notification = notification.id_notification
	WHERE adress.id_adress = 5 AND notification.title = 'Ivite' AND YEAR(arrival_date) = '2020';
	 --  4. FULL OUTER JOIN ���� ������
	SELECT * FROM adress FULL OUTER JOIN post ON adress.id_post = post.id_post;


-- 10. ����������
	--  1. �������� ������ � WHERE IN (���������)
	SELECT * FROM letter WHERE id_letter IN (
		SELECT id_letter FROM notification
		WHERE title = 'JKX')
	--  2. �������� ������ SELECT atr1, atr2, (���������) FROM ...    
	SELECT id_post, 
		   post_index, 
		  (SELECT name FROM adress WHERE post.id_post = adress.id_post) AS adress_relation
	FROM post;
