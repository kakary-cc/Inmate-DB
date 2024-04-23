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
            `<script>alert("Criminal successfully added!"); window.location.href = "/criminal"; </script>`
        );
    } catch (err) {
        console.log(err);
        res.send(
            `<script>alert("Create Criminal Unsuccessful"); window.location.href = "/criminal/new"; </script>`
        );
    }
});

app.get("/:Criminal_ID", async (req, res) => {
    try {
        const criminalID = req.params.Criminal_ID;
        const criminalDetails = await interactive.getCriminalDetails(
            criminalID
        );
        const criminalSentences = await interactive.getCriminalSentences(
            criminalID
        );
        const criminalCrimes = await interactive.getCriminalCrimes(criminalID);
        const criminalAliases = await interactive.getCriminalAliases(criminalID);

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
                aliases: criminalAliases
            });
        }
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving criminal details.");
    }
});

app.get("/alias/new", async (req, res) => {
    try {
        const Criminal_ID = req.query["criminal_id"];
        res.render("./criminal/alias/new", { Criminal_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add sentence page.");
    }
});

app.post("/alias/new", async (req, res) => {
    console.log("Pure Fiction I");
    const { id, alias } = req.body;
    console.log(id, alias);  
    console.log("Pure Fiction II");
    try {
        const Criminal_ID = parseInt(id);
        const aliases = alias.split(/\r?\n/);
        const results = [];

        for (let singleAlias of aliases) {
            const result = await interactive.insertAlias(Criminal_ID, singleAlias.trim());
            if (!result.success) {
                res.status(400).send(result.message);
                return;
            }
            results.push(result);
        }

        res.redirect(`/criminal/${Criminal_ID}`);
    } catch (error) {
        console.error("Error in submitting alias:", error);
        res.status(500).send("Server error in processing your request.");
    }
});


// update a single field for a single criminal
app.post("/:field", async (req, res) => {
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
app.delete("/:criminalId", async (req, res) => {
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

export { app as criminalRoutes };
