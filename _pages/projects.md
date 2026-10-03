---
layout: page
title: projects
permalink: /projects/
nav: false
nav_order: 3
description:
---

<!-- Projects come from _data/projects.yml -->
<div class="project-grid">
  {% for project in site.data.projects %}
    <div class="project-box">
      <a class="project-title" href="{{ project.url }}" target="_blank" rel="noopener noreferrer">{{ project.title }} <span aria-hidden="true">↗</span></a>
      {% if project.description %}<p class="project-desc">{{ project.description }}</p>{% endif %}
      {% if project.links %}
        <div class="project-links">
          {% for link in project.links %}<a class="pub-filter" href="{{ link.url }}" target="_blank" rel="noopener noreferrer">{{ link.label }}</a>{% endfor %}
        </div>
      {% endif %}
    </div>
  {% endfor %}
</div>
