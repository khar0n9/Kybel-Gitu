import re
counter = 0

def get_counter(m):
    global counter
    counter += 1
    return str(counter)

editor.replace('(x)', get_counter, re.IGNORECASE)