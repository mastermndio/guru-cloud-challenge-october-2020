import boto3
from datetime import datetime
#Initialize Dynamo Service
dynamodb = boto3.resource('dynamodb')

table = dynamodb.Table('cloudGuruChallenge')

def updateTable(date, usCases, deaths, recoveries):
    table.put_item(
        Item={
            'Date': datetime.strftime(date, '%Y-%m-%d'),
            'UsCases': int(usCases),
            'Deaths': int(deaths),
            'Recoveries': int(recoveries)
        }
    )

    print(f"{date} has been updates in DynamoDB")