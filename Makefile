all: can.json

clean:
	rm -rf -- can.json build

.PHONY: all clean

build/shapes: data/shapes
	mkdir -p $(dir $@)
	cp -r data/shapes $@

build/shapes/ger_000b06a_e.shp: build/shapes

build/subdivs.json: build/shapes/ger_000b06a_e.shp
	node_modules/.bin/topojson \
		-o $@ \
		--id-property='ERUID,geo_code' \
		--properties='name=ERNAME' \
		-q 1e4 \
		-s 1e-8 \
		--filter=none \
		-- subdivs=$<

build/provs.json: build/subdivs.json
	node_modules/.bin/topojson-merge \
		-o $@ \
		--in-object=subdivs \
		--out-object=provs \
		--key='d.id.substring(0, 2)' \
		-- $<

can.json: build/provs.json
	node_modules/.bin/topojson-merge \
		-o $@ \
		--in-object=provs \
		--out-object=nation \
		-- $<
