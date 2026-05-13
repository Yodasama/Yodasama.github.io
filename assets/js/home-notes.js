(function () {
  var maxVisibleCards = 6;

  function setCardVisibility(cards, topic) {
    var visibleCount = 0;

    cards.forEach(function (card) {
      var tags = (card.getAttribute("data-tags") || "").toLowerCase().split(/\s+/);
      var matchesTopic = !topic || tags.indexOf(topic) !== -1;
      var shouldShow = matchesTopic && visibleCount < maxVisibleCards;

      card.hidden = !shouldShow;
      if (shouldShow) {
        visibleCount += 1;
      }
    });
  }

  function setActiveButton(buttons, activeButton) {
    buttons.forEach(function (button) {
      var isActive = button === activeButton;
      button.classList.toggle("home-topic--active", isActive);
      button.setAttribute("aria-pressed", isActive ? "true" : "false");
    });
  }

  document.addEventListener("DOMContentLoaded", function () {
    var grid = document.querySelector("[data-home-note-grid]");
    if (!grid) {
      return;
    }

    var cards = Array.prototype.slice.call(grid.querySelectorAll("[data-note-card]"));
    var buttons = Array.prototype.slice.call(document.querySelectorAll(".home-topic[data-topic]"));

    setCardVisibility(cards, "");

    buttons.forEach(function (button) {
      button.addEventListener("click", function () {
        var isActive = button.getAttribute("aria-pressed") === "true";
        var topic = isActive ? "" : (button.getAttribute("data-topic") || "").toLowerCase();

        setActiveButton(buttons, isActive ? null : button);
        setCardVisibility(cards, topic);
      });
    });
  });
})();
