import SimpleMDE from "simplemde";

document.addEventListener("turbolinks:load", () => {
  const element = document.querySelector(".js-simplemde");
  if (!element) {
    return;
  }
  const simplemde = new SimpleMDE({ element });
});
