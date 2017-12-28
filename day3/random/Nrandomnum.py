# encoding=utf-8

import random

NumList=[]

def _gen_random_number(x):
    for i in range(x):
        if i == random.randint(1,5):
            NumList.append(str(i))
        else:
            NumList.append(chr(random.randint(65,90)))
    
    return "".join(NumList)

def _get_user_enter():
    Enter1=input("Please enter the number: ")
    Enter1=Enter1.strip()
    if Enter1.isnumeric():
        return Enter1
    else:
        return False

if __name__ == "__main__"
