<img width="4000" height="4618" alt="Untitled_Artwork" src="https://github.com/user-attachments/assets/0261ae9e-15ed-4840-9ba8-fbe69810800f" />

BioGeoFormer is a protein language model designed to predict and classify microbial proteins involved in key biogeochemical cycles — including methane, sulfur, nitrogen, and phosphorus transformations.
Built on the ESM-2 transformer architecture, fine-tuned on curated metabolic pathway databases (MCycDB, NCycDB, PCycDB, SCycDB), and a calibrated confidence function, BioGeoFormer extends sequence-function inference beyond traditional homology-based tools. 

Built on four databases, BioGeoFormer leverages 610 unique gene families to cover 37 metabolic pathways. It represents an excellent complementary method for metagenome and genome mining, to uncover hypothetical gene function related to biogeochemical cycling. 'BioGeoFormer' is a blanket term for the 8 fine-tuned models defined by their clustered identity splits, with training, validation, and test n% dissimilar at 10% intervals from 20% to 90%. While the nuance is described in our manuscript, we found that the 70% split model is the most effective at precisely identifying remote homologues, and recommend its use in most circumstances. 

### To download BioGeoFormer

```bash
git clone https://github.com/nimuh/biogeoformer.git
```

```bash
cd /path/to/biogeoformer/folder
```

```bash
pip install -e .
```

* git clone (link here)
* cd into the biogeoformer folder
* run the commnand in terminal: 'pip install -e .'
* 

### Inference 
* point to biogeoformer/cyc/inference.py
* -- sim "specify model split here"
* -- fasta_file "path/to/input/fasta/here"
* -- annot_file "path/to/output/annotations/here"
