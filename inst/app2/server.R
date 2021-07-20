library(AnVILBilling)
library(bigrquery)
library(tibble)
library(plotly)
  server = function(input, output) {
   getdb = eventReactive(input$go, {
    shinytoastr::toastr_info("establishing BQ connection", newestOnTop=TRUE)
    validate(need(nchar(input$email)>0, "enter your google identity (email)"))
    bigrquery::bq_auth(email=input$email, use_oob=TRUE)
    con = DBI::dbConnect(bigrquery::bigquery(), 
         project =input$bqproj, billing=input$billing, dataset=input$dataset)
    list(con=con, table=dbListTables(con))
    })
   getrequest = reactive({
    dbstuff = getdb()
    AnVILBilling::setup_billing_request(input$startd,
        input$endd, input$bqproj, input$dataset, dbstuff$table, input$billing)
    })
    getreck = reactive({
     shinytoastr::toastr_info("reckoning...", newestOnTop=TRUE)
      #ab_reckoning(AnVILBilling::reckon(getrequest())) ### Nov 19 2020: replace with higher-level function
     dbstuff = getdb() 
     getBilling(startDate = input$startd,
               endDate = input$endd,
               bqProject = input$bqproj,
               bqDataset = input$dataset,
               bqTable = dbstuff$table,
               bqBilling_code = input$billing,
               page_size=50000)

      })

   output$bag = DT::renderDataTable({
      arec = NULL
      arec = getreck()
      sk = as_tibble(AnVILBilling:::kvpivot(arec$sku)) # ::: in case we runApp outside
      ss = split(arec$cost, sk$description)
      ans = sort(sapply(ss, sum), decreasing=TRUE) 
      ans = ans[ans>0]
      nm = names(ans)
      lk = data.frame(service=nm, cost=ans[ans>0])
      sm = sum(ans[ans>0])
      nd = data.frame(service="TOTAL", cost=sm)
      lk = rbind(lk, nd)
      rownames(lk) = NULL
      lk
      }, options=list(lengthMenu=c(25,50,100)))
   output$plot = renderPlotly({
       arec = getreck()
       arecsk = AnVILBilling:::kvpivot(arec$sku)
       arec$res = arecsk[,2]
       arec = arec[arec$cost>0,]
       parec = ggplot(arec, aes(x=usage_start_time, y=cost, fill=res)) + 
             geom_bar(stat="identity")  + theme(legend.position="none")
       ggplotly(parec)
      })
   output$cumplot = renderPlot({
      arec = getreck()
      arec = arec[order(arec$usage_start_time),]
      ggplot(arec, aes(x=usage_start_time, y=cumsum(cost))) + geom_point()
      })
   output$sess = renderPrint({
      list(note="This is a prototype of a system for reviewing costs associated with AnVIL usage.", sess=sessionInfo())
      })
   observeEvent(input$stopBtn, stopApp(returnValue=getreck()))
  }
