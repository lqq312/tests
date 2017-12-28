# encoding=utf-8

import click
@click.command()
@click.option('--count',default=1,help="Number of greetings.")
@click.option('--name',prompt='Your name',help="The person to greet")

def f1(count,name):
    print(count,name)

f1()
