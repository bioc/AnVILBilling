library(AnVILBilling)
library(bigrquery)
library(tibble)
library(plotly)
  ui = fluidPage(
   shinytoastr::useToastr(),
   sidebarLayout(
    sidebarPanel(
     helpText("AnVIL Billing browser"),
     textInput("email", "Google email", value=""),
     textInput("bqproj", "BQproject", value="bjbilling"),
     textInput("dataset", "BQdataset", value="anvilbilling"),
     textInput("billing", "billing code", value="landmarkanvil2"),
     dateInput("startd", "start date", value="2021-07-01"),
     dateInput("endd", "end date (inclusive)", value="2021-07-15"),
     actionButton("go", "proceed", class="btn-success"),
     actionButton("stopBtn", "stop app"),
     width=3
     ),
    mainPanel(
     tabsetPanel(
      tabPanel("basic",
       DT::dataTableOutput("bag")
       ),
      tabPanel("plot",
       plotlyOutput("plot"),
       plotOutput("cumplot")
       ),
      tabPanel("about",
       verbatimTextOutput("sess")
       )
      )
    )
   )
  )
