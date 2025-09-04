
import argparse
from cyc import util, model
import torch
import pickle



def main():
    """
    Command line interface for performing inference on protein sequences in a FASTA file
    """
    parser = argparse.ArgumentParser(description='Predict protein classes from FASTA sequences')
    parser.add_argument('--fasta_file', type=str, required=True,
                      help='Path to input FASTA file')
    
    parser.add_argument('--sim', type=int, required=True,
                        help='Clusterng threshold')

    parser.add_argument('--annot_file', type=str, required=True,
                        help='Filename to save annotations')

    parser.add_argument('--device', type=str,
                      default="cuda:0" if torch.cuda.is_available() else "cpu",
                      help='Device to run inference on (default: CUDA if available, else CPU)')

    args = parser.parse_args()

    # Load label mapping
    with open(f'cycformer/data/cycle_maps/cyc_label_id_map_{args.sim}.pickle', 'rb') as f:
        mapper = pickle.load(f)
        print(mapper)

    # Run inference
    predictions = model.predict_fasta(
        sim=args.sim,
        fasta_file=args.fasta_file,
        mapper=mapper,
        annot_file=args.annot_file,
        device=args.device
    )
    
if __name__ == '__main__':
    main()
