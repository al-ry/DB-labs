-- 1. �������� ������� �����.
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

--2. ������ ���������� � �������� ��������� �������, ����������� � �������
--��������� ����� �� 1 ������ 2019�

SELECT client.id_client, client.name, client.phone FROM client
INNER JOIN booking ON client.id_client = booking.id_client
INNER JOIN room_in_booking ON booking.id_booking = room_in_booking.id_booking
INNER JOIN room ON room.id_room = room_in_booking.id_room
INNER JOIN hotel ON hotel.id_hotel = room.id_hotel
INNER JOIN room_category ON room_category.id_room_category = room.id_room_category
WHERE 
	hotel.name = N'������' AND
	room_category.name = N'����' AND
	room_in_booking.checkin_date <= '2019-04-01' AND '2019-04-01' <= room_in_booking.checkout_date;

--3. ���� ������ ��������� ������� ���� �������� �� 22 ������.
SELECT * FROM room
WHERE id_room NOT IN (
	SELECT id_room FROM room_in_booking
	WHERE room_in_booking.checkin_date <= '2019-04-22' AND '2019-04-22' <= room_in_booking.checkout_date);

SELECT * FROM room
WHERE NOT EXISTS (
	SELECT * FROM room_in_booking
	WHERE (room_in_booking.checkin_date <= '2019-04-22' AND '2019-04-22' <= room_in_booking.checkout_date) AND
	room.id_room = room_in_booking.id_room);


-- 4. ���� ���������� ����������� � ��������� "������" �� 23 ����� �� ������ ��������� �������	
SELECT COUNT(client.id_client) AS amount, room_category.name FROM client
INNER JOIN booking ON client.id_client = booking.id_client
INNER JOIN room_in_booking ON booking.id_booking = room_in_booking.id_booking
INNER JOIN room ON room.id_room = room_in_booking.id_room
INNER JOIN hotel ON hotel.id_hotel = room.id_hotel
INNER JOIN room_category ON room_category.id_room_category = room.id_room_category
WHERE 
	hotel.name = N'������' AND
	room_in_booking.checkin_date <= '2019-03-23' AND '2019-03-23' <= room_in_booking.checkout_date
GROUP BY room_category.name

--5. ���� ������ ��������� ����������� �������� �� ���� �������� ���������
--�������, ��������� � ������ � ��������� ���� ������. 

SELECT client.name, room_in_booking.checkout_date, room.id_room  FROM client
INNER JOIN booking ON client.id_client = booking.id_client
INNER JOIN room_in_booking ON booking.id_booking = room_in_booking.id_booking
INNER JOIN room ON room.id_room = room_in_booking.id_room
INNER JOIN hotel ON hotel.id_hotel = room.id_hotel
INNER JOIN room_category ON room_category.id_room_category = room.id_room_category
WHERE 
	hotel.name = N'������' AND
	room_in_booking.checkout_date >= '2019-04-01' AND '2019-05-01' > room_in_booking.checkout_date

--6. �������� �� 2 ��� ���� ���������� � ��������� ������� ���� ��������
--������ ��������� �������, ������� ���������� 10 ���.
CREATE NONCLUSTERED INDEX [IX_room_id_room_category] ON room
(
	id_hotel ASC,
	id_room_category ASC
)
(
	id_room ASC,
	id_booking ASC
)
(
	checkin_date ASC,
	checkout_date ASC
)
(
	id_client ASC
)
