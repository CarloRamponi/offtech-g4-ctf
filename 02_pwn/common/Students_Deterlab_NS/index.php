<html>
<body>

<form action="process.php" method="get">
Username: <input required type="text" name="user" minlength="4" maxlength="20" pattern='[a-zA-Z0-9]+'>
Password: <input required type="password" name="pass" minlength="6" maxlength="32" pattern='[a-zA-Z0-9]+'>
Amount: <input type="number" name="amount" min="1" max="2147483647">
Action: <select name='drop'>
  <option value='balance'>Balance and transfer history</option>
  <option value='register'>Register</option>
  <option value='deposit'>Deposit</option>
  <option value='withdraw'>Withdraw</option>
</select>
<input type="submit">
</form>

</body>
</html>
