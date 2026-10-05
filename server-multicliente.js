// server-chat.js
const net = require("net");
let clients = []; 
let clienteCounter = 0; 

const PORT = 3000;

const server = net.createServer((socket) => {
    clienteCounter++;
    socket.id = clienteCounter;
    socket.name = `Usuario_${socket.id}`;

    const peer = `${socket.remoteAddress}:${socket.remotePort}`;
    console.log(`[SRV] Cliente conectado: ${peer}`);
    clients.push(socket);

    socket.write("Bienvenido al chat!\n");

    socket.on("data", (data) => {
        // Evitar ataques DoS limitando el tamaño del mensaje
        if (data.length > 1024) { 
            socket.write("Error: Mensaje demasiado largo.\n");
            return;
        }

        const msg = data.toString().trim();
        if (!msg) return; 

        console.log(`[${socket.name}] ${msg}`);

        // Reenviar a los demás usuarios conectados
        clients.forEach((c) => {
            if (c !== socket && !c.destroyed) {
                c.write(`[${socket.name}] ${msg}\n`);
            }
        });
    });

    socket.on("error", (err) => {
        console.error(`[SRV] Error con ${socket.name}:`, err.message);
    });

    socket.on("close", () => {
        console.log(`[SRV] Conexión cerrada con: ${peer}`);
        clients = clients.filter(c => c !== socket);
    });
});

server.listen(PORT, () => {
    console.log(`[SRV] Servidor de chat corriendo en el puerto ${PORT}`);
});
