record Midi.WebMidiMessage {
  target: Midi.WebMidiInput
}

enum Midi.Message {
  /**  */
  NoteOn(Number, Number, Number)
  NoteOff(Number, Number, Number)
  CC(Number, Number, Number)
}

record Midi.Subscription {
  message : Function(Midi.Message, Promise(Never,Array(Midi.Message)))
}

provider Midi : Midi.Subscription {
  state setup = false
  fun handle(event : Midi.WebMidiEvent) {
    try {
      replies = for (s of subscriptions) {
        case (`#{event}.type`) {
          "noteon" => s.message(Midi.Message::NoteOn(
            `#{event}.channel`, `#{event}.note.number`, `#{event}.velocity`))
          "noteoff" => s.message(Midi.Message::NoteOff(
            `#{event}.channel`, `#{event}.note.number`, `#{event}.velocity`))
          => sequence { [] } 
        }
      }
      for (reply of replies) {
        sequence {
          messages = reply
          for (message of messages) {
            `WebMidi.outputs
            .filter(output => !output.name.startsWith('Midi Through'))
            .map(port => {
              #{
                case (message) {
                  Midi.Message::NoteOn(ch, num, vel) =>
                    `port.playNote(#{num}, #{ch}, {velocity: #{vel}})`
                  Midi.Message::NoteOff(ch, num, vel) =>
                    `port.stopNote(#{num}, #{ch}, {velocity: #{vel}})`
                  => void
                }
              }
            })`
          }
        }
      }
    }
  }
  fun update() {
    if (!setup) {
      try {
        x = `
          WebMidi.enable(err => {
            if (err) alert(err.message)
            for (const input of WebMidi.inputs)
            WebMidi.addListener('connected', ({port}) => {
              if (port.type === 'input') {
                port.addListener('noteon', 'all', #{handle})
                port.addListener('noteoff', 'all', #{handle})
                port.addListener('controlchange', 'all', #{handle})
              } else {

              }
            })
          })
        `
        next { setup = true }
      }
    } else {
      next {}
    }
  }
}