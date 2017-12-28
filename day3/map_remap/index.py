# encoding=utf-8
from importlib._bootstrap import __import__

Modu_Name="modu1"
Func="f1"
Modu1=__import__(Modu_Name)

F1=getattr(Modu1,Func)
print(F1())