import { Chart, Include } from "cdk8s";
import type { Construct } from "constructs";

import * as fs from "node:fs";
import * as path from "node:path";

export class SealedSecrets extends Chart {
	constructor(scope: Construct) {
		super(scope, "sealed-secrets");

		const sealedSecrets = path.join(__dirname, "sealed");
		const files = fs.readdirSync(sealedSecrets);

		for (const file of files) {
			const filePath = path.join(sealedSecrets, file);
			new Include(this, path.basename(filePath, ".yaml"), {
				url: filePath,
			});
		}
	}
}
