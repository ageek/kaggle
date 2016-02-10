#xgb_running_note.R

#average of 2 modles gives a bump of 40 positions (.0007increase in score)

t1 <- read_csv("./xgb_stop_2.csv")
t2 <- read_csv("./keras_nn_test_2.csv")

head(t1)
head(t2)

# t2: keras_nn_test_2.csv	0.96058
# t1: xgb_stop_2.csv	0.96793 
# avg: xgb_stop_mn.csv	0.96813

# t3: xgb_stop_3.csv	0.96787

# 123/3.0 : xgb_123.csv	0.96754


#average out 3 and check
t3 <- read_csv("./xgb_stop_3.csv")
head(t3)

a <- t1$QuoteNumber
b <- (t1$QuoteConversion_Flag + t2$QuoteConversion_Flag 
      + t3$QuoteConversion_Flag)/3.0

tem <- data.frame(QuoteNumber=a, QuoteConversion_Flag=b)
write_csv(tem, "xgb_123.csv")


#xgblinear + xgb_stop_2.csv /2.0
# lets do weighted average of the 1 & 2

tlinear <- read_csv("./xgb_gblinear_stop_4_withQ_mdepth_5.csv")

a <- t1$QuoteNumber
b <- (t1$QuoteConversion_Flag + tlinear$QuoteConversion_Flag)/2.0
tem <- data.frame(QuoteNumber=a, QuoteConversion_Flag=b)
write_csv(tem, "xgb_stop2_linear_mn.csv")

#gives .96222 , dropped from .96813 to .96222



#weighted  average of t1 and t2
# t2: keras_nn_test_2.csv	0.96058
# t1: xgb_stop_2.csv	0.96793 

b <- (0.96058 * t2$QuoteConversion_Flag +
        0.96793 * t1$QuoteConversion_Flag) /(0.96058 + 0.96793)
head(b)
tem <- data.frame(QuoteNumber=a, QuoteConversion_Flag=b)
write_csv(tem, "xgb_1_2_geam_mn.csv")

head(t1)
head(t2)
head(tem)
head(data.frame(t1$QuoteConversion_Flag, 
                t2$QuoteConversion_Flag, 
                tem$QuoteConversion_Flag)
     )
# gives 0.96675 --no improvment over avg score of 1 & 2

# 0.96772