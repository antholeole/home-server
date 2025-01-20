import { AsyncState } from "react-use/lib/useAsyncFn";

export const tristate = <R, T extends React.ReactNode>(
	state: AsyncState<R>,
	tristate: {
		loading: () => T;
		error: (e: Error) => T;
		value: (v: R) => T;
	},
) => {
	if (state.loading) {
		return tristate.loading();
	} else if (state.error !== undefined) {
		return tristate.error(state.error);
	} else {
		return tristate.value(state.value!);
	}
};
