#### Preamble ####
# Purpose: Prepare and clean the data on the current employees on the Blacksaber Software.
# Author: Rain Wu
# Data: 07 April 2021
# Contact: rain.run.wu@dataoverflow.ca
# License: MIT
# Please note that this is confidential data provided by Data Over Flow's clients, analysts must perform analysis in accordance
# with the code of conduct on information security. 

#### Workspace setup ####
if (!require("remotes")) install.packages("remotes")
remotes::install_github("AndriSignorell/DescTools")
                        
library(tidyverse)
library(DescTools)


#Import Data
black_saber_current_employees <- read_csv("../input/data/black-saber-current-employees.csv")
final_hires <- read_csv("../input/data/final-hires-newgrad_2020.csv")
phase1_new_applicants <- read_csv("../input/data/phase1-new-grad-applicants-2020.csv")
phase2_new_applicants <- read_csv("../input/data/phase2-new-grad-applicants-2020.csv")
phase3_new_applicants <- read_csv("../input/data/phase3-new-grad-applicants-2020.csv")

# Data Cleaning
# Current employees data

# Removing the dollar signs in current employees data
black_saber_current_employees$salary <- as.numeric(gsub('[$,]','',black_saber_current_employees$salary))

# Add a quarter variable indicating the financial quarter but not the years
black_saber_current_employees<- black_saber_current_employees %>% mutate(quarter = as.character(ifelse(StrRight(financial_q, 1) == '1', '1',
                                                                                          ifelse(StrRight(financial_q, 1) == '2',
                                                                                                 '2', ifelse(StrRight(financial_q, 1) == '3', 
                                                                                                             '3', ifelse(StrRight(financial_q, 1) == '4', '4', financial_q))))))
# Add a financial year variable indicating the financial year but not the quarters
black_saber_current_employees<- black_saber_current_employees %>% mutate(year = as.numeric(StrLeft(financial_q, 4)))

# Combined a few job seniority levels, ie. combined entry-level, junior I II III into junior, senior I II III into senior
black_saber_current_employees<- black_saber_current_employees %>% mutate(seniority = ifelse(role_seniority == 'Entry-level' | StrLeft(role_seniority, 6) 
                                                                                           == 'Junior', 'Junior', ifelse(StrLeft(role_seniority, 6) == 'Senior',
                                                                                                                         'Senior', role_seniority)))
# Promotion Data

current <- black_saber_current_employees
promotion <- current %>% select(employee_id, role_seniority)
promotion <- unique(promotion)
promotion <- promotion %>% group_by(employee_id) %>% mutate(promotion =n_distinct(role_seniority) - 1)
promotion <- merge(current, promotion, by = "employee_id", all.x = TRUE)
promotion <- promotion %>% select(employee_id, gender, promotion) %>% filter(gender != "Prefer not to say")
promotion <- unique(promotion)

# Calculate average productivity score for each employee
temp_promotion <- current %>% group_by(employee_id) %>% summarise_at(vars(productivity),
                                                                                         list(avg_productivity = mean))
promotion <- inner_join(promotion, temp_promotion, by = "employee_id")


# Hiring Data

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
phase1_new_applicants

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
write.csv(black_saber_current_employees, "../output/clean/current.csv")
write.csv(phase1_new_applicants, "../output/clean/phase1_new.csv")
write.csv(phase2_new_applicants, "../output/clean/phase2_new.csv")
write.csv(phase3_new_applicants, "../output/clean/phase3_new.csv")
write.csv(promotion, "../output/clean/promotion.csv")

