import data_processor

def handler(event, context):
    nytUrl = "https://raw.githubusercontent.com/nytimes/covid-19-data/master/us.csv"
    hopkinsUrl = "https://raw.githubusercontent.com/datasets/covid-19/master/data/time-series-19-covid-combined.csv?opt_id=oeu1606175811275r0.2180143506041583"

    nytData = data_processor.getUpdatedData(nytUrl)
    recoveryData = data_processor.getUpdatedData(hopkinsUrl)

    result = data_processor.parseData(nytData, recoveryData)
    data_processor.pushToDynamo(result)