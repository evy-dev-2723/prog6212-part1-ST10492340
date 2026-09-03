USE master;
GO

IF EXISTS (SELECT name FROM sys.databases WHERE name = N'RaceDay')
BEGIN
    ALTER DATABASE RaceDay SET SINGLE_USER WITH ROLLBACK IMMEDIATE;
    DROP DATABASE RaceDay;
END
GO

CREATE DATABASE RaceDay;
GO

USE RaceDay;
GO

CREATE TABLE Roles (
    RoleID INT IDENTITY(1,1) PRIMARY KEY,
    RoleName NVARCHAR(50) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL
);
GO
    

CREATE TABLE Users (
    UserID INT IDENTITY(1,1) PRIMARY KEY,
    Email NVARCHAR(255) NOT NULL UNIQUE,
    PasswordHash NVARCHAR(255) NOT NULL,
    FirstName NVARCHAR(100) NOT NULL,
    LastName NVARCHAR(100) NOT NULL,
    DateOfBirth DATE NOT NULL,
    ProfileImageURL NVARCHAR(500) NULL,
    RoleID INT NOT NULL,
    CONSTRAINT FK_Users_Roles FOREIGN KEY (RoleID) REFERENCES Roles(RoleID)
);
GO


    CREATE TABLE Events (
    EventID INT IDENTITY(1,1) PRIMARY KEY,
    OrganiserID INT NOT NULL,
    EventName NVARCHAR(200) NOT NULL,
    Description NVARCHAR(1000) NULL,
    EventDate DATETIME2 NOT NULL,
    Location NVARCHAR(200) NOT NULL,
    Venue NVARCHAR(200) NULL,
    DistanceKm DECIMAL(8,2) NOT NULL,
    RouteMapURL NVARCHAR(500) NULL,
    IsActive BIT DEFAULT 1,
    CONSTRAINT FK_Events_Users FOREIGN KEY (OrganiserID) REFERENCES Users(UserID)
);
GO

CREATE TABLE Categories (
    CategoryID INT IDENTITY(1,1) PRIMARY KEY,
    CategoryName NVARCHAR(100) NOT NULL UNIQUE,
    Description NVARCHAR(255) NULL,
    DefaultDistance DECIMAL(8,2) NOT NULL
);
GO

CREATE TABLE EventCategories (
    EventCategoryID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    CategoryID INT NOT NULL,
    EntryFee DECIMAL(10,2) NOT NULL DEFAULT 0,
    MaxParticipants INT NOT NULL DEFAULT 100,
    CurrentParticipants INT NOT NULL DEFAULT 0,
    CONSTRAINT FK_EventCategories_Events FOREIGN KEY (EventID) REFERENCES Events(EventID),
    CONSTRAINT FK_EventCategories_Categories FOREIGN KEY (CategoryID) REFERENCES Categories(CategoryID)
);
GO

CREATE TABLE Enrolments (
    EnrolmentID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    ParticipantID INT NOT NULL,
    EventCategoryID INT NOT NULL,
    EnrolmentDate DATETIME2 DEFAULT GETUTCDATE(),
    Status NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    PaymentStatus NVARCHAR(50) NOT NULL DEFAULT 'Pending',
    BibNumber INT NULL,
    CONSTRAINT FK_Enrolments_Events FOREIGN KEY (EventID) REFERENCES Events(EventID),
    CONSTRAINT FK_Enrolments_Users FOREIGN KEY (ParticipantID) REFERENCES Users(UserID),
    CONSTRAINT FK_Enrolments_EventCategories FOREIGN KEY (EventCategoryID) REFERENCES EventCategories(EventCategoryID)
);
GO

CREATE TABLE Results (
    ResultID INT IDENTITY(1,1) PRIMARY KEY,
    EnrolmentID INT NOT NULL,
    FinishTime TIME NOT NULL,
    Position INT NULL,
    OverallRank INT NULL,
    CategoryRank INT NULL,
    PacePerKm DECIMAL(6,2) NULL,
    Verified BIT DEFAULT 0,
    CONSTRAINT FK_Results_Enrolments FOREIGN KEY (EnrolmentID) REFERENCES Enrolments(EnrolmentID)
);
GO

CREATE TABLE WeatherInfo (
    WeatherID INT IDENTITY(1,1) PRIMARY KEY,
    EventID INT NOT NULL,
    ForecastDate DATE NOT NULL,
    Temperature DECIMAL(4,1) NULL,
    Conditions NVARCHAR(100) NULL,
    Humidity INT NULL,
    WindSpeed DECIMAL(5,2) NULL,
    Precipitation DECIMAL(5,2) NULL,
    CONSTRAINT FK_WeatherInfo_Events FOREIGN KEY (EventID) REFERENCES Events(EventID)
);
GO

INSERT INTO Roles (RoleName, Description) VALUES
('Organiser', 'Event organiser'),
('Participant', 'Event participant');
GO

INSERT INTO Users (Email, PasswordHash, FirstName, LastName, DateOfBirth, RoleID) VALUES
('john@raceday.co.za', 'hash123', 'John', 'Smith', '1985-03-15', 1),
('sarah@raceday.co.za', 'hash456', 'Sarah', 'Johnson', '1990-07-22', 1),
('mike@email.com', 'hash789', 'Mike', 'Brown', '1995-11-10', 2),
('emily@email.com', 'hash012', 'Emily', 'Davis', '1988-09-05', 2),
('david@email.com', 'hash345', 'David', 'Wilson', '2000-01-20', 2);
GO

INSERT INTO Categories (CategoryName, Description, DefaultDistance) VALUES
('5km Fun Run', 'Fun run for all ages', 5.00),
('10km Challenge', 'Challenging 10km race', 10.00),
('Half Marathon', '21.1km race', 21.10),
('Marathon', '42.2km race', 42.20),
('Relay Team', 'Team relay event', 10.00),
('Kids Race', '1km race for children', 1.00);
GO

INSERT INTO Events (OrganiserID, EventName, Description, EventDate, Location, Venue, DistanceKm, IsActive)
VALUES
(1, 'Comrades Marathon', '87km race', '2026-06-15 05:30:00', 'Pietermaritzburg', 'City Hall', 87.00, 1),
(1, 'Durban City Run', '10km run in Durban', '2026-07-20 07:00:00', 'Durban', 'City Hall', 10.00, 1),
(2, 'Soweto Marathon', 'Race through Soweto', '2026-11-15 06:00:00', 'Soweto', 'FNB Stadium', 42.20, 1);
GO

INSERT INTO EventCategories (EventID, CategoryID, EntryFee, MaxParticipants) VALUES
(1, 3, 850.00, 15000),
(1, 4, 1200.00, 10000),
(1, 5, 2000.00, 500),
(2, 2, 150.00, 5000),
(2, 1, 100.00, 2000),
(2, 6, 50.00, 500),
(3, 3, 500.00, 8000),
(3, 4, 750.00, 5000);
GO

INSERT INTO Enrolments (EventID, ParticipantID, EventCategoryID, Status, PaymentStatus, BibNumber)
VALUES
(1, 3, 2, 'Confirmed', 'Paid', 1001),
(1, 4, 1, 'Confirmed', 'Paid', 1002),
(2, 3, 4, 'Confirmed', 'Paid', 2001),
(2, 5, 5, 'Pending', 'Pending', NULL),
(3, 4, 7, 'Confirmed', 'Paid', 3001);
GO

INSERT INTO Results (EnrolmentID, FinishTime, Position, OverallRank, CategoryRank, PacePerKm, Verified)
VALUES
(1, '04:15:30', 150, 150, 45, 5.22, 1),
(2, '05:22:10', 500, 500, 120, 6.45, 1),
(3, '00:58:45', 25, 25, 10, 5.88, 1),
(5, '03:45:20', 200, 200, 30, 5.33, 1);
GO

INSERT INTO WeatherInfo (EventID, ForecastDate, Temperature, Conditions, Humidity, WindSpeed, Precipitation)
VALUES
(1, '2026-06-15', 18.5, 'Partly Cloudy', 65, 12.5, 0),
(2, '2026-07-20', 22.0, 'Sunny', 60, 8.0, 0),
(3, '2026-11-15', 25.0, 'Sunny', 50, 15.0, 0);
GO

SELECT 'Roles' AS TableName, COUNT(*) AS Count FROM Roles
UNION ALL
SELECT 'Users', COUNT(*) FROM Users
UNION ALL
SELECT 'Events', COUNT(*) FROM Events
UNION ALL
SELECT 'Categories', COUNT(*) FROM Categories
UNION ALL
SELECT 'EventCategories', COUNT(*) FROM EventCategories
UNION ALL
SELECT 'Enrolments', COUNT(*) FROM Enrolments
UNION ALL
SELECT 'Results', COUNT(*) FROM Results
UNION ALL
SELECT 'WeatherInfo', COUNT(*) FROM WeatherInfo;
GO
