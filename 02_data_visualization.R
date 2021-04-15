#### Preamble ####
# Purpose: Produce data visualizations to be used in the bias report for the Blacksaber Software.
# Author: Yiqu Ding
# Data: 12 April 2021
# Contact: yiqu.ding@dataoverflow.ca
# License: MIT
# Please note that this is cofidential data provided by Data Over Flow's clients, analysts must perform analysis in accordence
# with the code of conduct on information security. 

#### Workspace setup ####
library(tidyverse)
library(ggplot2)
#edit axis label (name)
salary_by_gender_q1 <- current %>% filter(substring(financial_q, nchar(financial_q)) == '1') %>% 
  ggplot(aes(x = gender, y = salary)) + geom_boxplot(aes(colour = gender))
salary_by_gender_q2 <- current %>% filter(substring(financial_q, nchar(financial_q)) == '1') %>% 
  ggplot(aes(x = gender, y = salary)) + geom_boxplot(aes(colour = gender))
salary_by_gender_q3 <- current %>% filter(substring(financial_q, nchar(financial_q)) == '1') %>% 
  ggplot(aes(x = gender, y = salary)) + geom_boxplot(aes(colour = gender))
salary_by_gender_q4 <- current %>% filter(substring(financial_q, nchar(financial_q)) == '1') %>% 
  ggplot(aes(x = gender, y = salary)) + geom_boxplot(aes(colour = gender))
gender_salary <- plot_grid(salary_by_gender_q1, salary_by_gender_q2, salary_by_gender_q3, 
                           salary_by_gender_q4, labels = c("Q1","Q2","Q3","Q4"), ncol = 2, nrow = 2)
ggsave("images/gender_salary.png", gender_salary)
