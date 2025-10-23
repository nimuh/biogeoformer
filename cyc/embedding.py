
from model import load_model
from sklearn.manifold import TSNE
import pandas as pd
from datasets import ProteinDataset
from transformers import EsmTokenizer
import pickle
import torch
from tqdm import tqdm
import datetime
import numpy as np
import matplotlib.pyplot as plt
import os


data_path = '../artifacts/selected_test'
device = "cuda:0" if torch.cuda.is_available() else "cpu"
SAMPLE_COUNT = 100000


# TODO
# adjust plots for 40 and 90 to use the same color pallete for cycles

def tsne(sim):

    model = load_model(sim=sim)
    model.eval()
    data_file_path = data_path + f'/selected_test_{sim}.csv'
    tokenizer = EsmTokenizer.from_pretrained('facebook/esm2_t6_8M_UR50D')
    
    with open(f'biogeoformer/data/cycle_maps/cyc_label_id_map_{sim}.pickle', 'rb') as f:
        mapper = pickle.load(f)

    protein_data = ProteinDataset(
        csv_file=data_file_path,
        tokenizer=tokenizer,
        label_column='cycle',
        seq_column='sequence',
        nsamples=0,
        mapper=None,
    )

    dataloader = torch.utils.data.DataLoader(protein_data, batch_size=1, shuffle=True)
    pathways_map = pd.read_csv('biogeoformer/pathways_df.csv')
    pathways_dict = dict(zip(pathways_map['biogeo_cycle'], pathways_map['long_name']))
    embeds = torch.zeros((len(dataloader), 320))
    labels = []

    #c = len(dataloader)
    c = 0
    #print(f'Iterating through {c} samples')
    for i, sample in enumerate(tqdm(dataloader)):
        inputs = sample['input_ids'][0].to(device)
        if protein_data.id2label[sample['label'].numpy()[0]] == 'nocycle':
            continue
        label = pathways_dict[protein_data.id2label[sample['label'].numpy()[0]]]
        
        labels.append(label)
        outputs = model(inputs, return_dict=True, output_hidden_states=True)
        h = outputs.hidden_states[-1]

        # Take mean across sequence length dimension (dim=1) to get single vector per sequence
        h_mean = torch.mean(h, dim=1)
        h_mean = h_mean.cpu().detach()
        embeds[i] = h_mean

        c += 1
        if c == SAMPLE_COUNT:
            break

    # Convert embeddings to numpy for TSNE
    embeds_np = embeds[:c, :].numpy()
    
    # Perform TSNE dimensionality reduction
    pe = 30
    lr = 'auto'
    n_iter = 1000
    tsne = TSNE(n_components=2,
                perplexity=pe,
                learning_rate=lr,
                n_iter=n_iter,
                verbose=1,
                random_state=42,
                )
    embeds_2d = tsne.fit_transform(embeds_np)

    # Create dataframe for plotting
    df = pd.DataFrame({
        'x': embeds_2d[:, 0],
        'y': embeds_2d[:, 1],
        'label': labels
    })

    # Plot using pandas/matplotlib
    plt.figure(figsize=(15, 9), dpi=300)
    
    # Ensure each label gets a unique color
    unique_labels = sorted(set(labels))
    num_labels = len(unique_labels)
    # Use a colormap with enough distinct colors
    cmap = plt.get_cmap('tab20' if num_labels <= 20 else 'hsv')
    colors = [cmap(i / num_labels) for i in range(num_labels)]
    color_map = {label: tuple(colors[i]) for i, label in enumerate(unique_labels)}

    """
    # Save the color mapping to a file for consistency across runs
    color_map_file = f'biogeoformer/data/color_map.pkl'
    os.makedirs(os.path.dirname(color_map_file), exist_ok=True)
    
    # If a color map already exists, use it and update with any new labels
    if os.path.exists(color_map_file):
        with open(color_map_file, 'rb') as f:
            existing_map = pickle.load(f)
            # Add any new labels with new colors
            for label in unique_labels:
                if label not in existing_map:
                    # Find the first unused color
                    used_colors = np.unique(existing_map.values())
                    for i, color in enumerate(colors):
                        color_tuple = tuple(color)
                        if color_tuple not in used_colors:
                            existing_map[label] = color_tuple
                            break
            color_map = existing_map
    
    # Save the updated color map
    with open(color_map_file, 'wb') as f:
        pickle.dump(color_map, f)
    """
    
    print(df)
    # Plot points colored by label
    for label in set(labels):
        mask = df['label'] == label
        plt.scatter(df[mask]['x'], df[mask]['y'], label=label, alpha=0.6, color=color_map[label])
    
    plt.legend(bbox_to_anchor=(1.05, 1), loc='upper left')
    plt.title(f'TSNE visualization of protein embeddings at {sim}% identity clustering')
    plt.tight_layout()

    date_time = datetime.datetime.now()
    time_stamp = str(date_time).split(' ')[0]
    print(f' Saving to : test_tsne_plot_c={c}_sim={sim}_pe{pe}_lr{lr}_niter{n_iter}_{time_stamp}.png')
    plt.savefig(f'test_tsne_plot_c={c}_sim={sim}_pe{pe}_lr{lr}_niter{n_iter}_{time_stamp}.png')
    plt.close()

        
        
tsne(sim=80)





