---
name: add-photos-to-albums
description: Add new album photos by copying images into `images/<album>/` and updating the UI image filename lists so they render in the carousel/lightbox. Use when the user asks to add photos to a specific album (e.g., "kids-ministry") and the UI must display them.
---

# Add Photos To Albums

## Goal

When the user provides (or points to) a folder of photos for an album (like `kids-ministry`), this skill will:
1. Identify where the album UI gets its image filenames.
2. Copy the new photos into the correct `images/<album>/` directory.
3. Rename them to the filenames the UI already expects (e.g., `gallery15.jpg`).
4. Update the album image list used by the carousel/lightbox (e.g., `galleryImages.kids` in `index.html`).
5. Verify the new image URLs resolve (files exist at the expected paths).

## How it was done (this repo)

### 1) Find the UI data source for the album

In this project, album rendering is driven by `index.html`.
The lightbox/carousels use a filename list like:

- `galleryImages.kids: [...]` (array of strings like `images/kids-ministry/gallery1.jpg`)

Because the UI uses these hardcoded paths, simply adding files to `images/kids-ministry/` is not enough unless the filename list includes them.

### 2) Determine what filenames the UI expects

For `kids`, `galleryImages.kids` was updated to include additional entries:

- `images/kids-ministry/gallery15.jpg` through `images/kids-ministry/gallery21.jpg`

The carousel preview/header also showed a hardcoded count initially ("8 Photos"), so it was updated to be dynamic by syncing the count with `galleryImages.kids.length`.

### 3) Copy and rename provided photos into the album folder

The photos were sourced from a local folder:

- `/Users/iliapavlov/Downloads/church/photo_old`

They were copied into:

- `images/kids-ministry/`

and renamed to the filenames that match the UI array entries:

- `gallery15.jpg` ... `gallery21.jpg`

### 4) Confirm the files exist at the referenced paths

After copying, the agent verifies that each expected file exists in `images/kids-ministry/` with the correct name.

Optionally, for quick confirmation, the agent can start a static server and `curl -I` one of the expected URLs (HTTP `200`) to confirm the path is reachable.

## What should be done next (repeatable checklist)

1. Ask the user:
   - Which album should be updated? (e.g., `kids-ministry`)
   - Where is the folder containing the new photos? (path)
   - Should photos be ordered as provided by the folder, or is there a preferred order?
2. Locate the album filename list in `index.html`:
   - Look for `galleryImages` and the relevant key (e.g., `kids`).
3. Decide the next available `gallery<N>.jpg` numbers:
   - Inspect `images/<album>/` to see the highest `gallery*.jpg` currently present.
4. Copy photos into the correct directory:
   - `images/<album>/gallery<N>.jpg`
5. Update the `galleryImages.<albumKey>` array to include every new `gallery<N>.jpg`.
6. Update any album header/overlay text that might be hardcoded (if present):
   - Prefer using `${images.length}` or `${galleryImages.<albumKey>.length}` so it stays correct.
7. Verify:
   - Each new referenced file exists.
   - (Optional) One `curl -I` check for a new image URL returns HTTP `200`.

## Notes / Constraints

- This UI relies on exact relative paths/filenames referenced in `galleryImages.<albumKey>`.
- File extensions matter for the hardcoded paths. If the UI references `.jpg`, ensure the destination filenames use `.jpg` (not `.JPG`), or update the UI paths accordingly.

