---
layout: page
permalink: /cv/
title: cv
nav: true
nav_order: 5
cv_pdf: Steven_Dillmann_CV.pdf # file in assets/pdf/ — replace it (or change this name) to update the CV
description:
---

{% assign cv_url = page.cv_pdf | prepend: 'assets/pdf/' | relative_url %}

<div class="cv-actions">
  <a class="cv-download" href="{{ cv_url }}" download>Download PDF</a>
  <a class="cv-open" href="{{ cv_url }}" target="_blank" rel="noopener noreferrer">Open in new tab ↗</a>
</div>

<object class="cv-embed" data="{{ cv_url }}#view=FitH&navpanes=0" type="application/pdf" aria-label="CV (PDF)">
  <p>Your browser can't display the PDF here. <a href="{{ cv_url }}">Download the CV</a> instead.</p>
</object>
