# JavaScript Object Graphs with Ruby

This Ruby gem serializes and deserializes cyclic object graphs in the [JSOG format](https://github.com/jsog/jsog).

## Source code

The official repository is (https://github.com/jsog/jsog-ruby).

## Download

Jsog is available from rubygems.org:

    $ gem install jsog

## Usage

This code mimics the standard *JSON* ruby package:

    require 'jsog'

	string = JSOG.dump(cyclicGraph);
	cyclicGraph = JSOG.parse(string);

It can be used to convert between object graphs directly:

    require 'jsog'

	jsogStructure = JSOG.encode(cyclicGraph);	// has { '@ref': 'ID' } links instead of cycles
	cyclicGraph = JSOG.decode(jsogStructure);

## Author

* Jeff Schnitzer (jeff@infohazard.org)

## License

This software is provided under the [MIT license](http://opensource.org/licenses/MIT)
