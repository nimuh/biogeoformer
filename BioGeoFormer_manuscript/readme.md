# File structure for the BioGeoFormer manuscript

## BGF_clustering: Folder for clustering and evaluating the BGF database
* anti_splits: folder that holds sequences dropped during clustering by CD-HIT, therefore not in the train/val/test sets. These sequences were appended to the filtered-test set for additional sequence coverage. Data is written out as .fasta and .csv format. 
* cleaned_unselected: train/test/val sets that have been processed but not selected to have just the required columns for downstream work.
* Summary for each identity split, confirming deduplication within and across train/test/validation sets.
* comparing_train_test_val_diamond: DIAMOND output to look at dissimilarity between datasets post clustering and cluster splitting for train/test/val.
* cycle_division_split: Sequence files split by pathway to be clustered.
   * 
