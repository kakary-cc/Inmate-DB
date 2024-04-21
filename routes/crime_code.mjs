import express from "express";
import db from "../db.mjs";

const app = express();

// Schema
class Crime_code {
    constructor({ code = "", description = "" } = {}) {
        this.code = parseInt(code);
        this.description = description.trim();
    }
    list = () => `SELECT * FROM Crime_codes;`;
    search = () =>
        `SELECT * FROM Crime_codes WHERE Crime_code LIKE "${this.code}";`;
    insert = () =>
        `INSERT INTO Crime_codes (Crime_code, Code_description) VALUES ("${this.code}", "${this.description}");`;
}

app.get("/", async (req, res) => {
    const result = (await db.query(new Crime_code().list()))[0];
    res.render("./crime_code", { Crime_code: result });
});

app.get("/new", async (req, res) => {
    res.render("./crime_code/new", {});
});

app.post("/new", async (req, res) => {
    try {
        await db.query(new Crime_code(req.body).insert());
        res.redirect("./");
    } catch (error) {
        console.log(error);
        res.send(
            error.errno === 1062
                ? `<script>
                alert("Duplicate key!");
                window.location.href = "/crime_code/new";</script>`
                : `<script>
                alert("Error occurred when adding new entry.");
                window.location.href = "/crime_code/new";</script>`
        );
    }
});

export { app as crimeCodeRoutes };
