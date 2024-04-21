CREATE DATABASE IF NOT EXISTS jail;

USE jail;

SELECT "Creating tables..." AS message;

CREATE TABLE Criminals (
    Criminal_ID INT AUTO_INCREMENT,
    Last VARCHAR(15),
    First VARCHAR(10),
    Street VARCHAR(30),
    City VARCHAR(20),
    State CHAR(2),
    Zip CHAR(5),
    Phone CHAR(10),
    V_status CHAR(1) DEFAULT 'N',
    P_status CHAR(1) DEFAULT 'N',
    PRIMARY KEY(Criminal_ID)
);
ALTER TABLE Criminals AUTO_INCREMENT = 100000;

CREATE TABLE Aliases (
    Alias_ID INT AUTO_INCREMENT,
    Criminal_ID INT,
    Alias VARCHAR(20),
    PRIMARY KEY(Alias_ID),
    FOREIGN KEY(Criminal_ID) REFERENCES Criminals(Criminal_ID)
);
ALTER TABLE Aliases AUTO_INCREMENT = 100000;

CREATE TABLE Crimes (
    Crime_ID INT AUTO_INCREMENT,
    Criminal_ID INT,
    Classification CHAR(1) DEFAULT 'U',
    Date_charged DATE,
    Status CHAR(2) NOT NULL,
    Hearing_date DATE,
    Appeal_cut_date DATE,
    PRIMARY KEY(Crime_ID),
    FOREIGN KEY(Criminal_ID) REFERENCES Criminals(Criminal_ID),
    CHECK (Hearing_date > Date_charged)
);
ALTER TABLE Crimes AUTO_INCREMENT = 100000000;

CREATE TABLE Prob_officers (
    Prob_ID INT AUTO_INCREMENT,
    Last VARCHAR(15),
    First VARCHAR(10),
    Street VARCHAR(30),
    City VARCHAR(20),
    State CHAR(2),
    Zip CHAR(5),
    Phone CHAR(10),
    Email VARCHAR(30),
    Status CHAR(1) NOT NULL,
    PRIMARY KEY(Prob_ID)
);
ALTER TABLE Prob_officers AUTO_INCREMENT = 10000;

CREATE TABLE Sentences (
    Sentence_ID INT AUTO_INCREMENT,
    Criminal_ID INT,
    Type CHAR(1),
    Prob_ID INT,
    Start_date DATE,
    End_date DATE,
    Violations DECIMAL(3) NOT NULL,
    PRIMARY KEY(Sentence_ID),
    FOREIGN KEY(Criminal_ID) REFERENCES Criminals(Criminal_ID),
    FOREIGN KEY(Prob_ID) REFERENCES Prob_officers(Prob_ID),
    CHECK (End_date > Start_date)
);
ALTER TABLE Sentences AUTO_INCREMENT = 100000;

CREATE TABLE Crime_codes (
    Crime_code DECIMAL(3) NOT NULL,
    Code_description VARCHAR(30) NOT NULL UNIQUE,
    PRIMARY KEY(Crime_code)
);

CREATE TABLE Crime_charges (
    Charge_ID BIGINT AUTO_INCREMENT,
    Crime_ID INT,
    Crime_code DECIMAL(3),
    Charge_status CHAR(2),
    Fine_amount DECIMAL(7,2),
    Court_fee DECIMAL(7,2),
    Amount_paid DECIMAL(7,2),
    Pay_due_date DATE,
    PRIMARY KEY(Charge_ID),
    FOREIGN KEY(Crime_ID) REFERENCES Crimes(Crime_ID),
    FOREIGN KEY(Crime_code) REFERENCES Crime_codes(Crime_code)
);
ALTER TABLE Crime_charges AUTO_INCREMENT = 1000000000;

CREATE TABLE Officers (
    Officer_ID INT AUTO_INCREMENT,
    Last VARCHAR(15),
    First VARCHAR(10),
    Precinct CHAR(4) NOT NULL,
    Badge VARCHAR(14) UNIQUE,
    Phone CHAR(10),
    Status CHAR(1) DEFAULT 'A',
    PRIMARY KEY(Officer_ID)
);
ALTER TABLE Officers AUTO_INCREMENT = 10000000;

CREATE TABLE Crime_officers (
    Crime_ID INT,
    Officer_ID INT,
    PRIMARY KEY(Crime_ID, Officer_ID),
    FOREIGN KEY(Crime_ID) REFERENCES Crimes(Crime_ID),
    FOREIGN KEY(Officer_ID) REFERENCES Officers(Officer_ID)
);

CREATE TABLE Appeals (
    Appeal_ID INT AUTO_INCREMENT,
    Crime_ID INT,
    Filling_date DATE,
    Hearing_date DATE,
    Status CHAR(1) DEFAULT 'P',
    PRIMARY KEY(Appeal_ID),
    FOREIGN KEY(Crime_ID) REFERENCES Crimes(Crime_ID)
);
ALTER TABLE Appeals AUTO_INCREMENT = 10000;

CREATE TABLE Users (
    User_ID INT AUTO_INCREMENT,
    Email VARCHAR(30) NOT NULL UNIQUE,
    Passwd VARCHAR(100) NOT NULL,
    Status CHAR(1) DEFAULT 'V',
    PRIMARY KEY(User_ID)
);
ALTER TABLE Users AUTO_INCREMENT = 100000;

SELECT "Inserting data with INSERT..." AS message;

INSERT INTO Criminals (Criminal_ID, Last, First, Street, City, State, Zip, Phone, V_status, P_status) VALUES
(100001, 'Smith', 'John', '123 Elm St', 'Springfield', 'IL', '62704', '2175550123', 'Y', 'N'),
(100002, 'Johnson', 'Jane', '456 Oak St', 'Decatur', 'IL', '62521', '2175550145', 'N', 'Y'),
(100003, 'Williams', 'James', '789 Pine St', 'Chicago', 'IL', '60607', '3125550198', 'Y', 'N'),
(100004, 'Brown', 'Linda', '101 Maple St', 'Aurora', 'IL', '60506', '6305550133', 'N', 'Y'),
(100005, 'Jones', 'Robert', '202 Birch St', 'Naperville', 'IL', '60540', '6305550110', 'Y', 'N'),
(100006, 'Garcia', 'Maria', '303 Cedar St', 'Peoria', 'IL', '61602', '3095550155', 'N', 'Y'),
(100007, 'Miller', 'Michael', '404 Spruce St', 'Elgin', 'IL', '60120', '8475550187', 'Y', 'N'),
(100008, 'Davis', 'Susan', '505 Aspen St', 'Rockford', 'IL', '61101', '8155550122', 'N', 'Y'),
(100009, 'Rodriguez', 'Jose', '606 Fir St', 'Joliet', 'IL', '60431', '8155550144', 'Y', 'N'),
(100010, 'Martinez', 'Angela', '707 Elm St', 'Springfield', 'IL', '62704', '2175550166', 'N', 'Y');

INSERT INTO Aliases (Alias_ID, Criminal_ID, Alias) VALUES
(200001, 100001, 'Johnny'),
(200002, 100002, 'JJ'),
(200003, 100003, 'Jimbo'),
(200004, 100004, 'Lindy'),
(200005, 100005, 'Bobby'),
(200006, 100006, 'Ria'),
(200007, 100007, 'Mike'),
(200008, 100008, 'Sue'),
(200009, 100009, 'Pepe'),
(200010, 100010, 'Angie');

INSERT INTO Crimes (Crime_ID, Criminal_ID, Classification, Date_charged, Status, Hearing_date, Appeal_cut_date) VALUES
(300000001, 100001, 'F', '2023-01-10', 'CL', '2023-02-20', '2023-03-20'),
(300000002, 100002, 'M', '2023-01-12', 'CA', '2023-02-22', '2023-03-22'),
(300000003, 100003, 'O', '2023-01-14', 'IA', '2023-02-24', '2023-03-24'),
(300000004, 100004, 'U', '2023-01-16', 'CL', '2023-02-26', '2023-03-26'),
(300000005, 100005, 'F', '2023-01-18', 'CA', '2023-02-28', '2023-03-28'),
(300000006, 100006, 'M', '2023-01-20', 'IA', '2023-03-02', '2023-04-02'),
(300000007, 100007, 'O', '2023-01-22', 'CL', '2023-03-04', '2023-04-04'),
(300000008, 100008, 'U', '2023-01-24', 'CA', '2023-03-06', '2023-04-06'),
(300000009, 100009, 'F', '2023-01-26', 'IA', '2023-03-08', '2023-04-08'),
(300000010, 100010, 'M', '2023-01-28', 'CL', '2023-03-10', '2023-04-10');

INSERT INTO Prob_officers (Prob_ID, Last, First, Street, City, State, Zip, Phone, Email, Status) VALUES
(40001, 'Anderson', 'Bill', '111 A St', 'Springfield', 'IL', '62701', '2175550200', 'banderson@example.com', 'A'),
(40002, 'Thompson', 'Karen', '222 B St', 'Decatur', 'IL', '62522', '2175550220', 'kthompson@example.com', 'I'),
(40003, 'Jackson', 'Steve', '333 C St', 'Chicago', 'IL', '60601', '3125550240', 'sjackson@example.com', 'A'),
(40004, 'White', 'Nancy', '444 D St', 'Aurora', 'IL', '60505', '6305550260', 'nwhite@example.com', 'I'),
(40005, 'Harris', 'Laura', '555 E St', 'Naperville', 'IL', '60565', '6305550280', 'lharris@example.com', 'A'),
(40006, 'Martin', 'Gary', '666 F St', 'Peoria', 'IL', '61601', '3095550300', 'gmartin@example.com', 'I'),
(40007, 'Clark', 'Diane', '777 G St', 'Elgin', 'IL', '60123', '8475550320', 'dclark@example.com', 'A'),
(40008, 'Lewis', 'Frank', '888 H St', 'Rockford', 'IL', '61107', '8155550340', 'flewis@example.com', 'I'),
(40009, 'Walker', 'Julie', '999 I St', 'Joliet', 'IL', '60435', '8155550360', 'jwalker@example.com', 'A'),
(40010, 'Allen', 'Tim', '1010 J St', 'Springfield', 'IL', '62702', '2175550380', 'tallen@example.com', 'I');

INSERT INTO Sentences (Sentence_ID, Criminal_ID, Type, Prob_ID, Start_date, End_date, Violations) VALUES
(500001, 100001, 'J', 40001, '2023-03-01', '2024-03-01', 0),
(500002, 100002, 'H', 40002, '2023-04-01', '2024-04-01', 1),
(500003, 100003, 'P', 40003, '2023-05-01', '2024-05-01', 2),
(500004, 100004, 'J', 40004, '2023-06-01', '2024-06-01', 0),
(500005, 100005, 'H', 40005, '2023-07-01', '2024-07-01', 1),
(500006, 100006, 'P', 40006, '2023-08-01', '2024-08-01', 2),
(500007, 100007, 'J', 40007, '2023-09-01', '2024-09-01', 0),
(500008, 100008, 'H', 40008, '2023-10-01', '2024-10-01', 1),
(500009, 100009, 'P', 40009, '2023-11-01', '2024-11-01', 2),
(500010, 100010, 'J', 40010, '2023-12-01', '2024-12-01', 0);

INSERT INTO Crime_codes (Crime_code, Code_description) VALUES
(101, 'Burglary'),
(102, 'Robbery'),
(103, 'Assault'),
(104, 'Murder'),
(105, 'Theft'),
(106, 'Fraud'),
(107, 'Drug Possession'),
(108, 'Vandalism'),
(109, 'Arson'),
(110, 'Kidnapping');

INSERT INTO Crime_charges (Charge_ID, Crime_ID, Crime_code, Charge_status, Fine_amount, Court_fee, Amount_paid, Pay_due_date) VALUES
(7000000001, 300000001, 101, 'PD', 500.00, 150.00, 650.00, '2023-03-20'),
(7000000002, 300000002, 102, 'GL', 1000.00, 200.00, 1200.00, '2023-03-22'),
(7000000003, 300000003, 103, 'NG', 1500.00, 250.00, 0.00, '2023-03-24'),
(7000000004, 300000004, 104, 'PD', 2000.00, 300.00, 2300.00, '2023-03-26'),
(7000000005, 300000005, 105, 'GL', 2500.00, 350.00, 2850.00, '2023-03-28'),
(7000000006, 300000006, 106, 'NG', 3000.00, 400.00, 0.00, '2023-04-02'),
(7000000007, 300000007, 107, 'PD', 3500.00, 450.00, 3950.00, '2023-04-04'),
(7000000008, 300000008, 108, 'GL', 4000.00, 500.00, 4500.00, '2023-04-06'),
(7000000009, 300000009, 109, 'NG', 4500.00, 550.00, 0.00, '2023-04-08'),
(7000000010, 300000010, 110, 'PD', 5000.00, 600.00, 5600.00, '2023-04-10');

INSERT INTO Officers (Officer_ID, Last, First, Precinct, Badge, Phone, Status) VALUES
(80000001, 'Hart', 'Kevin', '1234', 'BADGE1234', '3125550001', 'A'),
(80000002, 'Black', 'Jack', '5678', 'BADGE5678', '3125550002', 'I'),
(80000003, 'King', 'Regina', '9101', 'BADGE9101', '3125550003', 'A'),
(80000004, 'Smith', 'Will', '1123', 'BADGE1123', '3125550004', 'I'),
(80000005, 'Jones', 'Felicity', '4567', 'BADGE4567', '3125550005', 'A'),
(80000006, 'Brown', 'Chris', '8910', 'BADGE8910', '3125550006', 'I'),
(80000007, 'Davis', 'Viola', '2134', 'BADGE2134', '3125550007', 'A'),
(80000008, 'Wilson', 'Russell', '5679', 'BADGE5679', '3125550008', 'I'),
(80000009, 'Taylor', 'James', '9112', 'BADG9112', '3125550009', 'A'),
(80000010, 'Moore', 'Julianne', '1135', 'BADGE1135', '3125550010', 'I');

INSERT INTO Crime_officers (Crime_ID, Officer_ID) VALUES
(300000001, 80000001),
(300000002, 80000002),
(300000003, 80000003),
(300000004, 80000004),
(300000005, 80000005),
(300000006, 80000006),
(300000007, 80000007),
(300000008, 80000008),
(300000009, 80000009),
(300000010, 80000010);

INSERT INTO Appeals (Appeal_ID, Crime_ID, Filling_date, Hearing_date, Status) VALUES
(90001, 300000001, '2023-03-21', '2023-04-21', 'P'),
(90002, 300000002, '2023-03-23', '2023-04-23', 'A'),
(90003, 300000003, '2023-03-25', '2023-04-25', 'D'),
(90004, 300000004, '2023-03-27', '2023-04-27', 'P'),
(90005, 300000005, '2023-03-29', '2023-04-29', 'A'),
(90006, 300000006, '2023-04-01', '2023-05-01', 'D'),
(90007, 300000007, '2023-04-03', '2023-05-03', 'P'),
(90008, 300000008, '2023-04-05', '2023-05-05', 'A'),
(90009, 300000009, '2023-04-07', '2023-05-07', 'D'),
(90010, 300000010, '2023-04-09', '2023-05-09', 'P');

SELECT "Creating procedures (insertion)..." AS message;

DELIMITER $$
CREATE PROCEDURE insert_criminal(
    IN p_Criminal_ID DECIMAL(6),
    IN p_Last VARCHAR(15),
    IN p_First VARCHAR(10),
    IN p_Street VARCHAR(30),
    IN p_City VARCHAR(20),
    IN p_State CHAR(2),
    IN p_Zip CHAR(5),
    IN p_Phone CHAR(10),
    IN p_V_status CHAR(1),
    IN p_P_status CHAR(1)
)
BEGIN
    INSERT INTO Criminals (
        Criminal_ID,
        Last,
        First,
        Street,
        City,
        State,
        Zip,
        Phone,
        V_status,
        P_status
    ) VALUES (
        p_Criminal_ID,
        p_Last,
        p_First,
        p_Street,
        p_City,
        p_State,
        p_Zip,
        p_Phone,
        IFNULL(p_V_status, 'N'),
        IFNULL(p_P_status, 'N')
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_alias(
    IN p_Criminal_ID DECIMAL(6),
    IN p_Alias VARCHAR(20)
)
BEGIN
    INSERT INTO Aliases (
        Criminal_ID,
        Alias
    ) VALUES (
        p_Criminal_ID,
        p_Alias
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_crime(
    IN p_Criminal_ID DECIMAL(6),
    IN p_Classification CHAR(1),
    IN p_Date_charged DATE,
    IN p_Status CHAR(2),
    IN p_Hearing_date DATE,
    IN p_Appeal_cut_date DATE
)
BEGIN
    INSERT INTO Crimes (
        Criminal_ID,
        Classification,
        Date_charged,
        Status,
        Hearing_date,
        Appeal_cut_date
    ) VALUES (
        p_Criminal_ID,
        IFNULL(p_Classification, 'U'),
        p_Date_charged,
        p_Status,
        p_Hearing_date,
        p_Appeal_cut_date
    );
    IF p_Hearing_date <= p_Date_charged THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Hearing_date must be greater than Date_charged';
    END IF;
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_officer(
    IN p_Last VARCHAR(15),
    IN p_First VARCHAR(10),
    IN p_Precinct CHAR(4),
    IN p_Badge VARCHAR(14),
    IN p_Phone CHAR(10),
    IN p_Status CHAR(1)
)
BEGIN
    INSERT INTO Officers (
        Last,
        First,
        Precinct,
        Badge,
        Phone,
        Status
    ) VALUES (
        p_Last,
        p_First,
        p_Precinct,
        p_Badge,
        p_Phone,
        p_Status
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_prob_officer(
    IN p_Last VARCHAR(15),
    IN p_First VARCHAR(10),
    IN p_Street VARCHAR(30),
    IN p_City VARCHAR(20),
    IN p_State CHAR(2),
    IN p_Zip CHAR(5),
    IN p_Phone CHAR(10),
    IN p_Email VARCHAR(30),
    IN p_Status CHAR(1)
)
BEGIN
    INSERT INTO Prob_officers (
        Last,
        First,
        Street,
        City,
        State,
        Zip,
        Phone,
        Email,
        Status
    ) VALUES (
        p_Last,
        p_First,
        p_Street,
        p_City,
        p_State,
        p_Zip,
        p_Phone,
        p_Email,
        p_Status
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_sentence(
    IN p_Criminal_ID DECIMAL(6),
    IN p_Type CHAR(1),
    IN p_Prob_ID DECIMAL(5),
    IN p_Start_date DATE,
    IN p_End_date DATE,
    IN p_Violations DECIMAL(3)
)
BEGIN
    IF p_End_date <= p_Start_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'End_date must be greater than Start_date';
    ELSE
        INSERT INTO Sentences (
            Criminal_ID,
            Type,
            Prob_ID,
            Start_date,
            End_date,
            Violations
        ) VALUES (
            p_Criminal_ID,
            p_Type,
            p_Prob_ID,
            p_Start_date,
            p_End_date,
            p_Violations
        );
    END IF;
END$$
DELIMITER ;


DELIMITER $$
CREATE PROCEDURE insert_crime_code(
    IN p_Crime_code DECIMAL(3),
    IN p_Code_description VARCHAR(30)
)
BEGIN
    INSERT INTO Crime_codes (
        Crime_code,
        Code_description
    ) VALUES (
        p_Crime_code,
        p_Code_description
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_crime_charge(
    IN p_Crime_ID DECIMAL(9),
    IN p_Crime_code DECIMAL(3),
    IN p_Charge_status CHAR(2),
    IN p_Fine_amount DECIMAL(7,2),
    IN p_Court_fee DECIMAL(7,2),
    IN p_Amount_paid DECIMAL(7,2),
    IN p_Pay_due_date DATE
)
BEGIN
    INSERT INTO Crime_charges (
        Crime_ID,
        Crime_code,
        Charge_status,
        Fine_amount,
        Court_fee,
        Amount_paid,
        Pay_due_date
    ) VALUES (
        p_Crime_ID,
        p_Crime_code,
        p_Charge_status,
        p_Fine_amount,
        p_Court_fee,
        p_Amount_paid,
        p_Pay_due_date
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_officer(
    IN p_Last VARCHAR(15),
    IN p_First VARCHAR(10),
    IN p_Precinct CHAR(4),
    IN p_Badge VARCHAR(14),
    IN p_Phone CHAR(10),
    IN p_Status CHAR(1)
)
BEGIN
    INSERT INTO Officers (
        Last,
        First,
        Precinct,
        Badge,
        Phone,
        Status
    ) VALUES (
        p_Last,
        p_First,
        p_Precinct,
        p_Badge,
        p_Phone,
        p_Status
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_crime_officer(
    IN p_Crime_ID DECIMAL(9),
    IN p_Officer_ID DECIMAL(8)
)
BEGIN
    INSERT INTO Crime_officers (
        Crime_ID,
        Officer_ID
    ) VALUES (
        p_Crime_ID,
        p_Officer_ID
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_appeal_by_crime_id(
    IN p_Crime_ID DECIMAL(9),
    IN p_Filling_date DATE,
    IN p_Hearing_date DATE,
    IN p_Status CHAR(1)
)
BEGIN
    INSERT INTO Appeals (
        Crime_ID,
        Filling_date,
        Hearing_date,
        Status
    ) VALUES (
        p_Crime_ID,
        p_Filling_date,
        p_Hearing_date,
        p_Status
    );
END$$
DELIMITER ;

SELECT "Creating procedures (retrieval)..." AS message;

-- Retrieve: Criminals
-- Retrieve by Criminal_ID
DELIMITER $$
CREATE PROCEDURE get_criminal_by_id(IN p_Criminal_ID DECIMAL(6))
BEGIN
    SELECT * FROM Criminals
    WHERE Criminal_ID = p_Criminal_ID;
END$$
DELIMITER ;

-- Retrieve by First and Last Name
DELIMITER $$
CREATE PROCEDURE get_criminal_by_name(
    IN p_First VARCHAR(10),
    IN p_Last VARCHAR(15)
)
BEGIN
    SELECT * FROM Criminals
    WHERE First = p_First AND Last = p_Last;
END$$
DELIMITER ;

-- Retrieve: Aliases
-- Retrieve by p_Criminal_ID
DELIMITER $$
CREATE PROCEDURE get_aliases_by_criminal_id(
    IN p_Criminal_ID DECIMAL(6)
)
BEGIN
    SELECT Alias FROM Aliases
    WHERE Criminal_ID = p_Criminal_ID;
END$$
DELIMITER ;

-- Retrieve: Crime
-- Retrieve by Crime_ID
DELIMITER $$
CREATE PROCEDURE get_crime_by_id(
    IN p_Crime_ID DECIMAL(9)
)
BEGIN
    SELECT * FROM Crimes
    WHERE Crime_ID = p_Crime_ID;
END$$
DELIMITER ;

-- Retrieve by Criminal_ID
DELIMITER $$
CREATE PROCEDURE get_crimes_by_criminal_id(
    IN p_Criminal_ID DECIMAL(6)
)
BEGIN
    SELECT * FROM Crimes
    WHERE Criminal_ID = p_Criminal_ID;
END$$
DELIMITER ;

-- Retrieve: Prob_officers
-- Retrieve by Prob_ID
DELIMITER $$
CREATE PROCEDURE get_prob_officer_by_id(IN p_Prob_ID DECIMAL(5))
BEGIN
    SELECT * FROM Prob_officers
    WHERE Prob_ID = p_Prob_ID;
END$$
DELIMITER ;

-- Retrieve by First and Last Name
DELIMITER $$
CREATE PROCEDURE get_prob_officer_by_name(
    IN p_First VARCHAR(10),
    IN p_Last VARCHAR(15)
)
BEGIN
    SELECT * FROM Prob_officers
    WHERE First = p_First AND Last = p_Last;
END$$
DELIMITER ;

-- Retrieve: Sentences
-- Retrieve by Sentence_ID
DELIMITER $$
CREATE PROCEDURE get_sentence_by_id(
    IN p_Sentence_ID DECIMAL(6)
)
BEGIN
    SELECT * FROM Sentences
    WHERE Sentence_ID = p_Sentence_ID;
END$$
DELIMITER ;

-- Retrieve by Criminal_ID
DELIMITER $$
CREATE PROCEDURE get_sentences_by_criminal_id(
    IN p_Criminal_ID DECIMAL(6)
)
BEGIN
    SELECT * FROM Sentences
    WHERE Criminal_ID = p_Criminal_ID;
END$$
DELIMITER ;

-- Retrieve: Crime Code
-- Retrieve by Charge ID
DELIMITER $$
CREATE PROCEDURE get_crime_code_by_charge_id(
    IN p_Charge_ID DECIMAL(10)
)
BEGIN
    SELECT cc.Crime_code, cc.Code_description
    FROM Crime_charges cch
    JOIN Crime_codes cc ON cch.Crime_code = cc.Crime_code
    WHERE cch.Charge_ID = p_Charge_ID;
END$$
DELIMITER ;

-- Retrieve: Crime Charges
-- Retrieve by Charge_ID
DELIMITER $$
CREATE PROCEDURE get_charges_by_id(
    IN p_Charge_ID DECIMAL(10)
)
BEGIN
    SELECT * FROM Crime_charges
    WHERE Charge_ID = p_Charge_ID;
END$$
DELIMITER ;

-- Retrieve by Crime_ID
DELIMITER $$
CREATE PROCEDURE get_charges_by_crime_id(
    IN p_Crime_ID DECIMAL(9)
)
BEGIN
    SELECT * FROM Crime_charges
    WHERE Crime_ID = p_Crime_ID;
END$$
DELIMITER ;

-- Retrieve by Crime_code
DELIMITER $$
CREATE PROCEDURE get_charges_by_crime_code(
    IN p_Crime_code DECIMAL(3)
)
BEGIN
    SELECT * FROM Crime_charges
    WHERE Crime_code = p_Crime_code;
END$$
DELIMITER ;

-- Retrieve: Officers
-- Retrieve by Officer_ID
DELIMITER $$
CREATE PROCEDURE get_officer_by_id(IN p_Officer_ID DECIMAL(8))
BEGIN
    SELECT * FROM Officers
    WHERE Officer_ID = p_Officer_ID;
END$$
DELIMITER ;

-- Retrieve by First and Last Name
DELIMITER $$
CREATE PROCEDURE get_officer_by_name(
    IN p_First VARCHAR(10),
    IN p_Last VARCHAR(15)
)
BEGIN
    SELECT * FROM Officers
    WHERE First = p_First AND Last = p_Last;
END$$
DELIMITER ;

-- Retrieve: Crime_officers
-- Retrieve by Crime_ID
DELIMITER $$
CREATE PROCEDURE get_officers_by_crime_id(
    IN p_Crime_ID DECIMAL(9)
)
BEGIN
    SELECT o.Officer_ID, o.Last, o.First
    FROM Officers o
    JOIN Crime_officers co ON o.Officer_ID = co.Officer_ID
    WHERE co.Crime_ID = p_Crime_ID;
END$$
DELIMITER ;

-- Retrieve by Officer_ID
DELIMITER $$
CREATE PROCEDURE get_crimes_by_officer_id(
    IN p_Officer_ID DECIMAL(8)
)
BEGIN
    SELECT c.Crime_ID, c.Status
    FROM Crimes c
    JOIN Crime_officers co ON c.Crime_ID = co.Crime_ID
    WHERE co.Officer_ID = p_Officer_ID;
END$$
DELIMITER ;

-- Retrieve: Appeals
-- Retrieve by Appeal_ID
DELIMITER $$
CREATE PROCEDURE get_appeal_by_id(
    IN p_Appeal_ID DECIMAL(5)
)
BEGIN
    SELECT * FROM Appeals
    WHERE Appeal_ID = p_Appeal_ID;
END$$
DELIMITER ;

-- Retrieve by Crime_ID
DELIMITER $$
CREATE PROCEDURE get_appeals_by_crime_id(
    IN p_Crime_ID DECIMAL(9)
)
BEGIN
    SELECT * FROM Appeals
    WHERE Crime_ID = p_Crime_ID;
END$$
DELIMITER ;

SELECT "Creating procedures (update)..." AS message;

-- retrieve sentences by prob_officer_id
DELIMITER $$
CREATE PROCEDURE get_sentences_by_prob_officer_id(IN p_Prob_ID INT)
BEGIN
    SELECT s.Sentence_ID, s.Type, s.Start_date, s.End_date, s.Violations, c.Criminal_ID, c.First AS CriminalFirst, c.Last AS CriminalLast
    FROM Sentences s
    JOIN Criminals c ON s.Criminal_ID = c.Criminal_ID
    WHERE s.Prob_ID = p_Prob_ID;
END$$


-- Update Stored Procedures
-- Update Criminal by Criminal_ID
DELIMITER $$
CREATE PROCEDURE update_criminal_by_id(
    IN p_Criminal_ID DECIMAL(6),
    IN p_Last VARCHAR(15),
    IN p_First VARCHAR(10),
    IN p_Street VARCHAR(30),
    IN p_City VARCHAR(20),
    IN p_State CHAR(2),
    IN p_Zip CHAR(5),
    IN p_Phone CHAR(10),
    IN p_V_status CHAR(1),
    IN p_P_status CHAR(1)
)
BEGIN
    UPDATE Criminals
    SET Last = p_Last,
        First = p_First,
        Street = p_Street,
        City = p_City,
        State = p_State,
        Zip = p_Zip,
        Phone = p_Phone,
        V_status = IFNULL(p_V_status, 'N'),
        P_status = IFNULL(p_P_status, 'N')
    WHERE Criminal_ID = p_Criminal_ID;
END$$
DELIMITER ;

-- Update Alias by Alias_ID
DELIMITER $$
CREATE PROCEDURE update_alias_by_id(
    IN p_Alias_ID DECIMAL(6),
    IN p_Alias VARCHAR(20)
)
BEGIN
    UPDATE Aliases
    SET Alias = p_Alias
    WHERE Alias_ID = p_Alias_ID;
END$$
DELIMITER ;

-- Update Crime by Crime_ID
DELIMITER $$
CREATE PROCEDURE update_crime_by_id(
    IN p_Crime_ID DECIMAL(9),
    -- Included but not used for updates; does not make sense to change Criminal_ID of a Crime
    IN p_Criminal_ID DECIMAL(6),
    IN p_Classification CHAR(1),
    IN p_Date_charged DATE,
    IN p_Status CHAR(2),
    IN p_Hearing_date DATE,
    IN p_Appeal_cut_date DATE
)
BEGIN
    IF p_Hearing_date > p_Date_charged THEN
        UPDATE Crimes
        SET Classification = p_Classification,
            Date_charged = p_Date_charged,
            Status = p_Status,
            Hearing_date = p_Hearing_date,
            Appeal_cut_date = p_Appeal_cut_date
        WHERE Crime_ID = p_Crime_ID;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Hearing_date must be greater than Date_charged.';
    END IF;
END$$
DELIMITER ;

-- Update Probation Officer by Prob_ID
DELIMITER $$
CREATE PROCEDURE update_prob_officer_by_id(
    IN p_Prob_ID DECIMAL(5),
    IN p_Last VARCHAR(15),
    IN p_First VARCHAR(10),
    IN p_Street VARCHAR(30),
    IN p_City VARCHAR(20),
    IN p_State CHAR(2),
    IN p_Zip CHAR(5),
    IN p_Phone CHAR(10),
    IN p_Email VARCHAR(30),
    IN p_Status CHAR(1)
)
BEGIN
    UPDATE Prob_officers
    SET Last = p_Last,
        First = p_First,
        Street = p_Street,
        City = p_City,
        State = p_State,
        Zip = p_Zip,
        Phone = p_Phone,
        Email = p_Email,
        Status = p_Status
    WHERE Prob_ID = p_Prob_ID;
END$$
DELIMITER ;

-- Update Sentence by Sentence_ID
DELIMITER $$
CREATE PROCEDURE update_sentence_by_id(
    IN p_Sentence_ID DECIMAL(6),
    -- Faux input as it does not make sense to change, just like for Crime
    IN p_Criminal_ID DECIMAL(6),
    IN p_Type CHAR(1),
    IN p_Prob_ID DECIMAL(5),
    IN p_Start_date DATE,
    IN p_End_date DATE,
    IN p_Violations DECIMAL(3)
)
BEGIN
    IF p_End_date > p_Start_date THEN
        UPDATE Sentences
        SET Type = p_Type,
            Prob_ID = p_Prob_ID,
            Start_date = p_Start_date,
            End_date = p_End_date,
            Violations = p_Violations
        WHERE Sentence_ID = p_Sentence_ID;
    ELSE
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'End_date must be greater than Start_date.';
    END IF;
END$$
DELIMITER ;

-- Update Crime Code by Crime_code
DELIMITER $$
CREATE PROCEDURE update_crime_code_by_id(
    IN p_Crime_code DECIMAL(3),
    IN p_Code_description VARCHAR(30)
)
BEGIN
    UPDATE Crime_codes
    SET Code_description = p_Code_description
    WHERE Crime_code = p_Crime_code;
END$$
DELIMITER ;

-- Update Crime Charge by Charge_ID
DELIMITER $$
CREATE PROCEDURE update_crime_charge_by_id(
    IN p_Charge_ID DECIMAL(10),
    -- Faux input
    IN p_Crime_ID DECIMAL(9),
    IN p_Crime_code DECIMAL(3),
    IN p_Charge_status CHAR(2),
    IN p_Fine_amount DECIMAL(7,2),
    IN p_Court_fee DECIMAL(7,2),
    IN p_Amount_paid DECIMAL(7,2),
    IN p_Pay_due_date DATE
)
BEGIN
    UPDATE Crime_charges
    SET Crime_code = p_Crime_code,
        Charge_status = p_Charge_status,
        Fine_amount = p_Fine_amount,
        Court_fee = p_Court_fee,
        Amount_paid = p_Amount_paid,
        Pay_due_date = p_Pay_due_date
    WHERE Charge_ID = p_Charge_ID;
END$$
DELIMITER ;

-- Update Officer by Officer_ID
DELIMITER $$
CREATE PROCEDURE update_officer_by_id(
    IN p_Officer_ID DECIMAL(8),
    IN p_Last VARCHAR(15),
    IN p_First VARCHAR(10),
    IN p_Precinct CHAR(4),
    IN p_Badge VARCHAR(14),
    IN p_Phone CHAR(10),
    IN p_Status CHAR(1)
)
BEGIN
    UPDATE Officers
    SET Last = p_Last,
        First = p_First,
        Precinct = p_Precinct,
        Badge = p_Badge,
        Phone = p_Phone,
        Status = p_Status
    WHERE Officer_ID = p_Officer_ID;
END$$
DELIMITER ;

-- Skip updates for the joint table Crime_officers

-- Update Appeals by Appeal_ID
DELIMITER $$
CREATE PROCEDURE update_appeal_by_id(
    IN p_Appeal_ID DECIMAL(5),
    -- Faux input
    IN p_Crime_ID DECIMAL(9),
    IN p_Filling_date DATE,
    IN p_Hearing_date DATE,
    IN p_Status CHAR(1)
)
BEGIN
    UPDATE Appeals
    SET Filling_date = p_Filling_date,
        Hearing_date = p_Hearing_date,
        Status = p_Status
    WHERE Appeal_ID = p_Appeal_ID;
END$$
DELIMITER ;

SELECT "Creating procedures (deletion)..." AS message;

-- Deletion Stored Procedures
-- Delete Criminal by Criminal_ID
DELIMITER $$
CREATE PROCEDURE delete_criminal_by_id(
    IN p_Criminal_ID DECIMAL(6)
)
BEGIN
    -- Temporarily remove checks
    SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

    -- Delete relevant Crime_charges file(s)
    DELETE CC
    FROM Crime_charges CC
    JOIN Crimes C ON CC.Crime_ID = C.Crime_ID
    WHERE C.Criminal_ID = p_Criminal_ID;

    -- Delete relevant Appeal(s)
    DELETE Appeal
    FROM Appeals Appeal
    JOIN Crimes C ON Appeal.Crime_ID = C.Crime_ID
    WHERE C.Criminal_ID = p_Criminal_ID;

    -- Delete relevant Crime(s)
    DELETE FROM Crimes
    WHERE Criminal_ID = p_Criminal_ID;

    -- Delete relevant Aliases
    DELETE FROM Aliases
    WHERE Criminal_ID = p_Criminal_ID;

    DELETE FROM Criminals
    WHERE Criminal_ID = p_Criminal_ID;

    -- Restore checks
    SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
END$$
DELIMITER ;

-- Delete Alias by Alias_ID
DELIMITER $$
CREATE PROCEDURE delete_alias_by_id(
    IN p_Alias_ID DECIMAL(6)
)
BEGIN
    DELETE FROM Aliases
    WHERE Alias_ID = p_Alias_ID;
END$$
DELIMITER ;

-- Delete Crime by Crime_ID
DELIMITER $$
CREATE PROCEDURE delete_crime_by_id(
    IN p_Crime_ID DECIMAL(9)
)
BEGIN
    -- Temporarily remove checks
    SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

    -- Delete relevant Crime_charge(s)
    DELETE FROM Crime_charges
    WHERE Crime_ID = p_Crime_ID;

    -- Delete relevant Appeal(s)
    DELETE FROM Appeals
    WHERE Crime_ID = p_Crime_ID;

    -- Delete relevant Crime_officer(s)
    DELETE FROM Crime_officers
    WHERE Crime_ID = p_Crime_ID;

    DELETE FROM Crimes
    WHERE Crime_ID = p_Crime_ID;

    -- Restore checks
    SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
END$$
DELIMITER ;

-- Delete Prob_Officer by Prob_ID
DELIMITER $$
CREATE PROCEDURE delete_prob_officer_by_id(
    IN p_Prob_ID DECIMAL(5)
)
BEGIN
    DELETE FROM Prob_officers WHERE Prob_ID = p_Prob_ID;
END$$
DELIMITER ;

-- Delete Sentence by Sentence_ID
DELIMITER $$
CREATE PROCEDURE delete_sentence_by_id(
    IN p_Sentence_ID DECIMAL(6)
)
BEGIN
    DELETE FROM Sentences WHERE Sentence_ID = p_Sentence_ID;
END$$
DELIMITER ;

-- Delete Crime_codes by Crime_code
DELIMITER $$
CREATE PROCEDURE delete_crime_code_by_id(
    IN p_Crime_code DECIMAL(3)
)
BEGIN
    -- Temporarily remove checks
    SET @OLD_FOREIGN_KEY_CHECKS=@@FOREIGN_KEY_CHECKS, FOREIGN_KEY_CHECKS=0;

    -- Delete relevant Crime_charge(s)
    DELETE FROM Crime_charges
    WHERE Crime_code = p_Crime_code;

    DELETE FROM Crime_codes
    WHERE Crime_code = p_Crime_code;

    -- Restore checks
    SET FOREIGN_KEY_CHECKS=@OLD_FOREIGN_KEY_CHECKS;
END$$
DELIMITER ;

-- Delete Crime_charges by Charge_ID
DELIMITER $$
CREATE PROCEDURE delete_crime_charge_by_id(
    IN p_Charge_ID DECIMAL(10)
)
BEGIN
    DELETE FROM Crime_charges
    WHERE Charge_ID = p_Charge_ID;
END$$

-- Delete Officer by Officer_ID
CREATE PROCEDURE delete_officer_by_id(
    IN p_Officer_ID DECIMAL(8)
)
BEGIN
    DELETE FROM Officers
    WHERE Officer_ID = p_Officer_ID;
END$$

-- Delete Crime_officers by composite PK
CREATE PROCEDURE delete_crime_officer_by_id(
    IN p_Crime_ID DECIMAL(9),
    IN p_Officer_ID DECIMAL(8)
)
BEGIN
    DELETE FROM Crime_officers
    WHERE Crime_ID = p_Crime_ID
    AND Officer_ID = p_Officer_ID;
END$$

-- Delete Appeals by Appeal_ID
CREATE PROCEDURE delete_appeal_by_id(
    IN p_Appeal_ID DECIMAL(5)
)
BEGIN
    DELETE FROM Appeals WHERE Appeal_ID = p_Appeal_ID;
END$$
DELIMITER ;

SELECT "Testing procedures (insertion)..." AS message;

-- Insert Testing
CALL insert_criminal(654321, 'Smith', 'Alice', '456 Elm Street', 'Springfield', 'IL', '62704', '3125559821', 'N', 'N');
CALL insert_alias(654322, 654321, 'A. Smith');
CALL insert_crime(987654321, 654321, 'F', '2023-03-21', 'OP', '2023-04-15', '2023-05-20');

CALL insert_prob_officer(12345, 'Smith', 'Joe', '123 Maple St', 'Somewhere', 'CA', '90001', '1234567890', 'joe.smith@example.com', 'A');
CALL insert_sentence(123456, 654321, 'F', 12345, '2024-01-01', '2024-12-31', 0);
CALL insert_crime_code(001, 'Theft under $500');

CALL insert_crime_charge(1122334455, 987654321, 321, 'OP', 1200.00, 100.00, 600.00, '2023-08-31');
CALL insert_officer(87654321, 'Brown', 'Charlie', 'P123', 'B987654321', '3125550147', 'A');
CALL insert_crime_officer(987654321, 87654321);
CALL insert_appeal(54321, 987654321, '2023-04-01', '2023-04-22', 'P');

SELECT "Testing procedures (retrieval)..." AS message;

-- Retrieval Testing
CALL get_criminal_by_id(654321);
CALL get_criminal_by_name('Alice', 'Smith');

CALL get_aliases_by_criminal_id(654321);

CALL get_crime_by_id(987654321);
CALL get_crimes_by_criminal_id(654321);

CALL get_prob_officer_by_id(12345);
CALL get_prob_officer_by_name('Jane', 'Doe');

CALL get_sentence_by_id(123456);
CALL get_sentences_by_criminal_id(654321);

CALL get_crime_code_by_charge_id(1234567890);

CALL get_charges_by_id(1122334455);
CALL get_charges_by_crime_id(987654321);
CALL get_charges_by_crime_code(001);

CALL get_officer_by_id(87654321);
CALL get_officer_by_name('Charlie', 'Brown');

CALL get_officers_by_crime_id(987654321);
CALL get_crimes_by_officer_id(87654321);

CALL get_appeal_by_id(54321);
CALL get_appeals_by_crime_id(987654321);

SELECT "Testing procedures (update)..." AS message;

-- Update Testing
CALL update_criminal_by_id(654321, 'Smith', 'Alice', '455 Helm Lane', 'Springfield', 'IL', '62704', '3125559821', 'N', 'N');
CALL update_alias_by_id(123456, 'Harker');
CALL update_crime_by_id(987654321, 654321, 'F', '2023-03-21', 'OP', '2023-04-15', '2023-05-20');

CALL update_prob_officer_by_id(12345, 'Doe', 'John', '123 Oak Street', 'Elsewhere', 'CA', '90002', '3105550198', 'john.doe@example.com', 'A');
CALL update_sentence_by_id(123456, 654321, 'G', 12345, '2024-02-01', '2024-12-31', 1);
CALL update_crime_code_by_id(001, 'Petty Theft under $500');

CALL update_crime_charge_by_id(1122334455, 987654321, 002, 'PD', 1500.00, 200.00, 700.00, '2024-09-30');
CALL update_officer_by_id(87654321, 'Doe', 'John', 'D124', 'B9876543210987', '3105550148', 'B');

SELECT "Testing procedures (deletion)..." AS message;

-- Delete Testing
CALL delete_criminal_by_id(654321);
CALL delete_alias_by_id(654322);
CALL delete_crime_by_id(987654321);
CALL delete_prob_officer_by_id(12345);
CALL delete_sentence_by_id(123456);
CALL delete_crime_code_by_id(001);
CALL delete_crime_charge_by_id(1122334455);
CALL delete_officer_by_id(87654321);
CALL delete_crime_officer_by_id(987654321, 87654321);
CALL delete_appeal_by_id(54321);

SELECT * FROM Aliases WHERE Alias_ID = 654322;
SELECT * FROM Crimes WHERE Crime_ID = 987654321;
SELECT * FROM Crime_charges WHERE Crime_ID = 987654321;
SELECT * FROM Appeals WHERE Crime_ID = 987654321;
SELECT * FROM Crime_officers WHERE Crime_ID = 987654321;
SELECT * FROM Prob_officers WHERE Prob_ID = 12345;
SELECT * FROM Sentences WHERE Sentence_ID = 123456;
SELECT * FROM Crime_codes WHERE Crime_code = 001;
SELECT * FROM Crime_charges WHERE Charge_ID = 1122334455;
SELECT * FROM Officers WHERE Officer_ID = 87654321;
SELECT * FROM Crime_officers WHERE Crime_ID = 987654321 AND Officer_ID = 87654321;
SELECT * FROM Appeals WHERE Appeal_ID = 54321;

SELECT "Creating functions..." AS message;

-- Count total fine for a crime
DELIMITER //
CREATE OR REPLACE FUNCTION get_Total_fines(criminalID DECIMAL(6)) RETURNS DECIMAL(10,2)
BEGIN
    DECLARE totalFines DECIMAL(10,2);
    SELECT COALESCE(SUM(Fine_amount), 0) INTO totalFines
    FROM Crime_charges 
    INNER JOIN Crimes ON Crimes.Crime_ID = Crime_charges.Crime_ID
    WHERE Crimes.Criminal_ID = criminalID AND Crime_charges.Charge_status = 'GL';

    RETURN totalFines;
END//
DELIMITER ;

SELECT "Creating triggers..." AS message;

-- Update Crime charges
DELIMITER @@
CREATE OR REPLACE TRIGGER update_Crime_after_Appeal
AFTER UPDATE ON Appeals
FOR EACH ROW
BEGIN
    IF NEW.Status = 'A' THEN
        -- Update Crime_charges related to the crime of the successful appeal
        UPDATE Crime_charges
        JOIN Crimes ON Crime_charges.Crime_ID = Crimes.Crime_ID
        SET Crime_charges.Amount_paid = 0, Crime_charges.Charge_status = 'NG'
        WHERE Crimes.Crime_ID = NEW.Crime_ID;

        -- Update the status of the related crime to 'CL' (Closed)
        UPDATE Crimes
        SET Status = 'CL'
        WHERE Crime_ID = NEW.Crime_ID;
    END IF;
END @@

DELIMITER ;

-- Update Criminal srobation status
DELIMITER @@
CREATE OR REPLACE TRIGGER update_Criminal_Probation_status
AFTER UPDATE ON Sentences
FOR EACH ROW
BEGIN
    IF NEW.Type = 'P' THEN
        -- Update Crime_charges related to the crime of the successful appeal
        UPDATE Criminals
        SET Criminals.P_status = 'Y'
        WHERE Criminals.Criminal_ID = NEW.Criminal_ID;
        AND NEW.Start_date > GETDATE()
        AND NEW.End_date < GETDATE();

    END IF;
END @@

DELIMITER ;

ALTER TABLE Sentences
MODIFY Prob_ID INT NULL;
