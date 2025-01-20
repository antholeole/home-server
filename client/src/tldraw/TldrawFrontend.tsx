import {
	Tldraw,
	defaultShapeUtils,
	defaultBindingUtils,
	TLAssetStore,
} from "tldraw";
import { useSync } from "@tldraw/sync";
import "./style.css";
import { assets } from "./lib/assets";

const myAssetStore: TLAssetStore = {
	async upload() {
		return "";
	},
	resolve(asset) {
		return asset.props.src;
	},
};

const uri = `ws://${import.meta.env.VITE_SERVER_URL}/draw/connect`;

export const TldrawFrontend = () => {
	const store = useSync({
		uri,
		assets: myAssetStore,
		shapeUtils: defaultShapeUtils,
		bindingUtils: defaultBindingUtils,
	});

	return (
		<div style={{ position: "fixed", inset: 0 }}>
			<Tldraw store={store} assetUrls={assets}></Tldraw>
		</div>
	);
};

