import express from 'express';
import ws from 'ws';
import { get as getDB, subscribe as subscribeDB } from './db';

const settings = require("../settings.json").stats;

if(settings.enabled) {

    const port = settings.port;
    const app = express();

    app.use(express.static('statsServer'));

    const wss = new ws.Server({ noServer: true });

    const db = getDB();

    wss.on('connection', (ws) => {
        ws.send(JSON.stringify(db));
    });

    subscribeDB((record) => {
        wss.clients.forEach((client) => {
            client.send(JSON.stringify([record]));
        });
    });


    const server = app.listen(port, () => {
        console.log(`Stats server listening at http://localhost:${port}`);
    });

    server.on('upgrade', (request, socket, head) => {
        wss.handleUpgrade(request, socket, head, (ws) => {
            wss.emit('connection', ws, request);
        });
    });

}