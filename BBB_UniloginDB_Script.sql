USE Master
GO
IF DB_ID('BBBDB_UNILOGIN') IS NOT NULL
	BEGIN
		ALTER DATABASE BBBDB_UNILOGIN SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
		DROP DATABASE BBBDB_UNILOGIN
	END
GO
CREATE DATABASE BBBDB_UNILOGIN
GO
USE BBBDB_UNILOGIN
GO

--DROP TABLE IF EXISTS [Vaskeri]
--Vaskerier skal have navn og åbningstider (åben / luk) (brug Time som datatype).
CREATE TABLE [Vaskeri] (
  [Vaskeri_ID] INT PRIMARY KEY IDENTITY (1,1) NOT NULL,
  [VaskeriNavn] VARCHAR(255),
  [Åbner] Time,
  [Lukker] Time
);

--DROP TABLE IF EXISTS [Bruger]
--Brugere skal have navn, e-mail (skal være unik), password (skal være længere end 5 karakterer), konto (decimal), et vaskeri samt dato for oprettelse.

CREATE TABLE [Bruger] (
  [Bruger_ID] INT PRIMARY KEY IDENTITY (1,1),
  [Navn] VARCHAR(255),
  [Email] VARCHAR(255) UNIQUE,
  [Password] VARCHAR(255),
  [Konto] Decimal(8,2),
  [Vaskeri] INT NOT NULL,
  [Oprettet] Date,
  CONSTRAINT [FK_Bruger.Vaskeri] FOREIGN KEY ([Vaskeri]) REFERENCES [Vaskeri]([Vaskeri_ID]),
  CONSTRAINT [Password_Length] CHECK (LEN([Password]) >= 5)
);


--DROP TABLE IF EXISTS [Maskine]
--Maskiner skal have navn, pris pr. vask (decimal), hvor mange minutter en vask tager og id på vaskeri den står.
CREATE TABLE [Maskine] (
  [Maskine_ID] INT PRIMARY KEY IDENTITY (1,1),
  [MaskineNavn] VARCHAR(255),
  [PrisPrVask] Decimal(8,2),
  [Vasketid] VARCHAR(255),
  [Vaskeri] INT NOT NULL,
  CONSTRAINT [FK_Maskine.Vaskeri] FOREIGN KEY ([Vaskeri]) REFERENCES [Vaskeri]([Vaskeri_ID])
);

--DROP TABLE IF EXISTS [Booking]
--Bookinger skal have en dato og tidspunkt (Datetime) for bestilling, id på bruger der har booket og id  på maskinen der er booket tid på.
CREATE TABLE [Bookning] (
  [Booking_ID] INT PRIMARY KEY IDENTITY (1,1),
  [Tidspunkt] Datetime,
  [Bruger_ID] INT NOT NULL,
  [Maskine_ID] INT NOT NULL,

  	CONSTRAINT [FK_Bookning.Bruger_ID] FOREIGN KEY ([Bruger_ID]) REFERENCES [Bruger]([Bruger_ID]),
	CONSTRAINT [FK_Bookning.Maskine_ID] FOREIGN KEY ([Maskine_ID]) REFERENCES [Maskine]([Maskine_ID])
);


INSERT INTO Vaskeri VALUES ('Whitewash Inc.', '08:00', '20:00')
INSERT INTO Vaskeri VALUES ('Double Bubble', '02:00', '22:00')
INSERT INTO Vaskeri VALUES ('Wash & Coffee', '12:00', '20:00')

SELECT * FROM Vaskeri


INSERT INTO Bruger VALUES ('John', 'john_doe66@gmail.com', 'password', 100, 2, '2021-02-15')
INSERT INTO Bruger VALUES ('Neil Armstrong', 'firstman@nasa.gov', 'eagleLander69', 1000, 1, '2021-02-10')
INSERT INTO Bruger VALUES ('Batman', 'noreply@thecave.com', 'Rob1n', 500, 3, '2020-03-10')
INSERT INTO Bruger VALUES ('Goldman Sachs', 'moneylaundering@gs.com', 'NotRecognized', 100000, 1, '2021-01-01')
INSERT INTO Bruger VALUES ('50 Cent', '50cent@gmail.com', 'ItsMyBirthday', 0.50, 3, '2020-07-06')

SELECT * FROM Bruger

INSERT INTO Maskine VALUES ('Mielle 911 Turbo',5,60,2)
INSERT INTO Maskine VALUES ('Siemons IClean',10000,30,1)
INSERT INTO Maskine VALUES ('Electrolax FX-2',15,45,2)
INSERT INTO Maskine VALUES ('NASA Spacewasher 8000',500,5,1)
INSERT INTO Maskine VALUES ('The Lost Sock',3.5,90,3)
INSERT INTO Maskine VALUES ('Yo Mama',0.5,120,3)

SELECT * FROM Maskine

INSERT INTO Bookning VALUES ('2021-02-26 12:00:00', 1, 1)
INSERT INTO Bookning VALUES ('2021-02-26 16:00:00', 1, 3)
INSERT INTO Bookning VALUES ('2021-02-26 08:00:00', 2, 4)
INSERT INTO Bookning VALUES ('2021-02-26 15:00:00', 3, 5)
INSERT INTO Bookning VALUES ('2021-02-26 20:00:00', 4, 2)
INSERT INTO Bookning VALUES ('2021-02-26 19:00:00', 4, 2)
INSERT INTO Bookning VALUES ('2021-02-26 10:00:00', 4, 2)
INSERT INTO Bookning VALUES ('2021-02-26 16:00:00', 5, 6)

--Opret en transaktion med en booking for brugeren ’Goldman Sachs’ i dag kl. 12.00 på ’Siemons IClean’ -maskinen. Gennemfør transaktionen.
BEGIN TRAN [Transaction];
INSERT INTO Bookning VALUES ('2022-09-15 12:00:00', 4, 2)
COMMIT TRAN [Transaction];

--Opret et VIEW over bookinger med: tidspunkt for booking, brugernes navn, maskinens navn, pris på maskinens vask.
GO
CREATE VIEW BookningView as
SELECT Bookning.Tidspunkt as [Bookning Tidspunkt], Bruger.Navn as [Bestilt i Navnet], Maskine.MaskineNavn as [Maskines Navn], Maskine.PrisPrVask as [Prisen pr enkelt vask] FROM Bookning
JOIN Bruger ON Bookning.Bruger_ID = Bruger.Bruger_ID
JOIN Maskine ON Bookning.Maskine_ID = Maskine.Maskine_ID
GO

SELECT * FROM BookningView

--En SELECT der udvælger brugere med ’@gmail.com’ e-mails. Hint: Like
SELECT * FROM Bruger 
WHERE Bruger.Email LIKE '%@gmail.com%'

--En SELECT der viser alle maskinerne og vaskeriets detaljer de står i.
SELECT MaskineNavn as [Maskine Navn], PrisPrVask as [Pris pr enkelt vask], Vasketid as [Vasketid i Min.], Vaskeri.VaskeriNavn as [Vaskeri Maskinen står i], Vaskeri.Åbner as [Åbningstid for vaskeri], Vaskeri.Lukker as [Lukketid for vaskeri] FROM Maskine
JOIN Vaskeri ON Maskine.Vaskeri = Vaskeri.Vaskeri_ID

--En SELECT der udvælger hvor mange bookinger der er pr. maskine. Hint: Count + Group By
SELECT Maskine.MaskineNavn, COUNT(Booking_ID) as [Antal gange brugte] FROM Bookning
JOIN Maskine ON Bookning.Maskine_ID = Maskine.Maskine_ID
GROUP BY MaskineNavn

--En DELETE der sletter alle bookinger mellem kl. 12.00 - 13.00Hint: Cast as Time + Between
DELETE FROM Bookning WHERE CAST(Tidspunkt as Time) BETWEEN '12:00' AND '13:00'

--En UPDATE der ændrer Batmans password til ’SelinaKyle’.
UPDATE Bruger
SET [Password] = 'SelinaKyle'
WHERE [Email] = 'noreply@thecave.com'
AND [Password] = 'Rob1n';


