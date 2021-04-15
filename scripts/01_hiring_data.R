#### Preamble ####
# Purpose: Prepare and clean the data on the current employees on the Blacksaber Software.
# Author: Rain Wu
# Data: 07 April 2021
# Contact: rain.run.wu@dataoverflow.ca
# License: MIT
# Please note that this is cofidential data provided by Data Over Flow's clients, analysts must perform analysis in accordence
# with the code of conduct on information security. 

#### Workspace setup ####
library(tidyverse)

#Import Data
black_saber_current_employees <- read_csv("data/black-saber-current-employees.csv")
final_hires <- read_csv("data/final-hires-newgrad_2020.csv")
phase1_new_applicants <- read_csv("data/phase1-new-grad-applicants-2020.csv")
phase2_new_applicants <- read_csv("data/phase2-new-grad-applicants-2020.csv")
phase3_new_applicants <- read_csv("data/phase3-new-grad-applicants-2020.csv")

#Data Cleaning
#Removing the dollar signs in current employees data
black_saber_current_employees$salary <- as.numeric(gsub('[$,]','',black_saber_current_employees$salary))
# If the applicant is hired, final_hired = 1, otherwise final_hired = NA.
final_hires <- final_hires %>% mutate(final_hired = 1)

# If the applicant passed phase1, pass_phase1 = 1, otherwise = NA.
phase2_temp <- phase2_new_applicants %>% 
  select(applicant_id, technical_skills) %>% rename(pass_phase1 = technical_skills) %>% mutate(pass_phase1 = 1)

# If the applicant passed phase2, pass_phase2 = 1, otherwise = NA.
phase3_temp <- phase3_new_applicants %>% 
  select(applicant_id, interviewer_rating_1) %>% rename(pass_phase2 = interviewer_rating_1) %>% mutate(pass_phase2 = 1)

phase1_new_applicants <- phase1_new_applicants %>% 
  merge(final_hires, by = "applicant_id", all = TRUE) %>% merge(phase2_temp, by = "applicant_id", all = TRUE) 

phase1_new_applicants <- phase1_new_applicants %>% 
  mutate(pass_phase1 = ifelse(is.na(pass_phase1), 0, 1)) %>% mutate(final_hired = ifelse(is.na(final_hired), 0, 1)) 

phase2_new_applicants <- phase2_new_applicants %>% 
  merge(final_hires, by = "applicant_id", all = TRUE)%>% merge(phase3_temp, by = "applicant_id", all = TRUE)

phase2_new_applicants <- phase2_new_applicants %>% 
  mutate(pass_phase2 = ifelse(is.na(pass_phase2), 0, 1)) %>% mutate(final_hired = ifelse(is.na(final_hired), 0, 1)) 

phase2_temp1 <- phase2_new_applicants %>% select(-final_hired, -pass_phase2)

phase3_new_applicants <- phase3_new_applicants %>% 
  merge(final_hires, by = "applicant_id", all = TRUE) %>% inner_join(phase2_temp1, by = "applicant_id")

phase3_new_applicants <- phase3_new_applicants %>% 
  mutate(final_hired = ifelse(is.na(final_hired), 0, 1)) 

#Export cleaned data
write.csv(black_saber_current_employees, "data/clean/current.csv")
write.csv(phase1_new_applicants, "data/clean/phase1_new.csv")
write.csv(phase2_new_applicants, "data/clean/phase2_new.csv")
write.csv(phase3_new_applicants, "data/clean/phase3_new.csv")
