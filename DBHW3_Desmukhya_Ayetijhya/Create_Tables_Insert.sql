use groups_dwh;
/* Let us assume we need to frequently analyse the data of the groups. */

/* First let us recreate the table of:
Dimension Tables:
1. Courses 
2. Teachers (combined with Employees, some attributes),
3. Rooms
Fact Table:
1. Groups_Facts (a combination of data from Groups and Classes) */

CREATE TABLE Courses(
	[CourseID] [varchar](10) NOT NULL,
	[CourseName] [varchar](50) NOT NULL,
	-- to simplify the scenario, we will not include DepartmentID
	-- in reality the table (and foreign key) would be used
	--[DepartmentID] [varchar](10) NOT NULL,
	[CourseYear] [int] NOT NULL,
	[CourseSem] [int] NOT NULL,
	[isElective] [bit] NOT NULL,
	[MinStudents] [int] NOT NULL,
	[MaxStudents] [int] NULL,
	[CourseType] [varchar](20) NOT NULL,
    CONSTRAINT PK_Course PRIMARY KEY (CourseID),
	--CONSTRAINT FK_Courses_Departments FOREIGN KEY(DepartmentID) REFERENCES Departments(DepartmentID),
);

CREATE TABLE Teachers(
	-- let us remove IDENTITY setting, as the data will be imported with existing PK values
	[TeacherID] [int] NOT NULL, --IDENTITY(3000,1),
	[EmployeeID] [varchar](10) NOT NULL,
	[TeacherRole] [varchar](50) NULL,
	--adding some teacher details from Employees, changing the attribute names,e.g: EmployeeName -> TeacherName
	[DepartmentID] [varchar](10) NOT NULL,
	[TeacherName] [varchar](50) NOT NULL,
	[TeacherAddress] [varchar](50) NOT NULL,
	[TeacherEmail] [varchar](30) NOT NULL,
	[TeacherPhoneNumber] [varchar](20) NOT NULL,
	CONSTRAINT PK_Teachers PRIMARY KEY (EmployeeID),
	--CONSTRAINT FK_Teachers_Employees FOREIGN KEY(EmployeeID) REFERENCES Employees(EmployeeID),
);

CREATE TABLE Rooms(
	[RoomID] [int] NOT NULL,
	[DepartmentID] [varchar](10) NOT NULL,
	[RoomType] [varchar](10) NOT NULL,
    CONSTRAINT PK_Rooms PRIMARY KEY(RoomID,DepartmentID),
    --CONSTRAINT FK_Rooms_Departments FOREIGN KEY(DepartmentID) REFERENCES Departments(DepartmentID)
);

CREATE TABLE Groups_Facts(
	-- let us remove IDENTITY setting, as the data will be imported with existing PK values
	[GroupID] [int] NOT NULL, --IDENTITY(7000,1),
	[CourseID] [varchar](10) NOT NULL,
	[EmployeeID] [varchar](10) NOT NULL,
	[GroupNumber] [int] NOT NULL,
	--and now let us add the columns from Classes
	[DepartmentID] [varchar](10) NOT NULL,
	[RoomID] [int] NOT NULL,
	[ClassDay] [varchar](15) NOT NULL,
	[TimeFrom] [time](0) NOT NULL,
	[TimeTo] [time](0) NOT NULL,
	[TotalHours] [decimal](3,2) NOT NULL,
	CONSTRAINT PK_Classes PRIMARY KEY (GroupID),
	CONSTRAINT FK_Classes_Roooms FOREIGN KEY(RoomID,DepartmentID) REFERENCES Rooms(RoomID,DepartmentID),
	CONSTRAINT FK_Groups_Courses FOREIGN KEY(CourseID) REFERENCES Courses(CourseID),
	CONSTRAINT FK_Groups_Teachers FOREIGN KEY(EmployeeID) REFERENCES Teachers(EmployeeID)
);

--INSERT Statements

--Courses
insert into Courses select CourseID,CourseName,CourseYear,
				CourseSem,isElective,MinStudents,
				MaxStudents,CourseType from UniversityDatabase.dbo.Courses

--Teacher
insert into Teachers select TeacherID,t.EmployeeID,TeacherRole,
					 e.DepartmentID,EmployeeName,EmployeeAddress,EmployeeEmail,
						EmployeePhoneNumber from UniversityDatabase.dbo.Teachers t
inner join UniversityDatabase.dbo.Employees e on e.EmployeeID =  t.EmployeeID;

--Rooms
insert into Rooms select * from UniversityDatabase.dbo.Rooms;

--Groups_Facts
insert into Groups_Facts select g.GroupID,CourseID,g.EmployeeID,
						GroupNumber,c.DepartmentID,c.RoomID,
						ClassDay,TimeFrom,TimeTo,
						TotalHours from UniversityDatabase.dbo.Groups g
inner join UniversityDatabase.dbo.Classes c on c.GroupID=g.GroupID;