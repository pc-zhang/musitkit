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
    var filter: AKBandPassButterworthFilter!
    var mic: AKMicrophone!
    var tracker: AKAmplitudeTracker!
    var silence: AKBooster!
    
    var sequencer = AKAppleSequencer()
//    var currentTempo = 80.0 {
//        didSet {
//            sequencer.setTempo(currentTempo)
//        }
//    }
//    var piano : AKMIDISampler
//    var bell : AKMIDISampler
//    var mixer : AKMixer
//    var reverb : AKCostelloReverb
//    var dryWetMixer : AKDryWetMixer

    @objc
    override init() {
        super.init()
        
        AKSettings.audioInputEnabled = true
        mic = AKMicrophone()
        
        filter = AKBandPassButterworthFilter(mic)
        filter.centerFrequency = 440 // Hz
        filter.bandwidth = 440*0.03 // Cents
//        filter.rampDuration = 0.0
        
        tracker = AKAmplitudeTracker(filter)
        silence = AKBooster(tracker, gain: 0)
        
        
        AudioKit.output = silence
        do {
            try AudioKit.start()
        } catch {
            AKLog("AudioKit did not start!")
        }

        Timer.scheduledTimer(timeInterval: 0.01,
                            target: self,
                            selector: #selector(Conductor.updateUI),
                            userInfo: nil,
                            repeats: true)
        
//        piano = AKMIDISampler()
//        bell = AKMIDISampler()
//        do {
//            try piano.loadWav("FM Piano")
//            try bell.loadWav("Bell")
//        } catch {
//            AKLog("load wav fail!")
//        }
//
//        mixer = AKMixer(piano, bell)
//
//        reverb = AKCostelloReverb(mixer)
//
//        dryWetMixer = AKDryWetMixer(mixer, reverb, balance: 0.2)
//        AudioKit.output = piano
//        do {
//            try AudioKit.start()
//        } catch {
//            AKLog("AudioKit did not start!")
//        }
//
//        sequencer.setLength(AKDuration(seconds: 1000))
//        sequencer.setGlobalMIDIOutput(piano.midiIn)
//        sequencer.enableLooping()
//        sequencer.setTempo(60)
//        _ = sequencer.newTrack()
    }
    
    var amplitudes: [Double] = []
    
    @objc func updateUI() {
        
        let minAmp=0.001;
        let min_dAmp=0.0005;
        let m=0.9805;
        let w=10;
        
        let amplitude = max(tracker.amplitude, minAmp)
        
        amplitudes.append(amplitude)
        if amplitudes.count > w {
            amplitudes.remove(at: 0)
        } else {
            return
        }

        var sum = 0.0
        for j in 1..<w {
            sum=sum+(amplitudes[j]-max(amplitudes[0]*pow(m,Double(j)),minAmp));
        }
        sum /= Double(w-1)
        
        if sum>min_dAmp {
            print(amplitudes)
            amplitudes = []
        }
        
//        let noteNumber = midiSequence.first!
//        midiSequence.remove(at: 0)
//        let x = Double(noteNumber - 69) / 12.0
//        let y = 440 * pow(2, x)
//
//        self.filter.centerFrequency = y // Hz
//        self.filter.bandwidth = y*0.03 // Cents
//
//        print(noteNumber)
//        amplitudes = []
        
    }

    @objc
    func add(noteNumber:Int, position:Double, duration:Double) {
        DispatchQueue.main.async(flags: .barrier) {
            
            
        }
        
        midiSequence.append(Int(MIDINoteNumber(noteNumber)))
//        sequencer.tracks[0].add(noteNumber: MIDINoteNumber(noteNumber),
//                      velocity: 100,
//                      position: AKDuration(seconds: position),
//                      duration: AKDuration(seconds: duration))
    }
    
    var midiSequence: [Int] = []
    
    @objc
    func play() {
        let noteNumber = midiSequence.first!
        midiSequence.remove(at: 0)
        let x = Double(noteNumber - 69) / 12.0
        let y = 440 * pow(2, x)
        
        self.filter.centerFrequency = y // Hz
        self.filter.bandwidth = y*0.03 // Cents
//        sequencer.play()
    }

}
