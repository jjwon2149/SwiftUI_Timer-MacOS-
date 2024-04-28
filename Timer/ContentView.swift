//
//  ContentView.swift
//  Timer
//
//  Created by 정종원 on 4/12/24.
//

import SwiftUI
import AVFoundation

struct AlwaysOnTopView: NSViewRepresentable {
    let window: NSWindow
    let isAlwaysOnTop: Bool

    func makeNSView(context: Context) -> NSView {
        let view = NSView()
        return view
    }

    func updateNSView(_ nsView: NSView, context: Context) {
        if isAlwaysOnTop {
            window.level = .floating
        } else {
            window.level = .normal
        }
    }
}

class SoundManager {
    static let instance = SoundManager()
    var player: AVAudioPlayer?
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "BlopSound", withExtension: "mp3") else { return }
        
        do {
            player = try AVAudioPlayer(contentsOf: url)
            player?.play()
        } catch let error {
            print("재생하는데 오류가 발생했습니다. \(error.localizedDescription)")
        }
    }
}

struct ContentView: View {
    
    let soundManager = SoundManager()
    @State private var soundTimer: Timer?

    
    @State private var timeRemaining = 0
    @State private var isRunning = false
    let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    
    @State private var imageTimer: Timer?
    @State private var currentIndex: Int = 0
    let walkingImagesArray = [
        "gaming-cat-page-0",
        "gaming-cat-page-1",
        "gaming-cat-page-2",
        "gaming-cat-page-3",
        "gaming-cat-page-4",
        "gaming-cat-page-5",
        "gaming-cat-page-6",
        "gaming-cat-page-7",
        "gaming-cat-page-8",
        "gaming-cat-page-9"
    ]
    
    var body: some View {
        
        VStack(spacing: 10) {
            
            Spacer()
            
            Picker("MinuteTime", selection: $timeRemaining) {
                ForEach(1...10, id: \.self) { minute in
                    let second = minute * 60
                    Text("\(minute)")
                        .tag(second)
                }
            }
            .pickerStyle(.segmented)
            
            Text("\(timeRemaining / 60):\(String(format: "%02d", timeRemaining % 60))")
                .font(.system(size: 20))
            
            Image(walkingImagesArray[currentIndex])
                .resizable()
                .scaledToFit()
            
            HStack (spacing: 10) {
                
                Button {
                    isRunning.toggle()
                    if isRunning {
                        startImageAnimationTimer()
                    } else {
                        stopImageAnimation()
                    }
                } label: {
                    Image(systemName: isRunning ? "pause.fill" : "play.fill")
                }
                .buttonStyle(.borderedProminent)
                
                
                Button {
                    timeRemaining = 0
                    stopImageAnimation()
                } label: {
                    Image(systemName: "arrow.uturn.left.circle")
                    
                }
                .buttonStyle(.borderedProminent)
                .tint(.red)
                
            }
            
            Spacer()
            
        }//VStack
        .frame(width: 230, height: 200)
        .background(AlwaysOnTopView(window: NSApplication.shared.windows.first!, isAlwaysOnTop: true))
        .onReceive(timer) { _ in
            if isRunning && timeRemaining > 0 {
                timeRemaining -= 1
            } else if isRunning {
                isRunning = false
            }
            if timeRemaining == 10 {
                startImageAnimationTimer()
            }
        }
        
        
    }
    
    func startImageAnimationTimer() {
        imageTimer?.invalidate()
        soundTimer?.invalidate()
        if timeRemaining <= 10 {
            startImageFasterAnimationTimer()
            playSound()
        } else if timeRemaining > 11 {
            imageTimer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { timer in
                currentIndex = (currentIndex + 1) % walkingImagesArray.count
            }
        } else {
            stopImageAnimation()
        }
    }
    
    func startImageFasterAnimationTimer() {
        imageTimer = Timer.scheduledTimer(withTimeInterval: 0.05, repeats: true) { timer in
            if isRunning {
                currentIndex = (currentIndex + 1) % walkingImagesArray.count
            } else {
                currentIndex = 0
            }
        }
    }
    
    func stopImageAnimation() {
        imageTimer?.invalidate()
        soundTimer?.invalidate()
    }
    
    func playSound() {
        soundTimer = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: true) { timer in
            if isRunning {
                soundManager.playSound()
            }
        }
    }
    
}




#Preview {
    ContentView()
}
