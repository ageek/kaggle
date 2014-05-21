source("get_raw_data.R")

library(ggplot2)

# All state
ggplot(data.raw) + geom_histogram(aes(x=hour,colour=G_final), binwidth=.5, position="stack") + facet_wrap(~state)
ggplot(subset(data.raw, state %in% c("FL","NY","OH","PA"))) + geom_histogram(aes(x=hour,colour=G), binwidth=.5, position="stack") + facet_wrap(~state)


ggplot(data.raw) + geom_density(aes(x=hour,colour=G_final), binwidth=.5, position="stack") + facet_wrap(~state)
ggplot(subset(data.raw, state %in% c("FL","NY","OH","PA"))) + geom_density(aes(x=hour,colour=G), binwidth=.5, position="stack") + facet_wrap(~state)

# G == 2
ggplot(subset(data.raw, "2" == "2")) + geom_density(aes(x=hour,colour=G_final), binwidth=.5, position="stack") + facet_wrap(~ location_id)


ggplot(subset(data.raw, line_situation == "LAST" )) + geom_bar(aes(x=G_final)) + facet_wrap( ~ state)


ggplot(subset(data.raw, line_situation == "LAST" & state == "NY")) + geom_boxplot(aes(x=G_final, y=cost))


data.raw.NY <- subset(data.raw, state == "NY")

ggplot(subset(data.raw.NY, line_situation == "LAST")) + geom_bar(aes(x=factor(location)))



