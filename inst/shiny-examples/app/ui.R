# Use packman package to check whether required packages are installed.
# Install missing packages, and load all packages afterwards

if(!require(pacman)) install.packages("pacman")
devtools::install_github('charlie86/spotifyr')

pacman::p_load(
  spotifyr,
  shiny,
  inzightta,
  rlang,
  gutenbergr,
  pdftools,
  stringr,
  stringi,
  dplyr,
  tidytext,
  tidyr,
  genius,
  tidyRSS,
  rtweet,
  shinyjs,
  shinybusy,
  shinyWidgets,
  GuardianR,
  quanteda,
  jsonlite,
  ggplot2,
  data.table,
  DT,
  textclean,
  googleVis,
  shinyBS,
  purrr,
  ggstance,
  ggthemes,
  forcats,
  rvest,
  dplyr,
  httr,
  lubridate,
  readr,
  tibble)


text_sources = c("Upload .txt, .csv, .xlsx, or .xls file", "Project Gutenberg", "Twitter",
                 "Spotify/Genius", "The Guardian Articles", "stuff.co.nz Comments", "Reddit")


ui <- navbarPage("iNZight Text Analytics",
                 tabPanel("Processing",
                          sidebarLayout(
                            sidebarPanel(
                              useShinyjs(),
                              selectizeInput("import_from", "Retrieve text from", choices = text_sources),
                              
                              conditionalPanel(
                                condition = "input.import_from == 'Project Gutenberg'",
                                selectInput("gutenberg_work", "Select work(s)", multiple = TRUE, choices = character(0))
                              ),
                              uiOutput("side"),
                               
                              
                              tags$h4("Process"),
                              checkboxInput("lemmatise", "Lemmatise"),
                              uiOutput("sw_lexicon"),
                              checkboxInput("stopwords", "Stopwords"),
                              
                              textInput("addl_stopwords", "Additional stopwords",
                                        placeholder = "separate,the,words,with,commas"),
                              
                              a(id = "toggleAdvanced4", "Or upload stopword file(s)"), #, href = "#"),
                              shinyjs::hidden(
                                div(id = "advanced4",
                                    
                                    fileInput(inputId = "sw_file", label = ".txt files with one stopword per line", multiple = TRUE,
                                              accept = c("text/comma-separated-values,text/plain")),
                                    
                                )
                              ),
                              
                              actionButton("prep_button", "Prepare Text"),
                              tags$hr(),
                              
                              selectInput("section_by", "Section By",
                                          list("", "chapter", "part", "section", "canto", "book")),
                              
                              uiOutput("vars_to_filter"),
                              textInput("filter_pred", "value to match", "")
                              
                            ),
                            mainPanel(
                              tabsetPanel(
                                
                                tabPanel("Imported",
                                         
                                         fluidRow(
                                           downloadButton("downloadData_imported", "Download as csv"),
                                           
                                           column(width = 12,
                                                  ###################
                                                  textOutput("text"), 
                                                  ###################
                                                  
                                                  DT::dataTableOutput("imported_show")
                                                  #tableOutput("not_coll")
                                                  
                                           )
                                         )
                                ),
                                tabPanel("Pre-processed",
                                         fluidRow(
                                           downloadButton("downloadData_pre_processed", "Download as csv"),
                                           column(width = 12,
                                                  DT::dataTableOutput("pre_processed_show")
                                           )
                                         )
                                ),
                                tabPanel("Processed",
                                         downloadButton('downloadprocessed', 'Download'),
                                         
                                         tableOutput("table")
                                         
                                )
                                
                              )
                            ))),
                 
                 tabPanel("Visualisation",
                          sidebarLayout(
                            sidebarPanel(selectInput("what_vis",
                                                     "Select what you want to Visualise",
                                                     c("Term Frequency",
                                                       "Term Frequency-Inverse Document Frequency", 
                                                       "n-gram Frequency",
                                                       "Key Words",
                                                       ###########
                                                       "Readability",
                                                       "Word Tree",
                                                       ###########
                                                       "Term Sentiment",
                                                       "Moving Average Term Sentiment",
                                                       "Aggregated Term Count",
                                                       "Key Sections",
                                                       "Aggregated Sentiment")),
                                         
                                         #####
                                         conditionalPanel(
                                           condition = "!(input.what_vis == 'Word Tree'||input.what_vis == 'Readability')",
                                           uiOutput("group_by")
                                         ),
                                         
                                         conditionalPanel(
                                           condition = "!(input.what_vis == 'Readability')",
                                           uiOutput("insight_options")
                                         ),
                                         
                                          
                                         conditionalPanel(
                                           condition = "input.what_vis == 'Aggregated Sentiment'", 
                                           checkboxInput("scale_senti", "Scale Aggregated Sentiment Scores")
                                         ),
                                         
                                         conditionalPanel(
                                           condition = "!(input.what_vis == 'Word Tree'||input.what_vis == 'Readability')",
                                           uiOutput("vis_options"),
                                           uiOutput("vis_facet_by"),
                                           a(id = "toggle_vis", "Additional visualization options", href = "#"),
                                           
                                           uiOutput("add_vis_options"), 
                  
                                           downloadButton("downloadData", "Download data used in visualization")
                                         )
                            ),
                            
                            mainPanel(
                              conditionalPanel(
                                condition = "input.what_vis == 'Word Tree'",
                                addSpinner(htmlOutput("shinytest"), spin = "fading-circle", color = "#000000")
                              ),
                              conditionalPanel(
                                condition =  "input.what_vis == 'Readability'",
                                plotOutput("flesch_plot",
                                           dblclick = dblclickOpts(
                                             id = "plot1_click"), height = "1000px"
                                ),
                                
                                verbatimTextOutput("ex")
                              ),
                              conditionalPanel(
                                condition =  "!(input.what_vis == 'Word Tree'||input.what_vis == 'Readability')",
                                #plotOutput("plot", height = "1000px"),
                                uiOutput("plot.ui"), 
                                DTOutput("insighted_table")
                                ,
                                actionButton("subset_data", "Subset Data"),
                                actionButton("restore_data", "Restore Data"),
                                 verbatimTextOutput("num_subset"),
                                 verbatimTextOutput("num_restore"), 
                                tableOutput("lookie")
                              )
                              
                            ))),
                 #################
                 tabPanel("Keywords in Context",
                          
                          sidebarLayout(sidebarPanel(textInput("disp_words", "Keyword(s) or Key Phrase(s)", 
                                                               value = "love,thousand pounds"),
                                                     
                                                     selectInput("disp_valuetype",
                                                                 "Type of Pattern Matching",
                                                                 list("glob", "regex",
                                                                      "fixed")),
                                                     uiOutput("quant"), 
                                                    
                                                     selectInput("scale",
                                                                 "Scale",
                                                                 list("absolute",
                                                                      "relative")),
                                                     
                                                     numericInput("window", "Window", value = 5, min = 1, max = 10),
                                                     
                                                     checkboxInput("disp_case_insensitive", "Case Insensitive",
                                                                   value = TRUE, width = NULL),
                                                     sliderInput("plot_height2", "Plot height",
                                                                 min = 400, max = 2000,
                                                                 value = 1000),
                                                     ###################
                                                     selectInput("merge_id_grps", "Group text by", 
                                                                 choices = NULL, selected = "id"), 
                                                     ###################
                                                     actionButton("create_kwic", "Create lexical dispersion plot"),
                                                     tags$hr(),
                                                     
                                                     ##### For keywords in context
                                                     
                                                     actionButton("add", "Add Points"),
                                                     actionButton("delete", "Delete Points"),
                                            
                                                     checkboxInput('line_num', 'See doc name', value = FALSE, width = NULL)
                                                     
                          ),
                          mainPanel(
                            # plotOutput("plot2",
                            #            dblclick = "plot_dblclick",
                            #            brush = brushOpts(
                            #              id = "plot_brush",
                            #              resetOnNew = TRUE
                            #            ),
                            #            height = "800px"
                            # ),
                            uiOutput("plot2.ui"),
                            DT::dataTableOutput("keyword_table")
                          ))
                 ),
                 tabPanel("Getting keys and tokens", 
                          fluidPage(
                            navlistPanel(
                              #"Getting keys and tokens",
                              tabPanel("Twitter",
                                       includeMarkdown("R\\help_files\\twitter_token.rmd")
                              ),
                              tabPanel("Spotify/Genius",
                                       includeMarkdown("R\\help_files\\spot.Rmd")
                              ),
                              tabPanel("The Guardian Articles",
                                       includeMarkdown("R\\help_files\\guardian.rmd")
                              ), 
                              tabPanel("stuff.co.nz comments",
                                       includeMarkdown("R\\help_files\\stuff.Rmd")
                              )
                            )
                          )
                          ), 
                 
                 add_busy_spinner(spin = "fading-circle")
)
