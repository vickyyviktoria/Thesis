survey <- read.csv("survey.csv")

install.packages("car")
install.packages("writexl")
install.packages("dplyr")
install.packages("rtweet")
install.packages("ggplot2")
install.packages("tidyr")
install.packages("stringr")
install.packages("psych")
install.packages("lm.beta")
install.packages("Hmisc")
install.packages("corrplot")
install.packages("epiDisplay")
install.packages("quanteda")
install.packages("textdata")
install.packages("stargazer")
install.packages("janitor")
install.packages("summarytools")
install.packages("oii")
install.packages("psychTools")
install.packages("DescTools")
install.packages("MESS")
install.packages("gmodels")
install.packages("modeest")
install.packages("tibble")
install.packages("broom")


library(car)
library(writexl)
library(dplyr)
library(rtweet)
library(ggplot2)
library(tidyr)
library(stringr)
library(psych)
library(lm.beta)
library(Hmisc)
library(corrplot)
library(epiDisplay)
library(quanteda)
library(textdata)
library(stargazer)
library(janitor)
library(summarytools)
library(oii)
library(psychTools)
library(DescTools)
library(MESS)
library(gmodels)
library(modeest)
library(tibble)
library(broom)

################## data cleaning
########### removing columns 

survey <- survey [, -c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 43, 72)]
survey <- survey %>%  filter(!row_number() %in% c(1, 2))

############### transforming numbers into numeric data

print(colnames(survey))

numeric_columns <- c("Q2", "Q3", "Q4", "Q5",
                     paste0("Q6_", 1:12), paste0("Q7_", 1:10), 
                     paste0("Q8_", c(1:5, 7:11)), paste0("Q10_", 1:8), 
                     paste0("Q12_", 1:5), paste0("Q13_", 1:4), 
                     paste0("Q14_", c(1:4, 6:7)), paste0("Q15_", 1:10))

survey[numeric_columns] = lapply(survey[numeric_columns], as.numeric)

print(numeric_columns)
print(colnames(survey))

survey <- tibble::rowid_to_column(survey, "index")



########################################## descriptive statistics

################# AGE
str(survey$Q2)
describe(survey$Q2)
mfv(survey$Q2)

#### majority of participants are 18 - 24 years old (70%)


############################## GENDER
describe(survey$Q3)
mfv(survey$Q3)

#### most participants are female with 73%, male are 20%, non binary are 5% and prefer not to say 2%


############################## ACADEMIC BACKGROUND

describe(survey$Q4)
mfv(survey$Q4)

#### 73% are bachelors students, 17% are masters students, 1% are phd candidates and 9% are obtaining a different kind of degree


############################ START OF STUDY

describe(survey$Q5)
mfv(survey$Q5)
oii.freq(survey$Q5)

#### most participants started their studies in 2021 (37%), 17% started prior to 2018, 16% started in 2020


############################ GEN AI

platforms <- survey %>% dplyr::select(starts_with("Q6_"))

summary(platforms)
colSums(platforms)
apply(platforms, 2, sd, na.rm = TRUE)
apply(platforms, 2, median, na.rm = TRUE)


#### the median shows a strong indication, that ChatGPT is used most often by the participants, as it is the
#### only GEN AI with a mean above 1

colMeans(platforms, na.rm = TRUE)
sort(colMeans(platforms, na.rm = TRUE), decreasing = TRUE)

#### by sorting the means from highest to lowest value, it shows that ChatGPT is used most often, then Grammarly AI
#### then ChatPDF, then Quillbot, then Gemini, then Graph PDF, then Midjourney, then Dall-e, etc


################################ METHODS

uses <- survey %>% dplyr::select(starts_with("Q7_"), starts_with("Q8_"))
dishonest_uses <- survey %>% dplyr::select(c("Q8_2", "Q8_3", "Q8_4", "Q8_8", "Q8_9", "Q8_10", "Q8_11"))

uses_means <- rowMeans(uses)
uses <- cbind(uses, uses_means)


uses <- uses %>%
  dplyr :: select(index, uses_means)

survey <- left_join(survey, uses, by = "index")

dishonest_uses_means <- rowMeans(dishonest_uses)
dishonest_uses <- cbind(dishonest_uses, dishonest_uses_means)


dishonest_uses <- dishonest_uses %>%
  dplyr :: select(index, dishonest_uses_means)

survey <- left_join(survey, dishonest_uses, by = "index")



summary(uses)
colSums(uses)
apply(uses, 2, median, na.rm = TRUE)

#### the highest medians from the matrix is 3 for brainstorming, explanations for topics & concepts
#### and explanations for methodologies

apply(uses, 2, sd, na.rm = TRUE)

colMeans(uses, na.rm = TRUE)

sort(colMeans(uses, na.rm = TRUE), decreasing = TRUE)

#### the mean supports this as well, as brainstorming, explanations for topics & concepts
#### and explanations for methodologies have the highest means, followed with summarizing texts, 
#### pointing out key concepts, grammar help, and asking for text structures

summary(dishonest_uses)
colSums(dishonest_uses)
apply(dishonest_uses, 2, median, na.rm = TRUE)

#### for the dishonest uses, the highest median is 2 for paraphrasing output into essays, the others are 1
#### the maximum for 4 out of 7 items is 4 instead of 5, meaning nobody selected always for these items

colMeans(dishonest_uses, na.rm = TRUE)
sort(colMeans(dishonest_uses, na.rm = TRUE), decreasing = TRUE)

#### the mean supports this, the most used dishonest method is paraphrasing, followed by paraphrasing during exams, 
#### cheating during multiple choice exams, copy pasting output into essays, copy pasting whole essays, copy pasting
#### during exams, and making up fake sources

summary(survey$Q8_8)
describe(survey$Q8_8)

uses <- tibble::rowid_to_column(uses, "index")
dishonest_uses <- tibble::rowid_to_column(dishonest_uses, "index")



#### even though making up fake sources had the lowest mean, with 91% of participants choosing never, 4 people chose
#### rarely, 3 people chose occasionally, 1 person chose frequently and 1 person chose always


############################## GRATIFICATIONS

motivations <- survey %>% dplyr::select(starts_with("Q10_"))

summary(motivations)
colSums(motivations)
apply(motivations, 2, median, na.rm = TRUE)
apply(motivations, 2, sd, na.rm = TRUE)

#### the highest medians are for saving time, reducing stress, minimizing effort, and gaining new insights

colMeans(motivations, na.rm = TRUE)
sort(colMeans(motivations, na.rm = TRUE), decreasing = TRUE)

#### again supported by the mean as the highest motivations was saving time, minimizing effort, reducing stress, 
#### gaining new insights, the lowest motivations were enhancing creativity and poor time management

motivations <- tibble::rowid_to_column(motivations, "index")




############################### ACADEMIC DISHONESTY

ac_dishonesty <- survey %>% dplyr::select(starts_with("Q12_"), starts_with("Q13_"))


summary(ac_dishonesty)
colSums(ac_dishonesty)
apply(ac_dishonesty, 2, median, na.rm = TRUE)
apply(ac_dishonesty, 2, sd, na.rm = TRUE)

#### the only median above 1 is copy and changing sentences for assignments (Q13_2)

colMeans(ac_dishonesty, na.rm = TRUE)
sort(colMeans(ac_dishonesty, na.rm = TRUE), decreasing = TRUE)

#### the highest mean was for the same as the median, then Q13_3, Q12_3, Q12_1, Q12_5, etc

########################## evaluating high or low academic dishonesty

ad_score <- rowSums(ac_dishonesty, na.rm = TRUE)
summary(rowSums(ac_dishonesty, na.rm = TRUE))


#### threshhold: for this research, people below a score of 15 have a low academic dishonesty score
#### and people above 15 have a high academic dishonesty score


ac_dishonesty <- tibble::rowid_to_column(ac_dishonesty, "index")

ac_dishonesty <- cbind(ac_dishonesty, ad_score)

result <- ifelse(ac_dishonesty$ad_score < 15, print("low score"), print("high score"))

ac_results_num <- ifelse(ad_score < 15, 0, 1)

ac_dishonesty <- cbind(ac_dishonesty, result)

ac_dishonesty <- cbind(ac_dishonesty, ac_results_num)

survey <- cbind(survey, ad_score)

describe(survey$result)
describe(ac_dishonesty$ac_results_num)
str(ac_dishonesty$ac_results_num)
#### in total, 40% of participants have a high score for academic dishonesty, and 60% have a low score




###################### LEARNING STYLES

learning_styles <- survey %>%
  dplyr :: select(contains("Q15_"))

learning_styles <- learning_styles %>%
  mutate(
    solitary = rowSums(learning_styles[, c("Q15_1", "Q15_2")], na.rm = TRUE),
    competitive = rowSums(learning_styles[, c("Q15_3", "Q15_4")], na.rm = TRUE),
    imaginative = rowSums(learning_styles[, c("Q15_5", "Q15_6")], na.rm = TRUE),
    perceptive = rowSums(learning_styles[, c("Q15_7", "Q15_8")], na.rm = TRUE),
    analytic = rowSums(learning_styles[, c("Q15_9", "Q15_10")], na.rm = TRUE)
  )

learning_styles <- learning_styles %>%
  mutate(
    Style = apply(
      learning_styles[, c("solitary", "competitive", "imaginative", "perceptive", "analytic")],
      1,
      function(x) names(which.max(x))
    )
  )

learning_styles <- learning_styles %>%
  mutate(Style_num = as.numeric(factor(Style, levels = c("solitary", "competitive", "imaginative", "perceptive", "analytic"))))


describe(learning_styles$Style)
describe(learning_styles$Style_num)

learning_styles <- tibble::rowid_to_column(learning_styles, "index")


#### according to the survey, 52% have a solitary learning style, 24% imaginative, 12% perceptive, 7% analytic
#### and 5% competitive

ggplot(learning_styles, aes(x = Style, fill = Style)) +
  geom_bar(color = "black") +
  ggtitle("Learning Styles Distribution") +
  xlab("Styles") +
  ylab("Frequency") +
  scale_fill_manual(values = c(
    "solitary" = "lightblue", "competitive" = "skyblue", "imaginative" = "blue", "perceptive" = "darkblue", "analytic" = "purple")
    )



########################### Approaches


approaches <- survey %>%
  dplyr :: select(contains("Q14_"))


approaches <- approaches %>%
  mutate(
    surface = rowSums(approaches[, c("Q14_1", "Q14_2")], na.rm = TRUE),
    organised = rowSums(approaches[, c("Q14_3", "Q14_4")], na.rm = TRUE),
    deep = rowSums(approaches[, c("Q14_6", "Q14_7")], na.rm = TRUE),
   )

approaches <- approaches %>%
  mutate(
    Approach = apply(
      approaches[, c("surface", "organised", "deep")],
      1,
      function(x) names(which.max(x))
    )
  )

approaches <- approaches %>%
  mutate(approach_num = as.numeric(factor(Approach, levels = c("surface", "organised", "deep"))))


describe(approaches$Approach)
oii.freq(approaches$Approach)

approaches <- tibble::rowid_to_column(approaches, "index")



ggplot(approaches, aes(x = Approach, fill = Approach)) +
  geom_bar(color = "black") +
  ggtitle("Approaches to Learning Distribution") +
  xlab("Approaches") +
  ylab("Frequency") +
  scale_fill_manual(values = c(
    "surface" = "#FF1493", "organised" = "pink", "deep" = "#FF69B4")
  )

#### according to the data, 44% of participants use a deep learning approach, 40% use an organised approach,
#### and 16% use a surface learning approach = distribution




##################################### adding the categories to the df


ac_dishonesty <- ac_dishonesty %>%
 dplyr :: select(index, result)


ac_dishonesty <- ac_dishonesty %>%
  dplyr :: select(index, ac_results_num)

survey <- left_join(survey, ac_dishonesty, by = "index")


learning_styles <- learning_styles %>%
  dplyr :: select(index, Style)

learning_styles <- learning_styles %>%
  dplyr :: select(index, Style_num)

survey <- left_join(survey, learning_styles, by = "index")


approaches <- approaches %>%
  dplyr :: select(index, Approach)


approaches <- approaches %>%
  dplyr :: select(index, approach_num)


survey <- left_join(survey, approaches, by = "index")




############################################# bivariate analysis

############ Age and Usage

t.test(survey$Q2, survey$uses_means)

#### p-value < 0.05
#### H0: Age and frequency of usage of ChatGPT do not have any significant correlation
#### H0 is rejected

cor.test(survey$Q2, survey$uses_means)

#### no correlation

############ Gender and Usage

t.test(survey$Q3, survey$uses_means)

#### p-value > 0.05
#### H0 is accepted



########### Education and Usage

t.test(survey$Q4, survey$uses_means)

#### p-value < 0.05
#### H0 is rejected

cor_test <- cor.test(survey$Q4, survey$uses_means)

#### weak negative correlation


ggplot(data = survey, mapping = aes(x = factor(Q4), y = uses_means)) + 
  geom_boxplot(alpha = 0.6) + 
  geom_jitter(color = "#9400D3", size = 0.4, width = 0.2, alpha = 0.6) +
  labs(title = "Boxplots of Uses by Level of Education Categories",
       x = "Level of Education",
       y = "Uses") +
  theme_minimal()

########### Start of Study and Usage

t.test(survey$Q5, survey$uses_means)

#### p-value < 0.05
#### H0 is rejected

cor.test(survey$Q5, survey$uses_means)

#### weak negative correlation


########### Age and Dishonest Usage

t.test(survey$Q2, survey$dishonest_uses_means)

#### p-value > 0.05


########## Gender and Dishonest Usage

t.test(survey$Q3, survey$dishonest_uses_means)

#### p-value < 0.05

cor.test(survey$Q3, survey$dishonest_uses_means)

#### no correlation


########### Academic Degree and Dishonest Usage

t.test(survey$Q4, survey$dishonest_uses_means)

#### p-value > 0.05


############ Begin of Study and Dishonest Usage

t.test(survey$Q5, survey$dishonest_uses_means)

#### p-value < 0.05

cor.test(survey$Q5, survey$dishonest_uses_means)

#### no correlation




############ Academic Dishonesty and Usage

t.test(survey$ac_results_num, survey$uses_means)

#### p-value < 0.05

cor.test(survey$ac_results_num, survey$uses_means)

#### weak positive correlation

ggplot(data = survey, mapping = aes(x = factor(ac_results_num), y = uses_means)) + 
  geom_boxplot(alpha = 0.6) + 
  geom_jitter(color = "#9400D3", size = 0.4, width = 0.2, alpha = 0.6) +
  labs(title = "Boxplots of Uses by Academic Dishonesty",
       x = "Academic Dishonesty",
       y = "Uses") +
  theme_minimal()

############ Academic Dishonesty and Dishonest Usage

t.test(survey$ac_results_num, survey$dishonest_uses_means)

#### p-value < 0.05

cor.test(survey$ac_results_num, survey$dishonest_uses_means)

#### weak positive correlation

ggplot(data = survey, mapping = aes(x = factor(ac_results_num), y = dishonest_uses_means)) + 
  geom_boxplot(alpha = 0.6) + 
  geom_jitter(color = "#9400D3", size = 0.4, width = 0.2, alpha = 0.6) +
  labs(title = "Boxplots of Dishonest Uses by Academic Dishonesty",
       x = "Academic Dishonesty",
       y = "Dishonest Uses") +
  theme_minimal()


############ styles and usage

t.test(survey$Style_num, survey$uses_means)

#### p-value > 0.05


############ styles and dishonest usage

t.test(survey$Style_num, survey$dishonest_uses_means)

#### p-value < 0.05

cor.test(survey$Style_num, survey$dishonest_uses_means)




############ Approaches and Usage

t.test(survey$approach_num, survey$uses_means)

#### p-value < 0.05

cor.test(survey$approach_num, survey$uses_means)

#### weak negative correlation


############# Approaches and Dishonest Usage

t.test(survey$approach_num, survey$dishonest_uses_means)

#### p-value < 0.05

cor.test(survey$approach_num, survey$dishonest_uses_means)

#### weak negative correlation



########################################### MULTIPLE REGRESSION ANALYSIS

############ uses

lm3 <- lm(uses_means  ~ ac_results_num + approach_num, data = survey)

avPlots(lm3)

summary(lm.beta(lm3))



tidy_model3 <- tidy(lm3)

ggplot(tidy_model3, aes(x = term, y = estimate, fill = term)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_errorbar(aes(ymin = estimate - std.error * 1.96, ymax = estimate + std.error * 1.96), 
                width = 0.2, position = position_dodge(0.9)) +
  labs(title = "Regression Coefficients",
       x = "Variables",
       y = "Coefficient Estimate") +
  theme_minimal() +
  theme(legend.position = "none")


################ dishonest uses

lm4 <- lm(dishonest_uses_means  ~ ac_results_num + approach_num, data = survey)

avPlots(lm4)

summary(lm.beta(lm4))

tidy_model4 <- tidy(lm4)

ggplot(tidy_model4, aes(x = term, y = estimate, fill = term)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_errorbar(aes(ymin = estimate - std.error * 1.96, ymax = estimate + std.error * 1.96), 
                width = 0.2, position = position_dodge(0.9)) +
  labs(title = "Regression Coefficients",
       x = "Variables",
       y = "Coefficient Estimate") +
  theme_minimal() +
  theme(legend.position = "none")


########################### Moderated Multiple Regression Analysis
#################### USES

survey <- survey %>%
  mutate(
    ac_results_num_c = scale(ac_results_num, scale = FALSE),
    approach_num_c = scale(approach_num, scale = FALSE),
    Style_num_c = scale(Style_num, scale = FALSE)
  )

survey <- survey %>%
  mutate(
    ac_style = ac_results_num_c * Style_num_c,
    approach_style = approach_num_c * Style_num_c
  )

model_uses <- lm(uses_means ~ ac_results_num_c * Style_num_c + approach_num_c * Style_num_c, data = survey)

summary(model_uses)

avPlots(model_uses, main = "Added-Variable Plots for Uses")

ggplot(survey, aes(x = uses_means, y = as.factor(ac_results_num), color = Style_num)) +
  geom_point(position = position_jitter(width = 0.1, height = 0), alpha = 0.6) +
  geom_smooth(method = "lm", aes(group = Style_num), se = FALSE) +
  labs(title = "Interaction between Academic Dishonesty and Learning Styles",
       x = "Uses of GenAI",
       y = "Academic Dishonesty") +
  theme_minimal()


####################### DISHONEST USES

model_dishonest_uses <- lm(dishonest_uses_means ~ ac_results_num_c * Style_num_c + approach_num_c * Style_num_c, data = survey)

summary(model_dishonest_uses)

avPlots(model_dishonest_uses, main = "Added-Variable Plots for Dishonest Uses")

ggplot(survey, aes(x = dishonest_uses_means, y = as.factor(ac_results_num), color = Style_num)) +
  geom_point(position = position_jitter(width = 0.1, height = 0), alpha = 0.6) +
  geom_smooth(method = "lm", aes(group = Style_num), se = FALSE) +
  labs(title = "Interaction between Academic Dishonesty and Learning Styles",
       x = "Dishonest Uses GenAI",
       y = "Academic Dishonesty") +
  theme_minimal()
