//
//  VoiceSpeaker.swift
//  BLE-Swift
//
//  Created by SuJiang on 2019/1/22.
//  Copyright © 2019 ss. All rights reserved.
//

import UIKit
import AVFoundation

class VoiceSpeaker: NSObject, AVSpeechSynthesizerDelegate {
    
    static let shared = VoiceSpeaker()
    
    var audioSession = AVAudioSession.sharedInstance()
    var canSpeak = false
    
    var av: AVSpeechSynthesizer?
    
    var shouldStop = true
    
    override init() {
        do {
            try audioSession.setCategory(.playback, mode: .default)
            canSpeak = true
        } catch {
            canSpeak = false
        }
        
        av = AVSpeechSynthesizer()
    }
    
    func speak(text: String, shouldLoop: Bool) {
        
        let voice = AVSpeechSynthesisVoice(language: "zh-CN")
        
        let utt = AVSpeechUtterance(string: text)
        utt.rate = AVSpeechUtteranceDefaultSpeechRate
        utt.postUtteranceDelay = 0.1
        utt.volume = 1
        utt.pitchMultiplier = 1
        utt.voice = voice
        
        shouldStop = !shouldLoop
        
        doSpeak(utt: utt)
    }
    
    private func doSpeak(utt: AVSpeechUtterance) {
        
        av?.speak(utt)
        av?.delegate = self
    }
    
    func stopSpeaking() {
        shouldStop = true
        av?.stopSpeaking(at: .immediate)
    }
    
    func speechSynthesizer(_ synthesizer: AVSpeechSynthesizer, didFinish utterance: AVSpeechUtterance) {
        if !shouldStop {
            DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                self.av?.speak(utterance)
            }
        }
    }
    
}
