import express from "express";
import db from "../db.mjs";

const app = express();

// Schema
function Crime_code(code, description) {
    this.code = code;
    this.description = description;
    this.list = () => `SELECT * FROM Crime_codes;`;
    this.search = () =>
        `SELECT * FROM Crime_codes WHERE Crime_code LIKE "${this.code}";`;
    this.insert = () =>
        `INSERT INTO Crime_codes (Crime_code, Code_description) VALUES ("${this.code}", "${this.description}");`;
}

app.get("/", async (req, res) => {
    const result = (await db.query(new Crime_code().list()))[0];
    res.render("./crime_code", { Crime_code: result });
});

app.get("/new", async (req, res) => {
    res.render("./crime_code/new", {});
});

export { app as crimeCodeRoutes };
