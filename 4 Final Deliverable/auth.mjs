import * as argon2 from "argon2";
import db from "./db.mjs";

const startAuthenticatedSession = (req, user) => {
    return new Promise((fulfill, reject) => {
        req.session.regenerate((err) => {
            if (!err) {
                req.session.user = user;
                fulfill(user);
            } else {
                reject(err);
            }
        });
    });
};

const endAuthenticatedSession = (req) => {
    return new Promise((fulfill, reject) => {
        req.session.destroy((err) => (err ? reject(err) : fulfill(null)));
    });
};

const register = async (username, email, password) => {
    if (username.length !== 6) {
        throw { message: "USERNAME PASSWORD TOO SHORT" };
    }
    if (password.length < 8) {
        throw { message: "USERNAME PASSWORD TOO SHORT" };
    }
    let sql = `SELECT * FROM DB_Users WHERE Email LIKE "${email}";`;
    db.query(sql, async (err, result) => {
        if (err) throw err;
        if (result.length > 0) {
            throw { message: "EMAIL ALREADY EXISTS" };
        }
        const hash = await argon2.hash(password);
        sql = `INSERT INTO DB_Users VALUES (${username}, "${email}", "${hash}", "V");`;
        db.query(sql, async (err, result) => {
            if (err) throw err;
            return { username: username, email: email};
        });
    });
    
};

const login = async (username, password) => {
    let sql = `SELECT * FROM DB_Users WHERE U_ID LIKE "${username}";`;
    db.query(sql, async (err, result) => {
        if (err) throw err;
        if (result.length === 0) {
            throw { message: "USER NOT FOUND" };
        }
        // console.log(result);
        // console.log(result[0]);
        if (!await argon2.verify(result[0].Password, password)) {
            throw { message: "PASSWORDS DO NOT MATCH" };
        }
        return { username: username, email: 'email' };
    });
};

export { startAuthenticatedSession, endAuthenticatedSession, register, login };
