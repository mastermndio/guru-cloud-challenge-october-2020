import requests
from datetime import datetime
from pprint import pprint
import dynamo_helper

#Download NYT CSV
def getUpdatedData(url):
    data = requests.get(url)
    return data.content.decode('utf-8').splitlines()

def parseData(mainData, recoveryData):
    dates = []
    usCases = []
    deaths = []
    recoveries = {}
    finalData = {}

    # Split rows and sort them into appropriate collection
    for row in mainData[1:]:
        splitData = row.split(',')
        dates.append(dateConverter(splitData[0]))
        usCases.append(splitData[1])
        deaths.append(splitData[2])

    for row in recoveryData:
        if "US" in row:
            splitData = row.split(',')
            recoveries.update({dateConverter(splitData[0]): splitData[4]})
            
    for i in range(len(dates)):
        try:
            finalData.update({dates[i]: [usCases[i], deaths[i], recoveries[dates[i]]]})
        except:
            print("Date Not Found")
            continue

    return finalData

def dateConverter(date):
    return datetime.strptime(date, '%Y-%m-%d')

def pushToDynamo(finalData):
    for key, val in finalData.items():
        dynamo_helper.updateTable(key, val[0], val[1], val[2])

def extract():
    nytData = getUpdatedData('https://raw.githubusercontent.com/nytimes/covid-19-data/master/us.csv')
    recoveryData = getUpdatedData('https://raw.githubusercontent.com/datasets/covid-19/master/data/time-series-19-covid-combined.csv?opt_id=oeu1606175811275r0.2180143506041583')

    result = parseData(nytData, recoveryData)
    pushToDynamo(result)


extract()