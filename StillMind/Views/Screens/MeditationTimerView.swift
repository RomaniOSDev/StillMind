import SwiftUI
import Combine

struct MeditationTimerView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedDuration: TimeInterval = 15 * 60 // 15 minutes
    @State private var timeRemaining: TimeInterval = 15 * 60
    @State private var isRunning = false
    @State private var isPaused = false
    @State private var showingDurationPicker = false
    @State private var selectedType: MeditationSession.MeditationType = .mindfulness
    @State private var isAnimating = false
    @State private var breathingPhase = 0 // 0: inhale, 1: hold, 2: exhale, 3: hold
    
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()
    private let breathingTimer = Timer.publish(every: 4, on: .main, in: .common).autoconnect()
    
    private let durationOptions: [(String, TimeInterval)] = [
        ("5 min", 5 * 60),
        ("10 min", 10 * 60),
        ("15 min", 15 * 60),
        ("20 min", 20 * 60),
        ("30 min", 30 * 60),
        ("45 min", 45 * 60),
        ("60 min", 60 * 60)
    ]
    
    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 0) {
                // Custom Navigation Bar
                CustomNavigationBar(
                    title: "Meditation Timer",
                    leftButton: nil,
                    rightButton: NavigationButton(icon: "gear") {
                        showingDurationPicker = true
                    }
                )
                
                // Main timer display
                VStack(spacing: 40) {
                    // Meditation type selector
                    VStack(spacing: 16) {
                        Text("Meditation Type")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 12), count: 2), spacing: 12) {
                            ForEach(MeditationSession.MeditationType.allCases, id: \.self) { type in
                                MeditationTypeButton(
                                    type: type,
                                    isSelected: selectedType == type
                                ) {
                                    selectedType = type
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)
                    
                    // Timer circle
                    ZStack {
                        // Background circle
                        Circle()
                            .stroke(Color("cream").opacity(0.2), lineWidth: 20)
                            .frame(width: 280, height: 280)
                        
                        // Progress circle
                        Circle()
                            .trim(from: 0, to: progress)
                            .stroke(
                                LinearGradient(
                                    colors: [Color("chicken"), Color("warmOrange")],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                style: StrokeStyle(lineWidth: 20, lineCap: .round)
                            )
                            .frame(width: 280, height: 280)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 1), value: progress)
                        
                        // Center content
                        VStack(spacing: 16) {
                            if isRunning {
                                // Breathing indicator
                                VStack(spacing: 8) {
                                    Text(breathingText)
                                        .font(.system(size: 18, weight: .medium))
                                        .foregroundColor(Color("chicken"))
                                        .opacity(breathingPhase == 0 || breathingPhase == 2 ? 1.0 : 0.6)
                                    
                                    Circle()
                                        .fill(Color("chicken"))
                                        .frame(width: breathingPhase == 0 || breathingPhase == 2 ? 40 : 20, height: breathingPhase == 0 || breathingPhase == 2 ? 40 : 20)
                                        .animation(.easeInOut(duration: 2), value: breathingPhase)
                                }
                            }
                            
                            Text(timeString)
                                .font(.system(size: 48, weight: .light))
                                .foregroundColor(.primary)
                                .monospacedDigit()
                            
                            Text(isRunning ? (isPaused ? "Paused" : "Meditating") : "Ready to begin")
                                .font(.system(size: 16, weight: .medium))
                                .foregroundColor(.secondary)
                        }
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                    .animation(.spring(response: 0.8, dampingFraction: 0.8).delay(0.4), value: isAnimating)
                    
                    // Control buttons
                    HStack(spacing: 24) {
                        if isRunning {
                            // Pause/Resume button
                            CustomButton(
                                title: isPaused ? "Resume" : "Pause",
                                icon: isPaused ? "play.fill" : "pause.fill",
                                style: .secondary
                            ) {
                                isPaused.toggle()
                            }
                            
                            // Stop button
                            CustomButton(
                                title: "Stop",
                                icon: "stop.fill",
                                style: .destructive
                            ) {
                                stopTimer()
                            }
                        } else {
                            // Start button
                            CustomButton(
                                title: "Start Meditation",
                                icon: "play.fill",
                                style: .primary
                            ) {
                                startTimer()
                            }
                        }
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeOut(duration: 0.6).delay(0.6), value: isAnimating)
                    
                    // Session info
                    if isRunning {
                        VStack(spacing: 12) {
                            Text("Session Progress")
                                .font(.system(size: 16, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            HStack(spacing: 20) {
                                SessionInfoItem(
                                    title: "Elapsed",
                                    value: formatTime(selectedDuration - timeRemaining),
                                    icon: "clock",
                                    color: Color("chicken")
                                )
                                
                                SessionInfoItem(
                                    title: "Remaining",
                                    value: formatTime(timeRemaining),
                                    icon: "timer",
                                    color: Color("warmOrange")
                                )
                                
                                SessionInfoItem(
                                    title: "Type",
                                    value: selectedType.displayName,
                                    icon: selectedType.icon,
                                    color: Color("softYellow")
                                )
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                        .background(
                            RoundedRectangle(cornerRadius: 20)
                                .fill(Color("cream").opacity(0.1))
                        )
                        .padding(.horizontal, 24)
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(0.8), value: isAnimating)
                    }
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 20)
            }
            .onAppear {
                withAnimation(.easeOut(duration: 0.6)) {
                    isAnimating = true
                }
            }
            .onReceive(timer) { _ in
                if isRunning && !isPaused {
                    if timeRemaining > 0 {
                        timeRemaining -= 1
                    } else {
                        completeSession()
                    }
                }
            }
            .onReceive(breathingTimer) { _ in
                if isRunning && !isPaused {
                    breathingPhase = (breathingPhase + 1) % 4
                }
            }
            .sheet(isPresented: $showingDurationPicker) {
                DurationPickerView(
                    selectedDuration: $selectedDuration,
                    durationOptions: durationOptions
                )
            }
        }
    }
    
    private var progress: Double {
        1.0 - (timeRemaining / selectedDuration)
    }
    
    private var timeString: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    private var breathingText: String {
        switch breathingPhase {
        case 0: return "Inhale"
        case 1: return "Hold"
        case 2: return "Exhale"
        case 3: return "Hold"
        default: return ""
        }
    }
    
    private func startTimer() {
        isRunning = true
        isPaused = false
        timeRemaining = selectedDuration
        breathingPhase = 0
    }
    
    private func stopTimer() {
        isRunning = false
        isPaused = false
        timeRemaining = selectedDuration
        breathingPhase = 0
    }
    
    private func completeSession() {
        isRunning = false
        isPaused = false
        
        // Save session
        let session = MeditationSession(
            duration: selectedDuration,
            date: Date(),
            type: selectedType
        )
        dataManager.addMeditationSession(session)
        
        // Reset timer
        timeRemaining = selectedDuration
        breathingPhase = 0
        
        // Show completion alert or haptic feedback
        let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
        impactFeedback.impactOccurred()
    }
    
    private func formatTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%d:%02d", minutes, seconds)
    }
}

struct MeditationTypeButton: View {
    let type: MeditationSession.MeditationType
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: type.icon)
                    .font(.system(size: 24, weight: .medium))
                    .foregroundColor(isSelected ? .white : type.color)
                
                Text(type.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
            }
            .frame(maxWidth: .infinity, minHeight: 80)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? type.color : Color("cream").opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(type.color, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct SessionInfoItem: View {
    let title: String
    let value: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 16, weight: .medium))
                .foregroundColor(color)
                .frame(width: 32, height: 32)
                .background(
                    Circle()
                        .fill(color.opacity(0.1))
                )
            
            Text(value)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.primary)
                .lineLimit(1)
            
            Text(title)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity)
    }
}

struct DurationPickerView: View {
    @Binding var selectedDuration: TimeInterval
    let durationOptions: [(String, TimeInterval)]
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("darkBackground")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    Text("Select Duration")
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                        .padding(.top, 20)
                    
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 2), spacing: 16) {
                        ForEach(durationOptions, id: \.1) { option in
                            DurationOptionButton(
                                title: option.0,
                                isSelected: selectedDuration == option.1
                            ) {
                                selectedDuration = option.1
                                dismiss()
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    
                    Spacer()
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(Color("chicken"))
                }
            }
        }
    }
}

struct DurationOptionButton: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(isSelected ? .white : .primary)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 20)
                .background(
                    RoundedRectangle(cornerRadius: 16)
                        .fill(isSelected ? Color("chicken") : Color("cream").opacity(0.1))
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("chicken"), lineWidth: isSelected ? 0 : 1)
                )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    MeditationTimerView()
}
