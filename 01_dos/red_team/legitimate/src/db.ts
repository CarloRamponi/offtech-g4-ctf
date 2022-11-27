import fs from 'fs';

type Record = {
    ts: number,
    status: "OK" | "KO",
    duration: number,
}

const db:Record[] = [];

if(fs.existsSync('db.json')) {
    db.push(...JSON.parse(fs.readFileSync('db.json', 'utf8')));
}

const subscriptions:((record: Record) => void)[] = [];

function updateDb() {
    fs.writeFile('db.json', JSON.stringify(db), () => {});
}

export function push(record: Record): void {
    db.push(record);
    subscriptions.forEach((callback) => callback(record));
    updateDb();
}

export function get(): Record[] {
    return db;
}

export function subscribe(callback: (record: Record) => void): void {
    subscriptions.push(callback);
}

export function unsubscribe(callback: (record: Record) => void): void {
    const index = subscriptions.indexOf(callback);
    if(index !== -1) {
        subscriptions.splice(index, 1);
    }
}