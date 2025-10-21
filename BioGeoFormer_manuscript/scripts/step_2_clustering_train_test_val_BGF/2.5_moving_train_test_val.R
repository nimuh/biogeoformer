
setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

# Set your main directory
main_dir <- "../../BGF_clustering/train_test_val_final/"

# Get full file paths for everything in the folder
files <- list.files(main_dir, full.names = TRUE)

# Loop through each file
for (f in files) {
  # Extract just the filename
  fname <- basename(f)
  
  # Determine destination based on filename pattern
  if (grepl("test", fname, ignore.case = TRUE)) {
    dest_dir <- file.path(main_dir, "test")
  } else if (grepl("val", fname, ignore.case = TRUE) || grepl("validation", fname, ignore.case = TRUE)) {
    dest_dir <- file.path(main_dir, "validation")
  } else if (grepl("train", fname, ignore.case = TRUE)) {
    dest_dir <- file.path(main_dir, "train")
  } else {
    next  # skip anything that doesn't match
  }
  
  # Create destination directory if it doesn't exist
  if (!dir.exists(dest_dir)) dir.create(dest_dir, recursive = TRUE)
  
  # Build destination file path
  dest_file <- file.path(dest_dir, fname)
  
  # Move the file
  file.rename(f, dest_file)
  
  # Optional: print progress
  message("Moved ", fname, " -> ", dest_dir)
}

