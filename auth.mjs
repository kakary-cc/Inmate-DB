import * as argon2 from "argon2";
import db from "./db.mjs";

function User(email) {
    this.email = email;
    this.password = "";
    this.search = () => `SELECT * FROM Users WHERE Email LIKE "${this.email}";`;
    this.insert = () =>
        `INSERT INTO Users (Email, Passwd) VALUES ("${this.email}", "${this.password}");`;
}

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

const register = async (email, password) => {
    if (password.length < 8) throw { message: "PASSWORD TOO SHORT" };
    // TODO: Check for invalid email, potential SQL injection
    const newUser = new User(email);
    if ((await db.query(newUser.search()))[0].length !== 0)
        throw { message: "EMAIL ALREADY EXISTS" };
    newUser.password = await argon2.hash(password);
    await db.query(newUser.insert());
    return newUser;
};

const login = async (email, password) => {
    // TODO: Check for invalid email, potential SQL injection
    const newUser = new User(email);
    const result = await db.query(newUser.search());
    if (result[0].length === 0) throw { message: "USER NOT FOUND" };
    newUser.password = result[0][0].Passwd;
    if (!(await argon2.verify(newUser.password, password)))
        throw { message: "PASSWORDS DO NOT MATCH" };
    return newUser;
};

export { startAuthenticatedSession, endAuthenticatedSession, register, login };
