import express from "express";
import * as interactive from "../db-interactive.mjs";

const app = express();

app.get("/new", async (req, res) => {
    try {
        const Crime_ID = req.query["crime_id"];
        res.render("./appeal/new", { Crime_ID: Crime_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add appeal page.");
    }
});

app.post("/new", async (req, res) => {
    const Crime_ID = req.query["crime_id"];
    const { fillingDate, hearingDate, status } = req.body;

    try {
        const result = await interactive.addAppealByCrimeID(
            Crime_ID,
            fillingDate,
            hearingDate,
            status
        );
        if (result.success) {
            res.redirect(`/crime/${Crime_ID}`);
        } else {
            res.status(400).send(result.message);
        }
    } catch (error) {
        console.error("Error in submitting appeal:", error);
        res.status(500).send("Server error in processing your request.");
    }
});

export { app as appealRoutes };
