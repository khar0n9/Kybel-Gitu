import secrets

#password_length = int(input("Please enter desired password's length:"))
#print(secrets.token_bytes(password_length))


import string
#alphabet = string.ascii_letters + string.digits + '!@#$%^&*()'
alphabet = string.ascii_letters + string.digits + '@,.!+=%_-$' #toto je pre GTAC generation..


password = ''.join(secrets.choice(alphabet) for i in range(int(input("Please enter desired password's length:"))))
print(password)