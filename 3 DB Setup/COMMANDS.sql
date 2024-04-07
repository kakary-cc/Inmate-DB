USE jail;

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

-- Retrieval Stored Procedures
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

