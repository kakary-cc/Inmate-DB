import express from "express";
import * as interactive from "../db-interactive.mjs";

const app = express();

app.get("/new", async (req, res) => {
    try {
        const Crime_ID = req.query["crime_id"];
        res.render("./crime_charge/new", { Crime_ID: Crime_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add charge page.");
    }
});

app.post("/new", async (req, res) => {
    const Crime_ID = req.query["crime_id"];
    const {
        crimeCode,
        chargeStatus,
        fineAmount,
        courtFee,
        amountPaid,
        payDueDate,
    } = req.body;

    try {
        const result = await interactive.insertCrimeChargeByCrimeID(
            Crime_ID,
            crimeCode,
            chargeStatus,
            fineAmount,
            courtFee,
            amountPaid,
            payDueDate
        );
        if (result.success) {
            res.redirect(`/crime/${Crime_ID}`);
        } else {
            res.status(400).send(result.message);
        }
    } catch (error) {
        console.error("Error in submitting crime charge:", error);
        res.status(500).send("Server error in processing your request.");
    }
});

export { app as crimeChargeRoutes };
