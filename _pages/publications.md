---
layout: page
permalink: /publications/
title: publications
description:
nav: true
nav_order: 2
---

<!-- _pages/publications.md — entries come straight from Google Scholar (_plugins/google-scholar-publications.rb) -->

{% assign scholar_url = 'https://scholar.google.com/citations?user=' | append: site.data.socials.scholar_userid %}

<div class="scholar-header">
  <div class="pub-controls">
    <input type="search" id="pub-search" class="pub-search" placeholder="search publications…" aria-label="Search publications" autocomplete="off">
    <div class="pub-filters" role="group" aria-label="Filter by topic">
      {% for topic in site.data.pub_topics.topics %}
        <button type="button" class="pub-filter" data-topic="{{ topic.name }}" aria-pressed="false">{{ topic.name }}</button>
      {% endfor %}
    </div>
  </div>

  <a class="scholar-mini" href="{{ scholar_url }}" target="_blank" rel="noopener noreferrer" title="Google Scholar profile">
      <span class="scholar-stats">
        <span><span class="stat-label">Citations</span> <strong>{{ site.data.scholar_metrics.citations }}</strong></span>
        <span><span class="stat-label">h-index</span> <strong>{{ site.data.scholar_metrics.h_index }}</strong></span>
        <span><span class="stat-label">i10-index</span> <strong>{{ site.data.scholar_metrics.i10_index }}</strong></span>
      </span>
      {% assign per_year = site.data.scholar_metrics.per_year %}
      {% assign axis_max = site.data.scholar_metrics.axis_max %}
      {% if per_year and per_year.size > 0 and axis_max %}
      <span class="cites-chart" role="img" aria-label="Citations per year:{% for pt in per_year %} {{ pt.year }} {{ pt.citations }}{% unless forloop.last %},{% endunless %}{% endfor %}">
        <span class="cites-plot">
          <span class="scholar-badge" aria-hidden="true"><i class="ai ai-google-scholar"></i></span>
          {% for tick in site.data.scholar_metrics.axis_ticks %}
            <span class="cites-grid" style="bottom: {{ tick | times: 100.0 | divided_by: axis_max }}%"></span>
          {% endfor %}
          {% for pt in per_year %}
            <span class="cites-mini-col" data-tip="{{ pt.year }}: {{ pt.citations }} citations">
              <span class="cites-mini-bar" style="height: {{ pt.citations | times: 100.0 | divided_by: axis_max }}%"></span>
            </span>
          {% endfor %}
        </span>
        <span class="cites-axis">
          {% for tick in site.data.scholar_metrics.axis_ticks %}
            <span style="bottom: {{ tick | times: 100.0 | divided_by: axis_max }}%">{{ tick }}</span>
          {% endfor %}
        </span>
        <span class="cites-years">
          {% for pt in per_year %}<span>'{{ pt.year | slice: 2, 2 }}</span>{% endfor %}
        </span>
      </span>
      {% endif %}
  </a>
</div>

<div class="scholar-pubs">
  {% include selected_papers.liquid sortable=true %}

  <h2 class="pub-section"><span>all publications</span></h2>
  {% include pub_cols_header.liquid sortable=true default_year=true %}
  <ol class="pub-list" id="pub-all">
    {% for pub in site.data.scholar_publications %}{% include scholar_pub.liquid pub=pub %}{% endfor %}
  </ol>
  <p class="pub-empty" id="pub-empty" hidden>No publications match.</p>
</div>

<script>
  // Filter the publication list by search text and topic filters (any selected topic matches).
  (function () {
    const input = document.getElementById("pub-search");
    const root = document.querySelector(".scholar-pubs");
    if (!input || !root) return;
    const empty = document.getElementById("pub-empty");
    const selected = document.getElementById("pub-selected");
    const chips = document.querySelectorAll(".pub-filter");
    const active = new Set();

    function apply() {
      const terms = input.value.toLowerCase().trim().split(/\s+/).filter(Boolean);
      root.querySelectorAll(".pub-item").forEach(function (item) {
        const text = item.dataset.search;
        const topics = item.dataset.topics ? item.dataset.topics.split("|") : [];
        const matchesText = terms.every(function (t) { return text.includes(t); });
        const matchesTopic = active.size === 0 || topics.some(function (t) { return active.has(t); });
        item.hidden = !(matchesText && matchesTopic);
      });
      if (selected) selected.hidden = !selected.querySelector(".pub-item:not([hidden])");
      empty.hidden = !!root.querySelector("#pub-all .pub-item:not([hidden])");
    }

    // Topic words in the filter row and under each paper toggle the same filter
    chips.forEach(function (chip) {
      chip.addEventListener("click", function () {
        const topic = chip.dataset.topic;
        if (active.has(topic)) active.delete(topic); else active.add(topic);
        chips.forEach(function (c) {
          if (c.dataset.topic === topic) c.setAttribute("aria-pressed", active.has(topic));
        });
        apply();
      });
    });
    input.addEventListener("input", apply);

    // Preselect a topic from the URL, e.g. /publications/?topic=agents (used by homepage links)
    const initial = new URLSearchParams(location.search).get("topic");
    const initialChip = initial && document.querySelector('.pub-filters .pub-filter[data-topic="' + CSS.escape(initial) + '"]');
    if (initialChip) initialChip.click();
  })();
</script>

{% include pub_sort_script.liquid %}
