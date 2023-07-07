import json
from os import chdir
from os.path import dirname, join, basename, splitext
import requests as req
import browser_cookie3
from time import strftime, localtime, sleep
from random import randint, random
from urllib.parse import quote
from sys import argv
from bs4 import BeautifulSoup


for i, a in enumerate(argv):
    print(f'{i}): {a}')


input()
