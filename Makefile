#!/usr/bin/make -f

fontpath=/usr/share/fonts/truetype/malayalam
fonts=AnjaliOldLipi-Regular
feature=features/features.fea
PY=python2.7
buildscript=tools/build.py
version=7.0
default: otf
all: clean otf ttf webfonts test
.PHONY: ttf
ttf:
	@for font in `echo ${fonts}`;do \
		$(PY) $(buildscript) -t ttf -i $$font.sfd -f $(feature) -v $(version);\
	done;

otf:
	@for font in `echo ${fonts}`;do \
		$(PY) $(buildscript) -t otf -i $$font.sfd -f $(feature) -v $(version);\
	done;

webfonts:woff woff2
woff: ttf
	@rm -rf *.woff
	@for font in `echo ${fonts}`;do \
		$(PY) $(buildscript) -t woff -i build/$$font.ttf;\
	done;
woff2: ttf
	@rm -rf *.woff2
	@for font in `echo ${fonts}`;do \
		$(PY) $(buildscript) -t woff2 -i build/$$font.ttf;\
	done;

install: otf
	@for font in `echo ${fonts}`;do \
		install -D -m 0644 build/$${font}.otf ${DESTDIR}/${fontpath}/$${font}.otf;\
	done;

ifeq ($(shell ls -l *.ttf 2>/dev/null | wc -l),0)
test: ttf run-test
else
test: run-test
endif

run-test:
	@for font in `echo ${fonts}`; do \
		echo "Testing font $${font}";\
		hb-view build/$${font}.ttf --font-size 14 --margin 100 --line-space 1.5 --foreground=333333  --text-file tests/tests.txt --output-file tests/$${font}.pdf;\
	done;
clean:
	@rm -rf *.otf *.ttf *.woff *.woff2 *.sfd-* tests/*.pdf build
