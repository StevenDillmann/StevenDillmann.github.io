import { highlightSearchTerm } from "./highlight-search-term.js";

document.addEventListener("DOMContentLoaded", function () {
  // Collect all unique keywords from publications
  const collectKeywords = () => {
    const keywords = new Set();
    document.querySelectorAll(".keywords .keyword-tag").forEach(tag => {
      const keyword = tag.textContent.replace("#", "").trim();
      if (keyword) {
        keywords.add(keyword);
      }
    });
    return Array.from(keywords).sort();
  };

  // Create keyword filter buttons
  const createKeywordFilters = () => {
    const keywords = collectKeywords();
    const container = document.getElementById("keyword-filter-container");
    
    if (keywords.length === 0) {
      container.innerHTML = "<p>No keywords found in publications.</p>";
      return;
    }

    container.innerHTML = "";
    keywords.forEach(keyword => {
      const button = document.createElement("span");
      button.className = "filter-keyword-tag";
      button.textContent = keyword;
      button.onclick = () => toggleKeywordFilter(keyword);
      container.appendChild(button);
    });
  };

  // Toggle keyword filter
  const toggleKeywordFilter = (keyword) => {
    const button = Array.from(document.querySelectorAll(".filter-keyword-tag"))
      .find(btn => btn.textContent === keyword);
    
    if (button) {
      button.classList.toggle("active");
      applyKeywordFilters();
    }
  };

  // Apply keyword filters
  const applyKeywordFilters = () => {
    const activeKeywords = Array.from(document.querySelectorAll(".filter-keyword-tag.active"))
      .map(btn => btn.textContent);
    
    document.querySelectorAll(".bibliography > li").forEach(item => {
      const itemKeywords = Array.from(item.querySelectorAll(".keywords .keyword-tag"))
        .map(tag => tag.textContent.replace("#", "").trim());
      
      if (activeKeywords.length === 0) {
        // No keyword filters active, show all items (unless hidden by text search)
        item.classList.remove("unloaded");
      } else {
        const hasMatchingKeyword = activeKeywords.some(keyword => 
          itemKeywords.includes(keyword)
        );
        
        if (!hasMatchingKeyword) {
          item.classList.add("unloaded");
        } else {
          item.classList.remove("unloaded");
        }
      }
    });

    // Hide empty year groups
    document.querySelectorAll("h2.bibliography").forEach(function (element) {
      let iterator = element.nextElementSibling;
      let hideFirstGroupingElement = true;
      while (iterator && iterator.tagName !== "H2") {
        if (iterator.tagName === "OL") {
          const ol = iterator;
          const unloadedSiblings = ol.querySelectorAll(":scope > li.unloaded");
          const totalSiblings = ol.querySelectorAll(":scope > li");

          if (unloadedSiblings.length === totalSiblings.length) {
            ol.previousElementSibling.classList.add("unloaded");
            ol.classList.add("unloaded");
          } else {
            hideFirstGroupingElement = false;
          }
        }
        iterator = iterator.nextElementSibling;
      }
      if (hideFirstGroupingElement) {
        element.classList.add("unloaded");
      }
    });
  };

  // Clear all keyword filters and text search
  document.getElementById("clear-keyword-filters").onclick = () => {
    // Clear keyword filters
    document.querySelectorAll(".filter-keyword-tag").forEach(btn => {
      btn.classList.remove("active");
    });
    
    // Clear text search box
    const searchInput = document.getElementById("bibsearch");
    searchInput.value = "";
    
    // Clear search highlighting
    if (CSS.highlights) {
      // Clear CSS highlights registry
      CSS.highlights.clear();
    }
    // Also remove any legacy highlighted classes
    document.querySelectorAll(".highlighted").forEach((element) => {
      element.classList.remove("highlighted");
    });
    
    // Show all publications
    document.querySelectorAll(".bibliography > li, .unloaded").forEach((element) => {
      element.classList.remove("unloaded");
    });
    
    // Show all year groups
    document.querySelectorAll("h2.bibliography, h3.bibliography").forEach((element) => {
      element.classList.remove("unloaded");
    });
    document.querySelectorAll("ol").forEach((element) => {
      element.classList.remove("unloaded");
    });
  };

  // Initialize keyword filters
  createKeywordFilters();

  // Handle research interest clicks on about page
  document.addEventListener('DOMContentLoaded', function() {
    const researchInterests = document.querySelectorAll('.research-interest');
    researchInterests.forEach(interest => {
      interest.addEventListener('click', function(e) {
        e.preventDefault();
        const keyword = this.getAttribute('data-keyword');
        
        // Navigate to publications page with the keyword filter
        window.location.href = '/publications/?filter=' + encodeURIComponent(keyword);
      });
    });
  });

  // Handle keyword tag clicks within papers (on publications page)
  function handleKeywordTagClicks() {
    const keywordTags = document.querySelectorAll('.keyword-tag');
    console.log('Found keyword tags within papers:', keywordTags.length);
    keywordTags.forEach(tag => {
      console.log('Setting up click handler for:', tag.textContent);
      tag.addEventListener('click', function(e) {
        e.preventDefault();
        const keyword = this.textContent.replace('#', '').trim();
        console.log('Keyword tag clicked:', keyword);
        
        // Find the corresponding filter button and toggle it
        const filterButtons = document.querySelectorAll('.filter-keyword-tag');
        console.log('Available filter buttons:', filterButtons.length);
        let found = false;
        filterButtons.forEach(button => {
          if (button.textContent.trim() === keyword) {
            console.log('Found matching filter button, clicking:', button.textContent.trim());
            button.click();
            found = true;
          }
        });
        if (!found) {
          console.log('No matching filter button found for:', keyword);
        }
      });
    });
  }

  // Initialize keyword tag clicks when DOM is loaded
  document.addEventListener('DOMContentLoaded', handleKeywordTagClicks);

  // actual bibsearch logic
  const filterItems = (searchTerm) => {
    document.querySelectorAll(".bibliography, .unloaded").forEach((element) => element.classList.remove("unloaded"));

    // highlight-search-term
    if (CSS.highlights) {
      const nonMatchingElements = highlightSearchTerm({ search: searchTerm, selector: ".bibliography > li" });
      if (nonMatchingElements == null) {
        return;
      }
      nonMatchingElements.forEach((element) => {
        element.classList.add("unloaded");
      });
    } else {
      // Simply add unloaded class to all non-matching items if Browser does not support CSS highlights
      document.querySelectorAll(".bibliography > li").forEach((element, index) => {
        const text = element.innerText.toLowerCase();
        if (text.indexOf(searchTerm) == -1) {
          element.classList.add("unloaded");
        }
      });
    }

    document.querySelectorAll("h2.bibliography").forEach(function (element) {
      let iterator = element.nextElementSibling; // get next sibling element after h2, which can be h3 or ol
      let hideFirstGroupingElement = true;
      // iterate until next group element (h2), which is already selected by the querySelectorAll(-).forEach(-)
      while (iterator && iterator.tagName !== "H2") {
        if (iterator.tagName === "OL") {
          const ol = iterator;
          const unloadedSiblings = ol.querySelectorAll(":scope > li.unloaded");
          const totalSiblings = ol.querySelectorAll(":scope > li");

          if (unloadedSiblings.length === totalSiblings.length) {
            ol.previousElementSibling.classList.add("unloaded"); // Add the '.unloaded' class to the previous grouping element (e.g. year)
            ol.classList.add("unloaded"); // Add the '.unloaded' class to the OL itself
          } else {
            hideFirstGroupingElement = false; // there is at least some visible entry, don't hide the first grouping element
          }
        }
        iterator = iterator.nextElementSibling;
      }
      // Add unloaded class to first grouping element (e.g. year) if no item left in this group
      if (hideFirstGroupingElement) {
        element.classList.add("unloaded");
      }
    });
  };

  const updateInputField = () => {
    const hashValue = decodeURIComponent(window.location.hash.substring(1)); // Remove the '#' character
    document.getElementById("bibsearch").value = hashValue;
    filterItems(hashValue);
  };

  // Sensitive search. Only start searching if there's been no input for 300 ms
  let timeoutId;
  document.getElementById("bibsearch").addEventListener("input", function () {
    clearTimeout(timeoutId); // Clear the previous timeout
    const searchTerm = this.value.toLowerCase();
    timeoutId = setTimeout(() => {
      // First apply text search
      filterItems(searchTerm);
      // Then apply keyword filters on top of text search results
      applyKeywordFilters();
    }, 300);
  });

  window.addEventListener("hashchange", updateInputField); // Update the filter when the hash changes

  // Handle filter parameter from URL (for research interests)
  // This needs to run after keyword filters are created, so we'll use a timeout
  setTimeout(() => {
    const urlParams = new URLSearchParams(window.location.search);
    const filterKeyword = urlParams.get('filter');
    
    if (filterKeyword) {
      // Find and click the corresponding keyword filter button
      const keywordButtons = document.querySelectorAll('.filter-keyword-tag');
      let found = false;
      keywordButtons.forEach(button => {
        if (button.textContent.trim().toLowerCase() === filterKeyword.toLowerCase()) {
          button.click();
          found = true;
        }
      });
      
      // If no exact match found, try partial matching
      if (!found) {
        keywordButtons.forEach(button => {
          if (button.textContent.trim().toLowerCase().includes(filterKeyword.toLowerCase())) {
            button.click();
          }
        });
      }
    }
  }, 500);

  updateInputField(); // Update filter when page loads
});
