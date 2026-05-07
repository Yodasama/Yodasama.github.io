(function () {
  function normalize(value) {
    return (value || "").toString().toLowerCase();
  }

  function getQuery() {
    return new URLSearchParams(window.location.search).get("q") || "";
  }

  function matchPost(post, query) {
    const tags = Array.isArray(post.tags) ? post.tags.join(" ") : "";
    const haystack = normalize([post.title, post.summary, post.content, tags].join(" "));
    return haystack.includes(normalize(query));
  }

  function renderResults(container, status, posts, query) {
    container.innerHTML = "";

    if (!query.trim()) {
      status.textContent = "Enter keywords to search posts.";
      return;
    }

    const results = posts.filter(function (post) {
      return matchPost(post, query);
    });

    status.textContent = results.length
      ? results.length + " result" + (results.length === 1 ? "" : "s") + " found."
      : "No matching posts.";

    results.forEach(function (post) {
      const item = document.createElement("article");
      item.className = "site-search__result";

      const link = document.createElement("a");
      link.className = "site-search__result-title";
      link.href = post.url;
      link.textContent = post.title;

      const meta = document.createElement("div");
      meta.className = "site-search__result-meta";
      meta.textContent = post.date || "";

      if (Array.isArray(post.tags)) {
        post.tags.forEach(function (tag) {
          const tagEl = document.createElement("span");
          tagEl.className = "site-search__tag";
          tagEl.textContent = "#" + tag;
          meta.appendChild(tagEl);
        });
      }

      const summary = document.createElement("p");
      summary.className = "site-search__result-summary";
      summary.textContent = post.summary || "";

      item.appendChild(link);
      item.appendChild(meta);
      item.appendChild(summary);
      container.appendChild(item);
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    const search = document.querySelector(".site-search");
    if (!search) {
      return;
    }

    const input = search.querySelector(".site-search__input");
    const status = search.querySelector(".site-search__status");
    const results = search.querySelector(".site-search__results");
    const indexUrl = search.getAttribute("data-index-url") || "/index.json";
    const initialQuery = getQuery();

    input.value = initialQuery;
    status.textContent = "Loading search index...";

    fetch(indexUrl)
      .then(function (response) {
        if (!response.ok) {
          throw new Error("Could not load search index.");
        }
        return response.json();
      })
      .then(function (posts) {
        renderResults(results, status, posts, input.value);
        input.addEventListener("input", function () {
          renderResults(results, status, posts, input.value);
          const url = new URL(window.location.href);
          if (input.value.trim()) {
            url.searchParams.set("q", input.value);
          } else {
            url.searchParams.delete("q");
          }
          window.history.replaceState({}, "", url);
        });
      })
      .catch(function () {
        status.textContent = "Search is temporarily unavailable.";
      });
  });
})();
