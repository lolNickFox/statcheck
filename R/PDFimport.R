# Inner function to read pdf:
getPDF <- function(x)
{
  txtfiles <- character(length(x))
  for (i in 1:length(x))
  {
    system(paste('pdftotext -q -enc "ASCII7" "',x[i],'"',sep=""))
    
    # make sure that files saved as "myfile.pdf.pdf" or "myfile.html.pdf" are still converted from pdf to text
    if (file.exists(gsub("\\.pdf(?!(\\.pdf|\\.html?|//.txt))","\\.txt",x[i],perl=TRUE))){
      fileName <- gsub("\\.pdf(?!(\\.pdf|\\.html?|\\.txt))","\\.txt",x[i],perl=TRUE)
    txtfiles[i] <- readChar(fileName, file.info(fileName)$size)
    } else{
      warning(paste("Failure in file",x[i]))
      txtfiles[i] <- ""
    }
  }
  return(txtfiles)
}

## Function to check directory of PDFs:
checkPDFdir <- structure(function(# Extract statistics and recompute p values from a directory with pdf files.
  ### Extracts statistical references from a directory with PDF files. The "pdftotext" program (http://www.foolabs.com/xpdf/download.html) is used to convert PDF files to plain text files. This must be installed and PATH variables must be properly set so that this program can be used from command line.
  ### By default a GUI window is opened that allows you to choose the directory (using tcltk).
  dir,
  ### String indicating the directory to be used.
  subdir = TRUE,
  ### Logical indicating whether you also want to check subfolders. Defaults to TRUE
  ...
  ### Arguments sent to  \code{\link{statcheck}}.
  )
{
  ##details<<
  ## See \code{\link{statcheck}} for more details. Use \code{\link{checkPDF}} to import individual PDF files. Currently only statistics in the form "stat (df1, df2) = value, p = value" are extracted. Because the Chi-square symbol can not be repressented in plain text it is often lost in the conversion. Because of this Chi-square values are extracted by finding all statistical references with one degree of freedom that do not follow the symbol "t" or "r". While this does extract most Chi-square values it is possible that other statistics, possibly due to unconventional notation, are also extracted and reported as chi-square values.
  ## Depending on the PDF file the comparison operators can sometimes not be converted correctly, causing these to not be reported in the output. Using html versions of articles and the similar function \code{\link{checkHTMLdir}} is recommended for more stable results.
  ## Note that the conversion to plain text and extraction of statistics can result in errors. Some statistical values can be missed, especially if the notation is unconventional. It is recommended to manually check some of the results.
  ##seealso<<
  ## \code{\link{statcheck}}, \code{\link{checkPDF}}, \code{\link{checkHTMLdir}}, \code{\link{checkHTML}}, \code{\link{checkdir}}
  if (missing(dir)) dir <- tk_choose.dir()
    
  all.files <- list.files(dir,pattern="\\.pdf",full.names=TRUE,recursive=subdir)
  files <- all.files[grepl("\\.pdf(?!(\\.pdf|\\.html?|\\.txt))",all.files,perl=TRUE)]
  
  if(length(files)==0) stop("No PDF found")
  
  txts <- character(length(files))
  message("Importing PDF files...")
  pb <- txtProgressBar(max=length(files),style=3)
  for (i in 1:length(files))
  {
    txts[i] <-  getPDF(files[i])    
    setTxtProgressBar(pb, i)
  }
  close(pb)
  names(txts) <- gsub("\\.pdf(?!(\\.pdf|\\.html?|\\.txt))","",basename(files),perl=TRUE)
  return(statcheck(txts,...))
  ##value<<
  ## A data frame containing for each extracted statistic:
  ## \item{Source}{Name of the file of which the statistic is extracted}
  ## \item{Statistic}{Character indicating the statistic that is extracted}
  ## \item{df1}{First degree of freedom}
  ## \item{df2}{Second degree of freedom (if applicable)}
  ## \item{Test.Comparison}{Reported comparison of the test statistic, when importing from pdf this will often not be converted properly}
  ## \item{Value}{Reported value of the statistic}
  ## \item{Reported.Comparison}{Reported comparison, when importing from pdf this might not be converted properly}
  ## \item{Reported.P.Value}{The reported p-value, or NA if the reported value was NS}
  ## \item{Computed}{The recomputed p-value}
  ## \item{Raw}{Raw string of the statistical reference that is extracted}
  ## \item{Error}{The computed p value is not congruent with the reported p value}
  ## \item{DecisionError}{The reported result is significant whereas the recomputed result is not, or vice versa.}
  ## \item{OneTail}{Logical. Is it likely that the reported p value resulted from a correction for one-sided testing?}
  ## \item{OneTailedInTxt}{Logical. Does the text contain the string "sided", "tailed", and/or "directional"?}
  ## \item{CopyPaste}{Logical. Does the exact string of the extracted raw results occur anywhere else in the article?}
  
},ex=function(){
  # with this command a menu will pop up from which you can select the directory with PDF articles
# checkPDFdir()

# you could also specify the directory beforehand
# for instance:
# DIR <- "C:/mydocuments/articles"
# checkPDFdir(DIR)
  })

## Function to given PDFs:
checkPDF <- structure(function(# Extract statistics and recompute p-values from pdf files.
  ### Extracts statistical values (currently only t and F statistics) from PDF files. To this end the "pdftotext" program is used to convert PDF files to plain text files. This must be installed and PATH variables must be properly set so that this program can be used from command line.
  files,
  ### Vector with paths to the PDF files.
  ...
  ### Arguments sent to  \code{\link{statcheck}}
  )
{
  ##details<<
  ## See \code{\link{statcheck}} for more details. Use \code{\link{checkPDFdir}} to import every PDF file in a given directory. Currently only statistics in the form "(stat (df1, df2) = value, p = value)" are extracted.
  ## Note that this function is still in devellopment. Some statistical values can be missed, especially if the notation is unconvetional. It is recommended to manually check some of the results.
  ##seealso<<
  ## \code{\link{statcheck}}, \code{\link{checkPDFdir}}
  if (missing(files)) files <- tk_choose.files()
  
  txts <-  sapply(files,getPDF)
  names(txts) <- gsub("\\.pdf(?!(\\.pdf|\\.html?))","",basename(files),perl=TRUE)
  return(statcheck(txts,...))
  ##value<<
  ## A data frame containing for each extracted statistic:
  ## \item{Source}{Name of the file of which the statistic is extracted}
  ## \item{Statistic}{Character indicating the statistic that is extracted}
  ## \item{df1}{First degree of freedom}
  ## \item{df2}{Second degree of freedom (if applicable)}
  ## \item{Value}{Reported value of the statistic}
  ## \item{Reported.Comparison}{Reported comparison, when importing from pdf this will often not be converted properly}
  ## \item{Reported.P.Value}{The reported p-value, or NA if the reported value was NS}
  ## \item{Computed}{The recomputed p-value}
  ## \item{Raw}{Raw string of the statistical reference that is extracted}
  ## \item{InExactError}{Error in inexactly reported p values as compared to the recalculated p values}
  ## \item{ExactError}{Error in exactly reported p values as compared to the recalculated p values}
  ## \item{DecisionError}{The reported result is significant whereas the recomputed result is not, or vice versa.}
},ex=function(){
# given that my PDF file is called "article.pdf"
# and I saved it in "C:/mydocuments/articles"

 # checkPDF("C:/mydocuments/articles/article.pdf")
  })
