
import argparse
from cyc import util, model
import torch
import pickle

# TODO
# change to include model versions

def main():
    """
    Command line interface for performing inference on protein sequences in a FASTA file
    """
    parser = argparse.ArgumentParser(description='Predict protein classes from FASTA sequences')
    parser.add_argument('--fasta', type=str, required=True,
                      help='Path to input FASTA file')
    parser.add_argument('--model', type=str, required=True,
                      help='Path to model checkpoint/folder')
    parser.add_argument('--device', type=str,
                      default="cuda:0" if torch.cuda.is_available() else "cpu",
                      help='Device to run inference on (default: CUDA if available, else CPU)')
    
    args = parser.parse_args()

    # Load label mapping
    with open('data/ko_model_id_map.pickle', 'rb') as f:
        mapper = pickle.load(f)

    # Run inference
    predictions = model.predict_fasta(
        model_path=args.model,
        fasta_file=args.fasta,
        mapper=mapper,
        device=args.device
    )
    
    # Print predictions
    #for pred in predictions:
    #    print(pred)

if __name__ == '__main__':
    main()
