<#---
    Faceted Navigation tags
	
	Author: Peter Levan, Dec 2014
	Version: 24 Dec 2014 
	
	Faceted navigation macros based on the faceted navigaton tag set included in funnelback_classic.ftl and funnelback.ftl.  This extends the basic faceted navigation tags to support checkbox faceting as well as adding a some new macros.
			
-->
<#--
	Global variables defined within the namespace of the faceted navigation library

	Template-level variables (defined once template is imported)
	* clearAllFacetsLink: Returns link (when clicked) that will clear all the applied facets.
    
	Facet-level variables (use inside @Facet)
	* checkbox: (boolean) - indicates if the facet is a checkbox style facet (true) or standard facet (false)
    * checkboxMode: (link|form) - indicates type of checkbox faceting to use - use HTML links (link=def) or input checkbox elements
	* clearCurrentFacetLink: Returns link  (when clicked) that will clear the current facets.
    * facet
		- facet.name
    * facet_index
    * facet_has_next
    * facetDef
    * facetDef_index
    * facetDef_has_next

	Category-level variables (use inside @Category)
    * categoryLinkAddress: Returns link for the category value.  When clicked will apply (or remove, if applied) the current facet taking in to consideration other applied categories.
    * checked: (boolean) - indicates if the current category value is currently applied (used for checkbox faceting)
    * category
    * category_hax_next
    * category_index
	* categoryValue
		- categoryValue.label
		- categoryValue.count
	* categoryValue_has_next
	* categoryValue_index
	* cvQueryStringParam
	* cvConstraint

	Nesting:
	
	FacetedSearch
	- Facet
	  - CheckboxForm (opt)
	    - Category
	
-->

<#-- generate the link that can be used to reset all of the facets -->
<#if question.selectedCategoryValues?has_content>
<#assign clearAllFacetsLink = question.collection.configuration.value("ui.modern.search_link")+"?"+removeParam(QueryString,question.selectedCategoryValues?keys+["start_rank","facetScope"]) in .namespace />
<#else>
<#assign clearAllFacetsLink ="" in .namespace/>
</#if>

<#--- @begin Faceted navigation -->

<#---
    Conditional display against faceted navigation.

    <p>The content will be evaluated only if faceted navigation
    is configured.</p>
	
	@param negate Whether to negate the tag, i.e. evaluate the content if faceted navigation is not configured.
-->
<#macro FacetedSearch negate=false>
	<#if !negate>
		<#if question?exists
			&& facetedNavigationConfig(question.collection, question.profile)?exists >
			<#nested>
		</#if>
	<#else>
		<#if !question?exists
			|| !facetedNavigationConfig(question.collection, question.profile)?exists >
			<#nested>
		</#if>
    </#if>
</#macro>

<#---
    Return necessary HTML to produce a form containing the facets as HTML checkbox input elements.
	
	This should wrap the Category tag if form-based checkbox faceting is being used.

	@param negate Whether to negate the tag, i.e. evaluate the content if faceted navigation is not configured.
-->
<#macro CheckboxForm submitText="Apply" submitClass="button">
    <#local fs><@FacetScope input=false facetRemove=.namespace.facet.name/></#local>
    <#if checkbox && checkboxMode == "form">
         <form action="${question.collection.configuration.value("ui.modern.search_link")}" method="GET" role="search">
            <input type="hidden" name="collection" value="${question.inputParameterMap["collection"]!}">
            <#if question.inputParameterMap["enc"]?exists><input type="hidden" name="enc" value="${question.inputParameterMap["enc"]!}"></#if>
            <#if question.inputParameterMap["form"]?exists><input type="hidden" name="form" value="${question.inputParameterMap["form"]!}"></#if>
            <#if question.inputParameterMap["scope"]?exists><input type="hidden" name="scope" value="${question.inputParameterMap["scope"]!}"></#if>
            <#if question.inputParameterMap["lang"]?exists><input type="hidden" name="lang" value="${question.inputParameterMap["lang"]!}"></#if>
            <#if question.inputParameterMap["profile"]?exists><input type="hidden" name="profile" value="${question.inputParameterMap["profile"]!}"></#if>
            <#if question.inputParameterMap["query"]?exists><input type="hidden" name="query" value="${question.inputParameterMap["query"]!}"></#if>
            <#if question.inputParameterMap["checkbox"]?exists><input type="hidden" name="checkbox" value="${question.inputParameterMap["checkbox"]!}"></#if>
            <#if question.inputParameterMap["checkboxmode"]?exists><input type="hidden" name="checkboxmode" value="${question.inputParameterMap["checkboxmode"]!}"></#if>
			<input type="hidden" name="facetScope" value="${fs}">
	</#if>
	<#nested>
    <#if checkbox && checkboxMode == "form">
			<button type="submit" class="${submitClass}"><span class="glyphicon glyphicon-filter"></span> ${submitText}</button>
		</form>
    </#if>	
</#macro>


<#---
    Displays a facet, a list of facets, or all facets.

    <p>If both <code>name</code> and <code>names</code> are not set
    this tag iterates over all the facets.</p>

	Should be nested inside the FacetedSearch tag.
	
    @param name Name of a specific facet to display, optional.
    @param names A list of specific facets to display, optional. Won't affect facet display order (defined in <code>faceted_navigation.cfg</code>).
    @param checkbox Boolean to enable checkbox facet mode allowing multiple facet selection. checkboxes are disabled by default.
    @param checkboxMode Use link or form mode for display of checkbox facets. Acceptable values are link (defualt) and form.

    @provides The facet as <code>${.namespace.facet}</code>.
-->
<#macro Facet name="" names=[] checkbox=false checkboxMode="link">
  <#assign checkbox = checkbox in .namespace>
  <#assign checkboxMode = checkboxMode in .namespace>
  <#assign clearCurrentFacetLink ="" in .namespace/>

  <#local fn = facetedNavigationConfig(question.collection, question.profile) >

  <#-- Is this a checkbox facet (if so then use the extra search) -->
  <#if checkbox 
       && extraSearches?exists
       && extraSearches[ExtraSearches.FACETED_NAVIGATION]?exists
       && extraSearches[ExtraSearches.FACETED_NAVIGATION].response?exists
       && extraSearches[ExtraSearches.FACETED_NAVIGATION].response.facets?exists>
    <#assign facetResponse = extraSearches[ExtraSearches.FACETED_NAVIGATION].response>   
  <#elseif response?exists && response.facets?exists && response.resultPacket?exists && response.resultPacket.resultsSummary.totalMatching &gt; 0> 
    <#assign facetResponse = response>   
  </#if> <#--if  checkbox etc -->

  <#if facetResponse?exists>
  <#list facetResponse.facets as f>
    <#if ((name == "" && names?size == 0) 
          || ((f.name == name || names?seq_contains(f.name) ) && (f.hasValues() || question.selectedFacets?seq_contains(f.name))))>
      <#assign facet = f in .namespace>
      <#assign facet_index = f_index in .namespace>
      <#assign facet_has_next = f_has_next in .namespace>
      <#if fn?exists>
      <#-- Find facet definition in the configuration corresponding
           to the facet we're currently displaying -->
        <#list fn.facetDefinitions as fdef>
          <#if fdef.name == .namespace.facet.name>
            <#assign facetDef = fdef in .namespace />
            <#assign facetDef_index = fdef_index in .namespace />
            <#assign facetDef_has_next = fdef_has_next in .namespace />
          </#if>
        </#list>

		<#-- Generate the link to clear this facet -->
		<#if QueryString?contains("f." + facetDef.name?url)
		|| urlDecode(QueryString)?contains("f." + facetDef.name)
		|| urlDecode(QueryString)?contains("f." + facetDef.name?url)>
			<#assign clearCurrentFacetLink = question.collection.configuration.value("ui.modern.search_link")+"?"+removeParam(facetScopeRemove(QueryString, facetDef.allQueryStringParamNames), ["start_rank"] + facetDef.allQueryStringParamNames) in .namespace />
		</#if>

  	  </#if> <#-- if fn?exists -->
      <#nested>
    </#if>
  </#list>
  </#if>
</#macro>

<#---
Display the <em>facet scope</em> checkbox.

<p>Provides a checkbox to constraint search to the
currently selected facet(s) only.</p>

@nested Text to display beside the checkbox.
@facetRemove Don't include items from specified facet in the facetscope. 
-->
<#macro FacetScope input=true  facetRemove=""><#compress>
<#if question?exists && question.selectedCategoryValues?size &gt; 0>
<#local facetScope = "" />
<#list question.selectedCategoryValues?keys as key>
	<#if facetRemove != key?replace("^f\\.","","r")?replace("\\|\\w+$","","r")>
		<#list question.selectedCategoryValues[key] as value>
		<#local facetScope = facetScope + key?url+"="+value?url />
		<#if value_has_next><#local facetScope = facetScope + "&" /></#if>
		</#list>
		<#if key_has_next><#local facetScope = facetScope + "&" /></#if>
	</#if>
</#list> 
<#if input>
    <input type="checkbox" name="facetScope" id="facetScope" value="${facetScope}" checked="checked">
    <label for="facetScope"><#nested></label>
<#else>
    ${facetScope}
</#if>
</#if>
</#compress></#macro>
<#--- @end -->

<#---
Displays a link that, when clicked, clears all the selected categories for the selected facet.

@param clearAllText Optional link text to display.
-->
<#macro ResetFacetLink clearAllText="Clear selected" class="resetFacetLink">

<#if QueryString?contains("f." + facetDef.name?url)
|| urlDecode(QueryString)?contains("f." + facetDef.name)
|| urlDecode(QueryString)?contains("f." + facetDef.name?url)>
<span class="${class}"><a href="${.namespace.clearCurrentFacetLink?html}">${clearAllText?html} <span class="glyphicon glyphicon-remove-circle"></a></span>
</#if>
</#macro>



<#---
Displays all the currently applied facets

@param catdefs
@param recursionDepth
-->

<#macro AppliedFacets catdefs=.namespace.facetDef.categoryDefinitions recursionDepth=0>
<#compress><#if question.selectedFacets?seq_contains(.namespace.facet.name)>
    <#list catdefs as catdef>
		<#if question.selectedCategoryValues[catdef.queryStringParamName]?exists>
			<#assign subFacet=false in .namespace />
			<#list question.selectedCategoryValues[catdef.queryStringParamName] as sf>
				<#assign appliedFacetLink=question.collection.configuration.value("ui.modern.search_link")+"?"+urlDecode(removeParam(facetScopeRemove(QueryString, catdef.queryStringParamName),["start_rank"]))?replace(catdef.queryStringParamName+"="+sf,"")?replace("&+","&","r")?replace("&$","","r") in .namespace/>
				<#assign appliedFacetLabel=sf in .namespace />
				<#if recursionDepth &gt; 0>
					<#assign subFacet=true in .namespace />
				</#if>
				<#nested>
			</#list>
			<#if catdef.subCategories?exists && catdef.subCategories?size &gt; 0>
				<@AppliedFacets catdefs=catdef.subCategories recursionDepth=recursionDepth+1><#nested></@AppliedFacets>
			</#if>
		</#if>
	</#list>
</#if></#compress>
</#macro>


<#---
Displays a faceted navigation category.

<p>The presence of the <code>name</code> parameter determines the role.</p>
<p>The <code>nbCategories</code> and <code>recursionCategories</code> parameters
are internals and can be safely ignored when using this tag.</p>

<p>For faceted navigation the <tt>max</tt> parameter sets the maximum number of
categories to return. If you need to display only a few number of them with a <em>more...</em>
link for expansion, you'll need to use Javascript. See the default form file for an example.</p>

@param name Name of the category for contextual navigation. Can be <code>type</code>, <code>type</code> or <code>topic</code>. Empty for a faceted navigation category.
@param max Maximum number of categories to display, for faceted navigation.
@param nbCategories (Internal parameter, do not use) Current number of categories displayed (used in recursion for faceted navigation).
@param recursionCategories (Internal parameter, do not use) List of categories to process when recursing for faceted navigation).
@param tag HTML tag to wrap faceted navigation categories (defaults to DIV).

@provides The category as <code>${s.category}</code>.
-->
<#macro Category max=16 nbCategories=0 recursionCategories=[] tag="div" class="category" name...>

        <#-- Find if we are working at the root level (facet) or in a sub category -->
        <#if recursionCategories?exists && recursionCategories?size &gt; 0>
            <#local categories = recursionCategories />
        <#else>
            <#local categories = .namespace.facet.categories />
        </#if>
        <#if categories?exists && categories?size &gt; 0>
            <#list categories as c>
                <#assign category = c in .namespace />
                <#assign category_hax_next = c_has_next in .namespace />
                <#assign category_index = c_index in .namespace />
				<#assign categoryQueryStringParamName = c.queryStringParamName in .namespace/>
			
				<#list c.values as cv>
                    <#-- Find if this category has been selected. If it's the case, don't display
                         it in the list, except if it's an URL fill facet as we must display sub-folders
                         of the currently selected folder, or it's a checkbox facet-->
                    <#if (!question.selectedCategoryValues?keys?seq_contains(urlDecode(cv.queryStringParam?split("=")[0])))
                        || c.queryStringParamName?contains("|url") || .namespace.checkbox>
						
                        <#assign categoryValue = cv in .namespace/>
                        <#assign categoryValue_has_next = cv_has_next in .namespace/>
                        <#assign categoryValue_index = cv_index in .namespace/>
						<#-- Construct a HTML link for the category -->
						<#assign paramName = urlDecode(.namespace.categoryValue.queryStringParam?split("=")[0])>
						<#assign paramValue = urlDecode(.namespace.categoryValue.queryStringParam?split("=")[1])>
						<#assign QueryStringRemove = urlDecode(QueryString)?replace(urlDecode(.namespace.categoryValue.queryStringParam),"")?replace("&+","&","r")?replace("&$","","r")>
						<#local checked = question.selectedCategoryValues[paramName]?exists && question.selectedCategoryValues[paramName]?seq_contains(paramValue) />
												
						<#assign cvQueryStringParam = cv.queryStringParam in .namespace>
						<#assign cvConstraint = cv.constraint in .namespace>
						<#if question.selectedCategoryValues[c.queryStringParamName]?exists && question.selectedCategoryValues[c.queryStringParamName]?seq_contains(cv.label)>
							<#assign checked = true in .namespace/> 
						<#else>
							<#assign checked = false in .namespace/> 
						</#if>

						<#if .namespace.checkbox>
							<#if checked>
							  <#--${question.collection.configuration.value("ui.modern.search_link")}?${removeParam(QueryStringRemove,["start_rank"])}-->
							  <#assign categoryLinkAddress = question.collection.configuration.value("ui.modern.search_link")+"?"+removeParam(QueryStringRemove,["start_rank"]) in .namespace/>
							<#else>
							  <#assign categoryLinkAddress = question.collection.configuration.value("ui.modern.search_link")+"?"+removeParam(QueryStringRemove,["start_rank"])+"&"+.namespace.categoryValue.queryStringParam in .namespace />
							</#if>
						<#else>
							<#assign categoryLinkAddress = question.collection.configuration.value("ui.modern.search_link")+"?"+removeParam(facetScopeRemove(QueryString, paramName), ["start_rank", paramName])+"&"+.namespace.categoryValue.queryStringParam in .namespace />
						</#if>


                        <#local nbCategories = nbCategories+1 />
                        <#if nbCategories &gt; max>[BRK]<#break></#if>
						<#if tag !=""><${tag} class="${class}"></#if>
                        <#nested>
						<#if tag !=""></${tag}></#if>
					</#if>

                </#list>
                <#-- Recurse in sub categories -->
                <#if c.categories?exists && c.categories?size &gt; 0>
                    <@Category recursionCategories=c.categories max=max tag=tag class=class nbCategories=nbCategories><#nested></@Category>
                </#if>
            </#list>

        </#if>

</#macro>

<#macro listCategories type constraint>

<#if type="metadata">

<#assign cats = response.resultPacekt.rmcs/>

<#list cats?keys as c>
${c} : ${cats[c]}

</#list>

</#if>



</#macro>

<#-- DEPRECATED MACROS - these are provided for backwards compatibility and are no longer required -->

<#---
Displays a facet label and a breadcrumb.

@param class Optional class to affect to the div containing the facet and breadcrumb.
@param separator Separator to use in the breadcrumb.
@param summary Set to true if you want this tag to display the summary + breadcrumb, otherwise use <code>&lt;@s.FacetSummary /&gt;</code>.
@param tag HTML tag to wrap the name and summary
-->
<#macro FacetLabel class="facetLabel" separator="&rarr;" summary=true tag="div">
<#local fn = facetedNavigationConfig(question.collection, question.profile) >
<#if fn?exists>
<#-- Find facet definition in the configuration corresponding
     to the facet we're currently displaying -->
<#list fn.facetDefinitions as fdef>
    <#if fdef.name == .namespace.facet.name>
        <#assign facetDef = fdef in .namespace />
        <#assign facetDef_index = fdef_index in .namespace />
        <#assign facetDef_has_next = fdef_has_next in .namespace />
        <#if tag != ""><${tag} class="${class}"></#if> ${.namespace.facet.name}
            <#if summary><@FacetSummary separator=separator alltext="all" /></#if>
		<#if tag != ""></${tag}></#if>	
    </#if>
</#list>
</#if>
</#macro>

<#---
Displays a link for a facet category value.

@param class Optional CSS class to use, defaults to <code>categoryName</code>.
-->
<#macro CategoryName class="categoryName">
<#if .namespace.categoryValue?exists>
<#assign paramName = urlDecode(.namespace.categoryValue.queryStringParam?split("=")[0])>
<#assign paramValue = urlDecode(.namespace.categoryValue.queryStringParam?split("=")[1])>
<#assign QueryStringRemove = urlDecode(QueryString)?replace(urlDecode(.namespace.categoryValue.queryStringParam),"")?replace("&+","&","r")?replace("&$","","r")>
<#local checked = question.selectedCategoryValues[paramName]?exists && question.selectedCategoryValues[paramName]?seq_contains(paramValue) />

<#if .namespace.checkbox>
  <#if checked>
    <#if .namespace.checkboxMode == "form">
      <input id="facet-${paramName?replace(" ","_")?html}-${paramValue?replace(" ","_")?html}" type="checkbox" class="fb-facets-value" checked="checked" name="${paramName}" value="${paramValue}"/> <label for="facet-${paramName?replace(" ","_")?html}-${paramValue?replace(" ","_")?html}" title="Remove refinement - ${facet.name?html}: ${.namespace.categoryValue.label}">${.namespace.categoryValue.label}</label>
    <#else>
      <a href="${question.collection.configuration.value("ui.modern.search_link")}?${removeParam(QueryStringRemove,["start_rank"])?html}" title="Remove refinement - ${facet.name?html}: ${.namespace.categoryValue.label}"><span class="glyphicon glyphicon-check"></span><span class="category_text">${.namespace.categoryValue.label}</span></a>
    </#if>
  <#else>
    <#if .namespace.checkboxMode == "form">
      <input id="facet-${paramName?replace(" ","_")?html}-${paramValue?replace(" ","_")?html}" type="checkbox" class="fb-facets-value" name="${paramName}" value="${paramValue}"/> <label for="facet-${paramName?replace(" ","_")?html}-${paramValue?replace(" ","_")?html}" title="Refine by - ${facet.name?html}: ${.namespace.categoryValue.label}">${.namespace.categoryValue.label}</label>
    <#else>
      <a href="${question.collection.configuration.value("ui.modern.search_link")}?${removeParam(QueryStringRemove,["start_rank"])?html}&amp;${.namespace.categoryValue.queryStringParam?html}" title="Refine by - ${facet.name?html}: ${.namespace.categoryValue.label}"><span class="glyphicon glyphicon-unchecked"></span><span class="category_text">${.namespace.categoryValue.label}</span></a>
    </#if>
  </#if>
<#else>
    <a href="${question.collection.configuration.value("ui.modern.search_link")}?${removeParam(facetScopeRemove(QueryString, paramName), ["start_rank", paramName])?html}&amp;${.namespace.categoryValue.queryStringParam?html}">${.namespace.categoryValue.label}</a>
</#if>
</#if>
</#macro>
<#---
Displays the result count for a facet category value.

@param class Optional CSS class.
-->
<#macro CategoryCount displayAlways=false><#compress>
<#if displayAlways || !checkbox>
  <#if .namespace.categoryValue?exists>${.namespace.categoryValue.count}</#if>
</#if>
</#compress></#macro>


<#---
Displays a link that, when clicked, clears all the facets.

@param clearAllText Optional link text to display.
-->
<#macro ClearFacetsLink clearAllText="Clear all filters" class="clearFacetLink" title="Clear all filters">
<#if question.selectedCategoryValues?has_content>
<a href="${.namespace.clearAllFacetsLink?html}" title="${title}" class="${class}">${clearAllText?html} <span class="glyphicon glyphicon-remove-circle"></span></a>
</#if>
</#macro>


<#---
Displays a link to show more or less categories for a facet.
-->
<#macro MoreOrLessCategories>
<span class="moreOrLessCategories"><a href="#" onclick="javascript:toggleCategories(this)" style="display: none;">more...</a></span>
</#macro>

<#---
Displays The facet summary and breadcrumb.

<p>This tag is called by <code>&lt;@s.FacetLabel /&gt;</code> but this can be disabled
so that the summary and breadcrumb can be displayed separately using this tag for more flexibility.</p>

@param separator Separator to use in the breadcrumb.
@param alltext Text to use to completely remove the facet constraints. Defaults to &quot;all&quot;.
-->
<#macro FacetSummary separator="&rarr;" alltext="all" prefix=": " categoryPrepend="" categoryAppend="" categoryLinkClass="">
<#-- We must test various combinations here as different browsers will encode
 some characters differently (i.e. '/' will sometimes be preserved, sometimes
 encoded as '%2F' -->
	<#if QueryString?contains("f." + facetDef.name?url)
	|| urlDecode(QueryString)?contains("f." + facetDef.name)
	|| urlDecode(QueryString)?contains("f." + facetDef.name?url)>
		${prefix?html}${categoryPrepend}<a href="${question.collection.configuration.value("ui.modern.search_link")}?${removeParam(facetScopeRemove(QueryString, facetDef.allQueryStringParamNames), ["start_rank"] + facetDef.allQueryStringParamNames)?html}" class="${categoryLinkClass?html}">${alltext}</a>${categoryAppend}
	</#if>
	<@FacetBreadCrumb categoryDefinitions=facetDef.categoryDefinitions selectedCategoryValues=question.selectedCategoryValues separator=separator  categoryPrepend=categoryPrepend categoryAppend=categoryAppend categoryLinkClass=categoryLinkClass/>
</#macro>

<#---
Displays facet title or value of the current category.

<p>Displays either the facet title if no categories has been
selected, or the value of the currently selected category.</p>

<p>For hierarchical facets, displays the latest selected category.</p>

@param title Whether to display the facet title only, or the category.
@param class CSS class to apply to the container DIV, <code>shortFacetLabel</code> by default.
-->
<#macro ShortFacetLabel title=false class="shortFacetLabel">
<#if (title?is_boolean && title) || (title?is_string && title == "true")>
<div class="${class}">${.namespace.facet.name!""}</div>
<#else>
<#local deepest = .namespace.facet.findDeepestCategory(question.selectedCategoryValues?keys)!"">
<#if deepest != "">
    <div class="${class}">${question.selectedCategoryValues[deepest.queryStringParamName]?first}</div>
<#else>
    <div class="${class}">${.namespace.facet.name!""}</div>
</#if>
</#if>
</#macro>

<#---
Recursively generates the breadcrumbs for a facet.

@param categoryDefinitions List of sub categories (hierarchical).
@param selectedCategoryValues List of selected values.
@param separator Separator to use in the breadcrumb.
@param categoryAppend Code to append to each category entry
@param categoryprepend Code to prepend to each category entry
-->
<#macro FacetBreadCrumb categoryDefinitions selectedCategoryValues separator categoryPrepend="" categoryAppend="" categoryLinkClass="">
<#list categoryDefinitions as def>

<#if def.class.simpleName == "URLFill" && selectedCategoryValues?keys?seq_contains(def.queryStringParamName)>
    <#-- Special case for URLFill facets: Split on slashes -->
    <#assign path = selectedCategoryValues[def.queryStringParamName][0]>
    <#assign pathBuilding = "">
    <#list path?split("/", "r") as part>
	<#assign pathBuilding = pathBuilding + "/" + part>
	<#-- Don't display bread crumb for parts that are part
	     of the root URL -->
	<#if ! def.data?lower_case?matches(".*[/\\\\]"+part?lower_case+"[/\\\\].*")>
	    <#if part_has_next>
		${separator} ${categoryPrepend}<a href="${question.collection.configuration.value("ui.modern.search_link")}?${removeParam(facetScopeRemove(QueryString, def.allQueryStringParamNames), ["start_rank"] + def.allQueryStringParamNames)?html}&amp;${def.queryStringParamName}=${pathBuilding?url}" class="${categoryLinkClass?html}">${part?html}</a>${categoryAppend}
	    <#else>
		<#if !checkbox>
		${separator} ${categoryPrepend}${part?html}${categoryAppend}
		</#if>
	    </#if>
	</#if>
    </#list>
<#else>
    <#if selectedCategoryValues?keys?seq_contains(def.queryStringParamName)>
	<#-- Find the label for this category. For nearly all categories the label is equal
	     to the value returned by the query processor, but not for date counts for example.
	     With date counts the label is the actual year "2003" or a "past 3 weeks" but the
	     value is the constraint to apply like "d=2003" or "d>12Jun2012" -->
	<#-- Use value by default if we can't find a label -->
	<#local valueLabel = selectedCategoryValues[def.queryStringParamName][0] />

	<#assign referenceFacet = response.facets/>
    <#if extraSearches?exists
            && extraSearches[ExtraSearches.FACETED_NAVIGATION]?exists
            && extraSearches[ExtraSearches.FACETED_NAVIGATION].response?exists
            && extraSearches[ExtraSearches.FACETED_NAVIGATION].response.facets?exists>
        <#assign referenceFacet = extraSearches[ExtraSearches.FACETED_NAVIGATION].response.facets/>
    </#if>
	
	<#-- Iterate over generated facets -->
	<#list referenceFacet as facet>
	    <#if def.facetName == facet.name>
		<#-- Facet located, find current working category -->
		<#assign fCat = facet.findDeepestCategory([def.queryStringParamName])!"" />
		<#if fCat != "">
		    <#list fCat.values as catValue>
			<#-- Find the category value for which the query string param
			     matches the currently selected value -->
			<#local kv = catValue.queryStringParam?split("=") />
			<#if valueLabel == urlDecode(kv[1])>
			    <#local valueLabel = catValue.label />
			</#if>
		    </#list>
		</#if>
	    </#if>
	</#list> 

	<#-- Find if we are processing the last selected value (leaf node) -->
	<#local last = true>
	<#list def.allQueryStringParamNames as param>
	    <#if param != def.queryStringParamName && selectedCategoryValues?keys?seq_contains(param)>
		<#local last = false>
		<#break>
	    </#if>
	</#list>

	<#if last == true>
	    <#if !checkbox>
	    ${separator} ${categoryPrepend}${valueLabel?html}${categoryAppend}
	    </#if>
	<#else>
	    ${separator} ${categoryPrepend}<a href="${question.collection.configuration.value("ui.modern.search_link")}?${removeParam(facetScopeRemove(QueryString, def.allQueryStringParamNames), ["start_rank"] + def.allQueryStringParamNames)?html}&amp;${def.queryStringParamName}=${selectedCategoryValues[def.queryStringParamName][0]?url}">
		${valueLabel?html}
	    </a>${categoryAppend}
	    <@FacetBreadCrumb categoryDefinitions=def.subCategories selectedCategoryValues=selectedCategoryValues separator=separator categoryAppend=categoryAppend categoryPrepend=categoryPrepend/>
	</#if>
	<#-- We've displayed one step in the breadcrumb, no need to inspect
	     other category definitions -->
	<#break />
    </#if>
</#if>
</#list>
</#macro>


<#--
Returns a href link url for a facet category value.
 -->

<#macro CategoryLinkAddress>
<#if .namespace.categoryValue?exists>
  <#assign paramName = urlDecode(.namespace.categoryValue.queryStringParam?split("=")[0])>
  <#assign paramValue = urlDecode(.namespace.categoryValue.queryStringParam?split("=")[1])>
  <#assign QueryStringRemove = QueryString?replace(.namespace.categoryValue.queryStringParam,"")?replace("&+","&","r")?replace("&$","","r")>
  <#assign checked = question.selectedCategoryValues[paramName]?exists && question.selectedCategoryValues[paramName]?seq_contains(paramValue) in .namespace/>

  <#if .namespace.checkbox>
    <#if checked>
	<#assign categoryLinkAddress = question.collection.configuration.value("ui.modern.search_link")+"?"+removeParam(QueryStringRemove,["start_rank"]) in .namespace/>
    <#else>
      <#assign categoryLinkAddress = question.collection.configuration.value("ui.modern.search_link")+"?"+removeParam(QueryStringRemove,["start_rank"])+"&amp;"+.namespace.categoryValue.queryStringParam in .namespace />
    </#if>
  <#else>
    <#assign categoryLinkAddress = question.collection.configuration.value("ui.modern.search_link")+"?"+removeParam(facetScopeRemove(QueryString, paramName), ["start_rank", paramName])+"&amp;"+.namespace.categoryValue.queryStringParam in .namespace />
  </#if>
</#if>
</#macro>


