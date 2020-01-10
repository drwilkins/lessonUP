### From https://gist.github.com/JosiahParry/1f76cb7f2aab934b96359110a687d334
# authenticate yourself
#drive_auth()

publish <- function(drive_id, verbose = TRUE, overwrite = FALSE) {
  
  # get the doc
  doc <- drive_get(as_id(drive_id))
  
  # specify tempdir location for writing 
  fp <- paste0(getwd(),"/temp/")
  dir.create(fp)
  fn<-doc$name
  out=paste0(fp,fn)
  out.rmd=paste0(out,".Rmd")
  # download to tempdir
  drive_download(doc, paste0(out,".docx"), overwrite = overwrite)
  
  # convert to markdown
    pandoc_convert(
    paste0(out,".docx"),
    "markdown+smart", 
    output = out.rmd,
    options=c("--extract-media=.","--dpi=10","--wrap=preserve"),
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
fulltext <- c(header, readLines(out.rmd))
writeLines(fulltext, paste0(out,".Rmd"))
  
  
    render(input=out.rmd,c("html_document","pdf_document"),params=c("--css= pandoc.css","--pdf-engine=xelatex"))
  browseURL(paste0(out,".html"))
}



drive_id <- "1FT9MeizUKBdeV0bl1-xJ-tE-XGHQuZciqe30jdEq_j4"



#(overviewDocs<-drive_find(type="document",pattern="[Oo]verview$",order_by="modifiedByMeTime desc") )

#(drivefile<-drive_find(type="document", q="name contains 'Human' and name contains '[Oo]_Overview'"))

