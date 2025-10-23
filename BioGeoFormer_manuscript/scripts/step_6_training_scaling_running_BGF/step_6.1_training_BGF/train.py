

# TODO
# add code to save id mappings for each model version

import numpy as np
import torch
#import wandb
import argparse
from evaluate import load
from transformers import (
    Trainer,
    TrainingArguments,
    EsmTokenizer,
    EsmForSequenceClassification, 
)
from cyc.datasets import ProteinDataset
import os
import matplotlib.pyplot as plt
import seaborn as sns

os.environ["WANDB_DISABLED"] = "true"

torch.manual_seed(42)

accuracy = load("accuracy")
matthews_metric = load("matthews_correlation")
f1_metric = load("f1")
precision_metric = load("precision")
recall_metric = load('recall')
conf_mat_metric = load("confusion_matrix")

def main():
    # main logic
    args = parse_args()
    output_dir = args.model_save_dir
    TRAIN_DATA_FILENAME = args.trainseqs
    VAL_DATA_FILENAME = args.valseqs
    MODEL = args.model
    LABEL_NAME = args.label
    INPUT_NAME = args.inputs 
    EVAL_ONLY = args.eval_only
    SIM = args.sim

    # download data and get filenames
    #run = wandb.init(project=PROJECT_NAME, mode='disabled')
    #artifact = run.use_artifact(ARTIFACT_FILENAME, type='dataset')
    #artifact.download()

    #data_folder = ARTIFACT_FILENAME.split('/')[-1]
    #TRAIN_DATA_FILENAME = 'artifacts'+ '/' + data_folder + '/' + TRAIN_DATA_FILENAME
    #VAL_DATA_FILENAME = 'artifacts' + '/' + data_folder + '/' + VAL_DATA_FILENAME
    #SIM = 90
    #TRAIN_DATA_FILENAME = f'artifacts/august_2025/final_selected_train_{SIM}.csv'
    #VAL_DATA_FILENAME = f'artifacts/august_2025/final_selected_test_{SIM}.csv'

    #TRAIN_DATA_FILENAME = f'artifacts/august_2025/gene_split_filltrain/gene_split_train.csv' #final_selected_train_{SIM}.csv'
    #VAL_DATA_FILENAME = f'artifacts/august_2025/gene_split_filltrain/gene_split_val.csv' #final_selected_val_{SIM}.csv'

    #LABEL_NAME = 'cycle'
    #INPUT_NAME = 'sequence'
    
    #MODEL = 'facebook/esm2_t6_8m_UR50D'
    #MODEL = f'cycformer_{SIM}_med_sampled/checkpoint-306527'
    #MODEL = f'final_models/models/cyc_{SIM}'
    #MODEL = f'inf_pkg/cycformer/models/final_models/cyc_{SIM}'

    print(f'TRAINING DATA:   {TRAIN_DATA_FILENAME}')
    print(f'VALIDATION DATA: {VAL_DATA_FILENAME}')
    print(f'MODEL:           {MODEL}')

    # Set up tokenizer
    tokenizer = EsmTokenizer.from_pretrained('facebook/esm2_t6_8m_UR50D')

    # Set up datasets
    train_proteins = ProteinDataset(
        csv_file=TRAIN_DATA_FILENAME,
        tokenizer=tokenizer,
        label_column=LABEL_NAME,
        seq_column=INPUT_NAME,
        sim=SIM,
        nsamples=-1,
        dataframe=None,
        save_id_map=True,
    )

    val_proteins = ProteinDataset(
        csv_file=VAL_DATA_FILENAME,
        tokenizer=tokenizer,
        label_column=LABEL_NAME,
        seq_column=INPUT_NAME,
        mapper=train_proteins.label_dict,
        sim=SIM,
        dataframe=None,
        nsamples=0,
        filter_len=1000000,
    )


    # init model
    model = EsmForSequenceClassification.from_pretrained(MODEL, 
                                                         num_labels=train_proteins.nu_labels,
                                                         hidden_dropout_prob=0.1,
                                                         #attention_probs_dropout_prob=0.5,
                                                        )

    # model training
    #model.train()
    print(f'# of TRAIN SEQ:   {len(train_proteins)}')
    print(f'# of VAL SEQ:     {len(val_proteins)}')
    print(f'# OF LABELS:      {train_proteins.nu_labels}')

    tr_args = TrainingArguments(output_dir,
                                eval_strategy='steps',
                                save_strategy='steps',
                                learning_rate=1e-5,
                                #num_train_epochs=1,
                                #per_device_train_batch_size=2,
                                max_steps=20000,
                                logging_steps=50,
                                auto_find_batch_size=True,
                                #per_device_eval_batch_size=4,
                                #report_to='wandb',
                                #run_name=run_name,
                                save_steps=10000,
                                eval_steps=10000,
                                #eval_accumulation_steps=100,
                                dataloader_num_workers=1,
                                disable_tqdm=False,
                            )

    trainer = Trainer(model,
                      tr_args,
                      train_dataset=train_proteins,
                      eval_dataset=val_proteins,
                      tokenizer=tokenizer,
                      compute_metrics=compute_metrics,
                    )
    
    if EVAL_ONLY == 1:
        print('only running evaluations!')
        results = trainer.evaluate()
    else:
        trainer.train()
        results = trainer.evaluate()
    
    print("\nEvaluation Results:")
    for metric, value in results.items():
        if metric == 'eval_conf_mat': continue
        print(f"{metric}: {value}")

    
    # Extract confusion matrix from results
    conf_mat = results.get('eval_conf_mat') #['confusion_matrix']
    if conf_mat is not None:
        
        # Create figure for confusion matrix
        plt.figure(figsize=(10, 8))
        
        # Get label names from label_dict
        labels = list(train_proteins.label_dict.keys())
        print(train_proteins.label_dict)
        
        sns.heatmap(conf_mat, annot=False, cmap='Reds',
                   xticklabels=labels, yticklabels=labels)

        plt.xlabel('Predicted labels')
        plt.ylabel('True labels')
        plt.title('Confusion Matrix')
        
        # Create directory for plots if it doesn't exist
        os.makedirs(f"{output_dir}/plots", exist_ok=True)
        
        # Save the confusion matrix plot
        plt.tight_layout()
        plt.savefig(f"{output_dir}/plots/confusion_matrix_{SIM}.png")
        plt.close()
        
        print(f"Confusion matrix plot saved to {output_dir}/plots/confusion_matrix_{SIM}_test.png")
    else:
        print("Confusion matrix not found in evaluation results")
    #wandb.finish()
    


def compute_metrics(eval_pred):
    logits, labels = eval_pred
    predictions = np.argmax(logits, axis=-1)

    precision = precision_metric.compute(predictions=predictions, references=labels, average='weighted')
    recall = recall_metric.compute(predictions=predictions, references=labels, average='weighted')
    acc = accuracy.compute(predictions=predictions, references=labels)
    mcc = matthews_metric.compute(references=labels, predictions=predictions)    
    f1 = f1_metric.compute(references=labels, predictions=predictions, average='weighted')
    conf_mat = conf_mat_metric.compute(references=labels, predictions=predictions, normalize='true')['confusion_matrix'].tolist()
    return {"accuracy": acc, "MCC": mcc, "F1": f1, 'precision': precision, 'recall': recall, 'conf_mat': conf_mat}



def parse_args():
    # parse arguments
    parser = argparse.ArgumentParser()
    parser.add_argument('--model_save_dir')
    parser.add_argument('--trainseqs')
    parser.add_argument('--valseqs')
    parser.add_argument('--model')
    parser.add_argument('--label')
    parser.add_argument('--inputs')
    parser.add_argument('--eval_only')
    parser.add_argument('--sim')
    args = parser.parse_args()
    return args


if __name__ == '__main__':
    main()
    
                        

