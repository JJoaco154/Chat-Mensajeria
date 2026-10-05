const net = require("net");
const readline = require("readline");
const { Pool } = require("pg");

// esto y la parte de abajo es para que funcione con DBeaver y Postgres 
const HOST = process.env.SERVER_HOST || "localhost";
const PORT = Number(process.env.SERVER_PORT) || 3000;

// Configurar el Pool con los datos exactos de tu DBeaver y tambien para el docker-compose.yml
const db = new Pool({
    user: process.env.DB_USER || "postgres",
    host: process.env.DB_HOST || "localhost",
    database: process.env.DB_NAME || "chat_db",
    password: process.env.DB_PASSWORD || "root",
    port: Number(process.env.DB_PORT) || 5432,
    max: 10,
    idleTimeoutMillis: 30000
});

// Verificar la conexión inicial a la base de datos
db.connect((err, client, release) => {
    if (err) {
        console.error("[DB] Error crítico al conectar a PostgreSQL:", err.message);
        process.exit(1);
    }
    console.log("[DB] Pool de PostgreSQL conectado exitosamente");
    release(); 
});

// Conectarse al servidor de chat TCP
const client = net.createConnection({ host: HOST, port: PORT }, () => {
    console.log("[CLI] Conectado al servidor de chat");
});

// Mostrar mensajes recibidos y guardarlos en Postgres
client.on("data", (data) => {
    const message = data.toString().trim();
    console.log(message);

    if (message === "Bienvenido al chat!") return;

    // SOLUCIÓN: Agregamos "public." antes de "mensaje" para guiar a Postgres
    const query = "INSERT INTO public.mensaje (remitente, contenido) VALUES ($1, $2)";
    db.query(query, ["Servidor/Otros", message], (err) => {
        if (err) {
            console.error("[DB] Error al guardar mensaje entrante:", err.message);
        }
    });
});

client.on("end", () => {
    console.log("[CLI] Desconectado del servidor de chat");
    db.end(); 
});

// Configurar la lectura del teclado
const rl = readline.createInterface({
    input: process.stdin,
    output: process.stdout
});

rl.on("line", (line) => {
    const trimmedLine = line.trim();
    if (!trimmedLine) return; 

    client.write(trimmedLine + "\n"); 

    // SOLUCIÓN: Agregamos "public." antes de "mensaje" aquí también
    const query = "INSERT INTO public.mensaje (remitente, contenido) VALUES ($1, $2)";
    db.query(query, ["Yo", trimmedLine], (err) => {
        if (err) {
            console.error("[DB] Error al guardar tu mensaje:", err.message);
        }
    });
});
