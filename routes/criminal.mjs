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
        let criminals = await interactive.getAllCriminals();
        criminals = criminals.map((criminal) => ({
            ...criminal,
            Violent: criminal.V_status === "Y" ? "Yes" : "No",
            Probation: criminal.P_status === "Y" ? "Yes" : "No",
        }));
        res.render("./criminal", { criminals: criminals });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving criminals.");
    }
});

app.get("/new", (req, res) => {
    res.render("./criminal/new");
});

app.post("/new", async (req, res) => {
    try {
        const {
            firstName,
            lastName,
            street,
            city,
            state,
            zipCode,
            phoneNumber,
            violent,
            probation,
        } = req.body;

        const criminalDetails = {
            first: firstName,
            last: lastName,
            street: street,
            city: city,
            state: state,
            zip: zipCode,
            phone: phoneNumber,
            violent: violent === "yes" ? "Y" : "N",
            probation: probation === "yes" ? "Y" : "N",
        };

        const result = await interactive.insertCriminal(criminalDetails);
        console.log(result);
        res.send(
            `<script>alert("Criminal successfully added!"); window.location.href = "/criminal/all"; </script>`
        );
    } catch (err) {
        console.log(err);
        res.send(
            `<script>alert("Create Criminal Unsuccessful"); window.location.href = "/criminal/new"; </script>`
        );
    }
});

app.get("/view/:Criminal_ID", async (req, res) => {
    try {
        const criminalID = req.params.Criminal_ID;
        const criminalDetails = await interactive.getCriminalDetails(
            criminalID
        );
        const criminalSentences = await interactive.getCriminalSentences(
            criminalID
        );
        const criminalCrimes = await interactive.getCriminalCrimes(criminalID);

        if (!criminalDetails) {
            res.status(404).send("Criminal not found");
        } else {
            criminalDetails.selectedYesViolent =
                criminalDetails.V_status === "Y";
            criminalDetails.selectedNoViolent =
                criminalDetails.V_status === "N";
            criminalDetails.selectedYesProbation =
                criminalDetails.P_status === "Y";
            criminalDetails.selectedNoProbation =
                criminalDetails.P_status === "N";

            const formattedSentences = criminalSentences.map((sentence) => {
                return {
                    ...sentence,
                    Start_date: formatDate(sentence.Start_date),
                    End_date: formatDate(sentence.End_date),
                };
            });

            const formattedCrimes = criminalCrimes.map((crime) => {
                return {
                    ...crime,
                    Date_charged: formatDate(crime.Date_charged),
                    Hearing_date: formatDate(crime.Hearing_date),
                    Appeal_cut_date: formatDate(crime.Appeal_cut_date),
                };
            });

            res.render("./criminal/view", {
                criminal: criminalDetails,
                sentences: formattedSentences,
                crimes: formattedCrimes,
            });
        }
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving criminal details.");
    }
});

app.get("/alias/new", async (req, res) => {
    // TODO: Get Criminal_ID from param
    try {
        const { Criminal_ID } = req.params;
        res.render("./criminal/alias/new", { Criminal_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add sentence page.");
    }
});

app.post("/alias/new", async (req, res) => {
    // TODO: Get Criminal_ID from param
    const { Criminal_ID } = req.params;
    const { alias } = req.body;

    try {
        const result = await interactive.insertAlias(Criminal_ID, alias);
        if (result.success) {
            res.redirect(`/criminal/view/${Criminal_ID}`);
        } else {
            res.status(400).send(result.message);
        }
    } catch (error) {
        console.error("Error in submitting alias:", error);
        res.status(500).send("Server error in processing your request.");
    }
});

// update a single field for a single criminal
app.post("/update/:field", async (req, res) => {
    const { id, value } = req.body;
    const field = req.params.field;
    try {
        await interactive.updateCriminalField(id, field, value);
        res.json({ success: true });
    } catch (err) {
        console.error("Failed to update:", err);
        res.json({ success: false });
    }
});

// delete a single criminal
app.delete("/criminal/delete/:criminalId", async (req, res) => {
    const criminalId = req.params.criminalId;

    try {
        const result = await interactive.deleteCriminalById(criminalId);
        if (result.success) {
            res.json({
                success: true,
                message: "Criminal successfully deleted.",
            });
        } else {
            res.status(500).json({
                success: false,
                message: "Failed to delete criminal.",
            });
        }
    } catch (error) {
        console.error("Error deleting criminal:", error);
        res.status(500).json({
            success: false,
            message: "Error deleting criminal.",
        });
    }
});

// add a sentence for a criminal: the backend
app.post("/criminal/addSentence/:Criminal_ID", async (req, res) => {
    const { Criminal_ID } = req.params;
    const { type, probID, startDate, endDate, violations } = req.body;

    try {
        const result = await interactive.insertSentence(
            Criminal_ID,
            type,
            probID,
            startDate,
            endDate,
            violations
        );
        if (result.success) {
            res.redirect(`/criminal/view/${Criminal_ID}`);
        } else {
            res.status(500).send(
                "Inner Error inserting new sentence for criminal"
            );
        }
    } catch (error) {
        console.error("Error inserting sentence:", error);
        res.status(500).render("./error", {
            error: "Outer Error inserting sentence.",
        });
    }
});

// add a crime for a criminal: the backend
app.post("/criminal/addCrime/:Criminal_ID", async (req, res) => {
    const { Criminal_ID } = req.params;
    const { classification, dateCharged, status, hearingDate, appealCutDate } =
        req.body;

    try {
        const result = await interactive.insertCrime(
            Criminal_ID,
            classification,
            dateCharged,
            status,
            hearingDate,
            appealCutDate
        );
        if (result.success) {
            res.redirect(`/criminal/view/${Criminal_ID}`);
        } else {
            res.status(400).send(result.message);
        }
    } catch (error) {
        console.error("Error in submitting crime:", error);
        res.status(500).send("Server error in processing your request.");
    }
});

export { app as criminalRoutes };
