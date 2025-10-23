# Readme for scripts in BGF

## Step_1_BioGeoFormer_db

* in order to run this step you must have the databases downloaded: MCycDB (https://github.com/qichao1984/MCycDB), NCycDB (https://github.com/qichao1984/NCyc), SCycDB (https://github.com/qichao1984/SCycDB), and PCycDB (https://github.com/ZengJiaxiong/Phosphorus-cycling-database). Once downloaded, place each in the BioGeoFormer folder within this repository. 

* 1.1-1.4: scripts that create the .csv files of the metadata and database, for each respective database -- MCycDB (1.1), NCycDB (1.2), PCycDB (1.3), and SCycDB (1.4). 
* 1.5-1.6: scripts that group genes based on their respective biogeochemical pathways. A given ID may be assigned to one or more biogeochemical pathways at this point. 
* 1.9: Creation of the BioGeoFormer_db (BGF_db). This entails filtering out genes that fall into two or more pathways, with the exception of anaerobic oxidation of methane and the central methanogenic pathway. Combining all databases together, and mapping genes to pathways. 
* 1.10: Creating a fasta file of BioGeoFormer_db


## Step_2_clustering_train_test_val_BGF

* 2.1: Script to split BGF_db into fasta files by pathway (each file contains only sequences falling within a given pathway). These files are then to be used for clustering. 
* 2.2: Folder containing clustering scripts running CD-HIT to cluster each pathway from 100% sequence identity down to 20% identity. Also includes clustering scripts to reconcile each clustering split to improve coverage. The output of these scripts are not included due to space constraints but will be shared upon request. Running these commands will likely require HPC access. 
* 2.3: Script used to split cluster file output from CD-HIT into training, validation, and testing sets. A given cluster appears in only one split, with size of cluster accounted for to ensure a roughly 60/20/20 split by sequence count. 
* 2.4: QAQC script checking for data leakage after creating the training/validation/test sets. 
* 2.5: Moving training/validation/test sets to a new folder 
* 2.6-2.8: Writing fasta files for the validation, test, and training datasets. 
* 2.9: Writing fasta files that are split by biogeochemical pathway (e.g., one pathway per file) for validation, train, test datasets. 
* 2.10: Pulling sequences that were omitted by CD-HIT to be witheld and added to the 'filered-test' set, to benchmark the methods against stringently filtered sequence identities. 

## Step_3_train_test_val_cluster_performance_diamond

* 3.1: Folder containing scripts to run DIAMOND commands, including making diamond databases for each pathway's training splits. Then running diamond on validation and test sets to determine percent identity between train/test/val sets. Scripts were run on an HPC.  
* 3.2: Plotting the similarity and dissimilarity between training, testing, and validation sets. 

## Step_4_hmm_runs
* 4.1: Scripts for running FAMSA to perform multiple sequence alignments for each pathway's training splits. Scripts were run on an HPC.
* 4.2: Building HMM profiles for each pathway's MSA alignments. Scripts were run on an HPC.
* 4.3: Running HMMs against the pathway's splits for the validation, test, and anti_split (for the filtered-test) sets. Scripts were run on an HPC.
* 4.4-4.6: Scripts to process the HMM runs on the validation, test, and anti_split datasets, transforming output into a .csv file for each identity split.

## Step_5_diamond_runs
* 5.1: Scripts for making a DIAMOND database for each training split. Scripts were run on an HPC 
* 5.2: Scripts for running DIAMOND databases against test and validation splits. Scripts were run on an HPC.
* 5.3: Scripts for running DIAMOND databases against anti_split data. Scripts were run on an HPC.
* 5.4-5.5: Scripts to process the DIAMOND output against the test, validation and anti_split datasets, transforming output into a .csv file for each identity split.

## Step_6_training_scaling_running_BGF
* 6.1:
* 6.2: Scripts to carry out temperature scaling on all model splits post-training. Each script uses an asymmetric loss function to scale the softmax function under a range of weights. These scripts were run on an A100 GPU on Google Colab.
* 6.3: Scripts used to run BioGeoFormer against test sets. These scripts were run on an A100 GPU on Google Colab.

## Step_7_filtered_test_set
* 7.1: Script leveraging DIAMOND output to create the 'filtered-test' set, where sequences that are higher than a set percent identity threshold are removed. This is used to better compare methods and their ability to identify remote homology with higher stringency.
* 7.2: Script leveraging DIAMOND output to increase the number of sequences in the 'filtered-test' set. This script takes sequences from the 'anti_split' dataset which is comprised of sequences dropped by CD-HIT during clustering.

## Step_8_evaluating_models
* 8.1: Performance metric evaluations and comparison of methods using the metrics F1, Precision, Recall, Accuracy, Matthews Correlation Coefficient. Plotting for each model split and for each method.
* 8.2: Script analyzing the performance of each model-split and their precision across similar and dissimilar proteins. Predictions are binned by softmax output and and plotted against precision per bin. Other visualizations are output such as the area under the curve (AUC) for these plots and a box plot comparin precision above a high-confidence threshold.

## Step_9_MAG_application
* In order to run this step, you must download the deduplicated metagenome-assembled genomes (MAGs) from Han et al., 2023 (https://identifiers.org/ncbi/bioproject:PRJNA950938)
  
* 9.1: calling open reading frames (ORFs) for MAGs using Prodigal. These commands were run on an HPC.
* 9.2: DIAMOND run annotating MAG ORFs using the KEGG database. Requires a local KEGG database to run these commands. These commands were run on an HPC. 
* 9.3: DIAMOND run annotating MAG ORFs using the BGFdb database. These commands were run on an HPC.
* 9.4: HMM run annotating MAG ORFs against the HMMs constructed from the BGFdb database. These commands were run on an HPC.
* 9.5: Script processing the KEGG DIAMOND output into a .csv file.
* 9.6: Script to parse the KEGG orthology database from KEGG BRITE. Prior to running this script, download the ko0001 file from (https://www.kegg.jp/kegg-bin/get_htext?ko00001).
* 9.7: Script assigning gene names to KO IDs.
* 9.8: Mapping biogeochemical pathways to KEGG file. Primarily using gene names assigned in script 9.7.
* 9.9: Processing DIAMOND output for BGFdb, into a .csv file.
* 9.10: Processing HMM output for BGFdb, into a .csv file.
* 9.11: Formatting MAG data to be run by BioGeoFormer. Shortening sequences to more manageably work with the file, however not so short that they are included as complete proteins by BGF (context window 1024 tokens).
* 9.12: Splitting MAG data to parallelize BGF runs. 
* 9.13: BGF inference of MAG data. These scripts were run on Google Colab with an A100 GPU.
* 9.14: Script to compare annotation methods with one another, and plotting an Upset plot to visualize the comparison.
* 9.15: Script making a bubble plot to compare annotation counts for each pathway by each method. Additionally plotting a bar plot of only BGF annotations and appending it to the bubble plot.





