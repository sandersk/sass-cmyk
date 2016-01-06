# sass-cmyk

Need to preprocess CMYK colors with Sass? The sass-cmyk plugin lets you construct CMYK color objects with cmyk(), adds support 
for performing math operations (+, *, /) on CMYK colors, and provides functions for mixing, lightening, and darkening colors. 
sass-cmyk outputs CMYK color values using cmyk() function syntax supported by <a href="http://www.antennahouse.com">AntennaHouse</a> 
and <a href="http://www.princexml.com">PrinceXML</a> PDF formatters, making it a great fit for doing print typesetting with CSS.

## Installation

    $ gem install sass-cmyk

Or you can build from source:

    $ git clone https://github.com/sandersk/sass-cmyk.git
    $ cd sass-cmyk
    $ gem build sass-cmyk.gemspec
    $ gem install sass-cmyk-*.gem

## Usage

To use the sass-cmyk plugin when running the Sass converter, just require the library using the `-r` option:

    $ sass convert your_sass.scss -r 'sass-cmyk'

Or, if you're invoking Sass from within Ruby code, just require the `sass-cmyk` library:

````ruby
require 'sass-cmyk'
sass_engine = Sass::Engine.for_file("your_sass.scss", :style => :compact)
results = sass_engine.render
````

## Documentation

The sass-cmyk plugin supports constructing CMYK color objects using the `cmyk()` function, which accepts cyan, magenta, yellow, and black values (in that order) as either floats or percents, e.g.:

````
$cmyk-chartreuse: cmyk(0.5, 0, 1, 0);
$cmyk-vermillion: cmyk(0%, 84%, 71%, 0%);
````

CMYK values can also be supplied using keyword arguments, e.g.:

````
$cmyk-turquoise: cmyk($cyan: 71%, $magenta: 0%, $yellow: 7%, $black: 12%);
````

In CSS output, CMYK color values will be output in percents. The following SCSS:

````
$cmyk-chartreuse: cmyk(0.5, 0,	1, 0);

h1 {
  color: $cmyk-chartreuse;
}
````

Will be converted to the following CSS syntax:

````css
h1 {
  color: cmyk(50%,0%,1%,0%);
}
````

Which is supported by both AntennaHouse and Prince XML print typsetting applications.

### CMYK color manipulation

To mix two CMYK colors, use either the `+` operator, e.g.:

````
$cmyk-chartreuse + $cmyk-vermillion
````

Or the `cmyk_mix()` function:

````
cmyk_mix($cmyk-chartreuse, $cmyk-vermillion)
````

When mixing colors, sass-cmyk will normalize color component values to ensure none exceed 100%, and that equivalent percentages of cyan,
magenta, and yellow will be substituted with the corresponding percentage of black (i.e., if CMY values are each 30%, they can all be set to 0, and 30% can be added to K). For example, the following SCSS:

````
aside {
   color: cmyk(50%, 20%, 00%, 0%) + cmyk(70%, 20%, 0%, 0%);
   background-color: cmyk_mix(cmyk(30%, 50%, 0%, 0%), cmyk(10%, 0%, 30%, 0%));
}
````

will be converted to:

````css
aside {
  color: cmyk(100%,40%,0%,0%);
  background-color: cmyk(10%,20%,0%,30%); 
}
````

To scale CMYK color values up or down proportionally by a percentage, use the `cmyk_scale` function, which takes a CMYK color and a
percentage, e.g.:

````
$cmyk-salmon: cmyk(0, 0.45, 0.69, 0);
$cmyk-lighter-salmon: cmyk_scale($cmyk-salmon, 50%);
````

When scaling up CMYK colors, sass-cmyk will throw an error if any component value exceeds 100%, which would prevent colors from being
scaled proportionally. The following will throw an error, as it would scale the yellow percentage over 100%:

````
cmyk_scale($cmyk-salmon, 150%)
````

## Contributing

Issues and pull requests via GitHub are welcome &#9786;

