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
        else if ((transaction.question.collection.configuration.value("faceted_navigation."+it.name+".sort_mode") == "custom") || (transaction.question.collection.configuration.value("faceted_navigation."+it.name+".sort_mode") == "dcustom")) {
            // map to hold the custom ordering
            def labelOrderMap = [:]
	    def customMode = transaction.question.collection.configuration.value("faceted_navigation."+it.name+".sort_mode")
 
            if (transaction.question.collection.configuration.value("faceted_navigation."+it.name+".sort_order.first") != null) {
              def first = transaction.question.collection.configuration.value("faceted_navigation."+it.name+".sort_order.first").split('\\|')
	
              for (i=0; i<first.size(); i++) {
		if (customMode == "custom") {
                  labelOrderMap[first[i].toLowerCase()] = '00000' + String.format("%06d",i)
		}
		else if (customMode == "dcustom") {
                  labelOrderMap[first[i].toLowerCase()] = 'zzzzz' + String.format("%06d",first.size()-i)
                }
              }
            }
            
            if (transaction.question.collection.configuration.value("faceted_navigation."+it.name+".sort_order.last") != null) {
              def last = transaction.question.collection.configuration.value("faceted_navigation."+it.name+".sort_order.last").split('\\|')

              for (i=0; i<last.size(); i++) {
		if (customMode == "custom") {
                  labelOrderMap[last[i].toLowerCase()] = 'zzzzz' + String.format("%06d",i)
                }
                else if (customMode == "dcustom") {
                  labelOrderMap[last[i].toLowerCase()] = '00000' + String.format("%06d",last.size()-i)
		}
              }
            }

            //Rename then sort using custom sort.  For custom sort the unspecified values alphabetically, for dcustom sort these reverse alphabetically
            it.categories.each() {
                renameCategory(it,facetname);
                sortCategoryCustom(it,facetname,labelOrderMap,customMode);
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

//Recursively sort categories listing by reverse alphabetical order
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

// Recursively sort categories by alphabetical order
// Recursion is needed since categories are hierarchical
def sortCategoryCustom(category,facetname,labelOrderMap,mode) {
      category.values.sort {a, b -> sortCompareCustom(a, b, labelOrderMap,mode)}
      category.categories.each() { 
	sortCategoryCustom(it,facetname,labelOrderMap,mode) }
}

def sortCompareCustom(a, b, labelOrderMap,mode) {
      def labela = a.label.toLowerCase(), labelb = b.label.toLowerCase()

      if (labelOrderMap.containsKey(labela)) {
        labela = labelOrderMap[labela]
      }
      if (labelOrderMap.containsKey(labelb)) {
        labelb = labelOrderMap[labelb]
      }

      if (mode == "custom") {
        labela.compareTo(labelb);
      } else if (mode == "dcustom") {
        labelb.compareTo(labela);
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
