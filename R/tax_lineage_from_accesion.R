#' Get full taxonomic lineage from accession nucleotide ID
#'
#' @param accession Accesion ID for the nucleotide database
#'
#' @return Dataframe with taxonomic info for each accession
#' @export
#' @import rentrez
#' @import XML
#' @import stringr
#' @import tidyr
#'
#' @examples
#' tax_lineage_from_accesion(NZ_CP027599.1")
tax_lineage_from_accesion <- function(accession, custom_taxonomies = NA){
 # Checking inputs
 if (class(accession) != "character"){
         print("Please input the accession as a character/character vector")
 }
 tax_allowed <- c("superkingdom", "kingdom", "phylum", "class", "order", "family", "genus", "species")
 if (is.na(custom_taxonomies)){
         taxonomies <- tax_allowed
 } else if(all(!(custom_taxonomies %in% tax_allowed))){
         print(paste(paste("Only", tax_allowed, "are allowed for 'custom_taxonomies'")))
 } else{
         taxonomies <- custom_taxonomies
 }
 # data processing
 d_all <- data.frame(rank = taxonomies)
 for (acc in accession){
         # look up in the nucleotide database for id
         id_nuc <- entrez_search(db = "nucleotide", acc)
         # look id for the taxonomic database
         id_tax <- entrez_link(dbfrom = "nucleotide", id = id_nuc$ids, db = "taxonomy")
         # get taxonomic info
         tax <- entrez_fetch(db = "taxonomy", id = id_tax$links$nuccore_taxonomy, rettype = "xml", parse = TRUE)
         tax_list <- xmlToList(tax)
         # make data frame with rank and name
         rank <- data.frame(rank = sapply(tax_list$Taxon$LineageEx, function(x) x$Rank))
         name <- data.frame(name = sapply(tax_list$Taxon$LineageEx, function(x) x$ScientificName))
         d <- cbind(rank, name)
         colnames(d) <- c("rank", acc)
         # species isn't always included and is extracted seperately
         species <- str_split(tax_list$Taxon$ScientificName, pattern = " ")[[1]][2]
         if (any(d$rank == "species")){
                 d[,acc][d$rank == "species"] <- species
         } else{
                 d <- rbind(d, c("species", species))
         }
         # only take taxonomiuc info in the specified levels
         d <- as.data.frame(d[d$rank %in% taxonomies,])
         d_all <- merge(d_all, d, by = "rank", all = T,)

 }
 d_all <- d_all[match(taxonomies, d_all$rank),]
 return(d_all)
}
