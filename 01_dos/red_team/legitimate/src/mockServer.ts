import express from 'express';
import { randomInt, sleep } from './utils';

const settings = require("../settings.json").mock_server;

if(settings.enabled) {

    const app = express();
    const port = settings.port;

    app.get('/:file', async (req, res) => {
        if(randomInt(0, 4) !== 0) {
            await sleep(randomInt(0, 1000));
            res.sendStatus(200);
        } else {
            res.sendStatus(500);
        }
    });

    app.listen(port, () => {
        console.log(`Mock server listening at http://localhost:${port}`);
    });

}