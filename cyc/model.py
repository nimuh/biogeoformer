



from transformers import EsmForSequenceClassification
import torch
from util import fasta_to_dataset
from tqdm import tqdm

def load_model(model_path, device="cuda:0" if torch.cuda.is_available() else "cpu"):
    """
    Load an ESM sequence classification model from a given path
    
    Args:
        model_path (str): Path to the model checkpoint/folder
        device (str): Device to load the model on (default: CUDA if available, else CPU)
        
    Returns:
        model: Loaded ESM model on specified device
    """
    model = EsmForSequenceClassification.from_pretrained(model_path)
    model.to(device)
    return model


def predict_fasta(model_path, fasta_file, mapper, device="cuda:0" if torch.cuda.is_available() else "cpu"):
    """
    Load a model and perform inference on sequences in a FASTA file
    
    Args:
        model_path (str): Path to the model checkpoint/folder
        fasta_file (str): Path to input FASTA file
        mapper (dict): Dictionary mapping labels to indices
        device (str): Device to run inference on
        
    Returns:
        list: List of predicted labels for sequences
    """
    # Load the model
    model = load_model(model_path, device)
    model.eval()
    
    # Convert FASTA to dataset and create dataloader
    dataset = fasta_to_dataset(fasta_file, mapper)
    dataloader = torch.utils.data.DataLoader(dataset, batch_size=1, shuffle=False)

    # Perform inference
    predictions = []
    with torch.no_grad():        
        for sample in tqdm(dataloader):
            # Add batch dimension and move to device
            inputs = sample['input_ids'].squeeze(0).to(device)

            # Get model outputs 
            outputs = model(inputs)
            
            # Get predicted class
            pred = torch.argmax(outputs.logits, dim=-1)
            pred_label = dataset.label_dict[pred.item()]
            #print(pred_label)
            predictions.append(pred_label)
    

    df = dataset.dataframe
    df['prediction'] = predictions

    df.to_csv('data/test_annot.csv')
    print(df)

    #print(predictions)
            
    return predictions


