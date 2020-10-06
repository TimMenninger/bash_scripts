#!/usr/bin/python3
# Download the helper library from https://www.twilio.com/docs/python/install
from twilio.rest import Client

import sys

sender = "+18056003444"
recipient = sys.argv[1]
if recipient[0] != "+":
    if recipient[0] != "1":
        recipient = "+1" + recipient
    else:
        recipient = "+" + recipient

body = " ".join(sys.argv[2:])

# Your Account Sid and Auth Token from twilio.com/console
# DANGER! This is insecure. See http://twil.io/secure
account_sid = 'AC3f51b0e1002cf05fdb5d3f96d343e4d6'
auth_token = 'e0e5719e4629301aa2f9133a964d1fab'
client = Client(account_sid, auth_token)

message = client.messages \
    .create(
        body=body,
        from_=sender,
        to=recipient
    )

