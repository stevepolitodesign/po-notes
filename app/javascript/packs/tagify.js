import Tagify from "@yaireo/tagify";
import "@yaireo/tagify/dist/tagify.css";

document.addEventListener("turbolinks:load", () => {
  const tagListInput = document.querySelector("#note_tag_list");
    tagListInput && new Tagify(tagListInput);
});
