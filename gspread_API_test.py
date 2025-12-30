import gspread
from google.oauth2.service_account import Credentials



# Scope – práva, ktoré aplikácia potrebuje
SCOPES = [
    "https://www.googleapis.com/auth/spreadsheets",
    "https://www.googleapis.com/auth/drive"
]

# Načítanie service account JSON kľúča
creds = Credentials.from_service_account_file(r"C:\Users\pk922g\Downloads\money-tracker-api-469015-5dfebcefb560.json", scopes=SCOPES)

# Autorizácia a otvorenie spreadsheetu
client = gspread.authorize(creds)

# Otvorenie spreadsheetu podľa názvu
spreadsheet = client.open("Money tracker")

# Vybratie konkrétneho sheetu (listu) podľa názvu
worksheet = spreadsheet.worksheet("Income")

# Zápis hodnoty do bunky C75
worksheet.update([["2386"]], "B4")

print("Hotovo – hodnota '2386' bola zapísaná do Expenses!C76")