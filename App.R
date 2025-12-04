library(shiny)
library(DT)
library(stringr)
library(dplyr)
library(rmarkdown)

validate_csv <- function(file_path) {
  
  required_cols <- c(
    "pitchNum", "pitcher", "pitcherPitchNum", "batterNum", "pitcherBatterNum",
    "inning", "pitchCount", "calledPitchZone", "pitchType", "calledBallsOffPlate",
    "actualPitchZone", "actualBallsOffPlate",
    "isStrike", "isHBP", "didSwing", "madeContact", "isHit", "isOut", "isError"
  )
  
  df <- tryCatch(
    read.csv(file_path, stringsAsFactors = FALSE, fileEncoding = "UTF-8"),
    error = function(e) stop("Error reading CSV: ", e$message)
  )
  
  missing_cols <- setdiff(required_cols, colnames(df))
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

extract_metadata <- function(filename) {
  fname <- basename(filename)
  fname <- str_remove(fname, "\\.csv$")
  
  pattern_vs <- "pitch_data_vs_(.*)_([0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2})"
  pattern_practice <- "pitch_data_practice_([0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2})"
  
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
      actionButton("generate_report", "Generate Report"),
      downloadButton("download_pdf", "Download PDF Report")
    ),
    
    mainPanel(
      DTOutput("data_table"),
      verbatimTextOutput("validation_message"),
      verbatimTextOutput("report_output")
    )
  )
)

# --- Server ---
server <- function(input, output, session) {
  
  data <- reactive({
    req(input$file)
    tryCatch({
      df <- validate_csv(input$file$datapath)
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
  
  report_text <- reactiveVal("")  # store text version for PDF
  
  observeEvent(input$generate_report, {
    req(data())
    df <- data()
    
    meta <- extract_metadata(input$file$name)
    opponent <- ifelse(is.na(meta$opponent), "UNKNOWN", meta$opponent)
    date <- ifelse(is.na(meta$date), Sys.Date(), meta$date)
    
    report_sections <- c()
    pitchers <- unique(df$pitcher)
    
    for (p in pitchers) {
      
      sub <- df[df$pitcher == p, ]
      sub$pitchCount <- as.character(sub$pitchCount)
      
      # GAME MANAGEMENT ------------------------------------------------------------
      batters_faced <- length(unique(sub$batterNum))
      at_bats <- sum(sub$isOut) + sum(sub$isHit)
      total_pitches <- nrow(sub)
      strikes <- sum(sub$isStrike)
      balls <- sum(!sub$isStrike & !sub$isHBP)
      
      first_pitches <- sub %>% group_by(batterNum) %>% slice(1) %>% ungroup()
      first_pitch_strikes <- sum(first_pitches$isStrike)
      first_pitch_balls <- sum(!first_pitches$isStrike & !first_pitches$isHBP)
      
      # Walk = batter reaches base via 4-ball count
      walks <- sum(sub$pitchCount %in% c("3-0","3-1","3-2") &
                     !sub$isStrike & !sub$isHBP)
      
      strikeouts <- sum(endsWith(sub$pitchCount, "2") & sub$isStrike & !sub$madeContact)
      hits <- sum(sub$isHit)
      hbp <- sum(sub$isHBP)
      
      last_inning <- max(as.numeric(gsub("\\..*$", "", sub$inning)))
      last_outs <- max(as.numeric(gsub("^.*\\.", "", sub$inning)))
      innings_pitched <- last_inning + last_outs/3
      
      whip <- (walks + hits) / innings_pitched
      
      game_mgmt <- paste0(
        "### Game Management\n",
        "**Batters Faced:** ", batters_faced, "  \n",
        "**At Bats:** ", at_bats, "  \n",
        "**Total Pitches:** ", total_pitches, "  \n",
        "**Strikes:** ", strikes, "  ",
        "**Balls:** ", balls, "  \n",
        "**First Pitch Strikes:** ", first_pitch_strikes, "  ",
        "**First Pitch Balls:** ", first_pitch_balls, "  \n",
        "**Walks:** ", walks, "  ",
        "**Strikeouts:** ", strikeouts, "  ",
        "**Hits:** ", hits, "  ",
        "**HBP:** ", hbp, "  \n",
        "**Innings Pitched:** ", round(innings_pitched,2), "  \n",
        "**WHIP:** ", round(whip,3), "  \n\n"
      )
      
      # PITCHER'S COUNT ------------------------------------------------------------
      count_0_1 <- sum(sub$pitchCount == "0-1")
      count_0_2 <- sum(sub$pitchCount == "0-2")
      count_1_1 <- sum(sub$pitchCount == "1-1")
      count_1_2 <- sum(sub$pitchCount == "1-2")
      hits_0_2 <- sum(sub$isHit & sub$pitchCount == "0-2")
      hits_1_2 <- sum(sub$isHit & sub$pitchCount == "1-2")
      
      pitch_types <- unique(sub$pitchType)
      pitch_type_lines <- c()
      
      for(pt in pitch_types){
        pt_sub <- sub[sub$pitchType == pt, ]
        total <- nrow(pt_sub)
        strikes_pt <- sum(pt_sub$isStrike)
        balls_pt <- total - strikes_pt - sum(pt_sub$isHBP)
        strike_pct <- if(total > 0) round((strikes_pt/total)*100,1) else 0
        
        pitch_type_lines <- c(
          pitch_type_lines,
          paste0("- **", pt, "**: Total ", total,
                 ", Strikes ", strikes_pt,
                 ", Balls ", balls_pt,
                 ", Strike % ", strike_pct, "%")
        )
      }
      
      pitcher_count_section <- paste0(
        "### Pitcher's Count\n",
        "**0-1 Count:** ", count_0_1, "  ",
        "**0-2 Count:** ", count_0_2, "  ",
        "**1-1 Count:** ", count_1_1, "  ",
        "**1-2 Count:** ", count_1_2, "  \n",
        "**0-2 Hits:** ", hits_0_2, "  ",
        "**1-2 Hits:** ", hits_1_2, "  \n",
        "**Strikeouts:** ", strikeouts, "  ",
        "**Walks:** ", walks, "  ",
        "**Hits:** ", hits, "  ",
        "**HBP:** ", hbp, "  \n\n",
        paste(pitch_type_lines, collapse = "\n"), "\n\n"
      )
      
      # INNING PERFORMANCE ----------------------------------------------------------
      sub <- sub %>%
        mutate(
          inning_num = as.numeric(gsub("\\..*", "", inning)),
          outs_in_state = as.numeric(gsub(".*\\.", "", inning))
        )
      
      innings <- sort(unique(sub$inning_num))
      lead_off_outs <- c()
      one_two_three <- c()
      
      for (inn in innings) {
        
        inning_data <- sub[sub$inning_num == inn, ]
        first_batter <- min(inning_data$batterNum)
        first_batter_data <- inning_data[inning_data$batterNum == first_batter, ]
        
        lead_off_out <- any(first_batter_data$isOut)
        lead_off_outs <- c(lead_off_outs, ifelse(lead_off_out, "Y","N"))
        
        outs_recorded <- sum(inning_data$isOut)
        hits_i <- sum(inning_data$isHit)
        hbps_i <- sum(inning_data$isHBP)
        errors_i <- sum(inning_data$isError)
        walks_i <- sum(inning_data$pitchCount %in% c("3-0","3-1","3-2") &
                         !inning_data$isStrike & !inning_data$isHBP)
        
        no_baserunners <- (hits_i + walks_i + hbps_i + errors_i) == 0
        
        one_two_three_result <- (outs_recorded == 3 && no_baserunners)
        one_two_three <- c(one_two_three, ifelse(one_two_three_result,"Y","N"))
      }
      
      inning_table <- paste0(
        "### Inning Performance\n",
        "| Inning | ", paste(innings, collapse=" | "), " | Total |\n",
        "|--------|", paste(rep("---", length(innings)+1), collapse="|"), "|\n",
        "| **Lead-off Out** | ",
        paste(lead_off_outs, collapse=" | "), " | ", sum(lead_off_outs=="Y"), " |\n",
        "| **1-2-3 Inning** | ",
        paste(one_two_three, collapse=" | "), " | ", sum(one_two_three=="Y"), " |\n\n"
      )
      
      section <- paste0(
        "## Pitching Report for ", p, "\n",
        "**Date:** ", date, "  **Opponent:** ", opponent, "\n\n",
        game_mgmt,
        pitcher_count_section,
        inning_table,
        "\n---\n\n"
      )
      
      report_sections <- c(report_sections, section)
    }
    
    full_report <- paste(report_sections, collapse="\n")
    report_text(full_report)
    output$report_output <- renderText(full_report)
  })
  
  # PDF DOWNLOAD ---------------------------------------------------------------
  output$download_pdf <- downloadHandler(
    filename = function() {
      paste0("pitch_report_", Sys.Date(), ".pdf")
    },
    content = function(file) {
      
      temp_rmd <- tempfile(fileext = ".Rmd")
      
      writeLines(c(
        "---",
        "title: \"Pitching Report\"",
        "output: pdf_document",
        "params:",
        "  report: \"\"",
        "---",
        "",
        "```{r, echo=FALSE}",
        "cat(params$report)",
        "```"
      ), temp_rmd)
      
      rmarkdown::render(
        temp_rmd,
        output_file = file,
        params = list(report = report_text()),
        envir = new.env(parent = globalenv())
      )
    }
  )
}

shinyApp(ui, server)

