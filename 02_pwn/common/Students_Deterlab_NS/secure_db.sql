USE ctf2;

-- Add a timestamp for each transaction
ALTER TABLE transfers ADD COLUMN timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP;