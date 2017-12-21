#!/usr/bin/env test1_363
# encoding=utf-8

from prettytable import PrettyTable
from fileinput import input
from _dummy_thread import exit

# 定义第一层菜单内容
Start_Menu="""\033[32ma)\033[0m Display all employee information
\033[32mb)\033[0m Find the specified employee information
\033[32mc)\033[0m Quit"""

# 打印菜单并返回用户输入
def _get_start_enter():
    print(Start_Menu)
    User1Enter=input("Please select the option you want to perform: ")
    return User1Enter

# 显示所有员工信息
def _display_all_info():
    with open("/tests/test1/employee_info") as AllEmployeeInfo:
        AllInfoTable = PrettyTable(["User Name","Phone Num","Address","Email"])
        AllInfoTable.align["User Name"] = "l"
        AllInfoTable.padding_width = 1
        for Line in AllEmployeeInfo:
            AllInfoTable.add_row(Line.split())
    
    print(AllInfoTable)

# 获取用户输入的要查找的关键字
def _get_second_enter():
    User2Enter = input("Please input what you want to search: ")
    return User2Enter

# 查找用户指定关键字并打印该行数据
def _search_kw(x):
    with open("/tests/test1/employee_info") as AllEmployeeInfo:
        SearchCount1 = 0
        for Line in AllEmployeeInfo:
            FindFlag1 = Line.find(x)
            if FindFlag1 > 0:
                print(Line)
                SearchCount += 1
        
        if SearchCount1 == 0:
            print("Your keyword was not found.")

# 打印菜单并提示是否继续
Second_Menu="""\033[32ma)\033[0m Continue to find keywords
\033[32mb)\033[0m Return to the previous level
\033[32mc)\033[0m Drop out"""

# 打印第二层菜单并获取用户输入
def _is_continue():
    print(Second_Menu)
    User3Enter=input("Please select the option you want to perform: ")
    return User3Enter

#while True:
Enter1 = _get_start_enter()
if Enter1 == "a":
    _display_all_info()
elif Enter1 == "b":
    while True:
        Enter2 = _get_second_enter()
        _search_kw(Enter2)
        Enter3 = _is_continue()
        if Enter3 == "a":
            pass
        elif Enter3 == "b":
            continue
        elif Enter3 == "c":
            break
elif Enter1 == "c":
    pass