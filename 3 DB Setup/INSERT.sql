-- Insert Stored Procedures
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
    IN p_Alias_ID DECIMAL(6),
    IN p_Criminal_ID DECIMAL(6),
    IN p_Alias VARCHAR(20)
)
BEGIN
    INSERT INTO Aliases (
        Alias_ID,
        Criminal_ID,
        Alias
    ) VALUES (
        p_Alias_ID,
        p_Criminal_ID,
        p_Alias
    );
END$$
DELIMITER ;

DELIMITER $$
CREATE PROCEDURE insert_crime(
    IN p_Crime_ID DECIMAL(9),
    IN p_Criminal_ID DECIMAL(6),
    IN p_Classification CHAR(1),
    IN p_Date_charged DATE,
    IN p_Status CHAR(2),
    IN p_Hearing_date DATE,
    IN p_Appeal_cut_date DATE
)
BEGIN
    INSERT INTO Crimes (
        Crime_ID,
        Criminal_ID,
        Classification,
        Date_charged,
        Status,
        Hearing_date,
        Appeal_cut_date
    ) VALUES (
        p_Crime_ID,
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
CREATE PROCEDURE insert_prob_officer(
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
    INSERT INTO Prob_officers (
        Prob_ID,
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
        p_Prob_ID,
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
    IN p_Sentence_ID DECIMAL(6),
    IN p_Criminal_ID DECIMAL(6),
    IN p_Type CHAR(1),
    IN p_Prob_ID DECIMAL(5),
    IN p_Start_date DATE,
    IN p_End_date DATE,
    IN p_Violations DECIMAL(3)
)
BEGIN
    INSERT INTO Sentences (
        Sentence_ID,
        Criminal_ID,
        Type,
        Prob_ID,
        Start_date,
        End_date,
        Violations
    ) VALUES (
        p_Sentence_ID,
        p_Criminal_ID,
        p_Type,
        p_Prob_ID,
        p_Start_date,
        p_End_date,
        p_Violations
    );
    IF p_End_date <= p_Start_date THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'End_date must be greater than Start_date';
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
    IN p_Charge_ID DECIMAL(10),
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
        Charge_ID,
        Crime_ID,
        Crime_code,
        Charge_status,
        Fine_amount,
        Court_fee,
        Amount_paid,
        Pay_due_date
    ) VALUES (
        p_Charge_ID,
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
    IN p_Officer_ID DECIMAL(8),
    IN p_Last VARCHAR(15),
    IN p_First VARCHAR(10),
    IN p_Precinct CHAR(4),
    IN p_Badge VARCHAR(14),
    IN p_Phone CHAR(10),
    IN p_Status CHAR(1)
)
BEGIN
    INSERT INTO Officers (
        Officer_ID,
        Last,
        First,
        Precinct,
        Badge,
        Phone,
        Status
    ) VALUES (
        p_Officer_ID,
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
CREATE PROCEDURE insert_appeal(
    IN p_Appeal_ID DECIMAL(5),
    IN p_Crime_ID DECIMAL(9),
    IN p_Filling_date DATE,
    IN p_Hearing_date DATE,
    IN p_Status CHAR(1)
)
BEGIN
    INSERT INTO Appeals (
        Appeal_ID,
        Crime_ID,
        Filling_date,
        Hearing_date,
        Status
    ) VALUES (
        p_Appeal_ID,
        p_Crime_ID,
        p_Filling_date,
        p_Hearing_date,
        p_Status
    );
END$$
DELIMITER ;
