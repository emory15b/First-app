# Your own pictures go here

The Freeze Dried Apples website is a static site. To use your own photos,
drop image files into this folder (`LadyCrisp/Backend/public/images/`).
No upload UI or database is involved — the Express backend serves anything
in `public/` directly, so a file placed here is instantly live.

## Supported spots (use these exact file names)

| File name (in this folder) | Where it shows | Recommended size |
| --- | --- | --- |
| `product.jpg` | Main hero product photo (home page, top-left frame) | ~1000 × 1250 px (4:5 portrait) |
| `about.jpg`   | Background photo behind the "About" banner | ~1200 × 800 px (landscape) |

- `.jpg`, `.png`, and `.webp` all work. If you use a different extension than
  `.jpg`, update the `src` in `public/index.html` (search for `images/product`).
- If a file is **missing**, the site automatically falls back to the built-in
  styled placeholder — nothing breaks.

## Steps

1. Copy your image into this folder and name it `product.jpg` (and optionally `about.jpg`).
2. If the site is running, just refresh the browser at `http://localhost:4242/`.
   (Static files are served fresh — no server restart needed.)
3. To publish the change, commit the image file(s) to the repo.

## Want an in-browser upload form instead?

This folder-based approach is the simplest for a fixed storefront. If you'd
rather upload images through the website itself (a drag-and-drop form that
saves files on the server), that requires a small backend upload endpoint —
ask and it can be added.
