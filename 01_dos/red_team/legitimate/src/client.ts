import axios from 'axios';
import { sleep, log, randomInt } from './utils';
import { push as pushToDb } from './db';

const files = Array.from(Array(10).keys())
    .map((i) => (i+1))
    .map((i) => `${i}.html`);

export default async function client(baseUrl: string): Promise<void> {

    const urls = files.map((file) => `${baseUrl}/${file}`);

    // Select a random file among the 10 available
    function randomFile(): string {
        return urls[randomInt(0, urls.length - 1)];
    }

    // Random delay between 1 and 10 seconds
    function randomDelay(): Promise<void> {
        const delay = randomInt(5000, 10000);
        log(`Delaying for ${delay} milliseconds`);
        return sleep(delay);
    }

    while(true) {
        const url = randomFile();
        const userAgent = "AppleCoreMedia/1.0.0.12B466 (Apple TV; U; CPU OS 8_1_3 like Mac OS X; en_us)";
        const result = await request(url, userAgent);

        // if the request was successful, we wait a fairly long time,
        // otherwise we wait a short time
        if(result) {
            await randomDelay();
        } else {
            await sleep(1000);
        }
    }
}

async function request(url: string, userAgent: string): Promise<boolean> {
    log(`Requesting ${url}`);
    const start = Date.now();

    const controller = new AbortController();
    const timeout = setTimeout(() => {
        controller.abort();
    }, 500);


    const request = axios.get(url, {
        headers: {
            'User-Agent': userAgent,
        },
        signal: controller.signal,
    });

    try {
        const response = await request;
        clearTimeout(timeout);
        if(response.status === 200) {
            successfulRequest(start, Date.now());
            return true;
        } else {
            failedRequest(start, Date.now());
            return false;
        }
    } catch(e) {
        clearTimeout(timeout);
        failedRequest(start, Date.now());
        return false;
    }
}

function successfulRequest(start: number, end: number): void {
    pushToDb({
        ts: start,
        status: "OK",
        duration: end - start,
    });
    log(`Successful request in ${end - start} ms`);
}

function failedRequest(start: number, end: number): void {
    pushToDb({
        ts: start,
        status: "KO",
        duration: end - start,
    });
    log(`Failed request in ${end - start} ms`);
}