import SimpleMDE from "simplemde";
import "simplemde/dist/simplemde.min.css";

document.addEventListener("turbolinks:load", () => {
  const element = document.querySelector(".js-simplemde");
  element && new SimpleMDE({ element });
});
