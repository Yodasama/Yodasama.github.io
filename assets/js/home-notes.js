(function () {
  function setAccordionState(toggle, menu, expanded) {
    toggle.setAttribute("aria-expanded", expanded ? "true" : "false");
    toggle.classList.toggle("home-nav__item--open", expanded);
    menu.hidden = !expanded;

    var chevron = toggle.querySelector(".home-nav__chevron");
    if (chevron) {
      chevron.textContent = expanded ? "⌄" : "›";
    }
  }

  function setActiveFilter(shell, activeButton) {
    var filterControls = Array.prototype.slice.call(shell.querySelectorAll("[data-home-filter]"));
    var accordionToggles = Array.prototype.slice.call(shell.querySelectorAll("[data-home-accordion]"));

    filterControls.forEach(function (control) {
      var isActive = control === activeButton;
      control.classList.toggle("home-nav__item--active", isActive && control.classList.contains("home-nav__item"));
      control.classList.toggle("home-submenu__item--active", isActive && control.classList.contains("home-submenu__item"));

      if (isActive) {
        control.setAttribute("aria-current", "page");
      } else {
        control.removeAttribute("aria-current");
      }
    });

    accordionToggles.forEach(function (toggle) {
      toggle.classList.remove("home-nav__item--open");
    });

    var activeGroup = activeButton.closest(".home-nav__group");
    if (activeGroup) {
      var activeToggle = activeGroup.querySelector("[data-home-accordion]");
      if (activeToggle) {
        activeToggle.classList.add("home-nav__item--open");
      }
    }
  }

  function showPanel(shell, key) {
    var panels = Array.prototype.slice.call(shell.querySelectorAll("[data-home-panel]"));

    panels.forEach(function (panel) {
      var isActive = panel.getAttribute("data-home-panel") === key;
      panel.hidden = !isActive;
    });
  }

  function initHomeDashboard() {
    var shell = document.querySelector("[data-home-shell]");
    if (!shell) {
      return;
    }

    var accordionToggles = Array.prototype.slice.call(shell.querySelectorAll("[data-home-accordion]"));
    accordionToggles.forEach(function (toggle) {
      var key = toggle.getAttribute("data-home-accordion");
      var menu = shell.querySelector('[data-home-menu="' + key + '"]');
      if (!menu) {
        return;
      }

      toggle.addEventListener("click", function () {
        var expanded = toggle.getAttribute("aria-expanded") === "true";
        setAccordionState(toggle, menu, !expanded);
      });
    });

    var filterControls = Array.prototype.slice.call(shell.querySelectorAll("[data-home-filter]"));
    filterControls.forEach(function (control) {
      control.addEventListener("click", function () {
        var key = control.getAttribute("data-home-filter");

        setActiveFilter(shell, control);
        showPanel(shell, key);
      });
    });

  }

  function initArticleToc() {
    var panels = Array.prototype.slice.call(document.querySelectorAll("[data-article-toc-panel]"));

    panels.forEach(function (panel) {
      var content = panel.querySelector("[data-article-toc-content]");
      if (!content) {
        return;
      }

      var expandableItems = Array.prototype.slice.call(content.querySelectorAll("li")).filter(function (item) {
        var children = Array.prototype.slice.call(item.children);
        var directLink = children.find(function (child) {
          return child.tagName && child.tagName.toLowerCase() === "a";
        });
        var directSubmenu = children.find(function (child) {
          return child.tagName && child.tagName.toLowerCase() === "ul";
        });

        if (!directLink || !directSubmenu) {
          return false;
        }

        item.classList.add("article-toc-panel__item--has-children");
        directLink.setAttribute("aria-expanded", "false");
        directSubmenu.hidden = true;
        return true;
      });

      function setOpen(targetItem, open) {
        var children = Array.prototype.slice.call(targetItem.children);
        var link = children.find(function (child) {
          return child.tagName && child.tagName.toLowerCase() === "a";
        });
        var submenu = children.find(function (child) {
          return child.tagName && child.tagName.toLowerCase() === "ul";
        });

        if (!link || !submenu) {
          return;
        }

        targetItem.classList.toggle("article-toc-panel__item--open", open);
        link.setAttribute("aria-expanded", open ? "true" : "false");
        submenu.hidden = !open;
      }

      expandableItems.forEach(function (item, index) {
        var link = Array.prototype.slice.call(item.children).find(function (child) {
          return child.tagName && child.tagName.toLowerCase() === "a";
        });

        if (index === 0) {
          setOpen(item, true);
        }

        link.addEventListener("click", function (event) {
          event.preventDefault();

          var willOpen = !item.classList.contains("article-toc-panel__item--open");
          expandableItems.forEach(function (candidate) {
            setOpen(candidate, false);
          });
          setOpen(item, willOpen);
        });
      });
    });
  }

  function initPageInteractions() {
    initHomeDashboard();
    initArticleToc();
  }

  if (document.readyState === "loading") {
    document.addEventListener("DOMContentLoaded", initPageInteractions);
  } else {
    initPageInteractions();
  }
})();
