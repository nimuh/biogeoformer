#!/bin/bash

# Define input and output files (nucleotide version)
input_file="/nfs5/MICRO/Thurber_Lab/jacob/MAG_processing_deepsea/non-redundant_MAGs_nucleotides/MAGs_combined_prodigal.fna"
output_file="/nfs5/MICRO/Thurber_Lab/jacob/MAG_processing_deepsea/non-redundant_MAGs_nucleotides/MAGs_combined_prodigal.csv"

# Write the header row to the output CSV
echo "Sequence_ID,Start,End,Strand,ID,Partial,Start_Type,RBS_Motif,RBS_Spacer,GC_Content,Sequence" > "$output_file"

# Use awk to process the .fna file
awk '
BEGIN { OFS="," }
/^>/ {
    if (sequence_id) {
        # Write the previous gene entry
        print sequence_id, start, end, strand, id_info, partial, start_type, rbs_motif, rbs_spacer, gc_content, sequence > "'"$output_file"'"
    }

    # Reset and extract new header fields
    sequence = ""
    match($0, /^>([^ ]+)/, seq_id)
    sequence_id = seq_id[1]
    split($0, parts, " # ")

    start = parts[2]
    end = parts[3]
    strand = parts[4]

    split(parts[5], info, ";")
    split(info[1], id, "=")
    id_info = id[2]

    split(info[2], part, "=")
    partial = part[2]

    split(info[3], stype, "=")
    start_type = stype[2]

    split(info[4], rbs_m, "=")
    rbs_motif = rbs_m[2]

    split(info[5], rbs_s, "=")
    rbs_spacer = rbs_s[2]

    split(info[6], gc, "=")
    gc_content = gc[2]
}
/^[^>]/ {
    sequence = sequence $0
}
END {
    # Write the last record
    print sequence_id, start, end, strand, id_info, partial, start_type, rbs_motif, rbs_spacer, gc_content, sequence > "'"$output_file"'"
}
' "$input_file"

