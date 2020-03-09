import ClipboardJS from 'clipboard';

document.addEventListener("turbolinks:load", () => {
    new ClipboardJS('.js-copy-to-clipboard');
});
