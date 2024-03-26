#!/bin/python3
import requests
from bs4 import BeautifulSoup as sp
from os import system, mkdir, chdir
from sys import argv
import time


def find_pics(site: str) -> list:
    def page_pic():
        re1 = requests.get(link)
        soup1 = sp(re1.content, "html.parser")
        pic = soup1.select(".wallpaper__image")
        pic = pic[0]["src"]
        pics.append(pic)

    headers = {
        "User-Agent": "Mozilla/5.0 (Windows NT 6.3; Win64; x64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/54.0.2840.71 Safari/537.36"
    }
    re = requests.get(site, headers=headers)
    soup = sp(re.content, "html.parser")
    x = soup.select("li.wallpapers__item > a:nth-child(1)")
    links = ["https://wallpaperscraft.com" + str(i["href"]) for i in x]

    pics = []

    print("finding pic")
    for link in links:
        try:
            page_pic()
        except:
            try:
                time.sleep(5)
                page_pic()
            except:
                pass
    return pics


def download_pics(pics):
    print("downloading pic")
    for pic in pics:
        system("aria2c -c {}".format(pic))


def make_dir():
    dir = argv[3]
    try:
        mkdir(f"{dir}")
        chdir(f"{dir}")
    except FileExistsError:
        chdir(f"{dir}")
    else:
        print("error")


if "__main__" == __name__:
    # jost dl one page
    # print(argv)
    if len(argv) == 2:
        make_dir()
        site = argv[1]
        pics = find_pics(site)
        download_pics(pics)

    # dl range of page
    elif len(argv) >= 2:
        make_dir()

        pages = argv[1]
        site = argv[2]
        print(f"pages: {pages}, site: {site}")
        try:
            page = site.split("/")[-1]
            page_number = int(page.split("page")[-1])
            # delete page number
            site = "/".join(site.split("/")[:-1])
            # edit end of dl range
            pages = int(pages) + page_number
            # start in most of page 1
            link_pages = [
                site + "/page" + str(i) for i in range(page_number, int(pages) + 1)
            ]
        except:
            # start in page 1
            link_pages = [site + "/page" + str(i) for i in range(1, int(pages) + 1)]

        system("notify-send -u low 'search wallpaper'")
        for page in link_pages:
            site = page
            pics = find_pics(site)
            download_pics(pics)
