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


chdir(dirname(__file__))

host = 'https://disk.yandex.ru/'
mycookies = browser_cookie3.chrome(domain_name='.yandex.ru')
ses = req.Session()

h = {
    'Accept': 'application/json, text/javascript, */*; q=0.01',
    'Accept-Encoding': 'gzip, deflate, br',
    'Accept-Language': 'ru-RU,ru;q=0.9,en-US;q=0.8,en;q=0.7',
    'Cache-Control': 'no-cache',
    'Connection': 'keep-alive',
    'Host': 'disk.yandex.ru',
    'Pragma': 'no-cache',
    'sec-ch-ua': '".Not/A)Brand";v="99", "Google Chrome";v="103", "Chromium";v="103"',
    'sec-ch-ua-mobile': '?0',
    'sec-ch-ua-platform': '"Windows"',
    'Sec-Fetch-Dest': 'document',
    'Sec-Fetch-Mode': 'navigate',
    'Sec-Fetch-Site': 'none',
    'Sec-Fetch-User': '?1',
    'Upgrade-Insecure-Requests': '1',
    'User-Agent': 'Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/103.0.0.0 Safari/537.36'
}

ses.headers.update(h)
ses.cookies = mycookies

for i, a in enumerate(argv):
    print(f'{i}): {a}')

try:
    # 0. Сначала откроем сайт, и получим некоторые данные
    r = ses.get('https://disk.yandex.ru/client/albums')
    print(r.status_code)
    soup = BeautifulSoup(r.text, 'html.parser')
    script_tags = soup.find_all('script')
    for i, s in enumerate(script_tags):
        try:
            if s['id'] == 'preloaded-data' and s['type'] == 'application/json':
                break
        except Exception as e:
            # print(e)
            # print(f'{i=}')
            pass

    j = json.loads(s.string)

    sk = j['config']['sk']
    idClient = j['config']['idClient']
    print(sk, idClient)

    # Запрос добавления в альбом
    data = {
        'idClient': idClient,
        'sk': sk,
        '_model.0': 'do-add-resources-to-album',
        'id.0': argv[1],  # '630097b344ca3b2a9d2de2bb',
        'resourcesIds.0': argv[2],  # r'["/photounlim/2022-08-17 12-11-47.JPG","/photounlim/2022-08-17 12-11-41.JPG","/photounlim/2022-08-17 12-11-39.JPG"]'
    }
    r = ses.post('https://disk.yandex.ru/models/?_m=do-add-resources-to-album', data=data)
    print(r.status_code)
    print(r.text)

    # input()

except Exception as e:
    print(e)
finally:
    ses.close()
