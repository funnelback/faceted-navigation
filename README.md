# faceted-navigation

**This is only applicable to Funnelback 15.10 and earlier.  Funnelback 15.12 and newer should use the supported Faceted navigation code which provides all the functionality detailed here and more.**

Replacement macros for faceted navigation display.  Adds support for checkbox facets and faceted navigation category sort and rename.

Documentation is available from the [wiki page](https://github.com/funnelback/faceted-navigation/wiki)

## Introduction

The purpose of this macro library is to take the existing faceted navigation macros (from funnelback_classic.ftl) and extend them to support checkbox faceting.  It can be used to replace the faceted navigation macros from funnelback_classic.ftl

The work in progress macro library is attached faceted_navigation_v2.ftl.  Examples below assume that it is imported into your template in the fbf namespace.
This also addresses some other existing limitations when comparing Modern UI faceted navigation vs Classic UI faceted navigation (sort and rename functionality)

## Installation

The faceted navigation v2 code is installed by copying files from the gitlab bundle to the given location:

faceted_navigation_v2,ftl, hook_pre_process.groovy and hook_post_process.groovy are installed into the collection's configuration folder. (note: if there are existing hook scripts these will need to be merged.

faceted_navigation.css should be copied to the collection's _default/web/ and _default_preview/web/ folders.

## Faceted navigation - backend configuration

Faceted navigation is configured by editing the faceted navigation configuration in the normal product supported way.

## Faceted navigation - interface configuration

### Usage

Import into your freemarker template using the following command, placed below the other imports in your freemarker template (e.g. simple.ftl):

```
<#import "<PATH TO FILE>/faceted_navigation_v2.ftl" as fbf/>
```

Import styles into your freemarker template using the following command:

```
<link rel="stylesheet" href="/s/resources/${question.collection.id}/${question.profile}/faceted_navigation.css">
```

### Basic Freemarker tags

Freemarker tags for the faceted navigation are identical to existing faceted navigation tags (but in the fbf namespace).  

Note: fbf will be used for the examples below, but the macro library can be imported into an arbitrary namespace.

### Displaying the faceted navigation filter block

The faceted navigation filter block is the set of controls that allow you to apply/remove filters by selecting facet categories

The basic structure requires three tags: FacetedSearch, Facet and Category.  Variables can be used within these tags to print out things such as the facet or category name and count and also apply markup for templating the items.

A basic structure might look like:

```
<@fbf.FacetedSearch>
    <h1>Filter search results</h1>
    <@fbf.Facet>
        <h2>${fbf.facet.name}</h2>
        <ul>
            <@fbf.Category tag="">
                <li><a href="${fbf.categoryLinkAddress}">${fbf.categoryValue.label}</a> ${fbf.categoryValue.count}</li>
            </@fbf.Category>
        </ul>
    </@fbf.Facet>
</@fbf.FacetedSearch>
```

The existing default faceted navigation formatting can be replicated using code similar to:

```
<@fbf.FacetedSearch>
  <div class="col-md-3 col-md-pull-9 hidden-print" id="search-facets">
    <h2 class="sr-only">Refine</h2>
    <@fbf.Facet>
    <div class="facet">
      <div class="panel panel-default">
        <div class="panel-heading"><h3 class="facetLabel">${fbf.facet.name!""} <@fbf.FacetSummary /></h3></div>
        <div class="panel-body">
          <ul class="list-unstyled">
            <@fbf.Category tag="" max=20>
              <li><span class="categoryName"><a href="${fbf.categoryLinkAddress}" title="Remove filter - ${fbf.facet.name?html}: ${fbf.categoryValue.label?html}">${fbf.categoryValue.label}</a></span>&nbsp;<span class="badge pull-right"><span class="categoryCount">${fbf.categoryValue.count}</span></span></li>
            </@fbf.Category>
          </ul>
          <button type="button" class="btn btn-link btn-sm search-toggle-more-categories" style="display: none;" data-more="More&hellip;" data-less="Less&hellip;" data-state="more" title="Show more categories from this facet"><small class="glyphicon glyphicon-plus"></small>&nbsp;<span>More&hellip;</span></button>
        </div>
      </div>
    </div>
    </@fbf.Facet>
  </div>
</@fbf.FacetedSearch>
```

### Checkbox facets

#### 1. collection.cfg

In collection.cfg enable the full facet list.

Add the following to collection.cfg:

```
ui.modern.full_facets_list=true
```

Consider setting the category sort (see section below on sorting) - For checkbox facets you should sort alphabetically as counts are not displayed (making sort by count looking like a random sort)

```
faceted_navigation.<MY CHECKBOX FACET>.sort_mode=label
```

#### 2. Hook script

If you wish to apply sorting or renaming to faceted navigation then you need to include the hook_post_process.groovy code outlined below.

If you wish to use the facetscope control with checkbox facets then you should include the hook_pre_process.groovy code outlined below.

#### 3. Freemarker

Checkbox facets can be enabled by adding the parameter checkbox=true to the <@Facet> tag.  This will allow selection of multiple categories, with the list of categories displayed as links.  Every time a link is clicked the faceted navigation display is updated.

The category count value should be omitted when using checkbox facets as the count is not correct for checkbox faceting.

```
<@fbf.FacetedSearch>
    <h1>Filter search results</h1>
    <@fbf.Facet>
        <h2>${fbf.facet.name}</h2>
        <ul>
            <@fbf.Category tag="">
                 <li><a href="${fbf.categoryLinkAddress}"><#if fbf.checked><span class="glyphicon glyphicon-check"></span><#else><span class="glyphicon glyphicon-unchecked"></span></#if>${fbf.categoryValue.label}</a></li>
            </@fbf.Category>
        </ul>
    </@fbf.Facet>
</@fbf.FacetedSearch>
```

An additional parameter checkboxMode can be set to the value 'form' to allow the categories to be rendered as checkbox input elements within a form.  This allows multiple checkboxes to be selected within a facet before the changes are applied.  When using checkboxmode="form" an additional tag CheckboxForm should be included within the Facet tag.  This tag should wrap the Category tag and returns a HTML form allowing the checkbox input boxes to function as desired.

```
<@fbf.FacetedSearch>
    <h1>Filter search results</h1>
    <@fbf.Facet>
        <h2>${fbf.facet.name}
        <@fbf.CheckboxForm>
        <ul>
            <@fbf.Category>
                 <li>
<input id="facet-${fbf.facet.name?replace(" ","_")?html} type="checkbox" <#if fbf.checked>checked="checked" </#if>name="${fbf.categoryQueryStringParamName?html}" value="${fbf.categoryValue.label?html}"/> <label for="facet-${fbf.facet.name?replace(" ","_")?html}-${fbf.categoryValue.label?replace(" ","_")?html}">${fbf.categoryValue.label}</label></li>
            </@fbf.Category>
        </ul>
        </@fbf.CheckboxForm>
    </@fbf.Facet>
</@fbf.FacetedSearch>
```

## Displaying information about faceted navigation

### AppliedFacets

The AppliedFacets macro renders a control that allows you to remove facets that have been applied.

```
<#if question.selectedCategoryValues?has_content>
  <@fbf.ClearFacetsLink class="btn btn-xs btn-danger"/>
  <@fbf.FacetedSearch>
    <@fbf.Facet checkbox=true>
      <#if question.selectedFacets?seq_contains(fbf.facet.name)>
        <div class="appliedFacets">
          ${fbf.facet.name}:
          <ul>
            <@fbf.AppliedFacets>
              <li>
                <a href="${fbf.appliedFacetLink}" title="Remove refinement - ${fbf.facet.name?html}: ${fbf.appliedFacetLink?html}" class="btn btn-xs btn-warning">
                <#if fbf.subFacet><span class="glyphicon glyphicon-arrow-right"></span> </#if>
                ${fbf.appliedFacetLabel} <span class="glyphicon glyphicon-remove-circle"></span>
                </a>
              </li>
            </@fbf.AppliedFacets>
          </ul>
        </div>
      </#if>
    </@fbf.Facet>
  </@fbf.FacetedSearch>
</#if>
```

### Reset facet link

The clearCurrentFacetLink variable can be used to produce a button that clears all the currently applied filters within a single facet.  This control is only useful when used in conjunction with checkbox facets.

```
<@fbf.FacetedSearch>
  <@fbf.Facet>
  <#if QueryString?contains("f." + facetDef.name?url) || urlDecode(QueryString)?contains("f." + facetDef.name) || urlDecode(QueryString)?contains("f." + facetDef.name?url)>
      <span class="btn btn-xs btn-danger"><a href="${fbf.clearCurrentFacetLink?html}">Remove selected categories <span class="glyphicon glyphicon-remove-circle"></a></span>
    </#if>
  </@fbf.Facet>
</@fbf.FacetedSearch>
```

### Facet breadcrumbs

The FacetSummary macro, used within a fbf.Facet tag can be used to produce a Facet breadcrumb trail.

```
<@fbf.FacetedSearch>
  <@fbf.Facet>
    ${@fbf.Facet.name?html}: <@fbf.FacetSummary />
  </@fbf.Facet>
</@fbf.FacetedSearch>
```

## Other controls

### FacetScope

The FacetScope macro is used to produce information about the current faceted navigation state.  This is used to maintain the applied facets when refining a query via the page's search box and also in producing the links used for the facets themselves.

It can also be used to maintain selected facets when moving between pages in a tabbed search display.

The FacetScope macro can be used to return a hidden <input> element that when used inside a html form maintains the currently selected facets.

It can also be used to produce a CGI parameter that can be added to a html link to provide the same outcome.

If you wish to use this with checkbox facets then you should use the hook_pre_process.groovy code outlined below.  This code is included in the files managed in GitLab

```groovy
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
```

## Faceted navigation - category sort and rename options

If you wish to rename categories or sort the facets by anything other than reverse count use the attached hook_post_process.groovy, or take the code and add it to your post process hook script.

The sort and rename code will apply both the main search as well as extra searches.

### Renaming a category

Category renames are read on a per facet, per name basis from the collection.cfg.  This includes renaming of date facet labels.

The following option can be set in collection.cfg:

```
faceted_navigation.<FACET NAME>.rename.<OLD NAME>=<NEW NAME>
```

The label displayed to the end user will be updated to the new name. 

### Sorting categories

Sort options are read on a per facet basis from the collection.cfg.

Sort options can be applied to the following faceted navigation types

* Metadata fill / Metadata field fill / XML field fill
* Date
* URL fill

The product includes native support for date facet sorting (see: faceted_navigation.date.sort_mode)

Limitations:

* Gscope and Query facets are not currently supported
* Doesn't support the merging of category values from multiple sources


The following option can be set in collection.cfg:
```
faceted_navigation.<FACET NAME>.sort_mode = [count|label|dlabel|acount]
```

* count is the default and the hook script is not required for sorting by count.
* label sorts the facet alphabetically
* dlabel sorts the facet reverse alphabetically
* acount sorts the facet by ascending count
* custom sorts the facets in a custom order with unspecified items sorted alphabetically
* dcustom sorts the facets in a custom order with unspecified items sorted reverse alphabetically

For custom and dcustom sort modes additional parameters are available specifying the order of items to sort at the top and bottom of the list.

```
faceted_navigation.<FACET NAME>.sort_order.first=<Pipe delimited list of categories>
```

List of categories, pipe delimited, to place at the top of the list facet categories.

```
faceted_navigation.<FACET NAME>.sort_order.last=<Pipe delimited list of categories>
```

List of categories, pipe delimited, to place at the bottom of the list facet categories.
 
The following code must be included in the hook_post_process.groovy script: 

```groovy
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
```

## Macros and elements
### Facet scope 

#### `<@fbf.FacetScope>`

Returns the query string that sets the currently selected facets. This can be used to include the selected facets in a search box, or to add the selected facets to a URL used in a link (such as on a tab)

**Type:** macro

**Arguments:**
* input: (boolean) - If set to true return the link inside an input element
* facetRemove: (list) - List of facet names to exclude from the generated link

**Use scope:** Anywhere in the Funnelback freemarker template, after search results have been returned.

###Faceted Navigation information

#### `<@fbf.AppliedFacet>`

**Type:** macro

**Arguments:**
* catdefs - List of sub categories (hierarchical)
* recursionDepth - Displays all the currently applied categories, with links to remove individual applied categories.

**Use scope:** inside a Facet tag
#### `<@fbf.ClearFacetsLink>`

Displays a link that, when clicked, clears all the applied facet categories across all facets.

**Type:** macro
**Arguments:**
* clearAllText: Optional link text to display. (def: Clear all filters)
* class: Optional CSS class to apply to the link (def: clearFacetLink)
* title: Optional link text to display (def: Clear all filters)

**Use scope:** inside a Facet tag

#### `fbf.appliedFacetLabel`

Returns the label of the current applied facet

**Type:** variable (string)

**Use scope:** inside a AppliedFacets tag

#### `fbf.appliedFacetLink`

Returns the link of the current applied facet

**Type:** variable (string)

**Use scope:** inside a AppliedFacets tag

#### `fbf.clearCurrentFacetLink`

Return a link that, when clicked, clears all the categories within the current facet.

**Type:** variable

**Use scope:** inside a Facets tag

### Faceted Navigation filters

#### `<@fbf.FacetedSearch>`

Container for Faceted navigation filters

**Type:** macro

**Use scope:** Anywhere in the Funnelback freemarker template, after search results have been returned.

#### `<@fbf.Facet>`

Container for a Facet

**Type:** macro

**Arguments:**
* names (sequence) - (optional) List of facets to display.  Only facets matching these names will be displayed by this Facet macro.  Displays all defined facets if not set.
* checkbox (boolean) - true: enable checkbox facets (def: false)
* checkboxMode (string: link|form) - Return checkbox facets as links (def), or as form input checkboxes.

**Use scope:** Inside a `<@fbf.FacetedSearch>` tag

#### `<@fbf.FacetSummary />`

Returns a breadcrumb trail indicating the heirarchy of the current facet, including a link to remove all categories for the current facet.

**Type:** macro

**Arguments:**
* separator - string to insert between categories
* alltext - text to display for the 'all' link
* prefix - string to insert before the facet summary
* categoryPrepend - string to insert before each category
* categoryAppend - string to insert after each category
* categoryLinkClass - class to apply to each category link

**Use scope:** inside a Facet tag

#### `<@fbf.FacetBreadCrumb />`

Returns a breadcrumb trail indicating the heirarchy of the current facet

**Type:** macro

**Arguments:**
* categoryDefinitions - List of sub categories (hierarchical)
* selectedCategoryValues - List of selected values
* categoryPrepend - string to insert before each category
* categoryAppend - string to insert after each category
* categoryLinkClass - class to apply to each category link

**Use scope:** inside a Facet tag

#### `<@fbf.CheckboxForm>`

Returns HTML code to construct a form, to enable form-style checkbox faceting

**Type:** macro

**Use scope:** Inside a `<@fbf.Facet>` tag, wrapping the `<@fbf.Category>` tag.

#### `<@fbf.Category>`
Container for presentation of Facet categories

**Type:** macro

**Use scope:** Inside a `<@fbf.Facet>` or `<@fbf.CheckboxForm>` tag.

#### `fbf.facet.name`

Contains the name of the current facet

**Type:** variable (string)

**Use scope:** Inside a Facet tag

#### `fbf.checked`

Indicates if the current category is already selected/checked (used for checkbox facets, and for the applied facets code)

**Type:** variable (boolean) 

**Use scope:** Inside a Category tag

#### `fbf.categoryValue.label`

Contains the name of the current facet category

**Type:** variable (string)

**Use scope:** Inside a Category tag

#### `fbf.categoryLinkAddress`

Returns the link for the current category

**Type:** variable (string)

**Use scope:** Inside a Category tag

#### `fbf.categoryValue.count`

Returns the count of the current facet category

**Type:** variable

**Use scope:** Inside a Category tag

**Note:** do not use this with checkbox facets as the counts are incorrect

# Limitations and notes

## Bugs/limitations:
* Counts are not available when using checkbox facets
* Checkbox facets only work for the top faceted navigation level (sub-category selection is not possible)
* Behaviour is to AND between facets and OR between categories
* Gscope (+Query)  facet categories are ANDed by default (instead of OR as for other facet types)
* Data model subcategories are only calculated to a single level below the current selected facets
* Sorting does not merge categories from different groups
* Sorting does not support Gscope based facets (gscope or query facets)
* If using checkbox facets in it's possible to make a selection that will result in no results

## Deprecated macros

Several macros (still included for backwards compatibility) are now redundant:

* FacetLabel - you can use ${fbf.facet.name!""} to print out the Facet name
* CategoryName - This can be printed using ${fbf.categoryValue.label} inside the Category macro.
* CategoryCount - This can be printed using ${fbf.categoryValue.count} inside the Category macro.

