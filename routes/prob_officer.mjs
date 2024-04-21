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
        const probOfficers = await interactive.getAllProbOfficers();
        res.render("./prob_officer", { probOfficers: probOfficers });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving probation officers.");
    }
});

app.get("/new", (req, res) => {
    res.render("./prob_officer/new");
});

app.post("/new", async (req, res) => {
    const {
        firstName,
        lastName,
        street,
        city,
        state,
        zipCode,
        phoneNumber,
        email,
        status,
    } = req.body;

    try {
        const result = await interactive.insertProbationOfficer(
            firstName,
            lastName,
            street,
            city,
            state,
            zipCode,
            phoneNumber,
            email,
            status
        );
        if (result.success) {
            res.redirect("/prob_officer");
        } else {
            res.status(500).send("Failed to create probation officer.");
        }
    } catch (error) {
        console.error("Error creating new probation officer:", error);
        res.status(500).send("Error creating probation officer.");
    }
});

app.get("/:Prob_ID", async (req, res) => {
    try {
        const probID = req.params.Prob_ID;
        const probOfficerDetails = await interactive.getProbationOfficerById(
            probID
        );
        const [probOfficerSentences] =
            await interactive.getProbationOfficerSentences(probID);

        if (!probOfficerDetails) {
            res.status(404).send("Probation officer not found");
        } else {
            const formattedSentences = probOfficerSentences.map((sentence) => {
                return {
                    ...sentence,
                    Start_date: formatDate(sentence.Start_date),
                    End_date: formatDate(sentence.End_date),
                };
            });
            probOfficerDetails.StatusActive = probOfficerDetails.Status === "A";
            probOfficerDetails.StatusInactive =
                probOfficerDetails.Status === "I";
            res.render("./prob_officer/view", {
                probOfficer: probOfficerDetails,
                sentences: formattedSentences,
            });
        }
    } catch (err) {
        console.error("Error retrieving probation officer details:", err);
        res.status(500).send("Error retrieving probation officer details.");
    }
});

app.post("/:id", async (req, res) => {
    const { field, value } = req.body;
    const id = req.params.field;

    try {
        const validFields = [
            "First",
            "Last",
            "Street",
            "City",
            "State",
            "Zip",
            "Phone",
            "Email",
            "Status",
        ];

        // bare of handling potential SQL injections (future reference)
        if (!validFields.includes(field)) {
            return res.status(400).json({
                success: false,
                message: "Invalid field name for update.",
            });
        }

        await interactive.updateProbOfficerField(id, field, value);
        res.json({
            success: true,
            message: "Probation officer updated successfully.",
        });
    } catch (error) {
        console.error(
            `Error updating probation officer field ${field}:`,
            error
        );
        res.status(500).json({
            success: false,
            message: "Failed to update probation officer.",
        });
    }
});

// delete a probation officer
app.delete("/:probOfficerId", async (req, res) => {
    const probOfficerId = req.params.probOfficerId;

    try {
        const result = await interactive.deleteProbOfficerByID(probOfficerId);
        if (result.success) {
            res.json({
                success: true,
                message: "Probation officer successfully deleted.",
            });
        } else {
            res.status(500).json({
                success: false,
                message: "Failed to delete probation officer.",
            });
        }
    } catch (error) {
        console.error("Error deleting probation officer:", error);
        res.status(500).json({
            success: false,
            message: "Error deleting probation officer.",
        });
    }
});

export { app as probOfficerRoutes };
