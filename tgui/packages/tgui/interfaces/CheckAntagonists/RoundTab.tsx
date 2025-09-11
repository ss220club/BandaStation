import { Button, Section, Stack, Table } from 'tgui-core/components';
import { RoundTabInfoProps } from './types';
import { useBackend } from '../../backend';

export type Rows = {
  row_name: string;
  row_content: string;
}

export function RoundTab(props: RoundTabInfoProps) {
  const { roundTabInfo } = props;
  const { act } = useBackend();
  const RoundRows: Rows[] = [
    {"row_name": "Round Duration:", "row_content": roundTabInfo.round_duration},
    {"row_name": "Players:", "row_content":
      roundTabInfo.connected_players - roundTabInfo.lobby_players + " ingame | " + roundTabInfo.connected_players + " connected | " + roundTabInfo.lobby_players + " lobby"},
    {"row_name": "Living Players:", "row_content":
      roundTabInfo.living_players + " active | " + (roundTabInfo.living_players - roundTabInfo.living_players_connected) + " disconnected"},
    {"row_name": "Antagonists Players:", "row_content":
      roundTabInfo.antagonists + " ingame | " + (roundTabInfo.antagonists - roundTabInfo.antagonists_dead) + " alive | " + roundTabInfo.antagonists_dead + " dead"},
    {"row_name": "Security Players:", "row_content":
      roundTabInfo.security + " ingame | " + (roundTabInfo.security - roundTabInfo.security_dead) + " alive | " + roundTabInfo.security_dead + " dead"},
    {"row_name": "SKIPPED [On centcom Z-level]:", "row_content":
      roundTabInfo.living_skipped + " living players | " + roundTabInfo.drones + " living drones"},
    {"row_name": "Dead/Observing players:", "row_content":
      roundTabInfo.living_players_connected + " active | " + (roundTabInfo.living_players - roundTabInfo.living_players_connected) + " disconnected | " + roundTabInfo.brains + " brains"},
  ]
  if(roundTabInfo.other_players > 0) {
    RoundRows.push({"row_name": "Other Players:", "row_content":
      roundTabInfo.other_players + " players in invalid state or something bugged!"})
  }

  return (
    <Stack vertical>
      <Stack.Item>
        <Section fontSize="13px" textAlign="center">
          <Button onClick={() => act("delay-pre-game")} width="33%">
            Delay Pre-Game
          </Button>
          <Button onClick={() => act("delay-round-end")} width="33%">
            Delay Round End
          </Button>
          <Button onClick={() => act("end-round-now")} width="33%">
            End Round Now
          </Button>
        </Section>
      </Stack.Item>
      <Stack.Item>
        <Table fontSize="14px" textAlign="left">
          {RoundRows.map((value, index) => (
            <Table.Row className="candystripe" key={index}>
              <Table.Cell>{value.row_name}</Table.Cell>
              <Table.Cell>{value.row_content}</Table.Cell>
            </Table.Row>
          ))}
        </Table>
      </Stack.Item>
    </Stack>
    );
}
