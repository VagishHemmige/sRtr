// Adds a plain-text label above each page title saying what kind of page it
// is: "Guide · <its navbar group>" on articles, "Function reference" or
// "Dataset reference" on help pages (#287). Index pages, the home page and
// the changelog get no label. Without JavaScript, pages look as before.
document.addEventListener("DOMContentLoaded", function () {
  var header = document.querySelector("main .page-header");
  var title = header && header.querySelector("h1");
  if (!title) return;

  var path = window.location.pathname;
  var page = path.split("/").pop() || "index.html";
  if (page === "index.html" || page === "") return;

  var label = null;
  if (/\/reference\/[^/]+\.html$/.test(path)) {
    // Help pages for datasets have a "Format" section; functions do not.
    label = document.getElementById("format") ? "Dataset reference" : "Function reference";
  } else if (/\/articles\/[^/]+\.html$/.test(path)) {
    label = "Guide";
    // The navbar group that lists this page, if any.
    var links = document.querySelectorAll(".navbar .dropdown-menu a.dropdown-item");
    for (var i = 0; i < links.length; i++) {
      var href = (links[i].getAttribute("href") || "").split("#")[0];
      if (href.split("/").pop() === page) {
        var toggle = links[i].closest(".dropdown").querySelector(".dropdown-toggle");
        var group = toggle ? toggle.textContent.trim() : "";
        if (group === "Contribute") label = "Contribute";
        else if (group) label = "Guide · " + group;
        break;
      }
    }
  }
  if (!label) return;

  var p = document.createElement("p");
  p.className = "srtr-page-type";
  p.textContent = label;
  title.parentNode.insertBefore(p, title);
});
