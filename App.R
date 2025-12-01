library(shiny)
library(DT)
library(stringr)

validate_csv = function(file_path) {
  
  required_cols = c(
    "pitchNum", "pitcher", "pitcherPitchNum", "batterNum", "pitcherBatterNum",
    "inning", "pitchCount", "calledPitchZone", "pitchType", "calledBallsOffPlate",
    "actualPitchZone", "actualBallsOffPlate",
    "isStrike", "isHBP", "didSwing", "madeContact", "isHit", "isOut", "isError"
  )
  
  df = tryCatch(
    read.csv(file_path, stringsAsFactors = FALSE, fileEncoding = "UTF-8"),
    error = function(e) stop("Error reading CSV: ", e$message)
  )
  
  missing_cols = setdiff(required_cols, colnames(df))
  if(length(missing_cols) > 0){
    stop(paste("CSV is missing required columns:", paste(missing_cols, collapse = ", ")))
  }
  
  bool_cols <- c("isStrike", "isHBP", "didSwing", "madeContact", "isHit", "isOut", "isError")
  for (col in bool_cols) {
    if (is.logical(df[[col]])) {
      df[[col]] <- as.integer(df[[col]])
    }
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
    df <- data()
    
    meta <- extract_metadata(input$file$name)
    opponent <- ifelse(is.na(meta$opponent), "UNKNOWN", meta$opponent)
    date <- ifelse(is.na(meta$date), Sys.Date(), meta$date)
    
    report_sections <- c()
    
    for (p in pitchers) {
      
      sub <- df[df$pitcher == p, ]
      
      # ---------------------------------------------------------
      # GAME MANAGEMENT SECTION
      # ---------------------------------------------------------
      
      sub$pitchCount <- as.character(sub$pitchCount)
      
      # Batters faced
      batters_faced <- length(unique(sub$batterNum))
      
      # At-bats (hits + outs)
      at_bats <- sum(sub$isOut) + sum(sub$isHit)
      
      # Total pitches
      total_pitches <- nrow(sub)
      
      # Strikes / balls
      strikes <- sum(sub$isStrike)
      balls <- total_pitches - strikes - sum(sub$isHBP)
      
      # First pitch strikes / balls
      library(dplyr)
      first_pitches <- sub %>%
        group_by(batterNum) %>%
        slice(1) %>%
        ungroup()
      
      first_pitch_strikes <- sum(first_pitches$isStrike)
      first_pitch_balls   <- nrow(first_pitches) - first_pitch_strikes
      
      # Walks and strikeouts derived from pitchCount
      walks <- sum(startsWith(sub$pitchCount, "4"))
      strikeouts <- sum(endsWith(sub$pitchCount, "3"))
      hits <- sum(sub$isHit)
      hbp <- sum(sub$isHBP)
      
      # Convert inning.outs to innings pitched
      convert_inning <- function(x) {
        parts <- strsplit(x, "\\.")[[1]]
        inning <- as.numeric(parts[1])
        outs <- as.numeric(parts[2])
        inning + outs / 3
      }
      
      # Determine total innings pitched
      last_inning <- max(as.numeric(gsub("\\..*$", "", sub$inning)))
      last_outs <- max(as.numeric(gsub("^.*\\.", "", sub$inning)))
      innings_pitched <- last_inning + last_outs / 3
      
      # WHIP
      whip <- (walks + hits) / innings_pitched
      
      game_mgmt <- paste0(
        "Game Management:\n",
        "Number of Batters Faced: ", batters_faced, "\t",
        "At Bats: ", at_bats, "\t",
        "Total Number of Pitches: ", total_pitches, "\n",
        "How Many Strikes: ", strikes, "\t",
        "How Many Balls: ", balls, "\n",
        "First Pitch Strikes: ", first_pitch_strikes, "\t",
        "First Pitch Balls: ", first_pitch_balls, "\n",
        "Walks: ", walks, "\t",
        "Strikeouts: ", strikeouts, "\t",
        "Hits: ", hits, "\tHBP: ", hbp, "\n",
        "Innings Pitched: ", round(innings_pitched, 2), "\n",
        "WHIP (walks + hits)/innings pitched: ", round(whip, 3), "\n\n"
      )
      
      # ---------------------------------------------------------
      # PITCHER'S COUNT SECTION
      # ---------------------------------------------------------
      
      count_0_1 <- sum(sub$pitchCount == "0-1")
      count_0_2 <- sum(sub$pitchCount == "0-2")
      count_1_1 <- sum(sub$pitchCount == "1-1")
      count_1_2 <- sum(sub$pitchCount == "1-2")
      
      hits_0_2 <- sum(sub$isHit & sub$pitchCount == "0-2")
      hits_1_2 <- sum(sub$isHit & sub$pitchCount == "1-2")
      
      # ---------------------------------------------------------
      # PITCH TYPE BREAKDOWN
      # ---------------------------------------------------------
      
      pitch_types <- unique(sub$pitchType)
      pitch_type_lines <- c()
      
      for(pt in pitch_types){
        pt_sub <- sub[sub$pitchType == pt, ]
        total <- nrow(pt_sub)
        strikes_pt <- sum(pt_sub$isStrike)
        balls_pt <- total - strikes_pt - sum(pt_sub$isHBP)
        strike_pct <- if(total > 0) round((strikes_pt / total) * 100, 1) else 0
        
        line <- paste0(
          pt, " – Total: ", total,
          "\tFor a Strike: ", strikes_pt,
          "\tFor a Ball: ", balls_pt,
          "\tStrike %: ", strike_pct, "%"
        )
        
        pitch_type_lines <- c(pitch_type_lines, line)
      }
      
      pitcher_count_section <- paste0(
        "PITCHER'S COUNT:\n",
        "0-1 Count: ", count_0_1, "\t",
        "0-2 Count: ", count_0_2, "\t",
        "1-1 Count: ", count_1_1, "\t",
        "1-2 Count: ", count_1_2, "\n",
        "How Many 0-2 Hits: ", hits_0_2, "\t",
        "How Many 1-2 Hits: ", hits_1_2, "\n",
        "Strike Outs: ", strikeouts, "\t",
        "Walks: ", walks, "\t",
        "Hits: ", hits, "\t",
        "HBP: ", hbp, "\n",
        paste(pitch_type_lines, collapse = "\n"),
        "\n\n"
      )
      
      # ---------------------------------------------------------
      # FINAL SECTION ASSEMBLY
      # ---------------------------------------------------------
      
      section <- paste0(
        "-----------------------------------------\n",
        "Pitching Report for: ", p, "\n",
        "Date: ", date, "\n",
        "Opponent: ", opponent, "\n",
        "-----------------------------------------\n\n",
        game_mgmt,
        pitcher_count_section
      )
      
      report_sections <- c(report_sections, section)
    }
    
    output$report_output <- renderText(paste(report_sections, collapse = "\n"))
  })
}

shinyApp(ui, server)
