const fs = require('fs');
const { toMatchImageSnapshot } = require('jest-image-snapshot');
expect.extend({ toMatchImageSnapshot });

class testUtils {
    static async snapshotAndCompare(page, test_name, width, height) {
        const image = await page.screenshot({
            clip: {
                x: 0,
                y: 0,
                width: width,
                height: height
            }
        });

        const visual_snapshots = `${__dirname}/snapshots`;

        try {
            expect(image).toMatchImageSnapshot({
                customSnapshotsDir: `${visual_snapshots}`,
                customSnapshotIdentifier: `${test_name}`
            });
        } catch (e) { // if test fails, save the new snapshot in a folder called new
            const dir = `${visual_snapshots}/new/`;
            if (!fs.existsSync(dir)) {
                fs.mkdirSync(dir);
            }
            await page.screenshot({
                path: `${visual_snapshots}/new/${test_name}.png`,
                clip: {
                    x: 0,
                    y: 0,
                    width: width,
                    height: height
                }
            });
        }
    }
}
module.exports = testUtils;
