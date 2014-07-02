all: can.json

clean:
	rm -rf -- can.json build

.PHONY: all clean

build/shapes: data/shapes
	mkdir -p $(dir $@)
	cp -r data/shapes $@

build/shapes/gcsd000b11a_e.shp: build/shapes

build/subdivs.json: build/shapes/gcsd000b11a_e.shp total.csv
	node_modules/.bin/topojson \
		-o $@ \
		--id-property='CSDUID,geo_code' \
		--external-properties=total.csv \
		--properties='total=+d.properties["total"]' \
		--properties='name=CSDNAME' \
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