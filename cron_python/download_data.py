import time
from datetime import date, datetime as dt
from datetime import datetime, timedelta
import jq
from tqdm import tqdm
import json
import pickle
import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import numpy as np
import vk

import schedule
import time

session = vk.Session(access_token='*******')
api = vk.API(session, v='5.131')

list_communities = ['nichoneponimayu', 'humour.page', 'crazy_humor1', 'ilikes',  'botjoe',  'sociopat_ru', 'sh_ring', 'r0fl1m', 'dayvinchik', 'memes_bot', 'in.humour', 'surreal.memes', 'fruitveg', 'prekoli_blya', 'scolu', 'not_rofl', 'school.memy', 'invertedmemes', 'memsfrom2k11', 'weirdreparametrizationtrick', 'otchisleno', 'humor_schrodinger', 'stlbn', 'mhkon', 'jumoreski', 'mudakoff', 'sarsar']

def post_has_closed_comments(community_id, post_id):
    cmts = api.wall.getComments(owner_id=community_id, post_id=post_id)
    return cmts['count'] > 0 and len(cmts['items']) == 0

def parse_fresh_posts_community(name_comm):
    len_community = api.wall.get(domain=name_comm)['count']
    common_list_params = []
    for i in tqdm(range(0, len_community+1, 100)):
        #print(i)
        cur_res = api.wall.get(domain=name_comm, count=100, offset=i)
        time.sleep(1)
        # берем те посты, которые не являются рекламой, а также, где есть attachments 
        # и пока берем только посты с ОДНОЙ фоткой
        list_filtr = list(filter(lambda x: x['marked_as_ads'] == 0 and 'attachments' in x 
                                 and len(x['attachments']) == 1 
                                 and x['attachments'][0]['type'] == 'photo'
                                 and not post_has_closed_comments(x['owner_id'], x['id']), 
                                 cur_res['items']))

        common_list_params = common_list_params + list_filtr
        date_posted = pd.to_datetime(jq.compile('.items[-1].date | localtime | strftime("%Y-%m-%d %H:%M:%S")').input(cur_res).first())
        now = datetime.now()
        if date_posted < (now - timedelta(days=14)):
            break
            
    res_params_l = common_list_params.copy()
    now_time = str(dt.now())
    res_dict = {"now_time": now_time, "items": res_params_l }
    del res_dict['items'][0] #чтобы удалить pinned пост
    own_id = res_dict['items'][0]['owner_id']
    a_file = open(f"{name_comm}_{now_time}.pkl", "wb")
    pickle.dump(res_dict, a_file)
    a_file.close()
    return res_dict

schedule.every().hour.do(parse_fresh_posts_community, 'jokesss')

while True:
    schedule.run_pending()
    time.sleep(1)
