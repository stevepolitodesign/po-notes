import Tagify from "@yaireo/tagify";
import "@yaireo/tagify/src/tagify.scss";

document.addEventListener("turbolinks:load", () => {
  const tagListInput = document.querySelector(".js-tag-list");
  tagListInput && new Tagify(tagListInput);
});
