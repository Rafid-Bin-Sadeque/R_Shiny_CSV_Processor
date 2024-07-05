library(shiny)
library(shinyjs)
library(RMySQL)
library(tidyverse)
library(lubridate)
library(rio)

ui <- fluidPage(
  useShinyjs(),
  tags$head(
    tags$style(
      HTML(
        "
        .button_color {
          background-color: #89CFF0;
          border-color: white;
        }
        "
      )
    )
  ),
  
  titlePanel("FIRST PURCHASE"),
  fileInput("file1", "Choose CSV file ", accept = ".csv"),
  actionButton("process", "PROCESS"),
  downloadButton("download", "Download Processed CSV", style = "color: grey;"),
  textOutput("ready")
)

server <- function(input, output, session) {
  result_f <- reactiveVal(NULL)
  
  observeEvent(input$process, {
    req(input$file1)
    
    result <- tryCatch({
      ### Database Connection & Tables Connection -------------------
      db <- dbConnect(
        MySQL(),
        dbname = "x",
        user = "y",
        password = "z",
        host = "w",
        port = 3306
      )
      
      # Input Email list
      email_list <- read.csv(input$file1$datapath) %>% 
        filter(email != "") %>% 
        mutate(email = str_trim(tolower(email)))
      
      # Find customers that are present in the email list
      customers_df <- tbl(db, "customers") %>% 
        filter(email %in% !!email_list$email) %>% 
        collect()
      
      # Find accounts needed (doing this to make the code faster)
      accounts_df <- tbl(db, "accounts") %>% 
        filter(customer_id %in% !!customers_df$id) %>% 
        collect()
      
      # Find only the necessary orders
      orders_df <- tbl(db, "orders") %>% 
        filter(account_id %in% !!accounts_df$id) %>% 
        collect()
      
      coupons_df <- collect(tbl(db, "coupons"))
      
      orders_df_first_order <- orders_df %>% 
        filter(status == 1) %>% 
        distinct(customer_id, .keep_all = T)
      
      email_list %>% 
        left_join(
          select(customers_df, email, customer_id = id)
        ) %>% 
        left_join(
          select(orders_df_first_order, customer_id, purchase_date = created_at, coupon_id, price = grand_total)
        ) %>% 
        left_join(
          select(coupons_df, coupon_id = id, coupon_code = code)
        ) %>% 
        select(email, affiliate, price, purchase_date, coupon_code)
      
    }, error = function(e) {
      return(paste(
        "Some error happen!",
        "Error message:",
        e,
        sep = "\n"
      ))
    }, finally = {
      lapply(dbListConnections(MySQL()), dbDisconnect)
    })
    
 
    result_f(result)
  })
  
  
  
  observe({
    
    
   shinyjs:: disable('download')
    
  })
  
  observeEvent({input$file1}, {
    output$ready <- renderText({
      ""
    })
    shinyjs::removeClass("download", "button_color")
    shinyjs::disable("download") # Enable the download button when a new file is selected
    
  })
  
  observe({
    shinyjs::toggleClass("download", "button_color", condition = (class(result_f()) == "data.frame"))
    
    if (class(result_f()) == "character") {
      output$ready <- renderText({
        shinyjs::disable("download")
        "There is an issue."
      })
    } else if (class(result_f()) == "data.frame") {
      output$ready <- renderText({
        "The file is ready for download."
      })
      shinyjs::enable("download") 
    }
  })
  
  output$download <- downloadHandler(
    filename = function() {
      paste("req_file", ".csv", sep = "")
    },
    content = function(file) {
      write.csv(result_f(), file, row.names = FALSE)
    }
  )
}

shinyApp(ui = ui, server = server)

