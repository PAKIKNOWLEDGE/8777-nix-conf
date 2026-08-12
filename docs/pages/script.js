/* docs/script.js — 复制按钮 + 侧栏 TOC 滚动高亮 */
(function () {
  "use strict";

  /* ---- 代码块复制 ---- */
  document.querySelectorAll(".cmd-copy").forEach(function (btn) {
    btn.addEventListener("click", function () {
      var code = btn.closest(".cmd").querySelector("pre code");
      if (!code) return;
      var text = code.innerText;
      function done() {
        btn.textContent = "已复制 ✓";
        btn.classList.add("copied");
        setTimeout(function () {
          btn.textContent = "复制";
          btn.classList.remove("copied");
        }, 1600);
      }
      if (navigator.clipboard && navigator.clipboard.writeText) {
        navigator.clipboard.writeText(text).then(done, function () { fallback(text); done(); });
      } else {
        fallback(text);
        done();
      }
    });
  });

  function fallback(text) {
    var ta = document.createElement("textarea");
    ta.value = text;
    ta.style.position = "fixed";
    ta.style.opacity = "0";
    document.body.appendChild(ta);
    ta.select();
    try { document.execCommand("copy"); } catch (e) { /* noop */ }
    document.body.removeChild(ta);
  }

  /* ---- TOC 滚动高亮 ---- */
  var tocLinks = Array.prototype.slice.call(document.querySelectorAll(".toc a[href^='#']"));
  if (tocLinks.length && "IntersectionObserver" in window) {
    var map = {};
    tocLinks.forEach(function (a) {
      var sec = document.querySelector(a.getAttribute("href"));
      if (sec) map[sec.id] = a;
    });
    var ids = Object.keys(map);
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (entry.isIntersecting) setActive(entry.target.id);
      });
    }, { rootMargin: "-15% 0px -70% 0px" });
    ids.forEach(function (id) { observer.observe(document.getElementById(id)); });
  }

  function setActive(id) {
    if (!map[id]) return;
    tocLinks.forEach(function (a) { a.classList.remove("active"); });
    map[id].classList.add("active");
  }
})();
