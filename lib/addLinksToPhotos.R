addLinksToPhotos<-function(mdfile){
  d<-readLines(mdfile)
  s<-sapply(d,function(x) {
    replacementPattern="[\\1(\\2)](\\2)\\3"
    gsub('.*?(?<firstpart>!\\[[^\\]]*?\\])\\((?<filename>.*)\\)(?<potentialHTML>\\{.*?\\})?.*?',x=x,replacement=replacementPattern,perl=T)
  },USE.NAMES = F)
  writeLines(s,mdfile)
    }

  
  