require(googledrive);require(rmarkdown);require(shiny);require(gargle);require(DT)
### From https://gist.github.com/JosiahParry/1f76cb7f2aab934b96359110a687d334
# authenticate yourself

source("lib/publish.R")

#(overviewDocs<-drive_find(type="document",pattern="[Oo]verview$",order_by="modifiedByMeTime desc") )

#(drivefile<-drive_find(type="document", q="name contains '[Oo]_Overview'"))

#publish("1NWZU9sR-Xgnabcewpx_5BxAPsLBuAgG3nDv8JXJwDYc",overwrite=T)


# User Interface ----------------------------------------------------------
# Define UI for application that draws a histogram
ui <- fluidPage(
    # Application title
    titlePanel(h1("LessonUP:",style="font-family: 'Courier New';color: #444444;"),windowTitle="Lessonify"),
  p("Transform Gdoc lessons with custom styling into HTML+PDF",style="font-family: 'Courier New';color: #444444;"),
  
    sidebarLayout(
        sidebarPanel(tags$head(
    tags$style(HTML("hr {border-top: 1px solid #000000;}"))
  ),
          fluidRow(column(6,
             p(strong("Logged in as: ")),
              textOutput("user") 
            ),
          column(4,
             actionButton("auth","Change Login",icon=icon("google"))
            )),br(),
          fluidRow(
            textInput("q","Drive Query",value="name contains 'overview'"),
            actionButton("search","Submit"),br(),
             DTOutput("out",width="100%"),
            hr(),br(),
            uiOutput("lessonU"),
            conditionalPanel(condition = "typeof input.out_rows_selected  !== 'undefined' && input.out_rows_selected.length > 0",
              span(strong("Selected file: "), htmlOutput("selected"),style="display:inline"),
              br(),
              actionButton("publish","LessonUP",icon("feather-alt"),class="btn btn-success")
            )
          )
        ),

        mainPanel(
         wellPanel(
           h2("Preview"),
          p("saved: ",htmlOutput("path",style="display:inline")),
          hr(),
          ),
         uiOutput("preview")
         )
    )
)


# SERVER SIDE -------------------------------------------------------------
# Define server logic required to draw a histogram
server <- function(input, output) {
  v<-reactiveValues()
  v$userEmail=if(length(drive_user()>0)){drive_user()$emailAddress}else{"Need To Log In"}
  observeEvent(input$auth,{
    drive_auth()
    #token_fetch(scopes = "https://www.googleapis.com/auth/userinfo.email"
    })
  
  output$user<-renderText(v$userEmail)
  
tbl<-eventReactive(input$search,
    {
      if(input$q==""){""}else{
        #qresults=mtcars
        qresults<-drive_find(type="document", q=input$q )
       v$qresults<-qresults[,(1:2)]
        qresults[,"name"]
        }
    })
  
  output$out<-renderDT({
    tbl()
    #data.frame('N'=1:length(qresults$name),Name=qresults$name,rownames = F,selection="single")
        },select="single", options= list(paging=F,
        lengthMenu = list(c(5, 15, -1), c('5', '15', 'All')))
    )
  
  observe(v$clickedIdx<- input$out_cell_clicked$row)
  observe(v$filename<-v$qresults$id[v$clickedIdx])
  
  output$selected<-renderText(v$qresults$name[v$clickedIdx])
  
doIT<-eventReactive(input$publish,
  {
    publish(v$filename)
  }
  
)
  
  output$preview<-renderUI({
    prevHTML<-doIT()
    v$path<-prevHTML
    includeHTML(path=prevHTML)
  })
    
  output$path<-renderText(v$path)
}

# Run the application 
shinyApp(ui = ui, server = server)
