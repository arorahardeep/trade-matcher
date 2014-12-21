prepare <- function(fileName) {
  fileHandle <- read.csv(fileName)
  fileHandle[,ncol(fileHandle)+1] <- paste(fileHandle$SecurityID, fileHandle$AccountID, sep="")
  colnames(fileHandle)[ncol(fileHandle)] <- c("Key")

  fileHandle[,ncol(fileHandle)+1] <- rownames(fileHandle)
  colnames(fileHandle)[ncol(fileHandle)] <- c("LineNo")
  
  fileHandle
}

applyRules <- function(dataSet) {
  ## Rule 1: direction should be opposite
    directionFlag = dataSet$Direction.x != dataSet$Direction.y
  
  ## Rule 2: weighted price should be within 10% tolerance 
  weighted.price.x <- sum(dataSet$Price.x * dataSet$Quantity.x) / sum(dataSet$Quantity.x)
  weighted.price.y <- sum(dataSet$Price.y * dataSet$Quantity.y) / sum(dataSet$Quantity.y)
  priceFlag = ifelse(((abs(weighted.price.x - weighted.price.y) / weighted.price.x) <= 0.1), TRUE, FALSE)
  
  ## Rule 3: quantity match
  quantityFlag = sum(dataSet$Quantity.x) == sum(dataSet$Quantity.y)

  if (is.null(priceFlag) || is.na(priceFlag)) priceFlag = FALSE
  if (is.null(quantityFlag) || is.na(quantityFlag)) quantityFlag = FALSE
  if (is.null(directionFlag) || is.na(directionFlag)) directionFlag = FALSE
  
  ## message(paste("Key :", dataSet$Key, ", priceFlag =", priceFlag,", "))
  ## Matching Decision based on above rules
  matchingStatus = "UNMATCHED"
  if (directionFlag && priceFlag) {
    if (quantityFlag)
      matchingStatus = "MATCHED"
    else
      matchingStatus = "PARTIAL"
  }
  r <- data.frame(dataSet$Key,dataSet$TradeID.x,dataSet$TradeID.y,matchingStatus)
  colnames(r) <- c("Key","TradeID.x","TradeID.y","MatchStatus")
  return(r)
}

matcher <- function(side1File, side2File) {
  side1 <-  prepare(side1File)
  side2 <-  prepare(side2File)
  matchResult <- merge(side1, side2, by="Key", all=TRUE)
  m <- by(matchResult, matchResult$Key, applyRules)
  m
}
  