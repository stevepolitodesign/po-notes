import ClipboardJS from "clipboard";

document.addEventListener("turbolinks:load", () => {
  const clipBoardButton = document.querySelector(".js-copy-to-clipboard");
  clipBoardButton && new ClipboardJS(clipBoardButton);
});
