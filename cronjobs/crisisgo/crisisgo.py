#!/usr/bin/python3

import datetime as dt
import hashlib
import json
import os
from   pandas.tseries.holiday import USFederalHolidayCalendar
import requests
import time

TOPDIR = os.path.dirname(os.path.realpath(__file__))
RESULTS_FNAME = os.path.join(TOPDIR, "results.json")

# 1. write_data option_id and value are both the item value of the "no" checkbox
# 2. the token is the md5 checksum of the JSON string of everything alphabetized
#    and some salt:
#
#       function getToken(param, ignore) {
#           var param_arr = [];
#           $.each(param, function(index, value) {
#               if (ignore.indexOf(index) === -1) {
#                   param_arr.push(index)
#               }
#           })
#           param_arr = param_arr.sort();
#           var token = '';
#           $.each(param_arr, function(index, value) {
#               token += value + 'ipass' + param[value]
#           })
#           return md5(token)
#       }
#
#    the checksum is taken without the ignore or token fields

report_param = {
    "creator_type"        : 1,
    "creator_user_id"     : "4970818",
    "customer_id"         : "54311",
    "email"               : "tmenninger@ghs.com",
    "ignore"              : [ "write_data" ],
    "language"            : "en_US",
    "language_name"       : "English",
    "model_id"            : "472",
    "phone"               : "",
    "preview"             : 0,
    "source"              : "0",
    "temp_id"             : "",
    "template_version"    : "2021-08-17 17:23:41",
    "timezone"            : 420,
    "type"                : 1,
    "unit_name"           : "Main",
    "unit_uuid"           : "be9e78b6f84d93aee70e67327ef7f8b6",
    "user_id"             : "4970818",
    "user_uuid"           : "9ece6ffeebf24ed1bc8e6bdd21ebce67",
    "username"            : "Tim Menninger",
    "write_data"          : {
        "CreateChoiceDiv9433716" : {
            "type"    : "single-choose",
            "value"   : {
                "option_id"   : "k6b8qhmgslrdoylj35y4opa4lj0yhcd2",
                "type"        : "option",
                "value"       : "k6b8qhmgslrdoylj35y4opa4lj0yhcd2"
            }
        }
    }
}

def getToken(param):
    return hashlib.md5("".join([ "ipass".join([ k, str(param[k]) ]) for k in sorted(param) if k != "ignore" and k not in param["ignore"]]).encode()).hexdigest()
report_param["token"] = getToken(report_param)




results = {}
if os.path.exists(os.path.join(TOPDIR, "results.json")):
    with open(RESULTS_FNAME, "r") as f:
        results = json.load(f)
        assert(type(results) == type({}))




TODAY = dt.date.today()
UNIX = int(time.mktime(dt.datetime.now().timetuple()))

IS_WEEKDAY = TODAY.weekday() in range(0, 5)
IS_HOLIDAY = TODAY in USFederalHolidayCalendar().holidays(start="2021-01-01", end="2050-01-01").to_pydatetime()
IS_WORKDAY = (IS_WEEKDAY and not IS_HOLIDAY)
REPORTED_TODAY = not (len(results) > 0 and max(results) < str(TODAY))

if IS_WORKDAY and not REPORTED_TODAY:
    res = requests.post("https://report.crisisgo.net/safety_ipass", json=report_param)
    results[str(TODAY)] = {
        "unix" : UNIX,
        "report_param" : report_param,
        "response" : {
            "status" : "{} - {}".format(res.status_code, res.reason),
            "url" : res.url,
            "text" : json.loads(res.text)
        }
    }

    with open(RESULTS_FNAME, "w+") as f:
        json.dump(results, f, sort_keys=True, indent=4)

