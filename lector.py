#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Fri Jul 23 13:26:40 2021

@author: ivan
"""
from urllib.request import urlopen

import requests  
import time
import json
url = "http://192.168.1.145/solar_api/v1/GetInverterRealtimeData.cgi?Scope=Device&DeviceId=1&DataCollection=CommonInverterData"

WhOld = 0
idCEL = 0
while(True):
    
    try:
        response = urlopen(url)
          
        data_json = json.loads(response.read())
          
        print(data_json)
        
        filename = 'data.json'          #use the file extension .json
        with open(filename, 'a') as file_object:  #open the file in write mode
         json.dump(data_json, file_object)   # json.dump() function to stores the set of numbers in numbers.json file
        
        StatusCode = data_json['Body']['Data']['DeviceStatus']['StatusCode']
        Wh  = data_json['Body']['Data']['DAY_ENERGY']['Value']
        
        if (StatusCode == 7) and ((Wh - WhOld) > 0):
        
            #data_json['Body']['Data']['PAC']['Value']
            #Wh  = data_json['Body']['Data']['DAY_ENERGY']['Value']
            FAC = data_json['Body']['Data']['FAC']['Value']
            IAC = data_json['Body']['Data']['IAC']['Value']
            IDC = data_json['Body']['Data']['IDC']['Value']
            PAC = data_json['Body']['Data']['PAC']['Value']
            TE  = data_json['Body']['Data']['TOTAL_ENERGY']['Value'] 
            YE  = data_json['Body']['Data']['YEAR_ENERGY']['Value']
            UAC = data_json['Body']['Data']['UAC']['Value']
            UDC = data_json['Body']['Data']['UDC']['Value']
            
            WhReal = Wh - WhOld
            datos = {"idPP": "LiCore", "WH": WhReal, "A": IAC, "Hz": FAC, 
                     "PhVphA": TE, "VA": YE, "Evt1": UAC, "Evt2": UDC, 
                     "StVnd": 3, "EvtVnd1": 3, "DCV": IDC, "St": 2, 
                     "AphA": 2,"W": PAC, "DCW": 3, "VAr": 8, "PF": 4, 
                     "DCA": 3, "EvtVnd4": 7, "EvtVnd3": 9}
            
            print(datos)
            
            filename = 'datos.json'          #use the file extension .json
            with open(filename, 'a') as file_object:  #open the file in write mode
             json.dump(datos, file_object)   # json.dump() function to stores the set of numbers in numbers.json file
            
            response = requests.post('http://licore.tlachia.com:23456/createMicroCELs/ZF' + str(idCEL) + 'x', '[' + str(datos) + ']')
        
            print("Status code: ", response.status_code)
            print("Printing Entire Post Request")
            print(response)
        
            
            #WhOld = Wh
            idCEL += 1
        else:
            print("No solar production")
        
        WhOld = Wh
        print(WhOld)
    except:
        print("Cannot connect to inverter")
        
    time.sleep(50)
    
