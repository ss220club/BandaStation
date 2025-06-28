import { useState } from 'react';
import { useBackend } from 'tgui/backend';
import { Box, Button, Input, Section, Stack, Tabs } from 'tgui-core/components'
import { Window } from 'tgui/layouts';

type Data = {
	availability: number;
	last_caller: string | null;
	available_transmitters: string[];
	transmitters: {
		phone_category: string;
		phone_color: string;
		phone_id: string;
		phone_icon: string;
	}[];
};

export const PhoneMenu = (props) => {
	const { act, data } = useBackend();
	return (
		<Window width={500} height={400}>
			<Window.Content>
				<GeneralPanel />
			</Window.Content>
		</Window>
	);
};

const GeneralPanel = (props) => {
	const { act, data } = useBackend<Data>();
	const { availability, last_caller } = data;
	const available_transmitters = Object.keys(data.available_transmitters);
	const transmitters = data.transmitters.filter((val1) =>
		available_transmitters.includes(val1.phone_id),
	);

	const categories: string[] = [];
	for (let i = 0; i < transmitters.length; i++) {
		let data = transmitters[i];
		if (categories.includes(data.phone_category)) continue;
		categories.push(data.phone_category);
	}

	const [currentSearch, setSearch] = useState<string>('');
	const [selectedPhone, setSelectedPhone] = useState<string | null>(null);
	const [currentCategory, setCategory] = useState<string>(categories[0] || '');

	let dnd_tooltip = 'Do Not Disturb is DISABLED';
	let dnd_locked = 'No';
	let dnd_icon = 'volume-high';
	if (availability === 1) {
		dnd_tooltip = 'Do Not Disturb is ENABLED';
		dnd_icon = 'volume-xmark';
	} else if (availability >= 2) {
		dnd_tooltip = 'Do Not Disturb is ENABLED (LOCKED)';
		dnd_locked = 'Yes';
		dnd_icon = 'volume-xmark';
	} else if (availability < 0) {
		dnd_tooltip = 'Do Not Disturb is DISABLED (LOCKED)';
		dnd_locked = 'Yes';
	}

	return (
		<Box height='100%'>
			<Stack fill>
				<Stack.Item width="30%">
					<Stack vertical fill>
						<Stack.Item>
							<Section>
								<Button.Checkbox
									color="red"
									tooltip={dnd_tooltip}
									disabled={dnd_locked === 'Yes'}
									checked={availability >= 1}
									fluid
									textAlign="center"
									onClick={() => act('toggle_dnd')}
									lineHeight='3em'
								>
									Do Not Disturb
								</Button.Checkbox>
							</Section>
						</Stack.Item>
						<Stack.Item grow>
							<Section title="Call History" fill>
								<Box height='calc(100% - 1.5em)'>{!!last_caller && <Box>{last_caller}</Box>}</Box>
								<Button.Confirm icon="trash" color="transparent" confirmColor='red' confirmIcon='close' fluid>Clear</Button.Confirm>
							</Section>
						</Stack.Item>
					</Stack>
				</Stack.Item>
				<Stack.Item grow>
					<Section fill>
						<Stack vertical fill>
							<Stack.Item>
								<Tabs>
									{categories.map((val) => (
										<Tabs.Tab
											selected={val === currentCategory}
											onClick={() => setCategory(val)}
											key={val}
										>
											{val}
										</Tabs.Tab>
									))}
								</Tabs>
							</Stack.Item>
							<Stack.Item>
								<Input
									fluid
									value={currentSearch}
									placeholder="Begin typing..."
									onChange={(value) => setSearch(value.toLowerCase())}
								/>
							</Stack.Item>
							<Stack.Item grow>
								<Section fill scrollable>
									<Tabs vertical>
										{transmitters.map((val) => {
											if (
												val.phone_category !== currentCategory ||
												!val.phone_id.toLowerCase().match(currentSearch)
											) {
												return;
											}
											return (
												<Tabs.Tab
													selected={selectedPhone === val.phone_id}
													onClick={() => {
														if (selectedPhone === val.phone_id) {
															act('call_phone', { phone_id: selectedPhone });
														} else {
															setSelectedPhone(val.phone_id);
														}
													}}
													key={val.phone_id}
													color={val.phone_color}
													icon={val.phone_icon}
												>
													<div onFocus={() => (document.activeElement as HTMLElement)?.blur()}>
														{val.phone_id}
													</div>
												</Tabs.Tab>
											);
										})}
									</Tabs>
								</Section>
							</Stack.Item>
							{!!selectedPhone && (
								<Stack.Item>
									<Button
										color="good"
										fluid
										textAlign="center"
										onClick={() => act('call_phone', { phone_id: selectedPhone })}
									>
										Dial
									</Button>
								</Stack.Item>
							)}
						</Stack>
					</Section>
				</Stack.Item>
			</Stack>
		</Box>

	);
};
