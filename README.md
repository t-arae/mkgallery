

# Mkgallery Extension For Quarto

`mkgallery` shortcode makes easy to embed images in the specified
directory.

## Installing

To use `mkgallery` extension in your Quarto project, run this command in
terminal at the project’s working directory. This will install the
extension under the `_extensions` subdirectory.

``` bash
quarto add t-arae/mkgallery
```

and then, apply blogcard filter by adding this lines into your yaml
header of .qmd file.

``` yaml
filters:
  - t-arae/mkgallery
```

## Using

To make a card by blogcard shortcode, write shortcode directive like
this.

{{< mkgallery imgs >}}

## Example

Here is the source code for a minimal example:
[example.qmd](articles/example.qmd).
