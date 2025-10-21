setwd(dirname(rstudioapi::getActiveDocumentContext()$path))
getwd()

setwd('../../BGF_clustering/train_test_val_final/')


library(tidyverse)

selected_dir <- "."

# function to check one similarity level
check_splits <- function(train, val, test, level) {
  cat("\n=== Level", level, "===\n")
  
  summary <- tibble(
    level = level,
    train_unique = n_distinct(train$id),
    val_unique   = n_distinct(val$id),
    test_unique  = n_distinct(test$id),
    within_dup_train = train %>% count(id) %>% filter(n > 1) %>% nrow(),
    within_dup_val   = val   %>% count(id) %>% filter(n > 1) %>% nrow(),
    within_dup_test  = test  %>% count(id) %>% filter(n > 1) %>% nrow(),
    leak_count = 0
  )
  
  # within-split duplicates (console print)
  for (nm in c("train","val","test")) {
    d <- switch(nm, train = train, val = val, test = test)
    dups <- d %>% count(id) %>% filter(n > 1)
    if (nrow(dups) == 0) {
      cat("[WITHIN]", nm, ": no duplicate ids ✅\n")
    } else {
      cat("[WITHIN]", nm, ":", nrow(dups), "duplicate ids (e.g.", 
          paste(head(dups$id, 5), collapse = ", "), ")\n")
    }
  }
  
  # cross-split overlaps
  ids_t <- unique(train$id)
  ids_v <- unique(val$id)
  ids_s <- unique(test$id)
  
  leaks <- unique(c(intersect(ids_t, ids_v),
                    intersect(ids_t, ids_s),
                    intersect(ids_v, ids_s)))
  
  if (length(leaks) == 0) {
    cat("[LEAKAGE] no cross-split overlaps ✅\n")
  } else {
    cat("[LEAKAGE]", length(leaks), "ids overlap across splits (e.g.", 
        paste(head(leaks, 5), collapse = ", "), ")\n")
    summary$leak_count <- length(leaks)
  }
  
  # counts
  cat(sprintf("[COUNTS] train=%d, val=%d, test=%d\n",
              n_distinct(train$id), n_distinct(val$id), n_distinct(test$id)))
  
  return(summary)
}

# detect levels present
files <- list.files(selected_dir, pattern = "final_selected_.*\\.csv$")
levels <- str_match(files, "_(\\d{2,3})\\.csv$")[,2] %>% unique() %>% sort()

# run checks for each level and collect summaries
report <- list()
for (lv in levels) {
  train <- read_csv(file.path(selected_dir, paste0("final_selected_train_", lv, ".csv")),
                    show_col_types = FALSE)
  val   <- read_csv(file.path(selected_dir, paste0("final_selected_val_", lv, ".csv")),
                    show_col_types = FALSE)
  test  <- read_csv(file.path(selected_dir, paste0("final_selected_test_", lv, ".csv")),
                    show_col_types = FALSE)
  
  report[[lv]] <- check_splits(train, val, test, level = lv)
}

summary_tbl <- bind_rows(report)

cat("\n=== SUMMARY TABLE ===\n")
print(summary_tbl)

write_csv(summary_tbl, file.path(selected_dir, "../cluster_summary/final_train_test_val_summary.csv"))
