library(shiny)
library(DT)
library(stringr)
library(dplyr)

# this function validates that CSV is in the format specified by the iPad app
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
    df[[col]] <- as.integer(tolower(df[[col]]) %in% c("true","1"))
  }
  
  return(df)
}

# this function, as the name suggests, is just taking the necessary info from the actual CSV file name
# specifically the date and opponent
extract_metadata <- function(filename) {
  fname <- basename(filename)
  fname <- str_remove(fname, "\\.csv$")
  
  pattern_vs <- "pitch_data_vs_(.*)_([0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2})"
  pattern_practice <- "pitch_data_practice_([0-9]{4}-[0-9]{2}-[0-9]{2}_[0-9]{2}-[0-9]{2})"
  
  if (str_detect(fname, pattern_vs)) {
    matches <- str_match(fname, pattern_vs)
    opponent <- str_to_title(matches[2])
    date_raw <- matches[3]
  } else if (str_detect(fname, pattern_practice)) {
    matches <- str_match(fname, pattern_practice)
    opponent <- "Practice"
    date_raw <- matches[2]
  } else {
    return(list(opponent = NA, date = NA))
  }
  
  date_clean <- str_sub(date_raw, 1, 10)
  date_parsed <- as.Date(date_clean, format = "%Y-%m-%d")
  date_formatted <- format(date_parsed, "%B %d, %Y")
  
  return(list(opponent = opponent, date = date_formatted))
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
  
  observeEvent(input$generate_report, {
    req(data())
    df <- data()
    
    meta <- extract_metadata(input$file$name)
    opponent <- ifelse(is.na(meta$opponent), "UNKNOWN", meta$opponent)
    date <- ifelse(is.na(meta$date), Sys.Date(), meta$date)
    
    report_sections <- c()
    
    pitchers <- unique(df$pitcher)
    
    for (p in pitchers) {
      
      # named sub for subset, in case this ever gets read
      sub <- df[df$pitcher == p, ]
      
      # ---------------------------------------------------------
      # GAME MANAGEMENT SECTION
      # ---------------------------------------------------------
      sub$pitchCount <- as.character(sub$pitchCount)
      
      # Batters Faced
      batters_faced <- length(unique(sub$batterNum))
      
      # At-Bats
      at_bats <- sum(sub$isOut) + sum(sub$isHit)
      
      # Total Pitches
      total_pitches <- nrow(sub)
      
      # Strikes / Balls
      strikes <- sum(sub$isStrike)
      balls <- sum(!sub$isStrike & !sub$isHBP)
      
      # First pitch strikes / balls
      first_pitches <- sub %>%
        group_by(batterNum) %>%
        slice(1) %>%
        ungroup()
      
      first_pitch_strikes <- sum(first_pitches$isStrike)
      first_pitch_balls <- sum(!first_pitches$isStrike & !first_pitches$isHBP)
      
      # Walks / Strikeouts + other easier stats to find
      walks <- sum(startsWith(sub$pitchCount, "3") & (!sub$isStrike & !sub$isHBP))
      strikeouts <- sum(
        endsWith(sub$pitchCount, "2") & sub$isStrike & !sub$madeContact
      )
      hits <- sum(sub$isHit)
      hbp <- sum(sub$isHBP)
      
      # Calculating Innings Pitched
      total_outs <- sum(sub$isOut)
      full_innings <- floor(total_outs / 3)
      remaining_outs <- total_outs %% 3
      innings_pitched <- paste0(full_innings, ".", remaining_outs)  # 2.2 for 2 innings + 2 outs, traditional notation
      whip <- (walks + hits) / (total_outs / 3)
      
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
        "Innings Pitched: ", innings_pitched, "\n",
        "WHIP: ", round(whip, 3), "\n\n"
      )
      
      # ---------------------------------------------------------
      # PITCHER'S COUNT SECTION
      # ---------------------------------------------------------
      
      # here are all the pitch count related stats
      count_0_1 <- sum(sub$pitchCount == "0-1")
      count_0_2 <- sum(sub$pitchCount == "0-2")
      count_1_1 <- sum(sub$pitchCount == "1-1")
      count_1_2 <- sum(sub$pitchCount == "1-2")
      
      hits_0_2 <- sum(sub$isHit & sub$pitchCount == "0-2")
      hits_1_2 <- sum(sub$isHit & sub$pitchCount == "1-2")
      
      # ---------------------------------------------------------
      # PITCH TYPE BREAKDOWN
      # ---------------------------------------------------------
      
      # this is taking the stats for each particular pitch type the pitcher threw in the game
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
        "Pitcher's Count:\n",
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
      # INNING PERFORMANCE TABLE
      # ---------------------------------------------------------
      
      # this is to create that inning table on the "Gameday Pitching Summary" Document
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
        
        # Lead-off Out
        first_batter <- min(inning_data$batterNum)
        first_batter_data <- inning_data[inning_data$batterNum == first_batter, ]
        
        lead_off_out <- any(first_batter_data$isOut)
        lead_off_outs <- c(lead_off_outs, ifelse(lead_off_out, "Y", "N"))
        
        # 1-2-3 Inning
        outs_recorded <- sum(inning_data$isOut)
        
        hits <- sum(inning_data$isHit)
        hbps <- sum(inning_data$isHBP)
        errors <- sum(inning_data$isError)
        walks <- sum(startsWith(inning_data$pitchCount, "3") & inning_data$isStrike & !inning_data$madeContact)
        
        no_baserunners <- (hits + walks + hbps + errors) == 0
        
        one_two_three_result <- (outs_recorded == 3 && no_baserunners)
        one_two_three <- c(one_two_three, ifelse(one_two_three_result, "Y", "N"))
      }
      
      lead_off_total <- sum(lead_off_outs == "Y")
      one_two_three_total <- sum(one_two_three == "Y")
      
      inning_headers <- c(paste0("Inning ", innings), "Total")
      
      lead_off_row <- c(lead_off_outs, lead_off_total)
      one_two_three_row <- c(one_two_three, one_two_three_total)
      
      inning_table <- paste(
        "Inning Performance:\n",
        paste(c("", inning_headers), collapse = "\t"),
        "\n",
        paste(c("Lead-off Out", lead_off_row), collapse = "\t"),
        "\n",
        paste(c("1-2-3 Inning", one_two_three_row), collapse = "\t"),
        "\n\n",
        sep = ""
      )
      
      # ---------------------------------------------------------
      # MENTAL TOUGHNESS SECTION
      # ---------------------------------------------------------
      
      batters <- sub %>%
        group_by(batterNum) %>%
        summarize(
          hit = any(isHit == 1),
          walk = any(startsWith(pitchCount, "3") & (!isStrike & !isHBP)),
          error = any(isError == 1),
          out = any(isOut == 1),
          .groups = "drop"
        ) %>%
        arrange(batterNum)
      
      batters$next_out <- dplyr::lead(batters$out)
      
      after_hit_total <- sum(batters$hit)
      after_hit_success <- sum(batters$hit & batters$next_out, na.rm = TRUE)
      
      after_walk_total <- sum(batters$walk)
      after_walk_success <- sum(batters$walk & batters$next_out, na.rm = TRUE)
      
      after_error_total <- sum(batters$error)
      after_error_success <- sum(batters$error & batters$next_out, na.rm = TRUE)
      
      four_pitch_walks <- sum(
        sub$pitchCount == "3-0" & (!sub$isStrike & !sub$isHBP)
      )
      
      mental_toughness <- paste0(
        "Mental Toughness:\n",
        "Retire Next Batter After Hit: ", after_hit_success, " / ", after_hit_total, "\n",
        "Retire Next Batter After BB: ", after_walk_success, " / ", after_walk_total, "\n",
        "Retire Next Batter After Error: ", after_error_success, " / ", after_error_total, "\n",
        "4-Pitch Walks: ", four_pitch_walks, "\n\n"
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
        pitcher_count_section,
        inning_table,
        mental_toughness
      )
      
      report_sections <- c(report_sections, section)
    }
    
    output$report_output <- renderText(paste(report_sections, collapse = "\n"))
  })
}

shinyApp(ui, server)
