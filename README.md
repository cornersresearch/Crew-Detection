# Crew Detection
In collaboration with the Invisible Institute, N3 created this GitHub repo to hold all code, data and network files used in the process.

Key variables to know include:

* UID which is a unique identifier for each officer
* CRID which is a unique identifier for each complaint
* Community_ID which is the unique identifier for the assigned community

There are 6 sequential scripts used to create the final analysis. 
1. Tidy Datasets cleans the original II data into a format that is usable for this analysis
2. Network Creation creates the social network
3. Community Detection identifies communities in the network
4. Officer Categorization performs cluster analysis to identify officer typology
5. Crew Identification creates the dataset of all communities and performs the analysis to identify which of those communities are crews
6. Analyzing_Communities simply identifies trends and statistics relating to communities and crews

The datasets correspond with the analysis and should not be modified. The key datasets include:

* AttributesByCommunity which contains a dataset indexed by Community_ID that contains important information
* Officer_Community_Assignments contains a dataset indexed by UID that contains the Community_ID for each officer 
* Most other datasets are intermediaries to assist with the processing of II data and to assist with network creation and the development of other datasets

Networks contain 2 networks that are important for analysis. Both are saved as gml and gexf files and the filenames indicate their purpose. The network file with 'NoEdgesBelow2' is the one used for the analysis, though for visualizations, the other is also used. 

COPA Expansion Notes: 

This adaptation is currently under construction, and as such, its structure will change, but for now, the main goals are the adaptation of the crew detection framework to data sourced from COPA, instead of that from the Invisible Institute. This will allow for an additional 3 years of recent data to be incorporated (potentially more pending future updates from COPA). The currently available files are:

import_copa.R : The COPA data requires extensive reshaping and cleaning before it is usable. This scripts accomplishes that. \
generate_copa_roster.R : The COPA data is organized by complaints, this attempts to create a "roster" of officers with a complaint from that data. \
link_crews.R : This takes the UIDs listed in other analyses and attempts to link the officers to the II data, and  to see to what extent COPA data has coverage over those same officers and network ties. More of an ongoing investigation than discrete task, as the two datasets differ in unpredictable ways. 

