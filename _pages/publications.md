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
      {% assign per_year = site.data.scholar_metrics.per_year %}
      {% if per_year and per_year.size > 0 %}
      <svg class="citations-spark" width="100%" height="120" viewBox="0 0 300 120" preserveAspectRatio="xMaxYMin meet">
        {% assign series = per_year %}
        {% assign max = 0 %}
        {% for pt in series %}
          {% if pt.citations > max %}{% assign max = pt.citations %}{% endif %}
        {% endfor %}
        {% assign n = series.size %}
        {% if n > 0 and max > 0 %}
          {% assign bar_w = 300 | divided_by: n %}
          {% assign half_bar = bar_w | divided_by: 2 %}
          {% assign rect_w = bar_w | minus: 6 %}
          {% if rect_w < 10 %}{% assign rect_w = 10 %}{% endif %}
          {% for pt in series %}
            {% assign idx = forloop.index0 %}
            {% assign x = idx | times: bar_w %}
            {% assign h = pt.citations | times: 75 | divided_by: max %}
            {% assign y = 90 | minus: h %}
            {% assign pad = bar_w | minus: rect_w | divided_by: 2 %}
            {% assign x_bar = x | plus: pad %}
            {% assign ylo = pt.year %}
            {% assign yhi = pt.year %}
            {% assign scholar_url = 'https://scholar.google.com/scholar?hl=en&q=author:%22Steven%20Dillmann%22&as_ylo=' | append: ylo | append: '&as_yhi=' | append: yhi %}
            <a xlink:href="{{ scholar_url }}" target="_blank" rel="noopener noreferrer">
              <g class="bar">
                <rect x="{{ x_bar }}" y="{{ y }}" width="{{ rect_w }}" height="{{ h }}" fill="currentColor" rx="0" ry="0" />
                {% assign label_y = y | minus: 4 %}
                <text x="{{ x | plus: half_bar }}" y="{{ label_y }}" text-anchor="middle" font-size="9" class="citation-count" fill="currentColor">{{ pt.citations }}</text>
                <text x="{{ x | plus: half_bar }}" y="112" text-anchor="middle" font-size="10" class="year-label" fill="var(--global-text-color)">{{ pt.year }}</text>
              </g>
            </a>
          {% endfor %}
        {% endif %}
      </svg>
      {% endif %}
      <div class="scholar-link-center">
        <small><a href="https://scholar.google.com/citations?user={{ site.data.socials.scholar_userid }}" target="_blank">Google Scholar</a></small>
        {% if site.data.scholar_metrics.fetched_at %}
          <div class="fetched-at">Last updated: {{ site.data.scholar_metrics.fetched_at | date: "%B %e, %Y" }}</div>
        {% endif %}
      </div>
    </div>
  </div>
</div>

<div class="publications">

{% bibliography %}

</div>
