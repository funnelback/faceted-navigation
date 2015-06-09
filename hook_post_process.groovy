//**** Code for sorting of faceted navigation and renaming of faceted navigation categories****
// Checks collection.cfg for faceted_navigation.<FACET NAME>.sort_mode and  faceted_navigation.<FACET NAME>.rename.<CATEGORY LABEL>
// Default sort is by count, otherwise available options are sort alphabetically (label), reverse alphabetically (dlabel) or ascending count (acount)

if ( transaction.response != null && transaction.response.facets != null
        && transaction.response.facets.size() > 0 ) {
  transaction.response.facets.each() {

    def facetname=it.name;
    if(transaction.question.collection.configuration.value("faceted_navigation."+it.name+".sort_mode") != null) {
        if(transaction.question.collection.configuration.value("faceted_navigation."+it.name+".sort_mode") == "label") {
	    //Rename then sort alphabetically
            it.categories.each() { 
		renameCategory(it,facetname);
	        sortCategoryAlpha(it,facetname);
	    }
        }
        else if (transaction.question.collection.configuration.value("faceted_navigation."+it.name+".sort_mode") == "dlabel") {
            //Rename then sort reverse alphabetically
	    it.categories.each() { 
		renameCategory(it,facetname);
		sortCategoryDalpha(it,facetname);
	    }
        }
        else if (transaction.question.collection.configuration.value("faceted_navigation."+it.name+".sort_mode") == "acount") {
            //Rename then sort reverse by count
            it.categories.each() { 
		renameCategory(it,facetname);
		sortCategoryAcount(it,facetname);
	    }
        }		
        else {
        // Rename then sort by reverse count (default)
	    it.categories.each() {
		renameCategory(it,facetname);
	    }
        }
    }
     else {
        // Rename then sort by reverse count (default)
        it.categories.each() {
            renameCategory(it,facetname);
        }

    }
  }
}

// Recursively sort categories listing by alphabetical order
def sortCategoryAlpha(category,facetname) {
    category.values.sort {a, b -> a.label.toLowerCase().compareTo(b.label.toLowerCase())}
    category.categories.each() { 
	renameCategory(it,facetname);
        sortCategoryAlpha(it,facetname);
    }
}

// Recursively sort categories listing by reverse alphabetical order
def sortCategoryDalpha(category,facetname) {
    category.values.sort {a, b -> b.label.toLowerCase().compareTo(a.label.toLowerCase())}
    category.categories.each() { 
	renameCategory(it,facetname);
        sortCategoryDalpha(it,facetname) 
    }
}

// Recursively sort categories listing by count
def sortCategoryAcount(category,facetname) {
    category.values.sort {a, b -> a.count.compareTo(b.count)}
    category.categories.each() { 
        renameCategory(it,facetname);
        sortCategoryAcount(it,facetname);
    }
}

// Perform category rename if configured
def renameCategory(category,facetname) {
    category.values.each() {
        if (transaction.question.collection.configuration.value("faceted_navigation."+facetname+".rename."+it.label) != null) {
            it.label = transaction.question.collection.configuration.value("faceted_navigation."+facetname+".rename."+it.label);
        }
    }
}
