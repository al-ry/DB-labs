USE [university]

--1. Добавить внешние ключи.
ALTER TABLE student
ADD FOREIGN KEY (id_group) REFERENCES [group](id_group);

ALTER TABLE lesson
ADD FOREIGN KEY (id_group) REFERENCES [group](id_group);

ALTER TABLE lesson
ADD FOREIGN KEY (id_teacher) REFERENCES [teacher](id_teacher);

ALTER TABLE lesson
ADD FOREIGN KEY (id_subject) REFERENCES [subject](id_subject);

ALTER TABLE mark
ADD FOREIGN KEY (id_lesson) REFERENCES [lesson](id_lesson);

ALTER TABLE mark
ADD FOREIGN KEY (id_student) REFERENCES [student](id_student)

--2. Выдать оценки студентов по информатике если они обучаются данному предмету.
--   Оформить выдачу данных с использованием view.
 
CREATE VIEW cs_marks AS 
SELECT student.name, mark.mark AS cs_mark
FROM mark
INNER JOIN student ON mark.id_student = student.id_student
INNER JOIN lesson ON lesson.id_lesson = mark.id_lesson
INNER JOIN subject ON subject.id_subject = lesson.id_subject
WHERE subject.name = N'Информатика'

SELECT * FROM cs_marks;

--3. Дать информацию о должниках с указанием фамилии студента и названия предмета.
--Должниками считаются студенты, не имеющие оценки по предмету, который ведется в группе.
--Оформить в виде процедуры, на входе идентификатор группы.

CREATE PROCEDURE get_students_debts
@id_group AS INT
AS 
	SELECT student.name, subject.name 
	FROM student 
	LEFT JOIN [group] ON [group].id_group = student.id_group
	LEFT JOIN lesson ON lesson.id_group = [group].id_group
	LEFT JOIN subject ON subject.id_subject = lesson.id_subject
	LEFT JOIN mark ON lesson.id_lesson = mark.id_lesson AND mark.id_student = student.id_student
	WHERE [group].id_group = @id_group
	GROUP BY student.name, subject.name 
	HAVING COUNT(mark.mark) = 0
	ORDER BY student.name
GO

EXECUTE get_students_debts @id_group = 1;


--4. Дать среднюю оценку студентов по каждому предмету для тех предметов,
--по которым занимается не менее 35 студентов

SELECT subject.name, AVG(mark.mark) AS avg_mark
FROM mark
INNER JOIN student ON student.id_student = mark.id_student
INNER JOIN lesson ON lesson.id_lesson = mark.id_lesson
INNER JOIN subject ON lesson.id_subject = subject.id_subject
GROUP BY subject.name
HAVING COUNT(student.id_student) >= 35

--Дать оценки студентов специальности ВМ по всем проводимым предметам с указанием группы,
--фамилии, предмета, даты. При отсутствии оценки заполнить значениями NULL поля оценки

SELECT student.name, [group].name, subject.name, lesson.date, mark.mark
FROM student 
LEFT JOIN [group] ON student.id_group = [group].id_group
LEFT JOIN lesson ON lesson.id_group = [group].id_group
LEFT JOIN subject ON subject.id_subject = lesson.id_subject
LEFT JOIN mark ON mark.id_lesson = lesson.id_lesson AND mark.id_student = student.id_student
WHERE [group].name = N'ВМ'
ORDER BY student.name;


--6. Всем студентам специальности ПС, получившим оценки меньшие 5 по предмету
-- БД до 12.05, повысить эти оценки на 1 балл.

BEGIN TRANSACTION 

UPDATE mark
SET mark += 1 
FROM mark
INNER JOIN lesson ON lesson.id_lesson = mark.id_lesson
INNER JOIN [group] ON [group].id_group = lesson.id_group
INNER JOIN subject ON subject.id_subject = lesson.id_subject
WHERE (subject.name = N'БД' AND lesson.date < '2019-05-12' AND mark.mark < 5 AND [group].name = N'ПС')

ROLLBACK

--7. Добавить необходимые индексы.

CREATE NONCLUSTERED INDEX [IX_lesson_id_lesson] ON lesson
(
	id_lesson ASC
)

CREATE NONCLUSTERED INDEX [IX_lesson_id_group] ON lesson
(
	id_group ASC
)

CREATE NONCLUSTERED INDEX [IX_lesson_id_subject] ON lesson
(
	id_subject ASC
)
CREATE NONCLUSTERED INDEX [IX_lesson_date] ON lesson
(
	date ASC
)

CREATE NONCLUSTERED INDEX [IX_mark_id_lesson] ON mark
(
	id_lesson ASC
)

CREATE NONCLUSTERED INDEX [IX_mark_id_student] ON mark
(
	id_student ASC
)

CREATE NONCLUSTERED INDEX [IX_mark_mark] ON mark
(
	mark ASC
)

CREATE NONCLUSTERED INDEX [IX_subject_name] ON subject
(
	name ASC
)


CREATE NONCLUSTERED INDEX [IX_group_name] ON [group]
(
	name ASC
)

CREATE UNIQUE NONCLUSTERED INDEX [IU_teacher_phone] ON [teacher]
(
	phone ASC
)

CREATE UNIQUE NONCLUSTERED INDEX [IU_student_phone] ON [student]
(
	phone ASC
)

CREATE NONCLUSTERED INDEX [IX_student_id_group] ON [student]
(
	phone ASC
)