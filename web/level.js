(function () {
  const home = document.body.dataset.home || "";
  const up = document.body.dataset.up || "";

  function go(url) {
    if (url) location.href = url;
  }

  function goHome() {
    go(home);
  }

  function goUp() {
    if (typeof window.onLevelUp === "function" && window.onLevelUp()) return;
    go(up);
  }

  const slot = document.getElementById("levelNav");
  if (slot) {
    const canUp = Boolean(up) || typeof window.onLevelUp === "function";
    slot.className = "level-nav";
    slot.innerHTML =
      '<button type="button" data-nav="home"' + (home ? "" : " disabled") + '>首页 <kbd>Home</kbd></button>' +
      '<button type="button" data-nav="up"' + (canUp ? "" : " disabled") + '>上一级 <kbd>Esc</kbd></button>';
  }

  document.addEventListener("click", (e) => {
    const button = e.target.closest("[data-nav]");
    if (!button || button.disabled) return;
    if (button.dataset.nav === "home") goHome();
    if (button.dataset.nav === "up") goUp();
  });

  document.addEventListener("keydown", (e) => {
    if (e.metaKey || e.ctrlKey || e.altKey) return;
    const tag = (e.target && e.target.tagName || "").toLowerCase();
    if (tag === "input" || tag === "textarea") return;
    if (e.key === "Home") {
      e.preventDefault();
      goHome();
    } else if (e.key === "Escape") {
      e.preventDefault();
      goUp();
    }
  });
})();
