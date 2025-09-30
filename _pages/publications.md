---
layout: page
permalink: /publications/
title: publications
description: 
nav: true
nav_order: 2
---

<!-- _pages/publications.md -->

<!-- Bibsearch Feature -->
<div class="search-container">
  {% include bib_search.liquid %}
  <button id="clear-keyword-filters" class="btn btn-sm btn-outline-secondary">Show All</button>
</div>

<!-- Keyword Filter -->
<div class="keyword-filter">
  <div id="keyword-filter-container" class="keyword-filters">
    <!-- Keywords will be populated by JavaScript -->
  </div>
</div>

<div class="publications">

{% bibliography %}

</div>
