#!/bin/bash

#SBATCH -J cycformer_30_train_august_final
#SBATCH -A eecs
#SBATCH --time=1-12:00:00
#SBATCH -p dgx2
#SBATCH -o job_outputs/cycformer_30_train_august_final.out
#SBATCH -e job_outputs/cycformer_30_train_august_final.err
#SBATCH --gres=gpu:1
#SBATCH --mem=200G

#source ../ko-prediction/ko-pred/bin/activate
python train.py --model_save_dir=cycformer_tests_october \
				--trainseqs=../artifacts/august_2025/final_selected_train_90.csv \
				--valseqs=../artifacts/august_2025/final_selected_test_90.csv \
				--model=facebook/esm2_t6_8M_UR50D \
				--label=cycle \
				--inputs=sequence \
				--eval_only=0 \
				--sim=90 
