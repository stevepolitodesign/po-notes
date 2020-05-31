import SimpleMDE from "simplemde";
import "simplemde/dist/simplemde.min.css";

document.addEventListener("turbolinks:load", () => {
  const element = document.querySelector(".js-simplemde");
  element &&
    new SimpleMDE({
      element,
      autosave: {
        enabled: true,
      },
      toolbar: [
        "bold",
        "italic",
        "strikethrough",
        "|",
        "heading",
        "heading-smaller",
        "heading-bigger",
        "heading-1",
        "heading-2",
        "heading-3",
        "|",
        "code",
        "quote",
        "unordered-list",
        "ordered-list",
        "|",
        "clean-block",
        "link",
        "image",
        "table",
        "horizontal-rule",
        "|",
        "preview",
        "side-by-side",
        "fullscreen",
        "|",
        "guide",
      ],
    });
});
