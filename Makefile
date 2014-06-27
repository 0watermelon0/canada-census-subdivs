all: can.json

clean:
	rm -rf -- can.json build

.PHONY: all clean

build/shapes: data/shapes
	mkdir -p $(dir $@)
	cp -r data/shapes $@

build/shapes/gcsd000b11a_e.shp: build/shapes

# GeoJSON?

build/subdivs.json: build/shapes/gcsd000b11a_e.shp popchange.csv
	node_modules/.bin/topojson \
		-o $@ \
		--id-property='CCSUID,geo_code' \
		--external-properties=popchange.csv \
		--properties='populationch=+d.properties["popchange"]' \
		--simplify=.1 \
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