-- 1. Добавить внешние ключи.
ALTER TABLE room 
ADD FOREIGN KEY (id_hotel) REFERENCES hotel (id_hotel);

ALTER TABLE room 
ADD FOREIGN KEY (id_room_category) REFERENCES room_category (id_room_category);

ALTER TABLE booking
ADD FOREIGN KEY (id_client) REFERENCES client(id_client);

ALTER TABLE room_in_booking
ADD FOREIGN KEY (id_booking) REFERENCES booking(id_booking);

ALTER TABLE room_in_booking
ADD FOREIGN KEY (id_room) REFERENCES room(id_room);

--2. Выдать информацию о клиентах гостиницы “Космос”, проживающих в номерах
--категории “Люкс” на 1 апреля 2019г

SELECT client.id_client, client.name, client.phone FROM client
INNER JOIN booking ON client.id_client = booking.id_client
INNER JOIN room_in_booking ON booking.id_booking = room_in_booking.id_booking
INNER JOIN room ON room.id_room = room_in_booking.id_room
INNER JOIN hotel ON hotel.id_hotel = room.id_hotel
INNER JOIN room_category ON room_category.id_room_category = room.id_room_category
WHERE 
	hotel.name = N'Космос' AND
	room_category.name = N'Люкс' AND
	room_in_booking.checkin_date <= '2019-04-01' AND '2019-04-01' <= room_in_booking.checkout_date;

--3. Дать список свободных номеров всех гостиниц на 22 апреля.
SELECT * FROM room
WHERE NOT EXISTS (
	SELECT * FROM room_in_booking
	WHERE (room_in_booking.checkin_date <= '2019-04-22' AND '2019-04-22' <= room_in_booking.checkout_date) AND
	room.id_room = room_in_booking.id_room);


-- 4. Дать количество проживающих в гостинице "Космос" на 23 марта по каждой категории номеров
SELECT COUNT(room_category.id_room_category) AS is_living_amount, room_category.name FROM room_category
INNER JOIN room ON room.id_room_category = room_category.id_room_category
INNER JOIN hotel ON hotel.id_hotel = room.id_hotel
INNER JOIN room_in_booking ON room.id_room = room_in_booking.id_room
WHERE 
	hotel.name = N'Космос' AND
	room_in_booking.checkin_date <= '2019-03-23' AND '2019-03-23' <= room_in_booking.checkout_date
GROUP BY room_category.name;

--5. Дать список последних проживавших клиентов по всем комнатам гостиницы “Космос”, 
--   выехавшиx в апреле с указанием даты выезда.

SELECT client.name, room_in_booking.checkout_date, room.id_room  FROM client
INNER JOIN booking ON client.id_client = booking.id_client
INNER JOIN room_in_booking ON booking.id_booking = room_in_booking.id_booking
INNER JOIN room ON room.id_room = room_in_booking.id_room
INNER JOIN hotel ON hotel.id_hotel = room.id_hotel
INNER JOIN room_category ON room_category.id_room_category = room.id_room_category
WHERE 
	hotel.name = N'Космос' AND
	room_in_booking.checkout_date >= '2019-04-01' AND '2019-05-01' > room_in_booking.checkout_date;

--6. Продлить на 2 дня дату проживания в гостинице “Космос” всем клиентам
--комнат категории “Бизнес”, которые заселились 10 мая.

UPDATE room_in_booking
SET checkout_date = DATEADD(day, 2, checkout_date)
FROM room 
INNER JOIN room_in_booking ON room_in_booking.id_room = room.id_room
INNER JOIN hotel ON hotel.id_hotel = room.id_hotel
INNER JOIN room_category ON room_category.id_room_category = room.id_room_category
WHERE 
	hotel.name = N'Космос' AND room_category.name = N'Бизнес' AND
	room_in_booking.checkin_date = '2019-03-10';

--7. Найти все "пересекающиеся" варианты проживания.

SELECT * FROM room_in_booking AS col1
INNER JOIN room_in_booking AS col2 ON col1.id_room = col2.id_room
WHERE (
	(col1.id_room_in_booking != col2.id_room_in_booking) AND
	(col1.checkin_date <= col2.checkin_date AND col1.checkout_date > col2.checkin_date))


--8. Создать бронирование в транзакции
BEGIN TRANSACTION 

INSERT INTO client VALUES('Ivanov Ivan Ivanovich', '7(902)227-13-22');

INSERT INTO booking VALUES(
	(SELECT id_client FROM client WHERE name = 'Ivanov Ivan Ivanovich' AND phone = '7(902)227-13-22'), '2020-04-25');

INSERT INTO room_in_booking (id_booking, id_room, checkin_date, checkout_date)  VALUES (
	(SELECT MAX(booking.id_booking) FROM booking), 26, '2020-05-01','2020-05-12');
COMMIT;


--9. Добавить необходимые индексы для всех таблиц.
CREATE UNIQUE NONCLUSTERED INDEX [UI_client_phone] ON client
(
	phone ASC
)

CREATE NONCLUSTERED INDEX [IX_room_id_room_category] ON room
(
	id_hotel ASC,
	id_room_category ASC
)

CREATE NONCLUSTERED INDEX [IX_room_id_dooking-id_category] ON room_in_booking
(
	id_room ASC,
	id_booking ASC
)

CREATE NONCLUSTERED INDEX [IX_room_checkin_date-checkout_date] ON room_in_booking
(
	checkin_date ASC,
	checkout_date ASC
)

CREATE NONCLUSTERED INDEX [IX_booking_id_client] ON booking
(
	id_client ASC
)

CREATE NONCLUSTERED INDEX [IX_hotel_name] ON hotel
(
	name ASC
)

CREATE NONCLUSTERED INDEX [IX_hotel_name] ON room_category
(
	name ASC
)
CREATE NONCLUSTERED INDEX [IX_room_in_booking_id-booking] ON room_in_booking
(
	id_booking ASC
)



