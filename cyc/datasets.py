
from Bio import SeqIO
from torch.utils.data import Dataset
from pandas import read_csv, DataFrame
from numpy import unique
from pickle import dump, HIGHEST_PROTOCOL
"""
For loading dataframes containing protein sequences with a target ID
This serves as a general dataset for protein sequence classification

Arguments:
csv_file: the CSV file name that will be used as a pandas DataFrame
tokenizer: the HuggingFace tokenizer for processing sequences
label_column: the column name in the DataFrame corresponding to the targets
seq_column: the column name in the DataFrame corresponding to the proteins
"""
class ProteinDataset(Dataset):
    def __init__(self, dataframe, csv_file, tokenizer, label_column, seq_column, nsamples=-1, return_seqs=False, mapper=None):
        self.tokenizer = tokenizer
        data = dataframe
        self.return_seqs = return_seqs
        if dataframe is None:
            print('loading file: ', csv_file)
            data = read_csv(csv_file)
        
        self.dataframe = data
        if nsamples > 0:
            data = data.groupby(label_column).sample(n=nsamples, replace=True).reset_index()
        print('done.')
        self.label_dict = mapper
        if label_column is not None:
            self.labels = data[label_column]
            self.nu_labels = len(unique(self.labels))
            if mapper == None:
                label_dict = {}
                label_list = unique(self.labels)
                for i in range(len(label_list)):
                    label_dict[label_list[i]] = i
                self.label_dict = label_dict
            self.label_name = label_column
        self.id2label = dict([(k, v) for v, k in self.label_dict.items()])
        with open('cyc_label_id_map.pickle', 'wb') as f:
            dump(self.id2label, f, HIGHEST_PROTOCOL)
        self.seqs = data[seq_column]

    """
    This should work for a correctly formatted fasta/fastq file!
    """
    @classmethod
    def from_fastx(cls, fasta_filename, tokenizer, seq_column='SEQS', label_column=None, nsamples=-1, mapper=None):
        # read fasta file into dataframe
        df = None
        file_suffix = fasta_filename[-5:]
        print('File type: ', file_suffix)
        with open(fasta_filename) as fasta_file:  # Will close handle cleanly
            identifiers = []
            seqs = []
            for seq_record in SeqIO.parse(fasta_file, file_suffix):  # (generator)
                identifiers.append(seq_record.id)
                seqs.append(str(seq_record.seq))
            df = DataFrame({'IDs': identifiers,'SEQS': seqs})

            
            #df = df.sample(n=10).reset_index() # test

            return cls(dataframe=df, 
                    csv_file=None, 
                    tokenizer=tokenizer, 
                    seq_column=seq_column, 
                    label_column=label_column,
                    mapper=mapper,
                    return_seqs=True,
                    )
            
    def __len__(self):
        return len(self.seqs)

    def __getitem__(self, idx):
        sample = self.tokenizer(self.seqs[idx],
                                return_tensors='pt', 
                                padding=True,
                                truncation=True,
                                )
        if hasattr(self, 'labels'):
            sample['label'] = self.label_dict[self.labels[idx]]
        if self.return_seqs:
            sample['sequence'] = self.seqs[idx]
        #print(sample)
        return sample