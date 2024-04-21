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
    insert = () =>
        `INSERT INTO Crime_codes (Crime_code, Code_description) VALUES ("${this.code}", "${this.description}");`;
    delete = () => `DELETE FROM Crime_codes WHERE Crime_code = ${this.code};`;
}

app.get("/", async (req, res) => {
    try {
        const result = (await db.query(new Crime_code().list()))[0];
        res.render("./crime_code", { Crime_code: result });
    } catch (error) {
        console.log(error);
        res.status(500).render("error", { error: "Internal Error." });
    }
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
        if (error.errno === 1062) {
            res.send(`<script>alert("Duplicate key!");
            window.location.href = "/crime_code/new";</script>`);
        } else {
            res.status(500).render("error", { error: "Internal Error." });
        }
    }
});

// DELETE
app.post("/:code", async (req, res) => {
    if (req.query.method?.toUpperCase() !== "DELETE") {
        res.status(400).render("error", { error: "Bad Request." });
        return;
    }
    try {
        await db.query(new Crime_code(req.params).delete());
        res.redirect("./");
    } catch (error) {
        console.log(error);
        res.status(500).render("error", { error: "Internal Error." });
    }
});

export { app as crimeCodeRoutes };
