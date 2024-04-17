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

export async function getCriminalSentences(criminalID) {
    const query = 'SELECT * FROM Sentences WHERE Criminal_ID = ?;';
    try {
        const [results] = await db.query(query, [criminalID]);
        return results
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