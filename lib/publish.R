### From https://gist.github.com/JosiahParry/1f76cb7f2aab934b96359110a687d334
# authenticate yourself
#drive_auth()

addLinksToPhotos<-function(mdfile){
  #d<-readLines(mdfile)
  s<-sapply(mdfile,function(x) {
    replacementPattern="[\\1(\\2)](\\2)\\3"
    gsub('.*?(?<firstpart>!\\[[^\\]]*?\\])\\((?<filename>.*)\\)(?<potentialHTML>\\{.*?\\})?.*?',x=x,replacement=replacementPattern,perl=T)
  },USE.NAMES = F)
  s
    }


publish <- function(drive_id, verbose = TRUE, overwrite = TRUE) {
  
  # get the doc
  doc <- drive_get(as_id(drive_id))
  
  # specify tempdir location for writing 
  fp <- paste0(getwd(),"/temp/")
  dir.create(fp)
  fn<-doc$name
  #change [ <>()|\\:&;#?*'] to '-' in line w/ render()
  fn<-gsub(pattern=rmarkdown:::.shell_chars_regex,replacement="-", x=fn, fixed=F)
  out=paste0(fp,fn)
  out.rmd=paste0(out,".Rmd")
  # download to tempdir
  drive_download(doc, paste0(out,".docx"), overwrite = overwrite)
  
  # convert to markdown
    pandoc_convert(
    paste0(out,".docx"),
    "markdown+smart", 
    output = out.rmd,
    options=c("--extract-media=.","--dpi=300","--wrap=preserve"),
    verbose=T
    )

  #Add missing YAML header to markdown
  header <- paste0('---
title: "',fn,'"
output:
     html_document:
      toc: true
      toc_depth: 2
      toc_float: true
      number_sections: false
     pdf_document:
      toc: true
      toc_depth: 2
      number_sections: false
---')
fulltext <- c(header, addLinksToPhotos(readLines(out.rmd)))

writeLines(fulltext, paste0(out,".Rmd"))
  
    #knitr::pandoc(input=out.rmd,c("html_document","pdf_document"))
   # render_params="+RTS -K512m -RTS --to latex --from markdown+autolink_bare_uris+tex_math_single_backslash --output /Users/mattwilkins/GDrive/R/Shiny/lessonUP/White-Shark-NIT-overview.tex --self-contained --table-of-contents --toc-depth 2 --highlight-style tango --pdf-engine pdflatex --variable graphics --lua-filter /Library/Frameworks/R.framework/Versions/3.6/Resources/library/rmarkdown/rmd/lua/pagebreak.lua --lua-filter /Library/Frameworks/R.framework/Versions/3.6/Resources/library/rmarkdown/rmd/lua/latex-div.lua --variable 'geometry:margin=1in'"
    #system(paste(pandoc_exec(),out.rmd,"-f markdown -t html"))
    render(input=out.rmd,c("html_document","pdf_document"),output_dir=getwd(),params="ask")#"--css= 'lib/GitHub.css'","--pdf-engine xelatex","--o lib/template.docx"),clean=T)
    return(paste0(getwd(),"/",fn,".html"))#output preview file name/location
}



#drive_id <- "1FT9MeizUKBdeV0bl1-xJ-tE-XGHQuZciqe30jdEq_j4"



#(overviewDocs<-drive_find(type="document",pattern="[Oo]verview$",order_by="modifiedByMeTime desc") )

#(drivefile<-drive_find(type="document", q="name contains 'Human' and name contains '[Oo]_Overview'"))

