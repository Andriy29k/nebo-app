(function () {
  const STORAGE_KEY = "catalog_api_base";

  function metaApiBase() {
    var el = document.querySelector('meta[name="catalog-api-base"]');
    return el && el.getAttribute("content") ? el.getAttribute("content").trim() : "";
  }

  function getApiBase() {
    var fromStorage = localStorage.getItem(STORAGE_KEY);
    if (fromStorage) return fromStorage.replace(/\/$/, "");
    var meta = metaApiBase();
    if (meta) return meta.replace(/\/$/, "");
    return window.location.origin;
  }

  function setStatus(el, text, kind) {
    el.textContent = text || "";
    el.classList.remove("is-error", "is-ok");
    if (kind === "error") el.classList.add("is-error");
    if (kind === "ok") el.classList.add("is-ok");
  }

  function apiUrl(path) {
    return getApiBase() + path;
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
      var hint =
        " Перевірте: поле API порожнє (nginx), або http://… без https для прямого Flask; скиньте збережений URL кнопкою нижче.";
      setStatus(statusEl, "Помилка: " + e.message + "." + hint, "error");
    }
  }

  document.addEventListener("DOMContentLoaded", function () {
    var apiInput = document.getElementById("apiBase");
    var saveBtn = document.getElementById("saveApi");
    var resetApiBtn = document.getElementById("resetApi");
    var form = document.getElementById("addForm");
    var itemName = document.getElementById("itemName");
    var refreshBtn = document.getElementById("refreshBtn");
    var statusEl = document.getElementById("status");
    var listEl = document.getElementById("itemList");

    apiInput.value = localStorage.getItem(STORAGE_KEY) || metaApiBase() || "";
    syncFooterLinks();

    saveBtn.addEventListener("click", function () {
      var v = apiInput.value.trim().replace(/\/$/, "");
      if (v) localStorage.setItem(STORAGE_KEY, v);
      else localStorage.removeItem(STORAGE_KEY);
      setStatus(statusEl, "URL збережено в цьому браузері.", "ok");
      syncFooterLinks();
      fetchItems(statusEl, listEl);
    });

    if (resetApiBtn) {
      resetApiBtn.addEventListener("click", function () {
        localStorage.removeItem(STORAGE_KEY);
        apiInput.value = "";
        setStatus(statusEl, "Використовується той самий хост (nginx → бекенд).", "ok");
        syncFooterLinks();
        fetchItems(statusEl, listEl);
      });
    }

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
