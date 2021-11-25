const sankeyNetworkDefinition = require('./sankeyNetworkDefinition');

const puppeteer = require('puppeteer');

var data = {
    "links": {
        "source": [0, 0, 0, 0, 1, 1, 1, 1, 2, 2, 2, 2, 3, 3, 3, 3, 4, 4, 4, 5, 5, 5, 6, 6, 6, 7, 7, 7, 8, 8, 8, 9, 9, 9, 10, 10, 10],
        "target": [4, 5, 6, 7, 4, 5, 6, 7, 4, 5, 6, 7, 4, 5, 6, 7, 8, 9, 10, 8, 9, 10, 8, 9, 10, 8, 9, 10, 11, 12, 13, 11, 12, 13, 11, 12, 13],
        "value": [196, 112, 100, 56, 212, 161, 151, 137, 152, 108, 156, 121, 37, 15, 18, 85, 249, 332, 16, 151, 237, 8, 82, 341, 2, 47, 343, 9, 137, 305, 87, 101, 679, 473, 2, 24, 9],
        "group": ["0", "0", "0", "0", "1", "1", "1", "1", "2", "2", "2", "2", "3", "3", "3", "3", "4", "4", "4", "5", "5", "5", "6", "6", "6", "7", "7", "7", "8", "8", "8", "9", "9", "9", "10", "10", "10"]
    },
    "nodes": {
        "name": ["Online", "Offline", "Instore", "Other", "Online", "Offline", "Instore", "Did not research", "Online", "Offline", "Over the phone", "Review Online", "Review Offline", "No Review"],
        "group": ["0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "10", "11", "12", "13"]
    },
    "options": {
        "NodeID": "name", "NodeGroup": "group", "LinkGroup": "group", "colourScale": "d3.scaleOrdinal() .domain(['0','1','2','3','4','5','6','7','8','9','10','11','12','13']) .range(['#EF5953','#3E7DCC','#D18CA2','#6CA19D','#EF5953','#3E7DCC','#D18CA2','#6CA19D','#EF5953','#3E7DCC','#6CA19D','#EF5953','#3E7DCC','#6CA19D']);", "fontSize": 17, "fontFamily": "Arial", "nodeWidth": 30, "nodePadding": 40, "units": "",
        "margin": { "top": null, "right": null, "bottom": null, "left": null },
        "iterations": 0,
        "sinksRight": true
    }
}

let browser;
let page;

beforeEach(async () => {
    browser = await puppeteer.launch();
    page = await browser.newPage();
});


test('VIS-1023: node tooltips have newline separating category name and value', async () => {
	await page.setContent(`<html><head><meta charset="UTF-8"></head><body><div id="myDiv" style="width: 800; height: 600;"></div></body></html>`);
	await page.addScriptTag({ path: 'inst/htmlwidgets/lib/d3-4.9.1/d3.min.js' });
	await page.addScriptTag({ path: 'inst/htmlwidgets/lib/sankey.js' });
	await page.addScriptTag({ path: 'inst/htmlwidgets/lib/sankeyNetworkDefinition.js' });
	await page.evaluate(data => {
		window.HTMLWidgets = {};
		HTMLWidgets.dataframeToD3 = function(df) {
			var names = [];
			var length;
			for (var name in df) {
			    if (df.hasOwnProperty(name))
			        names.push(name);
			    if (typeof(df[name]) !== "object" || typeof(df[name].length) === "undefined") {
			        throw new Error("All fields must be arrays");
			    } else if (typeof(length) !== "undefined" && length !== df[name].length) {
			        throw new Error("All fields must be arrays of the same length");
			    }
			    length = df[name].length;
			}
			var results = [];
			var item;
			for (var row = 0; row < length; row++) {
			    item = {};
			    for (var col = 0; col < names.length; col++) {
			        item[names[col]] = df[names[col]][row];
			    }
			    results.push(item);
			}
			return results;
		};

		var el = document.getElementById("myDiv");
		var instance = sankeyNetworkDefinition.initialize(el, 800, 600);
		sankeyNetworkDefinition.renderValue(el, data, instance);
	}, data);

	const tooltip_html = await page.evaluate(() => Array.from(document.getElementsByClassName('node-tooltip'), e => e.innerHTML));
	tooltip_html.forEach(x => {
		expect(x.match('<pre>.+\n.+</pre>$')).toBeTruthy();
	});
});


afterEach(async () => {
    await browser.close();
});