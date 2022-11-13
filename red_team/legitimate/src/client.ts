import axios from 'axios';
import randomUserAgent from 'random-useragent';
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
        const delay = randomInt(1000, 10000);
        log(`Delaying for ${delay} milliseconds`);
        return sleep(delay);
    }

    while(true) {
        const url = randomFile();
        const userAgent = randomUserAgent.getRandom();
        request(url, userAgent);
        await randomDelay();
    }
}

async function request(url: string, userAgent: string): Promise<void> {
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

    request.then((response) => {
        clearTimeout(timeout);
        if(response.status === 200) {
            successfulRequest(start, Date.now());
        } else {
            failedRequest(start, Date.now());
        }
    }).catch(() => {
        clearTimeout(timeout);
        failedRequest(start, Date.now());
    })
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