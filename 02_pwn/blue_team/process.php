<html>
<body>

<?php

$myFile = "/tmp/request.log";
$fh = fopen($myFile, 'a');

// Only allow alphanumeric characters for both the username and the password
$user = preg_replace("/[^a-zA-Z0-9]/", '', $_GET["user"]);
$pass = $_GET["pass"];
$choice = $_GET["drop"];

$valid_actions = array('register', 'balance', 'deposit', 'withdraw');
if (!in_array($choice, $valid_actions))
{
  die('Invalid action!');
}

$mysqli = new mysqli('localhost', 'application', '26x0vVe71B8qY0jbMKDz1mc7UnAYhXkX', 'ctf2');
if (!$mysqli) 
{
   die('Could not connect: ' . $mysqli->error());
}

$url="process.php?user=$user&pass=$pass&drop=balance";

if ($choice == 'register')
{
  if (strlen($user) < 4 || strlen($user) > 20 || strlen($pass) < 6 || strlen($pass) > 50)
  {
    die('Username and/or password are not of allowed length!');
  }
    
  $hashed_password = password_hash($pass, PASSWORD_DEFAULT);
  $prep_stmt = $mysqli->prepare("insert into users (user,pass) values (?, ?)");
  $prep_stmt->bind_param("ss", $user, $hashed_password);
  $prep_stmt->execute() or die('Username already taken!');

  die('<script type="text/javascript">window.location.href="' . $url . '"; </script>');
}

// The remaining three actions require user authentication
$prep_stmt = $mysqli->prepare("select pass from users where user=?");
$prep_stmt->bind_param("s", $user);
$prep_stmt->execute();
$hashed_password = $prep_stmt->get_result()->fetch_row()[0];

if (!password_verify($pass, $hashed_password))
{
  die('User authentication failed!');
}

if ($choice == 'balance')
{
  $prep_stmt = $mysqli->prepare("select * from transfers where user=?");
  $prep_stmt->bind_param("s", $user);
  $prep_stmt->execute();
  $result = $prep_stmt->get_result();

  $sum = 0;

  print "<H1>Balance and transfer history for $user</H1><P>";
  print "<table border=1><tr><th>Action</th><th>Amount</th></tr>";

  while ($row = $result->fetch_array())
  {
    $amount = $row['amount'];
    if ($amount < 0)
    {
      $action = "Withdrawal";
      }
    else
    {
      $action = "Deposit";
    }
      print "<tr><td>" . $action . "</td><td>" . $amount . "</td></tr>";
      $sum += $amount;
    }
    print "<tr><td>Total</td><td>" . $sum . "</td></tr></table>";
    print "Back to <A HREF='index.php'>home</A>";		    
}
else 
{
  // The remaining two operations use the $amount variable
  $amount = $_GET["amount"];

  if(!is_numeric($amount) || $amount < 1) {
    die('Invalid value provided as amount!');
  }

  if ($choice == 'deposit')
  {
    $prep_stmt = $mysqli->prepare("insert into transfers (user,amount) values (?, ?)");
    $prep_stmt->bind_param("si", $user, $amount);
    $prep_stmt->execute();    

    die('<script type="text/javascript">window.location.href="' . $url . '"; </script>');
  }
  else
  {
    $amount = -1 * $amount;
    $prep_stmt = $mysqli->prepare("insert into transfers (user,amount) values (?, ?)");
    $prep_stmt->bind_param("si", $user, $amount);
    $prep_stmt->execute() or die('Insufficient balance!'); 

    die('<script type="text/javascript">window.location.href="' . $url . '"; </script>');
  }
}

//Log data for scoring
$query = "select * from transfers";
$result = $mysqli->query($query);
fwrite($fh, "BEGIN\n");
fwrite($fh, "TRANSFERS\n");
while ($row = $result->fetch_array())
{
    fwrite($fh, $row['user'] . " " . $row['amount'] . " " . $row['timestamp'] . "\n");
}
$query = "select * from users";
$result = $mysqli->query($query);
fwrite($fh, "USERS\n");
while ($row = $result->fetch_array())
{
    fwrite($fh, $row['user'] . " " . $row['pass'] . "\n");
}
fwrite($fh, "END\n");
?>

</body>
</html>
