import * as argon2 from "argon2";
import db from "./db.mjs";

export async function insertCriminal(criminalDetails) {
    const { first, last, street, city, state, zip, phone, violent, probation } = criminalDetails;
    const query = `
        INSERT INTO Criminals (First, Last, Street, City, State, Zip, Phone, V_status, P_status)
        VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?);
    `;
    try {
        const result = await db.query(query, [
            first,
            last,
            street,
            city,
            state,
            zip,
            phone,
            violent,
            probation,
        ]);
        return result;
    } catch (err) {
        throw new Error("Failed to insert new criminal: " + err.message);
    }
}

export async function getAllCriminals() {
    console.log("Attempting to fetch all criminals from the database.");
    const query = 'SELECT * FROM Criminals;';
    try {
        const [criminals, fields] = await db.query(query);
        console.log("Fetched criminals:", criminals);
        return criminals;
    } catch (err) {
        console.error("Error fetching criminals:", err);
        throw err;  
    }
}

export async function getCriminalDetails(criminalID) {
    const query = 'SELECT * FROM Criminals WHERE Criminal_ID = ?;';
    try {
        const [results] = await db.query(query, [criminalID]);
        return results[0]; 
    } catch (err) {
        throw err;
    }
}

export async function updateCriminalField(id, field, value) {
    try {
        const query = `UPDATE Criminals SET ${field} = ? WHERE Criminal_ID = ?`;
        await db.query(query, [value, id]);
    } catch (err) {
        throw err;
    }
}

export async function deleteCriminalById(criminalId) {
    try {
        await db.query('CALL delete_criminal_by_id(?)', [criminalId]);
        return { success: true };
    } catch (err) {
        console.error("Failed deleteCriminalById procedure:", err);
        return { success: false };
    }
}

export async function insertSentence(criminalId, type, probID, startDate, endDate, violations) {
    try {
        await db.query('CALL insert_sentence(?, ?, ?, ?, ?, ?)', [
            criminalId, type, probID, startDate, endDate, violations
        ]);
        return { success: true };
    } catch (err) {
        console.error("Failed to insert sentence:", err);
        return { success: false, message: err.message };
    }
}

export async function getAllCrimes() {
    console.log("Attempting to fetch all criminals from the database.");
    const query = 'SELECT * FROM Crimes;';
    try {
        const [crimes, fields] = await db.query(query);
        console.log("Fetched crimes:", crimes);
        return crimes;
    } catch (err) {
        console.error("Error fetching crimes:", err);
        throw err;  
    }
}

export async function getCrimeById(Crime_ID) {
    const query = 'SELECT * FROM Crimes WHERE Crime_ID = ?';
    try {
        const [results] = await db.query(query, [Crime_ID]);
        return results[0];
    } catch (err) {
        console.error('Failed to retrieve crime:', err);
        throw err;
    }
}


export async function insertCrime(criminalID, classification, dateCharged, status, hearingDate, appealCutDate) {
    try {
        await db.query('CALL insert_crime(?, ?, ?, ?, ?, ?)', [
            criminalID,
            classification,
            dateCharged,
            status,
            hearingDate,
            appealCutDate
        ]);
        return { success: true, message: "Crime successfully added." };
    } catch (err) {
        console.error("Failed to insert crime:", err);
        return { success: false, message: err.sqlMessage || "An error occurred while adding the crime." };
    }
}

export async function getAppealsByCrimeID(Crime_ID) {
    try {
        const [appeals, _] = await db.query('CALL get_appeals_by_crime_id(?)', [Crime_ID]);
        return appeals;
    } catch (err) {
        console.error('Failed to retrieve appeals:', err);
        throw err;
    }
}

export async function addAppealByCrimeID(crimeID, fillingDate, hearingDate, status) {
    try {
        await db.query('CALL insert_appeal_by_crime_id(?, ?, ?, ?)', [crimeID, fillingDate, hearingDate, status]);
        return { success: true, message: "Appeal successfully added." };
    } catch (err) {
        console.error("Failed to add appeal:", err);
        return { success: false, message: err.sqlMessage || "An error occurred while adding the appeal." };
    }
}



export async function insertProbationOfficer(firstName, lastName, street, city, state, zipCode, phoneNumber, email, status) {
    try {
        await db.query('CALL insert_prob_officer(?, ?, ?, ?, ?, ?, ?, ?, ?)', [
            lastName, firstName, street, city, state, zipCode, phoneNumber, email, status
        ]);
        return { success: true, message: "Probation officer successfully added." };
    } catch (err) {
        console.error("Failed to insert probation officer:", err);
        return { success: false, message: err.sqlMessage || "An error occurred while adding the probation officer." };
    }
}

export async function getAllProbOfficers() {
    console.log("Attempting to fetch all probation officers from the database.");
    const query = 'SELECT * FROM Prob_officers;';
    try {
        const [probOfficers, fields] = await db.query(query);
        console.log("Fetched probation officers:", probOfficers);
        return probOfficers;
    } catch (err) {
        console.error("Error fetching probation officers:", err);
        throw err;
    }
}

export async function getCriminalSentences(criminalId) {
    console.log(`Fetching sentences for criminal ID: ${criminalId}`);
    try {
        const [sentences, fields] = await db.query('CALL get_sentences_by_criminal_id(?)', [criminalId]);
        console.log(`Fetched sentences for criminal ID ${criminalId}:`, sentences);
        return sentences[0];
    } catch (err) {
        console.error(`Error fetching sentences for criminal ID ${criminalId}:`, err);
        throw err;
    }
}

export async function getCriminalCrimes(criminalId) {
    console.log(`Fetching crimes for criminal ID: ${criminalId}`);
    try {
        const [crimes, fields] = await db.query('CALL get_crimes_by_criminal_id(?)', [criminalId]);
        console.log(`Fetched crimes for criminal ID ${criminalId}:`, crimes);
        return crimes[0];
    } catch (err) {
        console.error(`Error fetching crimes for criminal ID ${criminalId}:`, err);
        throw err;
    }
}

export async function getProbationOfficerById(probID) {
    const query = 'CALL get_prob_officer_by_id(?);';
    try {
        const [results] = await db.query(query, [probID]);
        return results[0][0];
    } catch (err) {
        console.error('Failed to retrieve probation officer:', err);
        throw err;
    }
}

export async function deleteProbOfficerByID(probID) {
    const query = 'CALL delete_prob_officer_by_id(?);';
    try {
        const [results] = await db.query(query, [probID]);
        if (results.affectedRows > 0) {  
            return { success: true };
        } else {
            return { success: false, message: "No rows affected." };
        }
    } catch (err) {
        console.error('Failed to delete probation officer:', err);
        throw err; 
    }
}

export async function updateProbOfficerField(id, field, value) {
    try {
        const query = `UPDATE Prob_officers SET ${field} = ? WHERE Prob_ID = ?`;
        await db.query(query, [value, id]);
    } catch (err) {
        console.error('Failed to update probation officer:', err);
        throw err;
    }
}

export async function getProbationOfficerSentences(probID) {
    console.log(`Fetching sentences for probID: ${probID}`);
    try {
        const [sentences] = await db.query('CALL get_sentences_by_prob_officer_id(?)', [probID]);
        console.log(`Fetched sentences for probID ${probID}:`, sentences);
        return sentences;
    } catch (err) {
        console.error(`Error fetching sentences for probID ${probID}:`, err);
        throw err;
    }
}

// insert crime charge by crime_ID
export async function insertCrimeChargeByCrimeID(crimeID, crimeCode, chargeStatus, fineAmount, courtFee, amountPaid, payDueDate) {
    try {
        await db.query('CALL insert_crime_charge(?, ?, ?, ?, ?, ?, ?)', [
            crimeID,
            crimeCode,
            chargeStatus,
            fineAmount,
            courtFee,
            amountPaid,
            payDueDate
        ]);
        return { success: true, message: "Crime charge successfully added." };
    } catch (err) {
        console.error("Failed to add crime charge:", err);
        return { success: false, message: err.sqlMessage || "An error occurred while adding the crime charge." };
    }
}

// get crime charges by crime_ID
export async function getCrimeChargesByCrimeID(crimeID) {
    try {
        const [charges] = await db.query('CALL get_charges_by_crime_id(?)', [crimeID]);
        return charges;
    } catch (err) {
        console.error("Failed to retrieve crime charges:", err);
        throw err;
    }
}
