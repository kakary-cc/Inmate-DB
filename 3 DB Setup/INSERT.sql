USE jail;

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

-- Update Testing
CALL update_criminal_by_id(654321, 'Smith', 'Alice', '455 Helm Lane', 'Springfield', 'IL', '62704', '3125559821', 'N', 'N');
CALL update_alias_by_id(123456, 'Harker');
CALL update_crime_by_id(987654321, 654321, 'F', '2023-03-21', 'OP', '2023-04-15', '2023-05-20');

CALL update_prob_officer_by_id(12345, 'Doe', 'John', '123 Oak Street', 'Elsewhere', 'CA', '90002', '3105550198', 'john.doe@example.com', 'A');
CALL update_sentence_by_id(123456, 654321, 'G', 12345, '2024-02-01', '2024-12-31', 1);
CALL update_crime_code_by_id(001, 'Petty Theft under $500');

CALL update_crime_charge_by_id(1122334455, 987654321, 002, 'PD', 1500.00, 200.00, 700.00, '2024-09-30');
CALL update_officer_by_id(87654321, 'Doe', 'John', 'D124', 'B9876543210987', '3105550148', 'B');

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
