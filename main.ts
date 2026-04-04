import express from "express";
import itemsRouter from "./src/routes/items.js";
import healthRouter from "./src/routes/health.js";

const app = express();

app.use(express.json());

app.use("/items", itemsRouter);
app.use("/health", healthRouter);

app.listen(3000, () => {
    console.log("Server is running on port 3000");
});