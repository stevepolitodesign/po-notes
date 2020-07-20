import SimpleMDE from "simplemde";
import "simplemde/dist/simplemde.min.css";

document.addEventListener("turbolinks:load", () => {
  const element = document.querySelector(".js-simplemde");
  if (!element) return;
  const simplemde = new SimpleMDE({
      element,
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
    
    const wrapper = simplemde.codemirror.display.wrapper;
    wrapper && wrapper.classList.add("prose", "prose-lg", "max-w-none")
});