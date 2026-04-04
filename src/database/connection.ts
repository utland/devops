import { Pool } from "pg";

const db = new Pool({
    user: "postgres",
    host: "localhost",
    database: "inventory",
    password: "password",
    port: 5432,
});

export default db;