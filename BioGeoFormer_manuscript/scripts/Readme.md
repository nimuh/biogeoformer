# Readme for scripts in BGF

## Step_1_BioGeoFormer_db

* in order to run this step you must have the databases downloaded: MCycDB, NCycDB, SCycDB, and PCycDB. Once downloaded, place each in the BioGeoFormer folder within this repository. 

1.1-1.4: scripts that create the .csv files of the metadata and database, for each respective database -- MCycDB (1.1), NCycDB (1.2), PCycDB (1.3), and SCycDB (1.4). 
1.5-1.6: scripts that group genes based on their respective biogeochemical pathways. A given ID may be assigned to one or more biogeochemical pathways at this point. 
1.9: Creation of the BioGeoFormer_db (BGF_db). This entails filtering out genes that fall into two or more pathways, with the exception of anaerobic oxidation of methane and the central methanogenic pathway. Combining all databases together, and mapping genes to pathways. 
1.10: Creating a fasta file of BioGeoFormer_db


## Step_2_clustering_train_test_val_BGF

2.1: Script to split BGF_db into fasta files by pathway (each file contains only sequences falling within a given pathway). These files are then to be used for clustering. 
2.2: Folder containing clustering scripts running CD-HIT to cluster each pathway from 100% sequence identity down to 20% identity. Also includes clustering scripts to reconcile each clustering split to improve coverage. The output of these scripts are not included due to space constraints but will be shared upon request. Running these commands will likely require HPC access. 
2.3: Script used to split cluster file output from CD-HIT into training, validation, and testing sets. A given cluster appears in only one split, with size of cluster accounted for to ensure a roughly 60/20/20 split by sequence count. 
2.4: QAQC script checking for data leakage after creating the training/validation/test sets. 
2.5: Moving training/validation/test sets to a new folder 
2.6-2.8: Writing fasta files for the validation, test, and training datasets. 
2.9: Writing fasta files that are split by biogeochemical pathway (e.g., one pathway per file) for validation, train, test datasets. 
2.10: Pulling sequences that were omitted by CD-HIT to be witheld and added to the 'filered-test' set, to benchmark the methods against stringently filtered sequence identities. 

## Step_3_train_test_val_cluster_performance_diamond

3.1: 





