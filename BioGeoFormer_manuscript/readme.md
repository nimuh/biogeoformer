# File structure for the BioGeoFormer manuscript

## BGF_clustering: Folder for clustering and evaluating the BGF database
* anti_splits: folder that holds sequences dropped during clustering by CD-HIT, therefore not in the train/val/test sets. These sequences were appended to the filtered-test set for additional sequence coverage. Data is written out as .fasta and .csv format. 
* cleaned_unselected: train/test/val sets that have been processed but not selected to have just the required columns for downstream work.
* Summary for each identity split, confirming deduplication within and across train/test/validation sets.
* comparing_train_test_val_diamond: DIAMOND output to look at dissimilarity between datasets post clustering and cluster splitting for train/test/val.
* cycle_division_split: Sequence files split by pathway to be clustered.
   * cycle_splits_cdhit: processed cluster files of each pathway and at each identity split.
* splitting_output: output files after splitting cluster files into training/testing/validation sets.
* train_test_val_fasta_bypathway: fasta files of train/test/validation datasets split by sequence identity and metabolic pathway for downstream analysis.
* train_test_val_final: final processed training/testing/validation data sets. These are in .csv output (train, validation, test) and .fasta output (train_fasta, val_fasta, test_fasta).

## BGF_run_val_test_anti_split: output of BGF on certain dataset splits 
* anti_split: BGF inference on anti split datasets.
* test: BGF inference on test dataset.

## BioGeoFormer_db: constructed BioGeoFormer_db database (BioGeoFormer_db.csv, BioGeoFormer_db.fasta), and overview of the genes and pathways in the database (BioGeoFormer_db_overview.csv, BioGeoFormer_db_overview.docx)

## cold_seep_MAG_application: Folder for annotating metagenome-assembled genomes and comparing method performance
* 
