#!/usr/bin/env test1_363
# encoding=utf-8

#### Employee information in tabular form

# import module
from prettytable import PrettyTable

def Display_All_Info_():
    with open("/projects/test1/employee_info","r") as EmployeeInfo:
        # 设置表格格式与对齐
        AllInfoTable = PrettyTable(["User Name","Phone Num","Address","Email"])
        AllInfoTable.align["User Name"]="l"
        AllInfoTable.padding_width=1
    
        for Line in EmployeeInfo:
            AllInfoTable.add_row(Line.split())
    
    print(AllInfoTable)


Menu="""\033[32ma)\033[0m Display all employee information
\033[32mb)\033[0m Find the specified employee information
\033[32mc)\033[0m quit"""
UserChoice=""

def Menu_():
    print(Menu)
    UserChoice=input("Please select the option you want to perform: ")
    return UserChoice

UserChoice=Menu_()

while True:
    if UserChoice == "a":
        Display_All_Info_()
        break
    elif UserChoice == "b":
        print(UserChoice)
        break
    elif UserChoice == "q":
        break
    else:
        print("out of options")
        continue


