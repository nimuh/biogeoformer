# File structure for the BioGeoFormer manuscript

### BGF_clustering: Folder for clustering and evaluating the BGF database
* anti_splits: folder that holds sequences dropped during clustering by CD-HIT, therefore not in the train/val/test sets. These sequences were appended to the filtered-test set for additional sequence coverage. Data is written out as .fasta and .csv format. 
* cleaned_unselected: train/test/val sets that have been processed but not selected to have just the required columns for downstream work.
* Summary for each identity split, confirming deduplication within and across train/test/validation sets.
* comparing_train_test_val_diamond: DIAMOND output to look at dissimilarity between datasets post clustering and cluster splitting for train/test/val.
* cycle_division_split: Sequence files split by pathway to be clustered.
   * cycle_splits_cdhit: processed cluster files of each pathway and at each identity split.
* splitting_output: output files after splitting cluster files into training/testing/validation sets.
* train_test_val_fasta_bypathway: fasta files of train/test/validation datasets split by sequence identity and metabolic pathway for downstream analysis.
* train_test_val_final: final processed training/testing/validation data sets. These are in .csv output (train, validation, test) and .fasta output (train_fasta, val_fasta, test_fasta).

### BGF_run_val_test_anti_split: output of BGF on certain dataset splits 
* anti_split: BGF inference on anti split datasets.
* test: BGF inference on test dataset.

### BioGeoFormer_db: constructed BioGeoFormer_db database (BioGeoFormer_db.csv, BioGeoFormer_db.fasta), and overview of the genes and pathways in the database (BioGeoFormer_db_overview.csv, BioGeoFormer_db_overview.docx)

### cold_seep_MAG_application: Folder for annotating metagenome-assembled genomes and comparing method performance
* BGF_annotations: Folder for BGF output after inference.
* BGF_input_data: MAG data processed into a csv file structure that BGF can run inference on.
* DIAMOND_BGF_output: Output from running BGFdb DIAMOND alignment against MAGs.
* DIAMOND_KEGG_output: Output from running KEGG database DIAMOND alignment against MAGs.
* HMM_BGF_output: Output from running HMMs constructed with the BGFdb. The 50% identity split was selected for this application. 
* HMM_BGF_processed: Processing HMM output into a .csv file.
* joined_predictions_coldseep_mags.csv: File that contains predictions from each method on the MAG dataset.
* KEGG_mapping: Folder containing files for mapping KO to gene ID and then biogeochemical pathway.
* KEGG_processed: Processed KEGG output into a .csv file.
* mags_processed: MAG data processed into a .faa and .csv file as opposed to unique .fa files for each MAG.

## combined_cycdb: Folder containing 'combined100.faa', a a combination of MCycDB, NCycDB, SCycDB, and PCycDB databases. 

## cycdb_csv: Folder containing processing steps of the CycDB databases. 
* Metadata: Processed metadata from each of the CycDB databases
* Metadata_with_pathways: Metadata with biogeochemical pathways mapped onto each file.
* sequences: CycDB databases with metadata next to ID's removed for downstream processing.

## cycle_dicts: Dictionaries (.json and .txt files) of ID's mapped to their corresponding biogeochemical pathways. 

## diamond_run_val_test_anti_split: Contains files of DIAMOND output and processing for training set against validation, test and anti split sets. 
* anti_split_output: DIAMOND output from BGFdb training set against the anti_split dataset.
* anti_split_processed: Processing anti_split DIAMOND output into .csv file.
* val_test_output: DIAMOND output from BGFdb training set against the validation and test datasets.
* val_test_processed: Processing DIAMOND output on validation and test sets into .csv files.

## filtered_test_set: Folder for processing the filtered-test set. 
* anti_split_csv: .csv files of the anti_split dataset, filtered by different maximum percent identity thresholds with the training dataset.
* anti_split_fasta: .fasta files of the filtered anti-split set.
* final_filtered_test: final filtered-test set filtered and combined with the anti-split data. For each folder (e.g. test_20), there test sets are filtered by a certain filtering threshold against the training data set (e.g. merged_20_under20.csv or merged_20_under50.csv).
* split_test_diamond_hmm_bgf: annotations from each method on the filtered-test set.
* test_filtered_all: filtered test set prior to merging with the anti_split dataset.

## hmm_run_val_test_anti_split: Folder for HMM output and processing for validation, test, and anti_split datasets. 
* anti_split_hmm: HMM output on anti_split set.
* anti_split_processed_hmm: Processed HMM output on anti_split set.
* test_output_hmm: HMM output on test set.
* test_processed_hmm: Processed HMM output on test set.
* val_output_hmm: HMM output on validation set.
* val_processed_hmm: Processed HMM output on validation set.

## results: Figures and tables generated for the BioGeoFormer manuscript

## scripts: scripts ordered to reproduce the BioGeoFormer manuscript

## temperature_scaling_BGF: temperature scaling output for BGF
* cyc_20-cyc_90: temperature scaling output for each scalar (lambda_0-lambda_90).
* final_temps: temperature values chosen for optimal confidence output for each model's identity split. 













