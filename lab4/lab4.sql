USE hotels

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
LEFT JOIN (--Получаю комнаты занятые на 22 число
			SELECT * 
			FROM room_in_booking
			WHERE room_in_booking.checkin_date <= '2019-04-22' AND '2019-04-22' <= room_in_booking.checkout_date
			) AS booked_rooms
--соединяю по условию через LEFT JOIN и получаю свободные(те, которые имеют значение NULL) и занятые
ON room.id_room = booked_rooms.id_room
WHERE booked_rooms.id_room IS NULL

-- 4. Дать количество проживающих в гостинице "Космос" на 23 марта по каждой категории номеров
SELECT COUNT(room_category.id_room_category) AS is_living_amount, room_category.id_room_category FROM room_category
INNER JOIN room ON room.id_room_category = room_category.id_room_category
INNER JOIN hotel ON hotel.id_hotel = room.id_hotel
INNER JOIN room_in_booking ON room.id_room = room_in_booking.id_room
WHERE 
	hotel.name = N'Космос' AND
	room_in_booking.checkin_date <= '2019-03-23' AND '2019-03-23' <= room_in_booking.checkout_date
GROUP BY room_category.id_room_category;

--5. Дать список последних проживавших клиентов по всем комнатам гостиницы “Космос”, 
--   выехавшиx в апреле с указанием даты выезда.

SELECT client.name, room.id_room FROM client
INNER JOIN booking ON client.id_client = booking.id_client
INNER JOIN room_in_booking ON booking.id_booking = room_in_booking.id_booking
INNER JOIN room ON room.id_room = room_in_booking.id_room
INNER JOIN hotel ON hotel.id_hotel = room.id_hotel AND 	hotel.name = N'Космос' 
INNER JOIN (SELECT booked_in_april.id_room, MAX(booked_in_april.checkout_date) AS last_checkout
	FROM (--извлекаю комнаты забронированные в апреле
			SELECT * FROM room_in_booking WHERE checkout_date >= '2019-04-01' AND checkout_date < '2019-05-01'
			) AS booked_in_april
	--извлекаю макс по дату по каждой комнате
	GROUP BY booked_in_april.id_room) AS room_in_booking2 ON room_in_booking2.id_room = room_in_booking.id_room
WHERE room_in_booking2.last_checkout = room_in_booking.checkout_date

--6. Продлить на 2 дня дату проживания в гостинице “Космос” всем клиентам
--комнат категории “Бизнес”, которые заселились 10 мая.
BEGIN TRANSACTION

UPDATE room_in_booking
SET checkout_date = DATEADD(day, 2, checkout_date)
FROM room 
INNER JOIN room_in_booking ON room_in_booking.id_room = room.id_room
INNER JOIN hotel ON hotel.id_hotel = room.id_hotel
INNER JOIN room_category ON room_category.id_room_category = room.id_room_category
WHERE 
	hotel.name = N'Космос' AND room_category.name = N'Бизнес' AND
	room_in_booking.checkin_date = '2019-03-10';

ROLLBACK
--7. Найти все "пересекающиеся" варианты проживания.

SELECT * FROM room_in_booking AS col1
INNER JOIN room_in_booking AS col2 ON col1.id_room = col2.id_room
WHERE (
	(col1.id_room_in_booking != col2.id_room_in_booking) AND
	(col1.checkin_date <= col2.checkin_date AND col1.checkout_date > col2.checkin_date))

--8. Создать бронирование в транзакции
BEGIN TRANSACTION 

INSERT INTO client VALUES('Ivanov Ivan Ivanovich', '7(902)227-63-22');

INSERT INTO booking VALUES(SCOPE_IDENTITY(), '2020-04-25');

INSERT INTO room_in_booking (id_booking, id_room, checkin_date, checkout_date)
VALUES (SCOPE_IDENTITY(), 26, '2020-05-01','2020-05-12');

ROLLBACK;


--9. Добавить необходимые индексы для всех таблиц.
CREATE UNIQUE NONCLUSTERED INDEX [IU_client_phone] ON client
(
	phone ASC
)

DROP INDEX [IU_client_phone] ON client;

CREATE NONCLUSTERED INDEX [IX_room_id_room_category] ON room
(
	id_hotel ASC,
	id_room_category ASC
)

CREATE NONCLUSTERED INDEX [IX_room_id_booking_id_booking-id_room] ON room_in_booking
(
	id_room ASC,
	id_booking ASC
)

CREATE NONCLUSTERED INDEX [IX_room_checkin_date-checkout_date] ON room_in_booking
(
	checkin_date ASC,
	checkout_date ASC
)

DROP INDEX [IX_room_checkin_date-checkout_date] ON room_in_booking;

CREATE NONCLUSTERED INDEX [IX_booking_id_client] ON booking
(
	id_client ASC
)

CREATE NONCLUSTERED INDEX [IX_hotel_name] ON hotel
(
	name ASC
)

CREATE NONCLUSTERED INDEX [IX_room_category_name] ON room_category
(
	name ASC
)

CREATE NONCLUSTERED INDEX [IX_room_in_booking_id_booking] ON room_in_booking
(
	id_booking ASC
)

CREATE NONCLUSTERED INDEX [IX_room_in_booking_checkout_date] ON room_in_booking
(
	checkout_date ASC
)

CREATE NONCLUSTERED INDEX [IX_room_in_booking_id_room] ON room_in_booking
(
	id_room ASC
)
INCLUDE([checkout_date])

