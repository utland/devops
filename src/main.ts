import express from "express";
import itemsRouter from "./routes/items.js";
import healthRouter from "./routes/health.js";
import rootRouter from "./routes/root.js"

const app = express();

app.use(express.json());

app.use("/items", itemsRouter);
app.use("/health", healthRouter);
app.use("/", rootRouter);

if (process.env.LISTEN_FDS === '1') {
    const server = app.listen({ fd: 3 }, () => {
        console.log('App is listening on systemd socket (fd 3)');
    });
} else {
    const port = process.env.PORT || 8000;
    app.listen(port, () => {console.log(`App is listening on port ${port}`);
    });
}