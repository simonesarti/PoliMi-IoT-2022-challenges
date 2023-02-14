import requests

# Make the get request to gather fields values
channel_id = "1710551"
url = f"https://api.thingspeak.com/channels/{channel_id}/fields/1&2&5.json"
r = requests.get(url=url)
data = r.json()

# Filter out the needed data
fields1, fields2, fields5 = [],[],[]
for d in data['feeds']:
    fields1.append(float(d['field1']))
    fields2.append(float(d['field2']))    
    fields5.append(float(d['field5']))    
   
assert len(fields1)==100    
assert len(fields2)==100    
assert len(fields5)==100         

# Prepare the submission values for the form as csv format
with open("fields.txt","w") as f:
    for item in fields1:
        f.write("%s, " % item)
    f.write("\n")    
    for item in fields2:
        f.write("%s, " % item)
    f.write("\n")
    for item in fields5:
        f.write("%s, " % item)    
    f.write("\n") 