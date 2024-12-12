


from transformers import EsmTokenizer
from cyc.datasets import ProteinDataset


def fasta_to_dataset(fasta_file, mapper):
    """
    Convert a FASTA file to a ProteinDataset object
    
    Args:
        fasta_file (str): Path to the FASTA file
        mapper (dict, optional): Dictionary mapping labels to indices.
        
    Returns:
        ProteinDataset: Dataset containing the sequences from the FASTA file
    """
    tokenizer = EsmTokenizer.from_pretrained('facebook/esm2_t6_8M_UR50D')
    
    dataset = ProteinDataset.from_fastx(
        fasta_filename=fasta_file,
        tokenizer=tokenizer,
        mapper=mapper
    )
    
    return dataset
