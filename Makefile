all:
	rm -rf dist
	mkdir -p dist/js/learner
	cp -R src/js/vendor dist/js/vendor
	cp -R src/js/letters_data dist/js/letters_data
	cp src/js/canvas.js dist/js/canvas.js
	coffee -o dist/js/learner -bcm src/js/learner/*.coffee
	python -m SimpleHTTPServer
