

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

## Example

You can find the source code for several examples of the `mkgallery`
shortcode usage at the following link:
[example.qmd](https://github.com/t-arae/mkgallery/blob/main/articles/example.qmd).

To see the rendered version of this example, visit the following link:
[here](https://t-arae.quarto.pub/mkgallery/).
