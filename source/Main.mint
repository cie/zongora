component Main {
  use Midi {
    message = (m : Midi.Message) {
      sequence {
        case (m) {
          Midi.Message::NoteOn(ch, num, vel) => next { down = down |> Set.add(num) }
          Midi.Message::NoteOff(ch, num, vel) => next { down = down |> Set.delete(num) }
          Midi.Message::CC(ch, num, vel) => next { }
        }
        [Debug.log(m)]
      }
    }
  }

  state octave = 800
  state down : Set(Number) = Set.empty()
  state doe = 0

  fun render : Html {
    <svg width="100vw" height="100vh" style="background-color:#404037">
      for (n, i of [0,2,4,5,7,9,11,12,14,16,17,19,21,23,24]) {
        <White
          down={down |> Set.has(n + 48)}
          width={octave / 7} x={80 + i * octave / 7}
          onClick={(e : Html.Event) { next { doe = n }}}
          sound={(n + 12 - doe) % 12} />
      }
      for (n, i of [1,3,6,8,10,13,15,18,20,22]) {
        <Black
          down={down |> Set.has(n + 48)}
          width={octave / 12} x={80 + n * octave / 12}
          onClick={(e : Html.Event) { next { doe = n }}}
          sound={(n + 12 - doe) % 12}/>
      }
    </svg>
  }
}

component White {
  property down = false
  property sound : Number
  property x : Number
  property width : Number
  property onClick : Function(Html.Event,Promise(Never,Void))

  const N = Number.toString
  style white {
    fill:white;
    stroke: black;
    stroke-width: 2px;
    transition: fill 200ms ease-out;
  }

  fun render() {
    with Solfege {
      <g>
        <rect::white x={x |> N} y="100" width={width |> N} height="600" style={
          if (down) { "fill:#{col(sound)};transition:none;" } else { "" }
        } onClick={onClick} />
        if (sound == 0) {
          <circle
            cx={(x + width / 2)|> N}
            cy={600 |> N} r={20 |> N} style="fill:hsl(24deg 91% 53%)" />
        } 
      </g>
    }
  }
}

component Black {
  property down = false
  property sound : Number
  property x : Number
  property width : Number
  property onClick : Function(Html.Event,Promise(Never,Void))

  const N = Number.toString
  style black {
    fill:black;
    stroke: black;
    stroke-width: 2px;
    transition: fill 200ms ease-out;
    border-bottom-right-radius: 4px;
    border-bottom-left-radius: 4px;
  }

  fun render() {
    with Solfege {
      <g>
        <rect::black x={x |> N} y="100" width={width |> N} height="400" rx="6" ry="6" style={
          if (down) { "fill:#{col(sound)};transition:none;" } else { "" }
        } onClick={onClick} />
        if (sound == 0) {
          <circle
            cx={(x + width / 2)|> N}
            cy={400 |> N} r={20 |> N} style="fill:hsl(24deg 91% 53%)" />
        } 
      </g>
    }
  }
}

module Solfege {
  const COLORS = [
    "hsl(24deg 91% 53%)",
      "red",
    "hsl(273deg 41% 48%)",
      "hsl(273deg 100% 50%)",
    "hsl(62deg 93% 55%)",
    "hsl(226deg 84% 48%)",
      "hsl(323deg 100% 50%)",
    "hsl(120deg 77% 30%)",
      "hsl(120deg 91% 50%)",
    "hsl(350deg 88% 46%)",
      "hsl(26deg 76% 23%)",
    "hsl(153deg 83% 49%)"
  ]
  fun col(sound : Number) {
    COLORS[sound % 12] or "red"
  }
}