import { useBackend } from '../backend';
import { Button, LabeledList, Section } from 'tgui-core/components';
import { Window } from '../layouts';

export const Mortar = (props, context) => {
	const { act, data } = useBackend(context);
	// Extract `health` and `color` variables from the `data` object.
	const {
        target_x,
        target_y,
        target_z,
        offset_x,
        offset_y,
    } = data;
	return (
		<Window resizable>
			<Window.Content scrollable>
				<Section title="Health status">
					<LabeledList>
						<LabeledList.Item label="Healthtest">{target_x}</LabeledList.Item>
						<LabeledList.Item label="Color">{color}</LabeledList.Item>
						<LabeledList.Item label="Button">
							<Button
								content="Dispatch a 'test' action"
								onClick={() => act('test')}
							/>
						</LabeledList.Item>
					</LabeledList>
				</Section>
			</Window.Content>
		</Window>
	);
};
