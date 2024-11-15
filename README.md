# UUID Tools


## ✅ Fully Typechecked

This library takes full advantage of Swift's type system to **guarantee** it works as expected.


## Formatting

This package introduces a new `UuidFormat` type, which enumerates various string formats which can losslessly represent a UUID in text.


### Standard (hyphen-separated hexadecimal)

> `.standard`
> `2D3FB6B6-090D-4FBD-8AC2-428DC536FFE8`

This is the format we all know and love, the canonical string representation of a UUID: 32 hexadecimal digits grouped into 5 hyphen-separated sections, with the first digit of the third section showing the UUID version.

This is what you get when you ask Foundation for a `uuidString`, and what it expects when it takes one in using `UUID.init(uuidString:)`. 


### Base 64

> `.base64`
> `LT+2tgkNT72KwkKNxTb/6A==`

This takes the byte-data of the UUID and converts it into a Base 64 string, plain and simple.

Just like all standard-format UUIDs are always going to be exactly 32 characters long, this will always be exactly 24 characters long, where the last 2 of those characters will always be the trailing equal sigs (`==`).

Since the last 2 characters are always the exact same, this library also offers a truncated Base 64 format.


### Truncated Base 64

> `.truncatedBase64`
> `LT+2tgkNT72KwkKNxTb/6A`

This is identical to the Base 64 output, but without the trailing `==`.

This is the format used by Apple's Photos app, as well as several other services.



## Formatting

If you have a `UUID` instance already and want to format it into a string, you can call `.format(as:)` on the UUID itself, or if you have a format instance already, you can call `.apply(to:)` on the format:

```swift
let uuid = UUID()
print(uuid.format(as: .standard)) // 4A28F874-AA90-4C49-9956-8BF939BD0338
print(UuidFormat.base64.apply(to: uuid)) // Sij4dKqQTEmZVov5Ob0DOA==
```



## Detecting a format

If you want to know what format a UUID string might be, you can pass that string to `UuidFormat.init(detectingFormatIn:)`. This will look through all known formats to find a match.

```swift
print(UuidFormat(detectingFormatIn: "sZaQsY3CTAWIIvxz6VWd4w")) // .truncatedBase64
print(UuidFormat(detectingFormatIn: "sZaQsY3CTAWIIvxz6VWd4w==")) // .base64
print(UuidFormat(detectingFormatIn: "B19690B1-8DC2-4C05-8822-FC73E9559DE3")) // .standard
```



## Parsing

If you have a string representing a UUID and want to parse it into a `UUID` instance, you can call `UUID.init(_:format:)` or `.parse(_:)` on a `UuidFormat` instance.

```swift
let uuidString = "glv4+p3nRtGgxqa+blVeng"
print(UUID(uuidString, .truncatedBase64)) // 825BF8FA-9DE7-46D1-A0C6-A6BE6E555E9E
print(UuidFormat.truncatedBase64.parse(uuidString)) // 825BF8FA-9DE7-46D1-A0C6-A6BE6E555E9E
```


### Parsing without knowing the format

Sometimes you don't know the format of the UUID string. In these situations, you can sacrifice performance to allow this library to detect that format and then parse as that. Simply use `UUID.init(_:)` or `UuidFormat.parse(_:)`.

> ⚠️ Performance Concern:
>
> > `O(n)`
>
> This is intentionally **not-performant!**
> This intentionally sacrifices performance to automatically parse a UUID string of unknown format.
>
> > **Providing a known format drastically improves performance to `O(1)`.**
>
> If you actually know the format of the UUID string, then provide it using `.parse(_:)` on `UuidForamt` instances or `UUID.init(_:format:)`.

```swift
let uuidString = "sZaQsY3CTAWIIvxz6VWd4w"
print(UUID(uuidString)) // B19690B1-8DC2-4C05-8822-FC73E9559DE3
print(UuidFormat.parse(uuidString)) // B19690B1-8DC2-4C05-8822-FC73E9559DE3
```



## Converting

If you just want to convert UUIDs from one UUID string format directly to another, you may use the convenience function `.convert(_:)` on `UuidFormat` instances.





# `kyuuid`

This package also ships as a binary executable to allow you to format, parse, and convert UUIDs from the command line.

## Converting


## Help output
```plain
% kyuuid --help
OVERVIEW: A utility for generating & formatting UUIDs.

This utility only generates the version of UUIDs that Swift's Foundation
library generates. When this utility was originally written (2024-05-30),
that's UUIDv4.

FORMATS:

This utility offers 3 different formatting options:

    standard:  the typical 5-segment hex-digit UUID string
        Example: 44F4626A-1144-4FC5-BDE8-F94D2BE0F10F

    base64:  a Base64-encoded form of the raw bits of the UUID
        Example: RPRiahFET8W96PlNK+DxDw==

    truncatedBase64:  just like `base64`, but without the trailing `==`
        Example: RPRiahFET8W96PlNK+DxDw



USAGE: kyuuid [--format <format>] [--repeat <repeat>] <subcommand>

OPTIONS:
  --format <format>       The output format of the UUID(s) this generates. See
                          FORMATS for more info. (values: standard, base64,
                          truncatedBase64; default: standard)
  --repeat <repeat>       The number of UUIDs to generate at once. Each UUID
                          will be printed on its own line and formatted as
                          specified with the `--format` option. (default: 1)
  --version               Show the version.
  -h, --help              Show help information.

SUBCOMMANDS:
  convert                 A utility for converting UUIDs between formats.

  See 'kyuuid help <subcommand>' for detailed help.
```
---
```plain
% kyuuid help convert
OVERVIEW: A utility for converting UUIDs between formats.

See the documentation for kyuuid to learn more about the formats

USAGE: kyuuid convert [--to <to>] <uuid>

ARGUMENTS:
  <uuid>

OPTIONS:
  --to <to>               (values: standard, base64, truncatedBase64; default:
                          standard)
  --version               Show the version.
  -h, --help              Show help information.
```
