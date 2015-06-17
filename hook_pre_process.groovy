/* 
 * This code works around a bug that exists with the facetscope parameter when using with multi-select facets - See FUNNELAPPS-27 
 * The code reads the facetscope parameters, sets then as standard facet parameters then removes the facetscope parameter.
 */
if (transaction?.question?.inputParameterMap["query"] != null && transaction?.question?.rawInputParameters["facetScope"] != null) {
    if (transaction?.question?.rawInputParameters["facetScope"][0]) {
        def facetScope = java.net.URLDecoder.decode(transaction.question.rawInputParameters["facetScope"][0], "UTF-8").split("&")
        def result     = [:]
        
        facetScope.each {
            def param = it.split("=")
            if (param.size() == 2) {
                if (result[param[0]] == null) { result[param[0]] = [] }
                result[param[0]].add(param[1])
                
                if (transaction.question.additionalParameters[param[0]] != null) {
                    transaction.question.additionalParameters[param[0]].each { result[param[0]].add(it) }
                    transaction.question.additionalParameters.remove(param[0])
                }
            }
        }

        result.each {k,v -> 
            transaction.question.additionalParameters[k] = v
            transaction.question.rawInputParameters[k]   = v
        }
    }
    
    if (transaction.question.additionalParameters['facetScope'] != null) {
        transaction.question.additionalParameters.remove('facetScope')
    }
    transaction.question.rawInputParameters.remove('facetScope')
}