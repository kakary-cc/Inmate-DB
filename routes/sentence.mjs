import express from "express";
import * as interactive from "../db-interactive.mjs";

const app = express();

// Converts date to YYYY-MM-DD format
function formatDate(dateValue) {
    if (!dateValue) return "";
    return new Date(dateValue).toISOString().split("T")[0];
}

// add a sentence for a criminal: the page
app.get("/sentence/new", async (req, res) => {
    // TODO: Get Criminal_ID from param.
    try {
        const { Criminal_ID } = req.params;
        res.render("./sentence/new", { criminal_ID: Criminal_ID });
    } catch (err) {
        console.error(err);
        res.status(500).send("Error loading the add sentence page.");
    }
});

export { app as appealRoutes };
