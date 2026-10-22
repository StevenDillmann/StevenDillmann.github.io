// get the ninja-keys element
const ninja = document.querySelector('ninja-keys');

// add the home and posts menu items
ninja.data = [{
    id: "nav-about",
    title: "about",
    section: "Navigation",
    handler: () => {
      window.location.href = "/";
    },
  },{id: "nav-publications",
          title: "publications",
          description: "",
          section: "Navigation",
          handler: () => {
            window.location.href = "/publications/";
          },
        },{id: "nav-cv",
          title: "cv",
          description: "",
          section: "Navigation",
          handler: () => {
            window.location.href = "/cv/";
          },
        },{id: "post-google-gemini-updates-flash-1-5-gemma-2-and-project-astra",
        
          title: 'Google Gemini updates: Flash 1.5, Gemma 2 and Project Astra <svg width="1.2rem" height="1.2rem" top=".5rem" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg"><path d="M17 13.5v6H5v-12h6m3-3h6v6m0-6-9 9" class="icon_svg-stroke" stroke="#999" stroke-width="1.5" fill="none" fill-rule="evenodd" stroke-linecap="round" stroke-linejoin="round"></path></svg>',
        
        description: "We’re sharing updates across our Gemini family of models and a glimpse of Project Astra, our vision for the future of AI assistants.",
        section: "Posts",
        handler: () => {
          
            window.open("https://blog.google/technology/ai/google-gemini-update-flash-ai-assistant-io-2024/", "_blank");
          
        },
      },{id: "post-displaying-external-posts-on-your-al-folio-blog",
        
          title: 'Displaying External Posts on Your al-folio Blog <svg width="1.2rem" height="1.2rem" top=".5rem" viewBox="0 0 40 40" xmlns="http://www.w3.org/2000/svg"><path d="M17 13.5v6H5v-12h6m3-3h6v6m0-6-9 9" class="icon_svg-stroke" stroke="#999" stroke-width="1.5" fill="none" fill-rule="evenodd" stroke-linecap="round" stroke-linejoin="round"></path></svg>',
        
        description: "",
        section: "Posts",
        handler: () => {
          
            window.open("https://medium.com/@al-folio/displaying-external-posts-on-your-al-folio-blog-b60a1d241a0a?source=rss-17feae71c3c4------2", "_blank");
          
        },
      },{id: "news-graduated-from-imperial-college-london-with-an-meng-in-aeronautics-with-spacecraft-engineering-receiving-the-head-of-department-award",
          title: 'Graduated from Imperial College London with an MEng in Aeronautics with Spacecraft Engineering,...',
          description: "",
          section: "News",},{id: "news-graduated-from-the-university-of-cambridge-with-an-mphil-in-data-intensive-science",
          title: 'Graduated from the University of Cambridge with an MPhil in Data Intensive Science....',
          description: "",
          section: "News",},{id: "news-started-a-phd-in-computational-mathematics-at-stanford-university",
          title: 'Started a PhD in Computational Mathematics at Stanford University.',
          description: "",
          section: "News",},{id: "news-discovery-of-xrt-200515-a-new-extragalactic-fast-x-ray-transient-featured-by-the-royal-astronomical-society-space-com-phys-org-and-scitechdaily",
          title: 'Discovery of XRT 200515, a new extragalactic fast X-ray transient, featured by the...',
          description: "",
          section: "News",},{id: "news-honored-to-receive-the-stanford-interdisciplinary-graduate-fellowship-sigf",
          title: 'Honored to receive the Stanford Interdisciplinary Graduate Fellowship (SIGF).',
          description: "",
          section: "News",},{id: "news-released-terminal-bench-science-0-1-a-benchmark-to-evaluate-ai-agents-on-scientific-research-workflows",
          title: 'Released Terminal-Bench-Science 0.1, a benchmark to evaluate AI agents on scientific research workflows....',
          description: "",
          section: "News",},{id: "news-honored-to-be-named-a-stanford-hai-data-science-scholar",
          title: 'Honored to be named a Stanford HAI Data Science Scholar.',
          description: "",
          section: "News",},{
        id: 'social-discord',
        title: 'Discord',
        section: 'Socials',
        handler: () => {
          window.open("https://discord.com/users/838241195473502219", "_blank");
        },
      },{
        id: 'social-stanford_profile',
        title: 'Stanford_profile',
        section: 'Socials',
        handler: () => {
          window.open("https://profiles.stanford.edu/steven-dillmann", "_blank");
        },
      },{
        id: 'social-email',
        title: 'email',
        section: 'Socials',
        handler: () => {
          window.open("mailto:%73%74%65%76%65%6E%64%69@%73%74%61%6E%66%6F%72%64.%65%64%75", "_blank");
        },
      },{
        id: 'social-linkedin',
        title: 'LinkedIn',
        section: 'Socials',
        handler: () => {
          window.open("https://www.linkedin.com/in/stevendillmann", "_blank");
        },
      },{
        id: 'social-x',
        title: 'X',
        section: 'Socials',
        handler: () => {
          window.open("https://twitter.com/StevenDillmann", "_blank");
        },
      },{
        id: 'social-discord_username',
        title: 'Discord_username',
        section: 'Socials',
        handler: () => {
          window.open("", "_blank");
        },
      },{
        id: 'social-letterboxd_username',
        title: 'Letterboxd_username',
        section: 'Socials',
        handler: () => {
          window.open("", "_blank");
        },
      },{
        id: 'social-github',
        title: 'GitHub',
        section: 'Socials',
        handler: () => {
          window.open("https://github.com/StevenDillmann", "_blank");
        },
      },{
        id: 'social-orcid',
        title: 'ORCID',
        section: 'Socials',
        handler: () => {
          window.open("https://orcid.org/0000-0002-4773-1463", "_blank");
        },
      },{
        id: 'social-scholar',
        title: 'Google Scholar',
        section: 'Socials',
        handler: () => {
          window.open("https://scholar.google.com/citations?user=mwC8O9sAAAAJ", "_blank");
        },
      },{
      id: 'light-theme',
      title: 'Change theme to light',
      description: 'Change the theme of the site to Light',
      section: 'Theme',
      handler: () => {
        setThemeSetting("light");
      },
    },
    {
      id: 'dark-theme',
      title: 'Change theme to dark',
      description: 'Change the theme of the site to Dark',
      section: 'Theme',
      handler: () => {
        setThemeSetting("dark");
      },
    },
    {
      id: 'system-theme',
      title: 'Use system default theme',
      description: 'Change the theme of the site to System Default',
      section: 'Theme',
      handler: () => {
        setThemeSetting("system");
      },
    },];
