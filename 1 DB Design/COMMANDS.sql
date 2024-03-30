CREATE DATABASE IF NOT EXISTS Jail_DB;

USE Jail_DB;

CREATE TABLE Criminal(
    id int,
    name varchar(255),
    address_street varchar(255),
    address_city varchar(255),
    address_state varchar(20),
    address_zipcode varchar(20),
    phone varchar(20),
    violent_offender_status boolean,
    probabtion_status boolean,
    PRIMARY KEY(id)
);

CREATE TABLE Sentencing(
    id int,
    criminal_id int,
    start_date date,
    end_date date,
    number_of_violations int,
    type_of_sentence ENUM('jail_period', 'house_arrest', 'probation'),
    PRIMARY KEY(id),
    FOREIGN KEY(criminal_id) REFERENCES Criminal(id) 
);

CREATE TABLE Crime(
    id int,
    classification ENUM('felony', 'misdemeanor', 'other'),
    date_charged date,
    appeal_status ENUM('closed', 'can_appeal', 'in_appeal'),
    hearing_date date,
    amount_of_fine decimal(50,2),
    court_fee decimal(50,2),
    amount_paid decimal(50,2),
    payment_due_date date,
    charge_status ENUM('pending', 'guilty', 'not guilty'),
    PRIMARY KEY(id)
);

CREATE TABLE Police_Officer(
    name varchar(255),
    precinct varchar(255),
    badge_number int,
    phone varchar(20),
    active_status boolean,
    PRIMARY KEY(badge_number)
);

CREATE TABLE Appeal(
    id int,
    filling_date date,
    hearing_date date,
    case_status ENUM('pending', 'approved', 'disapproved'),
    PRIMARY KEY(id)
);

CREATE TABLE Criminal_Aliases(
    criminal_id int,
    alias varchar(255),
    PRIMARY KEY(criminal_id, alias),
    FOREIGN KEY(criminal_id) REFERENCES Criminal(id)
);

CREATE TABLE Sentencing_Appeal(
    sentencing_id int,
    appeal_id int,
    PRIMARY KEY(sentencing_id, appeal_id),
    FOREIGN KEY(sentencing_id) REFERENCES Sentencing(id),
    FOREIGN KEY(appeal_id) REFERENCES Appeal(id)
);

CREATE TABLE Criminal_Crime(
    criminal_id int,
    crime_id int,
    PRIMARY KEY(criminal_id, crime_id),
    FOREIGN KEY(criminal_id) REFERENCES Criminal(id),
    FOREIGN KEY(crime_id) REFERENCES Crime(id)
);

CREATE TABLE Crime_Officer(
    crime_id int,
    arresting_officer int,
    PRIMARY KEY(crime_id, arresting_officer),
    FOREIGN KEY(crime_id) REFERENCES Crime(id),
    FOREIGN KEY(arresting_officer) REFERENCES Police_Officer(badge_number)
);

CREATE TABLE Crime_Code(
    crime_id int,
    code varchar(255),
    PRIMARY KEY(crime_id, code),
    FOREIGN KEY(crime_id) REFERENCES Crime(id)
);