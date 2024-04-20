import express from "express";
import * as interactive from "../db-interactive.mjs";

const app = express();

// Converts date to YYYY-MM-DD format
function formatDate(dateValue) {
    if (!dateValue) return "";
    return new Date(dateValue).toISOString().split("T")[0];
}

// add appeal by crime_ID: the frontend
app.get("/new", async (req, res) => {
    // TODO: Get Crime_ID from pram
    try {
        const { Crime_ID } = req.params;
        res.render("./appeal/new", { crime_ID: Crime_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add appeal page.");
    }
});

export { app as appealRoutes };
