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
