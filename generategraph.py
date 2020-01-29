#!/usr/bin/python3

import json
import matplotlib
matplotlib.use('agg')

import matplotlib.pyplot as plt
import matplotlib.ticker as ticker
import matplotlib.dates as mdates
import datetime
import numpy as np
from datetime import date, timedelta

overrall_jsn = json.load(open("info.json"))
jsn = json.loads(overrall_jsn['download_breakdown'])

for group in jsn:
             if group['label'] == "Public":
	                  public=[val for (timestamp, val) in group['data']]
             elif group['label'] == "Guest":
                          if group['data'] is not None:
                                       guest=[val for (timestamp, val) in group['data']]
                          else:
                                       guest=None
                          
index = range(len(public))		  
width = 0.9
fig = plt.figure(figsize=(16, 10))
ax = fig.add_subplot(111)

#define multiples that y axis will count by
ax.yaxis.set_major_locator(ticker.MultipleLocator(10000))
ax.yaxis.set_minor_locator(ticker.MultipleLocator(10000))

#draw bars
p1=plt.bar(index, public, width=0.9)
p2=plt.bar(index, guest, width=0.9, bottom=public)

#define title
yesterday=date.today() - timedelta(1)

plt.title('Downloaded Data Breakdown [MB Down] - %s' % (yesterday.strftime('%b, %d %Y')))


#list of times
times=[datetime.datetime.strptime(str(i), '%H') for i in range(24)]

plt.xticks(np.arange(min(times), max(times), 1.0))                   
#define legend
if guest is not None or public is not None:
             plt.legend((p1[0], p2[0]), ('MemorialRES', 'MemorialRES-Guest'))
plt.grid()

plt.savefig("my_mun_barchart.png")

