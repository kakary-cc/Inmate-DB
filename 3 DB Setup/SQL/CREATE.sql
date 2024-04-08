CREATE DATABASE IF NOT EXISTS jail;

USE jail;

CREATE TABLE Criminals (
    Criminal_ID DECIMAL(6),
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

CREATE TABLE Aliases (
    Alias_ID DECIMAL(6),
    Criminal_ID DECIMAL(6),
    Alias VARCHAR(20),
    PRIMARY KEY(Alias_ID),
    FOREIGN KEY(Criminal_ID) REFERENCES Criminals(Criminal_ID)
);

CREATE TABLE Crimes (
    Crime_ID DECIMAL(9),
    Criminal_ID DECIMAL(6),
    Classification CHAR(1) DEFAULT 'U',
    Date_charged DATE,
    Status CHAR(2) NOT NULL,
    Hearing_date DATE,
    Appeal_cut_date DATE,
    PRIMARY KEY(Crime_ID),
    FOREIGN KEY(Criminal_ID) REFERENCES Criminals(Criminal_ID),
    CHECK (Hearing_date > Date_charged)
);

CREATE TABLE Prob_officers (
    Prob_ID DECIMAL(5),
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

CREATE TABLE Sentences (
    Sentence_ID DECIMAL(6),
    Criminal_ID DECIMAL(6),
    Type CHAR(1),
    Prob_ID DECIMAL(5),
    Start_date DATE,
    End_date DATE,
    Violations DECIMAL(3) NOT NULL,
    PRIMARY KEY(Sentence_ID),
    FOREIGN KEY(Criminal_ID) REFERENCES Criminals(Criminal_ID),
    FOREIGN KEY(Prob_ID) REFERENCES Prob_officers(Prob_ID),
    CHECK (End_date > Start_date)
);

CREATE TABLE Crime_codes (
    Crime_code DECIMAL(3) NOT NULL,
    Code_description VARCHAR(30) NOT NULL UNIQUE,
    PRIMARY KEY(Crime_code)
);

CREATE TABLE Crime_charges (
    Charge_ID DECIMAL(10),
    Crime_ID DECIMAL(9),
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

CREATE TABLE Officers (
    Officer_ID DECIMAL(8),
    Last VARCHAR(15),
    First VARCHAR(10),
    Precinct CHAR(4) NOT NULL,
    Badge VARCHAR(14) UNIQUE,
    Phone CHAR(10),
    Status CHAR(1) DEFAULT 'A',
    PRIMARY KEY(Officer_ID)
);

CREATE TABLE Crime_officers (
    Crime_ID DECIMAL(9),
    Officer_ID DECIMAL(8),
    PRIMARY KEY(Crime_ID, Officer_ID),
    FOREIGN KEY(Crime_ID) REFERENCES Crimes(Crime_ID),
    FOREIGN KEY(Officer_ID) REFERENCES Officers(Officer_ID)
);

CREATE TABLE Appeals (
    Appeal_ID DECIMAL(5),
    Crime_ID DECIMAL(9),
    Filling_date DATE,
    Hearing_date DATE,
    Status CHAR(1) DEFAULT 'P',
    PRIMARY KEY(Appeal_ID),
    FOREIGN KEY(Crime_ID) REFERENCES Crimes(Crime_ID)
);