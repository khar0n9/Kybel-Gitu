from Npp import *
import sys


console.clear()
console.show()

#if prvych x pismen neni interface tak vypise toto a posle break
#notepad.messageBox( "You haven't coppied interface configuration !"
#,'ERROR'
#,MESSAGEBOXFLAGS.ICONERROR)

#co keby si spravim temp file kde to tam nadrbem potm spravim analyzu (ci tam je vykricnik pred a po alebo neni vobec a potom obsah file upravim a skopcim a file zmazem
#temp = editor.paste()

input_count = int(notepad.prompt('What is the starting port number?'
,'Insert the number and press OK'))

input_x = int(notepad.prompt('How many times u wish to paste coppied text?'
,'Insert the number and press OK'))

for x in range(0, input_x):
    editor.paste()
    editor.addText('\n!\n')


##############################################################################################

import re
input_count = input_count - 1
print(input_count)

def get_counter(m):
    global input_count
    input_count += 1
    return str(input_count)
    
    
    

editor.replace('(x)', get_counter, re.IGNORECASE)

console.hide()