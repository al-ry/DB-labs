USE pharmacy;
--1. Добавить внешние ключи.

ALTER TABLE  dealer
ADD FOREIGN KEY (id_company) REFERENCES company(id_company);

ALTER TABLE production 
ADD FOREIGN KEY (id_company) REFERENCES company(id_company);

ALTER TABLE production 
ADD FOREIGN KEY (id_medicine) REFERENCES medicine(id_medicine);

ALTER TABLE [dbo].[order] 
ADD FOREIGN KEY (id_production) REFERENCES production(id_production);

ALTER TABLE [dbo].[order]
ADD FOREIGN KEY (id_dealer) REFERENCES dealer(id_dealer);

ALTER TABLE [dbo].[order] 
ADD FOREIGN KEY (id_pharmacy) REFERENCES pharmacy(id_pharmacy);

--2.Выдать информацию по всем заказам лекарства “Кордерон” компании “Аргус” с 
--  указанием названий аптек, дат, объема заказов.

SELECT pharmacy.name, [order].[date], quantity
FROM [order]
INNER JOIN pharmacy ON  [order].id_pharmacy = [pharmacy].id_pharmacy
INNER JOIN production ON production.id_production = [order].id_production
INNER JOIN company ON production.id_company = company.id_company
INNER JOIN medicine ON medicine.id_medicine = production.id_medicine
WHERE medicine.name = N'Кордерон' AND company.name = N'Аргус';

--3.Дать список лекарств компании “Фарма”, на которые не были сделаны заказ до 25 января

SELECT medicine.id_medicine, medicine.name
FROM medicine
WHERE medicine.name NOT IN 
(
	SELECT medicine.name FROM production
	INNER JOIN [order] ON [order].id_production = production.id_production AND [order].date <= '2019-01-25'
	INNER JOIN medicine ON medicine.id_medicine = production.id_medicine
	INNER JOIN company ON company.id_company = production.id_company AND company.name = N'Фарма'
) ORDER BY medicine.id_medicine;


--4.Дать минимальный и максимальный баллы лекарств каждой фирмы, которая оформила не менее 120 заказов.
SELECT company.name, MAX(rating) AS max_rating, MIN(rating) AS min_rating FROM production
INNER JOIN [order] ON [order].id_production = production.id_production
INNER JOIN company ON company.id_company = production.id_company
GROUP BY company.id_company, company.name
HAVING COUNT([order].id_order) >= 120;

--5.Дать списки сделавших заказы аптек по всем дилерам компании “AstraZeneca”.
--  Если у дилера нет заказов, в названии аптеки проставить NULL.
SELECT dealer.name, pharmacy.name FROM pharmacy
LEFT JOIN [order] ON [order].id_pharmacy = pharmacy.id_pharmacy
LEFT JOIN dealer ON dealer.id_dealer = [order].id_dealer
LEFT JOIN company ON company.id_company = dealer.id_company
WHERE company.name = N'AstraZeneca'

--6.Уменьшить на 20% стоимость всех лекарств, если она превышает 3000, а длительность лечения не более 7 дней.

BEGIN TRANSACTION

UPDATE production
SET production.price *=  0.8
WHERE production.id_medicine IN (
	SELECT id_medicine FROM medicine
	WHERE (production.price > 3000 AND medicine.cure_duration <= 7)
)
ROLLBACK;

--7.Добавить необходимые индексы.

CREATE NONCLUSTERED INDEX [IX_production_id_production] ON production
(
	id_company ASC
)

CREATE NONCLUSTERED INDEX [IX_production_id_medicine] ON production
(
	id_medicine ASC
)

CREATE NONCLUSTERED INDEX [IX_production_rating] ON production
(
	rating ASC
)

CREATE NONCLUSTERED INDEX [IX_order_id_pharmacy] ON [order]
(
	id_pharmacy ASC
)

CREATE NONCLUSTERED INDEX [IX_order_id_dealer] ON [order]
(
	id_dealer ASC
)

CREATE NONCLUSTERED INDEX [IX_order_id_production] ON [order]
(
	id_production ASC
)

CREATE NONCLUSTERED INDEX [IX_order_date] ON [order]
(
	date ASC
)

CREATE NONCLUSTERED INDEX [IX_dealer_id_company] ON dealer
(
	id_company ASC
)

CREATE NONCLUSTERED INDEX [IX_medicine_name] ON medicine
(
	name ASC
)

CREATE NONCLUSTERED INDEX [IX_company_name] ON company
(
	name ASC
)
