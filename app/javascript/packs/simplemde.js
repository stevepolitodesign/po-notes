import SimpleMDE from "simplemde";

document.addEventListener("turbolinks:load", () => {
  const element = document.querySelector(".js-simplemde");
  element && new SimpleMDE({ element });
});
