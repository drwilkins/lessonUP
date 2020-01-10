require(googledrive);require(rmarkdown);require(shiny)
### From https://gist.github.com/JosiahParry/1f76cb7f2aab934b96359110a687d334
# authenticate yourself

source("publish.R")


#(overviewDocs<-drive_find(type="document",pattern="[Oo]verview$",order_by="modifiedByMeTime desc") )

(drivefile<-drive_find(type="document", q="name contains '[Oo]_Overview'"))

publish("1NWZU9sR-Xgnabcewpx_5BxAPsLBuAgG3nDv8JXJwDYc",overwrite=T)


# User Interface ----------------------------------------------------------
# Define UI for application that draws a histogram
ui <- fluidPage(
    #Sign in code from https://stackoverflow.com/questions/50342061/how-do-you-implement-google-authentication-in-a-shiny-r-app
    tagList(
  tags$head(
    tags$meta(name="google-signin-scope",content="profile email"),
    tags$meta(name="google-signin-client_id", content="YOURCLIENTID.apps.googleusercontent.com"),
    HTML('<script src="https://apis.google.com/js/platform.js?onload=init"></script>'),
    includeScript("signin.js"),
  )),

    # Application title
    titlePanel(h1("Lessonify:",style="font-family: 'Courier New';color: #444444;"),windowTitle="Lessonify"),
  p("Transform Gdoc lessons with custom styling into HTML+PDF",style="font-family: 'Courier New';color: #444444;"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        sidebarPanel(
            div(id="signin", class="g-signin2", "data-onsuccess"="onSignIn"),
        actionButton("signout", "Sign Out", onclick="signOut();", class="btn-danger"),
            sliderInput("bins",
                        "Number of bins:",
                        min = 1,
                        max = 50,
                        value = 30)
        ),

        # Show a plot of the generated distribution
        mainPanel(
           with(tags, dl(dt("Name"), dd(textOutput("g.name")),
                      dt("Email"), dd(textOutput("g.email")),
                      dt("Image"), dd(uiOutput("g.image")) ))
        )
    )
)


# SERVER SIDE -------------------------------------------------------------
# Define server logic required to draw a histogram
server <- function(input, output) {

  #Pass Google login info to UI
  output$g.name = renderText({ input$g.name })
  output$g.email = renderText({ input$g.email })
  output$g.image = renderUI({ img(src=input$g.image) })
  
    output$distPlot <- renderPlot({
        # generate bins based on input$bins from ui.R
        x    <- faithful[, 2]
        bins <- seq(min(x), max(x), length.out = input$bins + 1)

        # draw the histogram with the specified number of bins
        hist(x, breaks = bins, col = 'darkgray', border = 'white')
    })
}

# Run the application 
shinyApp(ui = ui, server = server)
