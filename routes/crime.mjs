import express from "express";
import * as interactive from "../db-interactive.mjs";

const app = express();

// Converts date to YYYY-MM-DD format
function formatDate(dateValue) {
    if (!dateValue) return "";
    return new Date(dateValue).toISOString().split("T")[0];
}

app.get("/", async (req, res) => {
    try {
        const Crimes = await interactive.getAllCrimes();

        const formattedCrimes = Crimes.map((crime) => {
            return {
                ...crime,
                Date_charged: formatDate(crime.Date_charged),
                Hearing_date: formatDate(crime.Hearing_date),
                Appeal_cut_date: formatDate(crime.Appeal_cut_date),
            };
        });

        res.render("./crime", { Crimes: formattedCrimes });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving crimes.");
    }
});

app.get("/new", async (req, res) => {
    // Ger Criminal_ID from param
    try {
        const { Criminal_ID } = req.params;
        res.render("./crime/new", { criminal_ID: Criminal_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add sentence page.");
    }
});

app.get("/view/:Crime_ID", async (req, res) => {
    try {
        const { Criminal_ID, Crime_ID } = req.params;
        const Crime = await interactive.getCrimeById(Crime_ID);
        const [appeals] = await interactive.getAppealsByCrimeID(Crime_ID);
        const [charges] = await interactive.getCrimeChargesByCrimeID(Crime_ID);
        const [aliases] = await interactive.getAliasesByCriminalID(Criminal_ID);
        const [officers] = await interactive.getOfficersByCrimeID(Crime_ID);

        Crime.Date_charged = formatDate(Crime.Date_charged);
        Crime.Hearing_date = formatDate(Crime.Hearing_date);
        Crime.Appeal_cut_date = formatDate(Crime.Appeal_cut_date);

        const formattedAppeals = appeals.map((appeal) => {
            return {
                ...appeal,
                Filling_date: formatDate(appeal.Filling_date),
                Hearing_date: formatDate(appeal.Hearing_date),
                Appeal_cut_date: formatDate(appeal.Appeal_cut_date),
            };
        });

        const formattedCharges = charges.map((charge) => ({
            ...charge,
            Pay_due_date: formatDate(charge.Pay_due_date),
        }));

        if (!Crime) {
            res.status(404).send("Crime not found");
        } else {
            res.render("./crime/view", {
                crime: Crime,
                formattedAppeals,
                formattedCharges,
                aliases,
                officers,
            });
        }
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving crime details.");
    }
});

// add charge by crime_ID: the backend
app.post("/addCharge/:Crime_ID", async (req, res) => {
    const { Crime_ID } = req.params;
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
            res.redirect(`/crime/view/${Crime_ID}`);
        } else {
            res.status(400).send(result.message);
        }
    } catch (error) {
        console.error("Error in submitting crime charge:", error);
        res.status(500).send("Server error in processing your request.");
    }
});

// add appeal by crime_ID: the backend
app.post("/crime/addAppeal/:Crime_ID", async (req, res) => {
    const { Crime_ID } = req.params;
    const { fillingDate, hearingDate, status } = req.body;

    try {
        const result = await interactive.addAppealByCrimeID(
            Crime_ID,
            fillingDate,
            hearingDate,
            status
        );
        if (result.success) {
            res.redirect(`/crime/view/${Crime_ID}`);
        } else {
            res.status(400).send(result.message);
        }
    } catch (error) {
        console.error("Error in submitting appeal:", error);
        res.status(500).send("Server error in processing your request.");
    }
});

app.post("/addOfficer/:Crime_ID", async (req, res) => {
    const { Crime_ID } = req.params;
    const { officerID } = req.body;

    try {
        const result = await interactive.insertCrimeOfficer(
            Crime_ID,
            officerID
        );
        if (result.success) {
            res.redirect(`/crime/view/${Crime_ID}`);
        } else {
            res.status(400).send(result.message);
        }
    } catch (error) {
        console.error("Error linking officer to crime:", error);
        res.status(500).send("Server error in processing your request.");
    }
});

export { app as crimeRoutes };
