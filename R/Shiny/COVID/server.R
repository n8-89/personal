library(reshape2)
library(ggplot2)
library(tidyverse)
library(plotly)

# Define server logic
server <- function(input, output, session) {
  # read data
  covid <-
    read.csv(file.path("Data/covid-19-data", "us-counties.csv"))

  # melt data
  covid_melt <-
    melt(covid, id = c("date", "county", "state", "fips"))

  # order county values ascending
  covid_melt <- covid_melt[order(covid_melt$county),]

  # order state values ascending
  covid_melt <- covid_melt[order(covid_melt$state),]

  # convert date column to date dtype
  covid_melt$date <- as.Date(covid_melt$date, format = "%Y-%m-%d")

  # output state_selector
  output$state_selector <- renderUI({
    selectInput(
      inputId = "state",
      label = "Choose a State/Territory:",
      choices = unique(covid_melt$state),
      selected = unique(covid_melt$state[1])
    )
  })

  # output county_selector
  output$county_selector <- renderUI({
    available <- covid_melt[covid_melt$state == input$state, "county"]
    selectInput(
      inputId = "county",
      label = "Choose a County/Municipality:",
      choices = unique(available),
      selected = unique(available[1])
    )
  })

  # output range of dates
  output$date_selector <- renderUI({
    dateRangeInput(
      inputId = "dates",
      label = "Select a Range of Dates",
      start = "2020-01-01"
    )
  })

  # plot cases and deaths by selected state and count in selected state - plotly
  output$covid_plotly <- renderPlotly({
    state_filter <- filter(covid_melt, state == input$state)
    county_filter <- filter(state_filter, county == input$county)
    p <- ggplot(data = county_filter, aes(
      x = date,
      y = value,
      group = variable
    )) +
      geom_line(aes(color = variable)) +
      geom_point(aes(color = variable)) +
      scale_x_date(limits = c(input$dates[1], input$dates[2]))
    ggplotly(p +
      ggtitle("COVID Cases and Deaths by County"))
  })
}
