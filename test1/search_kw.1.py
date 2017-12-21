#!/usr/bin/env test1_363
# encoding=utf-8

from prettytable import PrettyTable
from fileinput import input

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
    with open("/projects/test1/employee_info") as AllEmployeeInfo:
        AllInfoTable=PrettyTable(["User Name","Phone Num","Address","Email"])
        AllInfoTable.align["User Name"]="l"
        AllInfoTable.padding_width=1
        for Line in AllEmployeeInfo:
            AllInfoTable.add_row(Line.split())
    
    print(AllInfoTable)

def _get_second_enter():
    User2Enter=input("Please input what you want to search: ")
    return User2Enter

def _search_kw(x):
    with open("/projects/test1/employee_info") as AllEmployeeInfo:
        for Line in AllEmployeeInfo:
            Line.

def _judge_1_enter(x):
    if x == "a":
        _display_all_info()
    elif x == "b":
        # 查找关键字
    elif x == "q":
        # 退出程序
    else:
        print("out of option")