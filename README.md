# webster

Generate a PDF file from a URL (rendered by WebKit).

## Important

This package has been superseded by the following packages and will no longer be updated:

* https://github.com/aaronland/webster-cli
* https://github.com/aaronland/swift-webster

## Example

```
$> swift build
[3/3] Linking webster

$> ./.build/debug/webster -h
USAGE: webster <url> [--dpi <dpi>] [--width <width>] [--height <height>] [--margin <margin>] [--filename <filename>]

ARGUMENTS:
  <url>                   The URL you want to generate a PDF from. 

OPTIONS:
  --dpi <dpi>             The DPI (dots per inch) of your output document. (default: 72.0)
  --width <width>         The width (in inches) of your document. (default: 8.5)
  --height <height>       The height (in inches) of your document. (default: 11.0)
  --margin <margin>       The margin (in inches) for each page in your document. (default: 1.0)
  --filename <filename>   The path where your PDF document will be created. Default is 'webster.pdf' in the current user's Documents folder. 
  -h, --help              Show help information.
```

## Credits

This build's on @msmollin's original [webster](https://github.com/msmollin/webster) and currently exists as a separate project because it is full of Swift Package Manager -isms and I am not sure what the best way to create a PR is yet.
