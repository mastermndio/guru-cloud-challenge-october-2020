#!/bin/bash

pip3 install -t ../data-loader requests
pip3 install -t ../data-loader boto3
zip -r data-processor.zip ../data-loader -x "__pycache__"