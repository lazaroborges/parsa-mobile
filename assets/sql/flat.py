import json
import pandas as pd
from pandas import json_normalize

# Load JSON data from a file
with open('initial_categories.json', 'r') as file:
    data = json.load(file)

# Flatten JSON data
df = json_normalize(data)

# Export to CSV
df.to_csv('output.csv', index=False)

print("CSV file has been created successfully.")