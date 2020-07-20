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
    
    console.log(simplemde.codemirror)
    const wrapper = simplemde.codemirror.display.wrapper;
    const preview = simplemde.codemirror.display.wrapper.nextElementSibling;
    wrapper && wrapper.classList.add("prose", "prose-lg", "max-w-none")
    preview && preview.classList.add("prose", "prose-lg", "max-w-none")
});