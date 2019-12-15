//
//  Conductor.swift
//  SequencerDemo
//
//  Created by Kanstantsin Linou, revision history on Githbub.
//  Copyright © 2018 AudioKit. All rights reserved.
//

import AudioKit

@objc
class Conductor: NSObject {
    var sequencer = AKAppleSequencer()
//    var currentTempo = 80.0 {
//        didSet {
//            sequencer.setTempo(currentTempo)
//        }
//    }
    var piano : AKMIDISampler
    var bell : AKMIDISampler
    var mixer : AKMixer
    var reverb : AKCostelloReverb
    var dryWetMixer : AKDryWetMixer

    @objc
    override init() {
        piano = AKMIDISampler()
        bell = AKMIDISampler()
        do {
            try piano.loadWav("FM Piano")
            try bell.loadWav("Bell")
        } catch {
            AKLog("load wav fail!")
        }

        mixer = AKMixer(piano, bell)

        reverb = AKCostelloReverb(mixer)

        dryWetMixer = AKDryWetMixer(mixer, reverb, balance: 0.2)
        AudioKit.output = piano
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }
        
        sequencer.setLength(AKDuration(seconds: 1000))
        sequencer.setGlobalMIDIOutput(piano.midiIn)
        sequencer.enableLooping()
        sequencer.setTempo(60)
        _ = sequencer.newTrack()
    }

    @objc
    func add(noteNumber:Int, position:Double, duration:Double) {
        sequencer.tracks[0].add(noteNumber: MIDINoteNumber(noteNumber),
                      velocity: 100,
                      position: AKDuration(seconds: position),
                      duration: AKDuration(seconds: duration))
    }
    
    @objc
    func play() {
        sequencer.play()
    }

}
