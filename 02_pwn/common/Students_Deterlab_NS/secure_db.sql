USE ctf2;

-- Add a timestamp for each transaction
ALTER TABLE transfers ADD COLUMN timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Use BIGINT so that more transactions can be stored on the server
ALTER TABLE transfers MODIFY id BIGINT NOT NULL auto_increment;