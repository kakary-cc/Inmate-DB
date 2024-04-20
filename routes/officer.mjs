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
        let officers = await interactive.getAllOfficers();

        res.render("./officer", { officers: officers });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving officers.");
    }
});

app.get("/view/:Officer_ID", async (req, res) => {
    try {
        const officerID = req.params.Officer_ID;
        const [officerDetails] = await interactive.getOfficerById(officerID);
        const [crimes] = await interactive.getCrimesByOfficerID(officerID);

        if (!officerDetails) {
            res.status(404).send("Officer not found");
        } else {
            res.render("./officer/view", { officer: officerDetails, crimes });
        }
    } catch (err) {
        console.error(err);
        res.status(500).send("Error retrieving officer details.");
    }
});

// create an officer: the frontend
app.get("/new", (req, res) => {
    res.render("./officer/new");
});

// create an officer: the backend
app.post("/new", async (req, res) => {
    const { firstName, lastName, precinct, badge, phone, status } = req.body;

    try {
        const result = await interactive.insertOfficer(
            lastName,
            firstName,
            precinct,
            badge,
            phone,
            status
        );
        if (result.success) {
            res.redirect("/officer");
        } else {
            res.status(500).send("Failed to create officer.");
        }
    } catch (error) {
        console.error("Error creating new officer:", error);
        res.status(500).send("Error creating officer.");
    }
});

app.delete("/view/:Officer_ID", async (req, res) => {
    const officerID = req.params.Officer_ID;

    try {
        const result = await interactive.deleteOfficerByID(officerID);
        if (result.success) {
            res.json({
                success: true,
                message: "Officer successfully deleted.",
            });
        } else {
            res.status(500).json({
                success: false,
                message: "Failed to delete officer.",
            });
        }
    } catch (error) {
        console.error("Error deleting officer:", error);
        res.status(500).json({
            success: false,
            message: "Error deleting officer.",
        });
    }
});

export { app as officerRoutes };
