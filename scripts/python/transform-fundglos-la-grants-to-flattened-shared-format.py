#!/usr/bin/env python3

# This script is adapted from the DeepNote Notebook by Isabel Precious-Birds <isabel.birds@opendataservices.coop>
# 
# https://deepnote.com/workspace/Open-Data-Services-Cooperative-46a54078-1c9e-4c25-b08c-69c3957de83a/project/FundGlos-706b0cbe-0a31-4ad2-806d-869380a34c72/notebook/dfc24360b1544205ae4a219a2d6abf84

# Modifications in this file by Matt Marshall <matt.marshall@opendataservices.coop>
# 
# Modifications will be with the intent of adapting this mapping pipeline for use within the standalone FundGlos pipeline.
# The original DeepNote code produced tabular data directly, whereas the existing fundglos pipeline mostly works with JSONL files

import pandas as pd
import csv
from datetime import datetime
import re


# ==================================
# Read in the source data
# ==================================

# Modification: read from source_data folder in the pipeline rather than the data folder in DeepNote
#data = pd.read_excel('data/Local authority data #Feb2026 #shared.xlsx', sheet_name=None)
data = pd.read_excel('pipeline/source_data/fundglos/local-authority-grants.xlsx', sheet_name=None)

gloucestershire_CC = pd.DataFrame.from_dict(data['Gloucestershire County Council'])
gloucester_CC = pd.DataFrame.from_dict(data['Gloucester City Council'])
stroud_DC = pd.DataFrame.from_dict(data['Stroud District Council'])
dean_DC = pd.DataFrame.from_dict(data['Forest of Dean District Council'])
cotswold_DC = pd.DataFrame.from_dict(data['Cotswold District Council'])
cheltenham_BC = pd.DataFrame.from_dict(data['Cheltenham Borough Council'])
tewkesbury_BC = pd.DataFrame.from_dict(data['Tewkesbury Borough Council'])

# ==================================
# Helper Functions
# ==================================

#regex to check structure
fy_pattern = re.compile("[0-9]{4}/[0-9]{2}")
y_pattern = re.compile("[0-9]{4}")

def fy_map(row):
    if re.match(fy_pattern,str(row['Year'])):
        return "06/04/" + str(row['Year'])[:4]
    elif re.match(y_pattern,str(row['Year'])):
        return "01/01/" + str(row['Year'])
    else:
        return ''

# ==================================
# Mappings
# ==================================

# ----------------------------------
# Gloucestershire County Council
# ----------------------------------

#use index + 1 for grant ID for now
gloucestershire_CC = gloucestershire_CC.reset_index()
gloucestershire_CC['index'] = (gloucestershire_CC['index'] + 1).astype(str)

# MM: I think this is an artefact of DeepNote, used to display something?
#gloucestershire_CC

gloucestershire_CC_funding = {
    "id": 'fundglos-gloucestershirecountycouncil-'+ gloucestershire_CC['index'],	
    "type":	'grant',
    "date":	gloucestershire_CC['Grant/Contribution Award Date'],
    "value/amount":	gloucestershire_CC['Value £'],
    "value/currency":	'GBP',
    "activity/title": '',
    "activity/description":	'',
    "activity/location/ewcd":''	,
    "activity/location/ewnm":	'',
    "activity/location/gbcd":	'',
    "activity/location/gbnm":	'',
    "activity/location/ukcd":	'',
    "activity/location/uknm":	'',
    "activity/location/ladcd":	'',
    "activity/location/ladnm":	'',
    "activity/location/rgncd":	'',
    "activity/location/rgnnm":	'',
    "activity/location/ctrycd":	'',
    "activity/location/ctrynm":	'',
    "activity/location/source":	'',
    "activity/location/utlacd":	'',
    "activity/location/utlanm":	'',
    "activity/location/areacode":	'',
    "activity/location/areaname":	'',
    "activity/location/areatype":	'',
    "activity/location/sourceCode":	'',
    "activity/location/ladcd_active":'',	
    "activity/location/ladnm_active":	'',
    "programme/id":	'',
    "programme/title":gloucestershire_CC['Grant/Contribution Title'],	
    "programme/description":gloucestershire_CC['Description Purpose of Grant/Contribution'],	
    "programme/uri":	'',
    "funder/id":	'',
    "funder/name":	'',
    "funder/identifiers":'',	
    "recipient/id":	'',
    "recipient/name": gloucestershire_CC['Grant Beneficiary'],	
    "recipient/location/ewcd":'',	
    "recipient/location/ewnm":	'',
    "recipient/location/gbcd":	'',
    "recipient/location/gbnm":	'',
    "recipient/location/ukcd":	'',
    "recipient/location/uknm":	'',
    "recipient/location/ladcd":	'',
    "recipient/location/ladnm":	'',
    "recipient/location/rgncd":	'',
    "recipient/location/rgnnm":	'',
    "recipient/location/ctrycd":	'',
    "recipient/location/ctrynm":	'',
    "recipient/location/source":	'',
    "recipient/location/utlacd":	'',
    "recipient/location/utlanm":	'',
    "recipient/location/lad20cd":	'',
    "recipient/location/lad20nm":	'',
    "recipient/location/areacode":	'',
    "recipient/location/areaname":	'',
    "recipient/location/areatype":	'',
    "recipient/location/sourceCode":'',	
    "recipient/location/sourcefile":'',	
    "recipient/location/ladcd_active":	'',
    "recipient/location/ladnm_active":	'',
    "uri":	'',
    "recipient/location/latitude":	'',
    "recipient/location/longitude":	'',
    "recipient/identifiers":	'',
    "activity/location":	'',
    "recipient/location":	'',
    "activity/location/msoacd":	'',
    "activity/location/msoanm":	'',
    "activity/location/latitude":'',	
    "activity/location/lsoa11cd":	'',
    "activity/location/lsoa11nm":	'',
    "activity/location/lsoa21cd":	'',
    "activity/location/msoa11cd":	'',
    "activity/location/msoa11nm":	'',
    "activity/location/longitude":	'',
    "activity/location/msoahclnm":	'',
    "activity/location/msoa11hclnm":'',	
    "activity/location/lad20cd":	'',
    "activity/location/lad20nm":	'',
    "activity/location/sourcefile":	'',
    "activity/location/cauthcd":	'',
    "activity/location/cauthnm":	'',
    "activity/location/msoa21cd":''
}

gloucestershire_CC_funding_df = pd.DataFrame(gloucestershire_CC_funding)

# ----------------------------------
# Gloucester City Council
# ----------------------------------

#use index for grant ID for now
gloucester_CC = gloucester_CC.reset_index()
gloucester_CC['index'] = (gloucester_CC['index'] + 1).astype(str)

# Map dates to the first of the financial year
gloucester_CC["date"] = gloucester_CC.apply(fy_map, axis=1)

gloucester_CC_funding = {
    "id": 'fundglos-gloucestercitycouncil-'+ gloucester_CC['index'],
    "type":	'grant',
    "date":	gloucester_CC["date"],
    "value/amount":	gloucester_CC['Grant value'],
    "value/currency":	'GBP',
    "activity/title":	gloucester_CC['Activity'],
    "activity/description":	'',
    "activity/location/ewcd":''	,
    "activity/location/ewnm":	'',
    "activity/location/gbcd":	'',
    "activity/location/gbnm":	'',
    "activity/location/ukcd":	'',
    "activity/location/uknm":	'',
    "activity/location/ladcd":	'',
    "activity/location/ladnm":	'',
    "activity/location/rgncd":	'',
    "activity/location/rgnnm":	'',
    "activity/location/ctrycd":	'',
    "activity/location/ctrynm":	'',
    "activity/location/source":	'',
    "activity/location/utlacd":	'',
    "activity/location/utlanm":	'',
    "activity/location/areacode":	'',
    "activity/location/areaname":	'',
    "activity/location/areatype":	'',
    "activity/location/sourceCode":	'',
    "activity/location/ladcd_active":'',	
    "activity/location/ladnm_active":	'',
    "programme/id":	'',
    "programme/title":gloucester_CC['Fund'],	
    "programme/description":'',	
    "programme/uri":	'',
    "funder/id":	'',
    "funder/name":	'',
    "funder/identifiers":'',	
    "recipient/id":	'',
    "recipient/name": gloucester_CC['Group'],	
    "recipient/location/ewcd":'',	
    "recipient/location/ewnm":	'',
    "recipient/location/gbcd":	'',
    "recipient/location/gbnm":	'',
    "recipient/location/ukcd":	'',
    "recipient/location/uknm":	'',
    "recipient/location/ladcd":	'',
    "recipient/location/ladnm":	'',
    "recipient/location/rgncd":	'',
    "recipient/location/rgnnm":	'',
    "recipient/location/ctrycd":	'',
    "recipient/location/ctrynm":	'',
    "recipient/location/source":	'',
    "recipient/location/utlacd":	'',
    "recipient/location/utlanm":	'',
    "recipient/location/lad20cd":	'',
    "recipient/location/lad20nm":	'',
    "recipient/location/areacode":	'',
    "recipient/location/areaname":	'',
    "recipient/location/areatype":	'',
    "recipient/location/sourceCode":'',	
    "recipient/location/sourcefile":'',	
    "recipient/location/ladcd_active":	'',
    "recipient/location/ladnm_active":	'',
    "uri":	'',
    "recipient/location/latitude":	'',
    "recipient/location/longitude":	'',
    "recipient/identifiers":	'',
    "activity/location":	'',
    "recipient/location":	'',
    "activity/location/msoacd":	'',
    "activity/location/msoanm":	'',
    "activity/location/latitude":'',	
    "activity/location/lsoa11cd":	'',
    "activity/location/lsoa11nm":	'',
    "activity/location/lsoa21cd":	'',
    "activity/location/msoa11cd":	'',
    "activity/location/msoa11nm":	'',
    "activity/location/longitude":	'',
    "activity/location/msoahclnm":	'',
    "activity/location/msoa11hclnm":'',	
    "activity/location/lad20cd":	'',
    "activity/location/lad20nm":	'',
    "activity/location/sourcefile":	'',
    "activity/location/cauthcd":	'',
    "activity/location/cauthnm":	'',
    "activity/location/msoa21cd":''
}

gloucester_CC_funding_df = pd.DataFrame(gloucester_CC_funding)

# ----------------------------------
# Stroud District Council
# ----------------------------------

#use index + 1 for grant ID for now
stroud_DC = stroud_DC.reset_index()
stroud_DC['index'] = (stroud_DC['index'] + 1).astype(str)

stroud_DC_funding = {
    "id":'fundglos-strouddistrictcouncil-'+ stroud_DC['index'],	
    "type":	'grant',
    "date":	stroud_DC['Date Paid'],
    "value/amount":	stroud_DC['Amount'],
    "value/currency":	'GBP',
    "activity/title":	'',
    "activity/description":	'',
    "activity/location/ewcd":''	,
    "activity/location/ewnm":	'',
    "activity/location/gbcd":	'',
    "activity/location/gbnm":	'',
    "activity/location/ukcd":	'',
    "activity/location/uknm":	'',
    "activity/location/ladcd":	'',
    "activity/location/ladnm":	'',
    "activity/location/rgncd":	'',
    "activity/location/rgnnm":	'',
    "activity/location/ctrycd":	'',
    "activity/location/ctrynm":	'',
    "activity/location/source":	'',
    "activity/location/utlacd":	'',
    "activity/location/utlanm":	'',
    "activity/location/areacode":	'',
    "activity/location/areaname":	'',
    "activity/location/areatype":	'',
    "activity/location/sourceCode":	'',
    "activity/location/ladcd_active":'',	
    "activity/location/ladnm_active":	'',
    "programme/id":	'',
    "programme/title":stroud_DC['Service Area Categorisation'],	
    "programme/description":stroud_DC['Responsible Unit'],	
    "programme/uri":	'',
    "funder/id":	'',
    "funder/name":	'',
    "funder/identifiers":'',	
    "recipient/id":	'',
    "recipient/name": stroud_DC['Supplier Name'],	
    "recipient/location/ewcd":'',	
    "recipient/location/ewnm":	'',
    "recipient/location/gbcd":	'',
    "recipient/location/gbnm":	'',
    "recipient/location/ukcd":	'',
    "recipient/location/uknm":	'',
    "recipient/location/ladcd":	'',
    "recipient/location/ladnm":	'',
    "recipient/location/rgncd":	'',
    "recipient/location/rgnnm":	'',
    "recipient/location/ctrycd":	'',
    "recipient/location/ctrynm":	'',
    "recipient/location/source":	'',
    "recipient/location/utlacd":	'',
    "recipient/location/utlanm":	'',
    "recipient/location/lad20cd":	'',
    "recipient/location/lad20nm":	'',
    "recipient/location/areacode":	'',
    "recipient/location/areaname":	'',
    "recipient/location/areatype":	'',
    "recipient/location/sourceCode":'',	
    "recipient/location/sourcefile":'',	
    "recipient/location/ladcd_active":	'',
    "recipient/location/ladnm_active":	'',
    "uri":	'',
    "recipient/location/latitude":	'',
    "recipient/location/longitude":	'',
    "recipient/identifiers":	'',
    "activity/location":	'',
    "recipient/location":	'',
    "activity/location/msoacd":	'',
    "activity/location/msoanm":	'',
    "activity/location/latitude":'',	
    "activity/location/lsoa11cd":	'',
    "activity/location/lsoa11nm":	'',
    "activity/location/lsoa21cd":	'',
    "activity/location/msoa11cd":	'',
    "activity/location/msoa11nm":	'',
    "activity/location/longitude":	'',
    "activity/location/msoahclnm":	'',
    "activity/location/msoa11hclnm":'',	
    "activity/location/lad20cd":	'',
    "activity/location/lad20nm":	'',
    "activity/location/sourcefile":	'',
    "activity/location/cauthcd":	'',
    "activity/location/cauthnm":	'',
    "activity/location/msoa21cd":''
}

stroud_DC_funding_df = pd.DataFrame(stroud_DC_funding)

# ----------------------------------
# Forest of Dean District Council
# ----------------------------------

#use index + 1 for grant ID for now
dean_DC = dean_DC.reset_index()
dean_DC['index'] = (dean_DC['index'] + 1).astype(str)

# Map dates to first of financial year
dean_DC["date"] = gloucester_CC.apply(fy_map, axis=1)

dean_DC_funding = {
    "id":  'fundglos-forestofdeandistrictcouncil-'+ dean_DC['index'],		
    "type":	'grant',
    "date":	dean_DC['date'],
    "value/amount":	dean_DC['Amount Awarded'],
    "value/currency":	'GBP',
    "activity/title":	dean_DC['Summary of Grant'],
    "activity/description":'' ,
    "activity/location/ewcd":''	,
    "activity/location/ewnm":	'',
    "activity/location/gbcd":	'',
    "activity/location/gbnm":	'',
    "activity/location/ukcd":	'',
    "activity/location/uknm":	'',
    "activity/location/ladcd":	'',
    "activity/location/ladnm":	'',
    "activity/location/rgncd":	'',
    "activity/location/rgnnm":	'',
    "activity/location/ctrycd":	'',
    "activity/location/ctrynm":	'',
    "activity/location/source":	'',
    "activity/location/utlacd":	'',
    "activity/location/utlanm":	'',
    "activity/location/areacode":	'',
    "activity/location/areaname":	'',
    "activity/location/areatype":	'',
    "activity/location/sourceCode":	'',
    "activity/location/ladcd_active":'',	
    "activity/location/ladnm_active":	'',
    "programme/id":	'',
    "programme/title": dean_DC['Fund'],	
    "programme/description":'',	
    "programme/uri":	'',
    "funder/id":	'',
    "funder/name":	'',
    "funder/identifiers":'',	
    "recipient/id":	dean_DC['Charity Number'],
    "recipient/name": dean_DC['Beneficiary'],	
    "recipient/location/ewcd":'',	
    "recipient/location/ewnm":	'',
    "recipient/location/gbcd":	'',
    "recipient/location/gbnm":	'',
    "recipient/location/ukcd":	'',
    "recipient/location/uknm":	'',
    "recipient/location/ladcd":	'',
    "recipient/location/ladnm":	'',
    "recipient/location/rgncd":	'',
    "recipient/location/rgnnm":	'',
    "recipient/location/ctrycd":	'',
    "recipient/location/ctrynm":	'',
    "recipient/location/source":	'',
    "recipient/location/utlacd":	'',
    "recipient/location/utlanm":	'',
    "recipient/location/lad20cd":	'',
    "recipient/location/lad20nm":	'',
    "recipient/location/areacode":	'',
    "recipient/location/areaname":	'',
    "recipient/location/areatype":	'',
    "recipient/location/sourceCode":'',	
    "recipient/location/sourcefile":'',	
    "recipient/location/ladcd_active":	'',
    "recipient/location/ladnm_active":	'',
    "uri":	'',
    "recipient/location/latitude":	'',
    "recipient/location/longitude":	'',
    "recipient/identifiers":	'',
    "activity/location":	'',
    "recipient/location":	'',
    "activity/location/msoacd":	'',
    "activity/location/msoanm":	'',
    "activity/location/latitude":'',	
    "activity/location/lsoa11cd":	'',
    "activity/location/lsoa11nm":	'',
    "activity/location/lsoa21cd":	'',
    "activity/location/msoa11cd":	'',
    "activity/location/msoa11nm":	'',
    "activity/location/longitude":	'',
    "activity/location/msoahclnm":	'',
    "activity/location/msoa11hclnm":'',	
    "activity/location/lad20cd":	'',
    "activity/location/lad20nm":	'',
    "activity/location/sourcefile":	'',
    "activity/location/cauthcd":	'',
    "activity/location/cauthnm":	'',
    "activity/location/msoa21cd":''
}

dean_DC_funding_df = pd.DataFrame(dean_DC_funding)


# ----------------------------------
# Cotswald District Council
# ----------------------------------

#use index + 1 for grant ID for now
cotswold_DC = cotswold_DC.reset_index()
cotswold_DC['index'] = (cotswold_DC['index'] + 1).astype(str)

cotswold_DC_funding = {
    "id": 'fundglos-cotswolddistrictcouncil-'+ cotswold_DC['index'],	
    "type":	'grant',
    "date":	cotswold_DC['Date of Award'],
    "value/amount":	cotswold_DC['Amount (£)'],
    "value/currency":	'GBP',
    "activity/title":	'',
    "activity/description":	'',
    "activity/location/ewcd":''	,
    "activity/location/ewnm":	'',
    "activity/location/gbcd":	'',
    "activity/location/gbnm":	'',
    "activity/location/ukcd":	'',
    "activity/location/uknm":	'',
    "activity/location/ladcd":	'',
    "activity/location/ladnm":	'',
    "activity/location/rgncd":	'',
    "activity/location/rgnnm":	'',
    "activity/location/ctrycd":	'',
    "activity/location/ctrynm":	'',
    "activity/location/source":	'',
    "activity/location/utlacd":	'',
    "activity/location/utlanm":	'',
    "activity/location/areacode":	'',
    "activity/location/areaname":	'',
    "activity/location/areatype":	'',
    "activity/location/sourceCode":	'',
    "activity/location/ladcd_active":'',	
    "activity/location/ladnm_active":	'',
    "programme/id":	'',
    "programme/title":cotswold_DC['Funding Stream'],	
    "programme/description":cotswold_DC['Summary of Purpose'],	
    "programme/uri":	'',
    "funder/id":	'',
    "funder/name":	'',
    "funder/identifiers":'',	
    "recipient/id": cotswold_DC['Charity No'],
    "recipient/name": cotswold_DC['Beneficiary'],	
    "recipient/location/ewcd":'',	
    "recipient/location/ewnm":	'',
    "recipient/location/gbcd":	'',
    "recipient/location/gbnm":	'',
    "recipient/location/ukcd":	'',
    "recipient/location/uknm":	'',
    "recipient/location/ladcd":	'',
    "recipient/location/ladnm":	'',
    "recipient/location/rgncd":	'',
    "recipient/location/rgnnm":	'',
    "recipient/location/ctrycd":	'',
    "recipient/location/ctrynm":	'',
    "recipient/location/source":	'',
    "recipient/location/utlacd":	'',
    "recipient/location/utlanm":	'',
    "recipient/location/lad20cd":	'',
    "recipient/location/lad20nm":	'',
    "recipient/location/areacode":	'',
    "recipient/location/areaname":	'',
    "recipient/location/areatype":	'',
    "recipient/location/sourceCode":'',	
    "recipient/location/sourcefile":'',	
    "recipient/location/ladcd_active":	'',
    "recipient/location/ladnm_active":	'',
    "uri":	'',
    "recipient/location/latitude":	'',
    "recipient/location/longitude":	'',
    "recipient/identifiers":	'',
    "activity/location":	'',
    "recipient/location":	'',
    "activity/location/msoacd":	'',
    "activity/location/msoanm":	'',
    "activity/location/latitude":'',	
    "activity/location/lsoa11cd":	'',
    "activity/location/lsoa11nm":	'',
    "activity/location/lsoa21cd":	'',
    "activity/location/msoa11cd":	'',
    "activity/location/msoa11nm":	'',
    "activity/location/longitude":	'',
    "activity/location/msoahclnm":	'',
    "activity/location/msoa11hclnm":'',	
    "activity/location/lad20cd":	'',
    "activity/location/lad20nm":	'',
    "activity/location/sourcefile":	'',
    "activity/location/cauthcd":	'',
    "activity/location/cauthnm":	'',
    "activity/location/msoa21cd":''
}

cotswold_DC_funding_df = pd.DataFrame(cotswold_DC_funding)

# ----------------------------------
# Cheltenham Borough Council
# ----------------------------------

#use index + 1 for grant ID for now
cheltenham_BC = cheltenham_BC.reset_index()
cheltenham_BC['index'] = (cheltenham_BC['index'] + 1).astype(str)

# Map year to first day of the year or financial year
cheltenham_BC["date"] = cheltenham_BC.apply(fy_map, axis=1)

cheltenham_BC_funding = {
    "id": 'fundglos-cheltenhamboroughcouncil-'+ cheltenham_BC['index'],	
    "type":	'grant',
    "date":	cheltenham_BC['date'],
    "value/amount":	cheltenham_BC['Amount granted'],
    "value/currency":	'GBP',
    "activity/title":	cheltenham_BC['Project'],
    "activity/description":	'',
    "activity/location/ewcd":''	,
    "activity/location/ewnm":	'',
    "activity/location/gbcd":	'',
    "activity/location/gbnm":	'',
    "activity/location/ukcd":	'',
    "activity/location/uknm":	'',
    "activity/location/ladcd":	'',
    "activity/location/ladnm":	'',
    "activity/location/rgncd":	'',
    "activity/location/rgnnm":	'',
    "activity/location/ctrycd":	'',
    "activity/location/ctrynm":	'',
    "activity/location/source":	'',
    "activity/location/utlacd":	'',
    "activity/location/utlanm":	'',
    "activity/location/areacode":	'',
    "activity/location/areaname":	'',
    "activity/location/areatype":	'',
    "activity/location/sourceCode":	'',
    "activity/location/ladcd_active":'',	
    "activity/location/ladnm_active":	'',
    "programme/id":	'',
    "programme/title":cheltenham_BC['Fund'],	
    "programme/description":'',	
    "programme/uri":	'',
    "funder/id":	'',
    "funder/name":	'',
    "funder/identifiers":'',	
    "recipient/id":	'',
    "recipient/name": cheltenham_BC['Organisation'],	
    "recipient/location/ewcd":'',	
    "recipient/location/ewnm":	'',
    "recipient/location/gbcd":	'',
    "recipient/location/gbnm":	'',
    "recipient/location/ukcd":	'',
    "recipient/location/uknm":	'',
    "recipient/location/ladcd":	'',
    "recipient/location/ladnm":	'',
    "recipient/location/rgncd":	'',
    "recipient/location/rgnnm":	'',
    "recipient/location/ctrycd":	'',
    "recipient/location/ctrynm":	'',
    "recipient/location/source":	'',
    "recipient/location/utlacd":	'',
    "recipient/location/utlanm":	'',
    "recipient/location/lad20cd":	'',
    "recipient/location/lad20nm":	'',
    "recipient/location/areacode":	'',
    "recipient/location/areaname":	'',
    "recipient/location/areatype":	'',
    "recipient/location/sourceCode":'',	
    "recipient/location/sourcefile":'',	
    "recipient/location/ladcd_active":	'',
    "recipient/location/ladnm_active":	'',
    "uri":	'',
    "recipient/location/latitude":	'',
    "recipient/location/longitude":	'',
    "recipient/identifiers":	'',
    "activity/location":	'',
    "recipient/location":	'',
    "activity/location/msoacd":	'',
    "activity/location/msoanm":	'',
    "activity/location/latitude":'',	
    "activity/location/lsoa11cd":	'',
    "activity/location/lsoa11nm":	'',
    "activity/location/lsoa21cd":	'',
    "activity/location/msoa11cd":	'',
    "activity/location/msoa11nm":	'',
    "activity/location/longitude":	'',
    "activity/location/msoahclnm":	'',
    "activity/location/msoa11hclnm":'',	
    "activity/location/lad20cd":	'',
    "activity/location/lad20nm":	'',
    "activity/location/sourcefile":	'',
    "activity/location/cauthcd":	'',
    "activity/location/cauthnm":	'',
    "activity/location/msoa21cd":''
}

cheltenham_BC_funding_df = pd.DataFrame(cheltenham_BC_funding)

# ----------------------------------
# Tewkesbury Borough Council
# ----------------------------------

#use index + 1 for grant ID for now
tewkesbury_BC = tewkesbury_BC.reset_index()
tewkesbury_BC['index'] = (tewkesbury_BC['index'] + 1).astype(str)

# Remove spaces from dates
tewkesbury_BC['Date Grant paid'] = tewkesbury_BC['Date Grant paid'].str.replace(" ", "")

tewkesbury_BC_funding = {
    "id": 'fundglos-tewkesburyboroughcouncil-'+ tewkesbury_BC['index'],	
    "type":	'grant',
    "date":	tewkesbury_BC['Date Grant paid'],
    "value/amount":	tewkesbury_BC['Amount Awarded'],
    "value/currency":	'GBP',
    "activity/title":	tewkesbury_BC['Summary of the purpose of the grant'],
    "activity/description":	'',
    "activity/location/ewcd":''	,
    "activity/location/ewnm":	'',
    "activity/location/gbcd":	'',
    "activity/location/gbnm":	'',
    "activity/location/ukcd":	'',
    "activity/location/uknm":	'',
    "activity/location/ladcd":	'',
    "activity/location/ladnm":	'',
    "activity/location/rgncd":	'',
    "activity/location/rgnnm":	'',
    "activity/location/ctrycd":	'',
    "activity/location/ctrynm":	'',
    "activity/location/source":	'',
    "activity/location/utlacd":	'',
    "activity/location/utlanm":	'',
    "activity/location/areacode":	'',
    "activity/location/areaname":	'',
    "activity/location/areatype":	'',
    "activity/location/sourceCode":	'',
    "activity/location/ladcd_active":'',	
    "activity/location/ladnm_active":	'',
    "programme/id":	'',
    "programme/title":tewkesbury_BC['Grant Type'],	
    "programme/description":'',	
    "programme/uri":	'',
    "funder/id":	'',
    "funder/name":	'',
    "funder/identifiers":'',	
    "recipient/id":	tewkesbury_BC['Registration Number/Charity Number'],
    "recipient/name": tewkesbury_BC['Beneficiary'],	
    "recipient/location/ewcd":'',	
    "recipient/location/ewnm":	'',
    "recipient/location/gbcd":	'',
    "recipient/location/gbnm":	'',
    "recipient/location/ukcd":	'',
    "recipient/location/uknm":	'',
    "recipient/location/ladcd":	'',
    "recipient/location/ladnm":	'',
    "recipient/location/rgncd":	'',
    "recipient/location/rgnnm":	'',
    "recipient/location/ctrycd":	'',
    "recipient/location/ctrynm":	'',
    "recipient/location/source":	'',
    "recipient/location/utlacd":	'',
    "recipient/location/utlanm":	'',
    "recipient/location/lad20cd":	'',
    "recipient/location/lad20nm":	'',
    "recipient/location/areacode":	'',
    "recipient/location/areaname":	'',
    "recipient/location/areatype":	'',
    "recipient/location/sourceCode":'',	
    "recipient/location/sourcefile":'',	
    "recipient/location/ladcd_active":	'',
    "recipient/location/ladnm_active":	'',
    "uri":	'',
    "recipient/location/latitude":	'',
    "recipient/location/longitude":	'',
    "recipient/identifiers":	'',
    "activity/location":	'',
    "recipient/location":	'',
    "activity/location/msoacd":	'',
    "activity/location/msoanm":	'',
    "activity/location/latitude":'',	
    "activity/location/lsoa11cd":	'',
    "activity/location/lsoa11nm":	'',
    "activity/location/lsoa21cd":	'',
    "activity/location/msoa11cd":	'',
    "activity/location/msoa11nm":	'',
    "activity/location/longitude":	'',
    "activity/location/msoahclnm":	'',
    "activity/location/msoa11hclnm":'',	
    "activity/location/lad20cd":	'',
    "activity/location/lad20nm":	'',
    "activity/location/sourcefile":	'',
    "activity/location/cauthcd":	'',
    "activity/location/cauthnm":	'',
    "activity/location/msoa21cd":''
}

tewkesbury_BC_funding_df = pd.DataFrame(tewkesbury_BC_funding)


# ==========================
# Post-processing
# ==========================

# (Matt added this bit. If it's naff, it's not Isabel's fault!)

# The goal of this section is to get our nice re-mapped flat dataframes into a single CSV file so that it can be fed to flatten-tool to convert to JSON, then split to JSONL via jq, and thus integrated into the rest of the pipeline to add classifications etc where we can get them

all_data_df=pd.concat([
    gloucestershire_CC_funding_df, 
    gloucester_CC_funding_df,
    stroud_DC_funding_df,
    dean_DC_funding_df,
    cotswold_DC_funding_df,
    cheltenham_BC_funding_df,
    tewkesbury_BC_funding_df  
    ], ignore_index = True)


# Isabel/Pandas has done the hard work by converting nasty dates into a common format. However, we want ISO 8601 strings. This is basically the default date but with a "T" separator.
# We could interfere with this at the source mappings, but this would get tough to maintain if the mappings were ever adjusted. Instead, let's manipulate the date column on our new concatanated dataset.

# The 'date' column is currently stored as strings, not datetime objects which we need. There are also a few null entries so we need to do some massaging here

# 1. Convert all "date" column strings to datetimes. 'coerce' forces Null values to become "NaT" (Not a Time) which can then be converted properly when exporting to CSV. Not great for data quality… but garbage in garbage out I suppose. At this point we also have a solid mix of date formats, in YYYY-MM-DD and DD/MM/YY{YY}.

all_data_df['date'] = pd.to_datetime(all_data_df['date'], errors='coerce', yearfirst = True, dayfirst = True)

# 2. Convert all of the dates to ISO 8601

all_data_df['date'] = all_data_df['date'].dt.strftime('%Y-%m-%dT%H:%M:%S')

# Here we pass csv.QUOTE_ALL to enforce quoting of every column, otherwise the resulting file is very messy with strings spanning lots of columns.

all_data_df.to_csv('pipeline/intermediate_data/fundglos-local-authority-grants/fundglos-la-grants.csv',
        index=False,
        quoting=csv.QUOTE_ALL)
