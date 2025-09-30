---
layout: page
permalink: /publications/
title: publications
description: 
nav: true
nav_order: 2
---

<!-- _pages/publications.md -->

<div class="pub-header">
  <div class="pub-header-left">
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
  </div>
  <div class="pub-header-right">
    <!-- Google Scholar Metrics -->
    <div class="scholar-metrics compact">
      <ul class="metrics-list">
        <li><span class="metric-label">Citations:</span> <span class="metric-value">{{ site.data.scholar_metrics.citations }}</span></li>
        <li><span class="metric-label">h-index:</span> <span class="metric-value">{{ site.data.scholar_metrics.h_index }}</span></li>
        <li><span class="metric-label">i10-index:</span> <span class="metric-value">{{ site.data.scholar_metrics.i10_index }}</span></li>
      </ul>
      <div class="metrics-note"><small><a href="https://scholar.google.com/citations?user={{ site.data.socials.scholar_userid }}" target="_blank">Google Scholar</a></small></div>
      {% assign per_year = site.data.scholar_metrics.per_year %}
      {% if per_year and per_year.size > 0 %}
      <svg class="citations-spark" width="100%" height="72" viewBox="0 0 300 72" preserveAspectRatio="xMaxYMin meet">
        {% assign max = 0 %}
        {% for pt in per_year %}
          {% if pt.citations > max %}{% assign max = pt.citations %}{% endif %}
        {% endfor %}
        {% assign n = per_year.size %}
        {% if n > 0 and max > 0 %}
          {% assign bar_w = 300 | divided_by: n %}
          {% for pt in per_year %}
            {% assign idx = forloop.index0 %}
            {% assign x = bar_w | times: idx %}
            {% assign h = pt.citations | times: 60 | divided_by: max %}
            {% assign y = 65 | minus: h %}
            <rect x="{{ x }}" y="{{ y }}" width="{{ bar_w | minus: 1 }}" height="{{ h }}" fill="currentColor" rx="0" ry="0" />
          {% endfor %}
        {% endif %}
      </svg>
      {% endif %}
    </div>
  </div>
</div>

<div class="publications">

{% bibliography %}

</div>
