-- Create database
IF DB_ID('RaceDay_DB') IS NULL
BEGIN
    CREATE DATABASE RaceDay_DB;
END;
GO

USE RaceDay_DB;
GO

/* ============================================================
   ACCOUNT
   Stores the common account information for users.
   ============================================================ */

CREATE TABLE dbo.Account
(
    AccountID INT IDENTITY(1,1) NOT NULL,
    FirstName NVARCHAR(50) NOT NULL,
    LastName NVARCHAR(50) NOT NULL,
    Email NVARCHAR(255) NOT NULL,
    PasswordHash NVARCHAR(255) NOT NULL,
    Role NVARCHAR(20) NOT NULL,
    DateCreated DATETIME2 NOT NULL
        CONSTRAINT DF_Account_DateCreated DEFAULT SYSDATETIME(),

    CONSTRAINT PK_Account
        PRIMARY KEY (AccountID),

    CONSTRAINT UQ_Account_Email
        UNIQUE (Email),

    CONSTRAINT CK_Account_Role
        CHECK (Role IN ('Organiser', 'Participant'))
);
GO

/* ============================================================
   ORGANISER
   An organiser is an account that creates and manages events.
   ============================================================ */

CREATE TABLE dbo.Organiser
(
    OrganiserID INT IDENTITY(1,1) NOT NULL,
    AccountID INT NOT NULL,
    ContactEmail NVARCHAR(255) NOT NULL,
    PhoneNumber NVARCHAR(20) NOT NULL,
    Organisation NVARCHAR(150) NOT NULL,

    CONSTRAINT PK_Organiser
        PRIMARY KEY (OrganiserID),

    CONSTRAINT UQ_Organiser_AccountID
        UNIQUE (AccountID),

    CONSTRAINT FK_Organiser_Account
        FOREIGN KEY (AccountID)
        REFERENCES dbo.Account(AccountID)
);
GO

/* ============================================================
   PARTICIPANT
   A participant is an account that can enrol in events.
   ============================================================ */

CREATE TABLE dbo.Participant
(
    ParticipantID INT IDENTITY(1,1) NOT NULL,
    AccountID INT NOT NULL,
    DateOfBirth DATE NOT NULL,
    EmergencyContact NVARCHAR(100) NOT NULL,

    CONSTRAINT PK_Participant
        PRIMARY KEY (ParticipantID),

    CONSTRAINT UQ_Participant_AccountID
        UNIQUE (AccountID),

    CONSTRAINT FK_Participant_Account
        FOREIGN KEY (AccountID)
        REFERENCES dbo.Account(AccountID)
);
GO

/* ============================================================
   EVENT TYPE
   Examples: Road Running, Walking, Cycling.
   ============================================================ */

CREATE TABLE dbo.EventType
(
    EventTypeID INT IDENTITY(1,1) NOT NULL,
    TypeName NVARCHAR(50) NOT NULL,
    Description NVARCHAR(255) NOT NULL,

    CONSTRAINT PK_EventType
        PRIMARY KEY (EventTypeID),

    CONSTRAINT UQ_EventType_TypeName
        UNIQUE (TypeName)
);
GO

/* ============================================================
   EVENT
   An event belongs to one organiser and one event type.
   ============================================================ */

CREATE TABLE dbo.Event
(
    EventID INT IDENTITY(1,1) NOT NULL,
    OrganiserID INT NOT NULL,
    EventTypeID INT NOT NULL,
    EventName NVARCHAR(150) NOT NULL,
    EventDate DATE NOT NULL,
    Location NVARCHAR(200) NOT NULL,
    Description NVARCHAR(500) NOT NULL,

    CONSTRAINT PK_Event
        PRIMARY KEY (EventID),

    CONSTRAINT FK_Event_Organiser
        FOREIGN KEY (OrganiserID)
        REFERENCES dbo.Organiser(OrganiserID),

    CONSTRAINT FK_Event_EventType
        FOREIGN KEY (EventTypeID)
        REFERENCES dbo.EventType(EventTypeID)
);
GO

/* ============================================================
   EVENT CATEGORY
   Categories belong to a particular event.
   Examples: 5km, 10km, Half Marathon.
   ============================================================ */

CREATE TABLE dbo.EventCategory
(
    EventCategoryID INT IDENTITY(1,1) NOT NULL,
    EventID INT NOT NULL,
    CategoryName NVARCHAR(100) NOT NULL,
    Distance DECIMAL(6,2) NOT NULL,
    EntryFee DECIMAL(10,2) NOT NULL,
    StartTime TIME NOT NULL,
    MaximumParticipants INT NOT NULL,

    CONSTRAINT PK_EventCategory
        PRIMARY KEY (EventCategoryID),

    CONSTRAINT FK_EventCategory_Event
        FOREIGN KEY (EventID)
        REFERENCES dbo.Event(EventID),

    CONSTRAINT CK_EventCategory_Distance
        CHECK (Distance > 0),

    CONSTRAINT CK_EventCategory_EntryFee
        CHECK (EntryFee >= 0),

    CONSTRAINT CK_EventCategory_MaxParticipants
        CHECK (MaximumParticipants > 0),

    CONSTRAINT UQ_EventCategory_Event_Name
        UNIQUE (EventID, CategoryName)
);
GO

/* ============================================================
   ROUTE
   Each event can have one or more routes.
   ============================================================ */

CREATE TABLE dbo.Route
(
    RouteID INT IDENTITY(1,1) NOT NULL,
    EventID INT NOT NULL,
    RouteName NVARCHAR(100) NOT NULL,
    Distance DECIMAL(6,2) NOT NULL,
    Description NVARCHAR(500) NOT NULL,
    RouteImage NVARCHAR(500) NULL,

    CONSTRAINT PK_Route
        PRIMARY KEY (RouteID),

    CONSTRAINT FK_Route_Event
        FOREIGN KEY (EventID)
        REFERENCES dbo.Event(EventID),

    CONSTRAINT CK_Route_Distance
        CHECK (Distance > 0)
);
GO

/* ============================================================
   ENROLMENT
   One participant makes one enrolment into an event.
   Multiple categories can then be selected through
   EnrolmentCategory.
   ============================================================ */

CREATE TABLE dbo.Enrolment
(
    EnrolmentID INT IDENTITY(1,1) NOT NULL,
    ParticipantID INT NOT NULL,
    EventID INT NOT NULL,
    EnrolmentDate DATETIME2 NOT NULL
        CONSTRAINT DF_Enrolment_EnrolmentDate DEFAULT SYSDATETIME(),
    PaymentStatus NVARCHAR(20) NOT NULL,
    RaceNumber INT NULL,

    CONSTRAINT PK_Enrolment
        PRIMARY KEY (EnrolmentID),

    CONSTRAINT FK_Enrolment_Participant
        FOREIGN KEY (ParticipantID)
        REFERENCES dbo.Participant(ParticipantID),

    CONSTRAINT FK_Enrolment_Event
        FOREIGN KEY (EventID)
        REFERENCES dbo.Event(EventID),

    CONSTRAINT CK_Enrolment_PaymentStatus
        CHECK (PaymentStatus IN ('Pending', 'Paid', 'Cancelled')),

    CONSTRAINT CK_Enrolment_RaceNumber
        CHECK (RaceNumber IS NULL OR RaceNumber > 0),

    CONSTRAINT UQ_Enrolment_Participant_Event
        UNIQUE (ParticipantID, EventID)
);
GO

/* ============================================================
   ENROLMENT CATEGORY
   Resolves the many-to-many relationship between Enrolment
   and EventCategory.

   This allows ONE enrolment to contain MULTIPLE categories.
   ============================================================ */

CREATE TABLE dbo.EnrolmentCategory
(
    EnrolmentCategoryID INT IDENTITY(1,1) NOT NULL,
    EnrolmentID INT NOT NULL,
    EventCategoryID INT NOT NULL,

    CONSTRAINT PK_EnrolmentCategory
        PRIMARY KEY (EnrolmentCategoryID),

    CONSTRAINT FK_EnrolmentCategory_Enrolment
        FOREIGN KEY (EnrolmentID)
        REFERENCES dbo.Enrolment(EnrolmentID),

    CONSTRAINT FK_EnrolmentCategory_EventCategory
        FOREIGN KEY (EventCategoryID)
        REFERENCES dbo.EventCategory(EventCategoryID),

    CONSTRAINT UQ_EnrolmentCategory
        UNIQUE (EnrolmentID, EventCategoryID)
);
GO

/* ============================================================
   RESULT
   A participant receives a result for an entered category.
   ============================================================ */

CREATE TABLE dbo.Result
(
    ResultID INT IDENTITY(1,1) NOT NULL,
    EnrolmentCategoryID INT NOT NULL,
    FinishTime TIME NULL,
    Position INT NULL,
    ResultStatus NVARCHAR(20) NOT NULL,

    CONSTRAINT PK_Result
        PRIMARY KEY (ResultID),

    CONSTRAINT FK_Result_EnrolmentCategory
        FOREIGN KEY (EnrolmentCategoryID)
        REFERENCES dbo.EnrolmentCategory(EnrolmentCategoryID),

    CONSTRAINT UQ_Result_EnrolmentCategory
        UNIQUE (EnrolmentCategoryID),

    CONSTRAINT CK_Result_Position
        CHECK (Position IS NULL OR Position > 0),

    CONSTRAINT CK_Result_Status
        CHECK (ResultStatus IN ('Finished', 'Did Not Finish', 'Disqualified'))
);
GO

/* ============================================================
   SAMPLE DATA
   ============================================================ */

/* ------------------------------------------------------------
   ACCOUNTS
   ------------------------------------------------------------ */

INSERT INTO dbo.Account
    (FirstName, LastName, Email, PasswordHash, Role)
VALUES
    ('Sarah', 'Naidoo', 'sarah.naidoo@example.com',
     'HASHED_PASSWORD_001', 'Organiser'),

    ('Michael', 'van der Merwe', 'michael.vdm@example.com',
     'HASHED_PASSWORD_002', 'Organiser'),

    ('Liam', 'Pillay', 'liam.pillay@example.com',
     'HASHED_PASSWORD_003', 'Participant'),

    ('Emma', 'Botha', 'emma.botha@example.com',
     'HASHED_PASSWORD_004', 'Participant');
GO

/* ------------------------------------------------------------
   ORGANISERS
   ------------------------------------------------------------ */

INSERT INTO dbo.Organiser
    (AccountID, ContactEmail, PhoneNumber, Organisation)
VALUES
    (1, 'events@durbanrunners.co.za', '0315550101',
     'Durban Runners Association'),

    (2, 'info@kznactive.co.za', '0315550102',
     'KZN Active Events');
GO

/* ------------------------------------------------------------
   PARTICIPANTS
   ------------------------------------------------------------ */

INSERT INTO dbo.Participant
    (AccountID, DateOfBirth, EmergencyContact)
VALUES
    (3, '2001-04-15', 'Thabo Pillay - 0825551001'),

    (4, '1998-09-22', 'Samantha Botha - 0835551002');
GO

/* ------------------------------------------------------------
   EVENT TYPES
   ------------------------------------------------------------ */

INSERT INTO dbo.EventType
    (TypeName, Description)
VALUES
    ('Road Running', 'Competitive and recreational road running events'),

    ('Walking', 'Organised walking events for recreational participants'),

    ('Cycling', 'Road cycling events for recreational and competitive cyclists');
GO

/* ------------------------------------------------------------
   EVENTS
   ------------------------------------------------------------ */

INSERT INTO dbo.Event
    (OrganiserID, EventTypeID, EventName, EventDate, Location, Description)
VALUES
    (1, 1,
     'Durban Summer Run',
     '2026-10-18',
     'Durban, KwaZulu-Natal',
     'Annual road running event along the Durban beachfront.'),

    (1, 2,
     'Umhlanga Charity Walk',
     '2026-11-08',
     'Umhlanga, KwaZulu-Natal',
     'Community walking event supporting local charities.'),

    (2, 3,
     'KZN Coastal Cycle Challenge',
     '2026-11-22',
     'Ballito, KwaZulu-Natal',
     'Road cycling challenge along the KwaZulu-Natal coastline.');
GO

/* ------------------------------------------------------------
   EVENT CATEGORIES
   Event 1 - Durban Summer Run
   ------------------------------------------------------------ */

INSERT INTO dbo.EventCategory
    (EventID, CategoryName, Distance, EntryFee, StartTime, MaximumParticipants)
VALUES
    (1, '5km Fun Run', 5.00, 80.00, '07:00', 1000),

    (1, '10km Road Race', 10.00, 150.00, '06:30', 1500),

    (1, 'Half Marathon', 21.10, 250.00, '06:00', 1000);

/* Event 2 - Umhlanga Charity Walk */

INSERT INTO dbo.EventCategory
    (EventID, CategoryName, Distance, EntryFee, StartTime, MaximumParticipants)
VALUES
    (2, '5km Charity Walk', 5.00, 60.00, '08:00', 800),

    (2, '10km Charity Walk', 10.00, 90.00, '07:30', 600);

/* Event 3 - KZN Coastal Cycle Challenge */

INSERT INTO dbo.EventCategory
    (EventID, CategoryName, Distance, EntryFee, StartTime, MaximumParticipants)
VALUES
    (3, '40km Cycle', 40.00, 200.00, '06:30', 500),

    (3, '80km Cycle', 80.00, 300.00, '06:00', 400),

    (3, '120km Cycle Challenge', 120.00, 450.00, '05:30', 250);
GO

/* ------------------------------------------------------------
   ROUTES
   ------------------------------------------------------------ */

INSERT INTO dbo.Route
    (EventID, RouteName, Distance, Description, RouteImage)
VALUES
    (1, 'Durban Beachfront Route', 10.00,
     'Route starting at the beachfront and continuing through central Durban.',
     'durban-beachfront-route.jpg'),

    (1, 'Durban Half Marathon Route', 21.10,
     'Extended beachfront and city route for the half marathon.',
     'durban-half-marathon-route.jpg'),

    (2, 'Umhlanga Promenade Route', 5.00,
     'Scenic walking route along the Umhlanga promenade.',
     'umhlanga-promenade-route.jpg'),

    (3, 'Coastal Cycle Route', 80.00,
     'Coastal cycling route between Ballito and surrounding areas.',
     'kzn-coastal-cycle-route.jpg');
GO

/* ------------------------------------------------------------
   ENROLMENTS
   Each participant enrols ONCE per event and can select
   multiple event categories through EnrolmentCategory.
   ------------------------------------------------------------ */

INSERT INTO dbo.Enrolment
    (ParticipantID, EventID, PaymentStatus, RaceNumber)
VALUES
    (1, 1, 'Paid', 101),

    (2, 1, 'Paid', 102),

    (1, 2, 'Pending', NULL),

    (2, 3, 'Paid', 301);
GO

/* ------------------------------------------------------------
   ENROLMENT CATEGORIES
   Participant 1 entered both the 5km and 10km categories
   for Event 1 using ONE enrolment.

   Participant 2 entered the Half Marathon for Event 1.

   Participant 1 entered the 5km Charity Walk.

   Participant 2 entered the 80km Cycle.
   ------------------------------------------------------------ */

INSERT INTO dbo.EnrolmentCategory
    (EnrolmentID, EventCategoryID)
VALUES
    (1, 1), -- Liam: Durban Summer Run - 5km
    (1, 2), -- Liam: Durban Summer Run - 10km
    (2, 3), -- Emma: Durban Summer Run - Half Marathon
    (3, 4), -- Liam: Umhlanga Charity Walk - 5km
    (4, 7); -- Emma: KZN Coastal Cycle Challenge - 80km
GO

/* ------------------------------------------------------------
   RESULTS
   Results are associated with individual categories entered.
   ------------------------------------------------------------ */

INSERT INTO dbo.Result
    (EnrolmentCategoryID, FinishTime, Position, ResultStatus)
VALUES
    (1, '00:27:42', 18, 'Finished'),

    (2, '00:58:31', 25, 'Finished'),

    (3, '01:52:14', 12, 'Finished');
GO

/* ============================================================
   VERIFICATION QUERIES
   These can be run in SSMS to verify the seeded database.
   ============================================================ */

-- View accounts
SELECT * FROM dbo.Account;

-- View organisers
SELECT * FROM dbo.Organiser;

-- View participants
SELECT * FROM dbo.Participant;

-- View event types
SELECT * FROM dbo.EventType;

-- View events
SELECT * FROM dbo.Event;

-- View categories
SELECT * FROM dbo.EventCategory;

-- View routes
SELECT * FROM dbo.Route;

-- View enrolments and selected categories
SELECT
    e.EnrolmentID,
    a.FirstName + ' ' + a.LastName AS Participant,
    ev.EventName,
    ec.CategoryName,
    e.PaymentStatus,
    e.RaceNumber
FROM dbo.Enrolment e
INNER JOIN dbo.Participant p
    ON e.ParticipantID = p.ParticipantID
INNER JOIN dbo.Account a
    ON p.AccountID = a.AccountID
INNER JOIN dbo.Event ev
    ON e.EventID = ev.EventID
INNER JOIN dbo.EnrolmentCategory enc
    ON e.EnrolmentID = enc.EnrolmentID
INNER JOIN dbo.EventCategory ec
    ON enc.EventCategoryID = ec.EventCategoryID
ORDER BY e.EnrolmentID;

-- View results
SELECT
    r.ResultID,
    a.FirstName + ' ' + a.LastName AS Participant,
    ev.EventName,
    ec.CategoryName,
    r.FinishTime,
    r.Position,
    r.ResultStatus
FROM dbo.Result r
INNER JOIN dbo.EnrolmentCategory enc
    ON r.EnrolmentCategoryID = enc.EnrolmentCategoryID
INNER JOIN dbo.Enrolment e
    ON enc.EnrolmentID = e.EnrolmentID
INNER JOIN dbo.Participant p
    ON e.ParticipantID = p.ParticipantID
INNER JOIN dbo.Account a
    ON p.AccountID = a.AccountID
INNER JOIN dbo.EventCategory ec
    ON enc.EventCategoryID = ec.EventCategoryID
INNER JOIN dbo.Event ev
    ON ec.EventID = ev.EventID
ORDER BY r.ResultID;
GO

/*Drops tables (for testing)*/

IF OBJECT_ID('dbo.Result', 'U') IS NOT NULL DROP TABLE dbo.Result;
IF OBJECT_ID('dbo.EnrolmentCategory', 'U') IS NOT NULL DROP TABLE dbo.EnrolmentCategory;
IF OBJECT_ID('dbo.Enrolment', 'U') IS NOT NULL DROP TABLE dbo.Enrolment;
IF OBJECT_ID('dbo.Route', 'U') IS NOT NULL DROP TABLE dbo.Route;
IF OBJECT_ID('dbo.EventCategory', 'U') IS NOT NULL DROP TABLE dbo.EventCategory;
IF OBJECT_ID('dbo.Event', 'U') IS NOT NULL DROP TABLE dbo.Event;
IF OBJECT_ID('dbo.EventType', 'U') IS NOT NULL DROP TABLE dbo.EventType;
IF OBJECT_ID('dbo.Participant', 'U') IS NOT NULL DROP TABLE dbo.Participant;
IF OBJECT_ID('dbo.Organiser', 'U') IS NOT NULL DROP TABLE dbo.Organiser;
IF OBJECT_ID('dbo.Account', 'U') IS NOT NULL DROP TABLE dbo.Account;
GO