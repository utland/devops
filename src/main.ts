import express from "express";
import itemsRouter from "./routes/items.js";
import healthRouter from "./routes/health.js";
import rootRouter from "./routes/root.js"

const app = express();

app.use(express.json());

app.use("/items", itemsRouter);
app.use("/health", healthRouter);
app.use("/", rootRouter);

app.listen(3000, () => {
    console.log("Server is running on port 3000");
});