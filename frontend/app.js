(function () {
  function apiUrl(path) {
    return window.location.origin.replace(/\/$/, "") + path;
  }

  function setStatus(el, text, kind) {
    el.textContent = text || "";
    el.classList.remove("is-error", "is-ok");
    if (kind === "error") el.classList.add("is-error");
    if (kind === "ok") el.classList.add("is-ok");
  }

  function syncFooterLinks() {
    var h = document.getElementById("footerHealth");
    var r = document.getElementById("footerReady");
    if (h) h.href = apiUrl("/health");
    if (r) r.href = apiUrl("/ready");
  }

  async function fetchItems(statusEl, listEl) {
    setStatus(statusEl, "Завантаження…", null);
    listEl.innerHTML = "";
    try {
      var res = await fetch(apiUrl("/items"));
      if (!res.ok) throw new Error("HTTP " + res.status);
      var data = await res.json();
      if (!Array.isArray(data) || data.length === 0) {
        setStatus(statusEl, "Список порожній. Додайте позицію вище.", "ok");
        return;
      }
      data.forEach(function (row) {
        var li = document.createElement("li");
        var name = document.createElement("span");
        name.className = "item-name";
        name.textContent = row.name;
        var meta = document.createElement("span");
        meta.className = "item-meta";
        meta.textContent = "#" + row.id + " · " + (row.created_at || "").slice(0, 19).replace("T", " ");
        li.appendChild(name);
        li.appendChild(meta);
        listEl.appendChild(li);
      });
      setStatus(statusEl, "Завантажено позицій: " + data.length, "ok");
    } catch (e) {
      setStatus(
        statusEl,
        "Помилка: " + e.message + ". Перевірте nginx і бекенд на цьому ж хості.",
        "error"
      );
    }
  }

  document.addEventListener("DOMContentLoaded", function () {
    try {
      localStorage.removeItem("catalog_api_base");
    } catch (ignore) {}

    var form = document.getElementById("addForm");
    var itemName = document.getElementById("itemName");
    var refreshBtn = document.getElementById("refreshBtn");
    var statusEl = document.getElementById("status");
    var listEl = document.getElementById("itemList");

    syncFooterLinks();

    refreshBtn.addEventListener("click", function () {
      fetchItems(statusEl, listEl);
    });

    form.addEventListener("submit", async function (ev) {
      ev.preventDefault();
      var name = itemName.value.trim();
      if (!name) return;
      setStatus(statusEl, "Збереження…", null);
      try {
        var res = await fetch(apiUrl("/items"), {
          method: "POST",
          headers: { "Content-Type": "application/json" },
          body: JSON.stringify({ name: name }),
        });
        if (!res.ok) {
          var errBody = await res.text();
          throw new Error(res.status + (errBody ? ": " + errBody.slice(0, 80) : ""));
        }
        itemName.value = "";
        setStatus(statusEl, "Позицію додано.", "ok");
        await fetchItems(statusEl, listEl);
      } catch (e) {
        setStatus(statusEl, "Помилка: " + e.message, "error");
      }
    });

    fetchItems(statusEl, listEl);
  });
})();
