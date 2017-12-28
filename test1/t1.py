# encoding=utf-8

""" Example
Usage:
    t1.py [-c|-d|-m|-h] 
"""

from docopt import docopt

if __name__ == "__main__":
    Argus=docopt(__doc__)
    print(Argus)
