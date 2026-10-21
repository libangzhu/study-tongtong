(function () {
  const name = document.body.dataset.subject;
  const total = Number(document.body.dataset.units || 0);
  const ready = {};
  (document.body.dataset.ready || "").split(",").filter(Boolean).forEach((pair) => {
    const parts = pair.split(":");
    ready[Number(parts[0])] = parts.slice(1).join(":");
  });
  const box = document.getElementById("units");
  if (!box) return;
  const html = [];
  for (let n = 1; n <= total; n++) {
    const href = ready[n];
    html.push(href
      ? `<a href="${href}" aria-label="${name}第${n}单元">${n}</a>`
      : `<span aria-label="${name}第${n}单元，还没有题目">${n}</span>`);
  }
  box.innerHTML = html.join("");
})();
