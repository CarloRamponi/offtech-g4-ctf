USE ctf2;

-- Add a timestamp for each transaction
ALTER TABLE transfers ADD COLUMN timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP;

-- Use BIGINT so that more transactions can be stored on the server
ALTER TABLE transfers MODIFY id BIGINT NOT NULL auto_increment;

-- Create a balances table for easier maintenance of the balance sums
CREATE TABLE balances (user CHAR(20) NOT NULL, balance INT DEFAULT 0, PRIMARY KEY (user)) ENGINE=MyISAM;


DELIMITER $$

-- Trigger for updating the balance table with each new transaction.
-- The new transaction is not accepted if it would bring the balance below zero.
CREATE TRIGGER update_balance BEFORE INSERT ON transfers
FOR EACH ROW
BEGIN
    SELECT balance FROM balances WHERE user=NEW.user INTO @user_balance;
    IF @user_balance + NEW.amount < 0 THEN			
        SIGNAL SQLSTATE '45000' SET message_text = "Balance cannot go below zero!";
    ELSE
        UPDATE balances SET balance=balance+NEW.amount WHERE user=NEW.user;
    END IF;			
END;


-- For each newly registered user initialize an entry in the balances table
CREATE TRIGGER add_balance_for_new_user AFTER INSERT ON users
FOR EACH ROW
    INSERT INTO balances (user) VALUES (NEW.user);


-- Initalize a table for maintaining balances, then update all weak password for current users
CREATE PROCEDURE initBalances ()
BEGIN
	DECLARE finished INTEGER DEFAULT 0;
    
	DECLARE userName varchar(20);

	-- declare cursor for users
	DEClARE curUsers 
		CURSOR FOR 
			SELECT user FROM users;

	-- declare NOT FOUND handler
	DECLARE CONTINUE HANDLER 
        FOR NOT FOUND SET finished = 1;

	OPEN curUsers;

	initializeBalances: LOOP
		FETCH curUsers INTO userName;
		IF finished = 1 THEN 
			LEAVE initializeBalances;
		END IF;

		-- initialize a balance entry for all users
        SELECT SUM(amount) from transfers WHERE user=userName INTO @balance;
		INSERT INTO balances (user, balance) VALUES (userName, @balance);

	END LOOP initializeBalances;
	CLOSE curUsers;
END; $$

DELIMITER ;

CALL initBalancesAndUpdatePasswords();