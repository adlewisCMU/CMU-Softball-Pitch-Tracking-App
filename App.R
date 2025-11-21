library(shiny)
library(DT)
library(stringr)

validate_csv = function(file_path) {
  required_cols = c(
    "pitch_num", "pitcher", "pitcher_pitch_num", "batter_num",
    "pitcher_batter_num", "pitch_count", "called_pitch_zone",
    "pitch_type", "called_balls_off_plate", "actual_pitch_zone",
    "actual_balls_off_plate", "isStrike", "isHBP", "didSwing",
    "madeContact", "isHit", "isOut", "isError"
  )
  
  df = tryCatch(
    read.csv(file_path, stringsAsFactors = FALSE, fileEncoding = "UTF-8"),
    error = function(e) stop("Error reading CSV: ", e$message)
  )
  
  missing_cols = setdiff(required_cols, colnames(df))
  if(length(missing_cols) > 0){
    stop(paste("CSV is missing required columns:", paste(missing_cols, collapse = ", ")))
  }
  
  if(!all(required_cols == colnames(df)[1:length(required_cols)])) {
    stop("CSV columns are not in the expected order.")
  }
  
  return(df)
}

extract_metadata = function(filename) {
  fname = basename(filename)
  fname = str_remove(fname, "\\.csv$")
  
  pattern_vs = "pitch_data_vs_(.*)_([0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2})"
  pattern_practice = "pitch_data_(practice)_([0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2})"
  
  if(str_detect(fname, pattern_vs)){
    matches <- str_match(fname, pattern_vs)
    opponent <- matches[2]
    date <- matches[3]
  } else if(str_detect(fname, pattern_practice)){
    matches <- str_match(fname, pattern_practice)
    opponent <- "practice"
    date <- matches[3]
  } else {
    opponent <- NA
    date <- NA
  }
  
  return(list(opponent = opponent, date = date))
}

# --- UI ---
ui <- fluidPage(
  titlePanel("CMU Pitch Tracker Report Generation"),
  
  sidebarLayout(
    sidebarPanel(
      fileInput("file", "Upload CSV", accept = ".csv"),
      actionButton("generate_report", "Generate Report")
    ),
    
    mainPanel(
      DTOutput("data_table"),
      verbatimTextOutput("validation_message"),
      verbatimTextOutput("report_output")
    )
  )
)

# --- Server ---
server = function(input, output, session) {
  
  data = reactive({
    req(input$file)
    tryCatch({
      df = validate_csv(input$file$datapath)
      output$validation_message <- renderText("CSV validation successful.")
      return(df)
    }, error = function(e) {
      output$validation_message <- renderText(paste("CSV validation failed.\n", e$message))
      return(NULL)
    })
  })
  
  output$data_table <- renderDT({
    req(data())
    datatable(data(), options = list(pageLength = 10))
  })
  
  observeEvent(input$generate_report, {
    req(data())
    meta <- extract_metadata(input$file$name)
    opponent <- ifelse(is.na(meta$opponent), "UNKNOWN", meta$opponent)
    date <- ifelse(is.na(meta$date), Sys.Date(), meta$date)
    
    report_text <- paste0(
      "Pitching Evaluations\n",
      "Date: ", date, "    Opponent: ", opponent, "\n\n",
      "Number of pitches: ", nrow(data()), "\n",
      "Strikes: ", sum(data()$isStrike), "\n",
      "Balls Hit By Pitch: ", sum(data()$isHBP), "\n",
      "Batter Swings: ", sum(data()$didSwing), "\n",
      "Hits: ", sum(data()$isHit), "\n",
      "Outs: ", sum(data()$isOut), "\n",
      "Errors: ", sum(data()$isError)
    )
    
    output$report_output <- renderText(report_text)
  })
}

shinyApp(ui, server)
