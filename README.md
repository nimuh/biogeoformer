<img width="4000" height="4618" alt="Untitled_Artwork" src="https://github.com/user-attachments/assets/0261ae9e-15ed-4840-9ba8-fbe69810800f" />

BioGeoFormer is a protein language model designed to predict and classify microbial proteins involved in key biogeochemical cycles — including methane, sulfur, nitrogen, and phosphorus transformations.
Built on the ESM-2 transformer architecture, fine-tuned on curated metabolic pathway databases (MCycDB, NCycDB, PCycDB, SCycDB), and a calibrated confidence function, BioGeoFormer extends sequence-function inference beyond traditional homology-based tools. 

Built on four databases, BioGeoFormer leverages 610 unique gene families to cover 37 metabolic pathways. It represents an excellent complementary method for metagenome and genome mining, to uncover hypothetical gene function related to biogeochemical cycling. 'BioGeoFormer' is a blanket term for the 8 fine-tuned models defined by their clustered identity splits, with training, validation, and test n% dissimilar at 10% intervals from 20% to 90%. While the nuance is described in our manuscript, we found that the 70% split model is the most effective at precisely identifying remote homologues, and recommend its use in most circumstances. 

While the tool does run on CPU-based infrastructure, we strongly recommend using a GPU-based infrastructure to annotate sequences to ensure the fastest completion time, especially for large datasets. If you do not have one personally available to you or do not have access through your institution, Google Colab is a user-friendly option to run a notebook with a GPU. 

### To download BioGeoFormer

git clone the repository to the location you intend to run the tool: 
```bash
git clone https://github.com/nimuh/biogeoformer.git
```

direct to the repository folder and make sure that you are in 'biogeoformer' only and not within any subdirectories
```bash
cd /path/to/biogeoformer/folder
```
run the `setup.py` script by entering the following command
```bash
pip install -e .
```

### Formatting input data
Input data must be a `.fasta` file format with an identifiable sequence ID, followed by a biological sequence sequence in *amino acid format*. Files must end with `.fasta`, and not `.faa` in order for BioGeoFormer to correctly identify the input. 


### Inference 
* point to biogeoformer/cyc/inference.py
* -- sim "specify model split here"
* -- fasta_file "path/to/input/fasta/here"
* -- annot_file "path/to/output/annotations/here"
