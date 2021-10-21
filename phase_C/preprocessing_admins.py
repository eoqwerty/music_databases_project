#INPUT DATA: presidents.csv
#OUTPUT DATA: Administrations.txt 

import pandas as pd

#years constrained by the billboard data 
START_YEAR = '1953'
END_YEAR = '2017'

#empty dataframe analogous to the Administration relation 
admins = pd.DataFrame()

#GET PPREZS FROM CSV
prezs = pd.read_csv("presidents.csv") 

#PUT ONLY NECESSARY ATTRIBUTES IN ADMINS
admins['president'] = prezs['president']
#extract only the year from the start and end dates 
admins['startYear'] = prezs.start.str.extract(r'\b(\w+)$', expand=True) 
admins['endYear'] = prezs.end.str.extract(r'\b(\w+)$', expand=True) 

#constrain to only years that match billboard data 
admins = admins[(admins.startYear >= START_YEAR) & (admins.startYear <= END_YEAR)]

#export to a text file with no row numbers, no headers
admins.to_csv("Administration.txt", index = False, header = False, sep = '\t') 
