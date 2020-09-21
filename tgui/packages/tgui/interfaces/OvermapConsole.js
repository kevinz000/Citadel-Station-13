/**
 * @file
 * @copyright 2020 LetterN (https://github.com/LetterN)
 * @author Original LetterN (https://github.com/LetterN)
 * @license MIT
 */
import { Fragment, Component, createRef } from 'inferno';
import { useBackend, useSharedState } from '../backend';
import { AnimatedNumber, Box, Button, Flex, LabeledList, Section, Table, Tabs } from '../components';
import { Window } from '../layouts';

const PX_PER_UNIT = 32;

export const OvermapPannel = (props, context) => {
  const { act, data } = useBackend(context);
  const {
    map_data = {},
    map_ships = {},
    map_static = {},
    meta_info = {},
    map_size = [],
  } = data;
  return (
    <Window resizable>
      <Window.Content>
        <OvermapMap
          mapSize = map_size
          />
      </Window.Content>
    </Window>
  );
};
class OvermapMap extends Component {
  constructor(props) {
    super(props);
    this.mapRef = createRef();
  }

  componentDidMount() {
    this.drawMap(this.props);
  }

  componentDidUpdate() {
    this.drawMap(this.props);
  }

  drawMap(props) {
    const mapShips = props.ships;
    const mapClutter = props.clutter;
    const mapLiveData = props.liveData;
    const ctx = this.mapRef.current.getContext("2d");
    //draw image here
    ctx.restore();
  }

  render() {
    const {
      size = [],
      ...rest
    } = this.props;
    const {
      width = 255,
      height = 255,
    } = size;
    // pull a webmap here, make background work using some css
    return (
      <canvas
        ref={this.canvasRef}
        width={(width * PX_PER_UNIT) || 300}
        height={(height * PX_PER_UNIT) || 300}
        {...rest}>
        Canvas failed to render.
      </canvas>
    )
  }
}
