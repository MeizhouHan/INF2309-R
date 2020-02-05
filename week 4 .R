## DATA VISUALIZATIONS IN R
library(dslabs)
library(dplyr)
library(ggplot2)
install.packages("gridExtra")
#this is R script

## Simple plots with qplot
data(murders)   # in dslabs
x <- murders$population
y <- murders$total
qplot(x,y)

##draw plots next to each other
library(gridExtra)
p1 <- qplot(x)
p2 <- qplot(x,y)
grid.arrange(p1, p2, ncol = 2)
#x and the distribution of x

##Correlation plots
## Load the iris dataset and keep only the first four columns (numeric)
data(iris)
iris_x <-iris[,1:4]
cor(iris_x)  ## creates a correlation matrix
library(corrplot)
corrplot(cor(iris_x),method="ellipse")#椭圆形
#blue are positive corr, orange are negative corr

### MORE FANCY PLOTS WITH ggplot2
# ggplot2 cheatsheet can be found here https://www.rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf
## produce the plot summarizing murder rates by states.
ggplot(data = murders)   ## to create a ggplot object and specify data associated with it
##create graphs by adding layers using +
## geom_point is a layer to draw a scatterplot that requires data and aesthetic mapping 

?geom_point  ## to see what aesthetics are required

##plot a scatterplot of population in millions on x-axis and total murder on y-axis
##note: I didn't identify any labels or scale for the axes here
ggplot(murders) + geom_point(aes(x = population/10^6, y = total))
#same as qplot

#OR 
p<- ggplot(murders)
p + geom_point(aes(x = population/10^6, y = total)) #we keep adding layers

### set the limits of the x and y axes
ggplot(murders) + geom_point(aes(x = population/10^6, y = total))+ coord_cartesian(xlim = c(0, 40), ylim=c(0,1500))

##Add labels to points
p + geom_point(aes(population/10^6, total)) +
  geom_text(aes(population/10^6, total, label = abb)) ##label should be inside aes to recognize it 

##Add a vertical line 
p + geom_point(aes(population/10^6, total)) +
  geom_text(aes(population/10^6, total, label = abb))+
  geom_vline(xintercept =20)

##Add text 
p + geom_point(aes(population/10^6, total)) +
  geom_text(aes(population/10^6, total, label = abb))+
  geom_vline(xintercept =20)+
  geom_text(x=20, y=1000, label="population = 20 million",hjust = 0) 
#default in the middle, hjust=0 move to the right, hjust=1 move to left

?geom_text
##Add some embetterments through arguments
## Increase the size of the point 
p + geom_point(aes(population/10^6, total), size=2) +
  geom_text(aes(population/10^6, total, label = abb))

### shift the label to the right
p + geom_point(aes(population/10^6, total), size=2) +
  geom_text(aes(population/10^6, total, label = abb), nudge_x = 1.5)

##Instead of writing aes mapping with each geometries, define the mapping once in the original global ggplot
p <- ggplot(murders, aes(population/10^6, total, label = abb))
p+geom_point(size=2) + geom_text(nudge_x = 1.5)

## the third argument overrides the global mapping and takes a local one
p + geom_point(size = 2) +  geom_text(nudge_x = 1.5)+
  geom_text(aes(x = 10, y = 800, label = "Hello there!"))  

##apply scale of x and y axes
p + geom_point(size = 2) +  
  geom_text(nudge_x = 0.05) +   ##make the nudge smaller as it is the log
  scale_x_continuous(trans = "log10") +
  scale_y_continuous(trans = "log10") 

##explore scale_x_log10(), scale_x_sqrt() and scale_x_reverse().
?scale_x_continuous

##Add title and axes labels
p + geom_point(size = 2) +  
  geom_text(nudge_x = 0.05) + 
  scale_x_log10() +
  scale_y_log10() +
  xlab("Populations in millions (log scale)") + 
  ylab("Total number of murders (log scale)") +
  ggtitle("US Gun Murders in 2010")

##OR
p + geom_point(size = 2) +  
  geom_text(nudge_x = 0.05) + 
  scale_x_log10() +
  scale_y_log10() +
  labs(x="Populations in millions (log scale)",
       y="Total number of murders (log scale)",
       title="US Gun Murders in 2010")  

##Add colors
## define p as everything else except geom_point
p <- ggplot(murders, aes(population/10^6, total, label = abb))+
     geom_text(nudge_x = 0.05)+ 
     scale_x_log10()+ 
     scale_y_log10()+
     labs(x="Populations in millions (log scale)",
          y="Total number of murders (log scale)",
          title="US Gun Murders in 2010") 
p

p+geom_point(size = 2, color ="blue")

##color by region
p + geom_point(col=region, size = 2) ##ERROR! Why? 

p + geom_point(aes(col=region), size = 2) ## we need to use aes with any mapping of data

## EXERCISE 1
data("murders")
## Draw a ggplot of the murders dataset and store it in variable p, what is the class of p
p<- ggplot(murders)
p
class(p)

##Draw a ggplot with only state abbreviations as labels (no points)
p <- ggplot(murders, aes(population/10^6, total, label = abb))
p+geom_text()

## Draw the labels as state abbreviation in Blue
p+geom_text(col ="blue")

#Rewrite the code above to make the labels’ color be determined by the state’s region.
# and the size of the label=2 
p+geom_text(aes(col=region), size=2)

###### ADDING INFORMATION ON THE PLOT
##Create a line of average murder rate
## see explanation of how to claculate r (murder rate for the entire country) in slide 7 
r <- summarize(murders, rate = sum(total) /  sum(population) * 10^6) 
r$rate 
# OR r <- sum(murders$total)/sum(murders$population) *10^6

#define global mapping
p <- ggplot(murders, aes(population/10^6, total, label = abb))+
  geom_text(nudge_x = 0.05)+ 
  scale_x_log10()+ 
  scale_y_log10()+
  labs(x="Populations in millions (log scale)",
       y="Total number of murders (log scale)",
       title="US Gun Murders in 2010")+
  geom_point(aes(col=region), size = 2)
p

#To add a line we use the geom_abline function. 
#ggplot2 uses ab in the name to remind us we are supplying 
#the intercept (a) and slope (b). The default line has slope 1 
#and intercept 0 so we only have to define the intercept
p + geom_abline(intercept = log10(r$rate), slope=1)

##always draw the abline first so it doesnt go over the points
p + geom_abline(intercept = log10(r$rate), lty = 2, color = "darkgrey") 

##lty is line type
?geom_abline()

## To change the title of the legend
p <- p + geom_abline(intercept = log10(r$rate), lty = 2, color = "darkgrey") +
  scale_color_discrete(name = "Region of US")

p

## SOME MORE AESTHETICS
#####
install.packages("ggthemes")
library(ggthemes)
p + theme_economist()    ## theme of the Economist
p + theme_excel_new()    ## excel
p +theme_gdocs()     #google docs
? theme_   ## to know about other themes

install.packages("ggrepel")
library(ggrepel)

##the full code from beginning
library(ggplot2)
library(ggthemes)
library(ggrepel)
library(dplyr)
r <- summarize(murders, rate = sum(total) /  sum(population) * 10^6) 
r$rate 

ggplot(murders, aes(population/10^6, total, label = abb)) +   
  geom_abline(intercept = log10(r$rate), lty = 2, color = "darkgrey") +
  geom_point(aes(col=region), size = 2) +
  geom_text_repel() + 
  scale_x_log10() +
  scale_y_log10() +
  xlab("Populations in millions (log scale)") + 
  ylab("Total number of murders (log scale)") +
  ggtitle("US Gun Murders in 2010") + 
  scale_color_discrete(name = "Region") +
  theme_economist()

### EXERCISE 2
## See details of exercise 2 in slide 8 of the slide deck
data(heights)


ggplot(heights, aes(sex, height)) + 
  geom_point(aes(col=sex), size = 2) +
  xlab("Gender") + 
  ylab("Height in inches") +
  ggtitle("Student height in the iSchool") + 
  scale_color_discrete(name = "Gender") +
  geom_hline(yintercept = mean(filter(heights,sex == "Male")$height), lty = 2, color = "#00FFFF") + 
  geom_hline(yintercept = mean(filter(heights,sex == "Female")$height), lty = 2, color = "#FF6666")+
  coord_cartesian(xlim=c(0,3))+
  geom_text(x=1, y=mean(filter(heights,sex == "Female")$height)+1, label="Avg Female Height")+
  geom_text(x=2, y=mean(filter(heights,sex == "Male")$height)+1, label="Avg Male Height")






