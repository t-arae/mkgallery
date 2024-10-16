

# `mkgallery` extension for Quarto <a href="https://github.com/t-arae/mkgallery/" alt="mkgallery"><img src="logo.png" alt="mkgallery logo" align="right" width="120"/></a>

`mkgallery`, a quarto shortcode extension, makes easy to put images in
the specified directory on the document.

## Instalation

To use the mkgallery extension in your Quarto project, follow these
steps:

1.  Run the following command in your terminal within the project’s
    working directory. This will install the extension under the
    `_extensions` subdirectory:

``` bash
quarto add t-arae/mkgallery
```

2.  Once installed, apply the `mkgallery` filter by adding the following
    lines to the YAML header of your `.qmd` file:

``` yaml
filters:
  - t-arae/mkgallery
```

## Using the shortcode

To display images from the `articles/imgs/` directory in your Quarto
document using the `mkgallery` shortcode, use the following syntax:

``` markdown
{{< mkgallery articles/imgs >}}
```

This will embed all images from the `articles/imgs/` directory onto your
document.

<div style="display: flex; gap: 20px; overflow-x: auto;">

<div style="flex: 0 0 calc(33% - 20px); max-width: calc(33% - 20px);">

<img src="articles/imgs/beko.jpeg" title="beko.jpeg" class="lightbox"
data-group="all" alt="beko.jpeg" />

<div id="beko.jpeg"
style="overflow: hidden; text-overflow: ellipsis; max-width: 100%;">

beko.jpeg

</div>

</div>

<div style="flex: 0 0 calc(33% - 20px); max-width: calc(33% - 20px);">

<img src="articles/imgs/beko.png" title="beko.png" class="lightbox"
data-group="all" alt="beko.png" />

<div id="beko.png"
style="overflow: hidden; text-overflow: ellipsis; max-width: 100%;">

beko.png

</div>

</div>

<div style="flex: 0 0 calc(33% - 20px); max-width: calc(33% - 20px);">

<img src="articles/imgs/beko_blur.png" title="beko_blur.png"
class="lightbox" data-group="all" alt="beko_blur.png" />

<div id="beko_blur.png"
style="overflow: hidden; text-overflow: ellipsis; max-width: 100%;">

beko_blur.png

</div>

</div>

<div style="flex: 0 0 calc(33% - 20px); max-width: calc(33% - 20px);">

<img src="articles/imgs/beko_gray.png" title="beko_gray.png"
class="lightbox" data-group="all" alt="beko_gray.png" />

<div id="beko_gray.png"
style="overflow: hidden; text-overflow: ellipsis; max-width: 100%;">

beko_gray.png

</div>

</div>

<div style="flex: 0 0 calc(33% - 20px); max-width: calc(33% - 20px);">

<img src="articles/imgs/beko_half.jpg" title="beko_half.jpg"
class="lightbox" data-group="all" alt="beko_half.jpg" />

<div id="beko_half.jpg"
style="overflow: hidden; text-overflow: ellipsis; max-width: 100%;">

beko_half.jpg

</div>

</div>

<div style="flex: 0 0 calc(33% - 20px); max-width: calc(33% - 20px);">

<img src="articles/imgs/beko_noise.png" title="beko_noise.png"
class="lightbox" data-group="all" alt="beko_noise.png" />

<div id="beko_noise.png"
style="overflow: hidden; text-overflow: ellipsis; max-width: 100%;">

beko_noise.png

</div>

</div>

<div style="flex: 0 0 calc(33% - 20px); max-width: calc(33% - 20px);">

<img src="articles/imgs/beko_one_fourth.jpg" title="beko_one_fourth.jpg"
class="lightbox" data-group="all" alt="beko_one_fourth.jpg" />

<div id="beko_one_fourth.jpg"
style="overflow: hidden; text-overflow: ellipsis; max-width: 100%;">

beko_one_fourth.jpg

</div>

</div>

</div>

## Example

You can find the source code for several examples of the `mkgallery`
shortcode usage at the following link:
[example.qmd](https://github.com/t-arae/mkgallery/blob/main/articles/example.qmd).

To see the rendered version of this example, visit the following link:
[here](https://t-arae.quarto.pub/mkgallery/).
