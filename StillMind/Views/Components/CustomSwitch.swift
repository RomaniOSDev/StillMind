import SwiftUI

struct CustomSwitch: View {
    @Binding var isOn: Bool
    let title: String
    let subtitle: String?
    let icon: String?
    
    @State private var dragOffset: CGFloat = 0
    @State private var isAnimating = false
    
    init(isOn: Binding<Bool>, title: String, subtitle: String? = nil, icon: String? = nil) {
        self._isOn = isOn
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
    }
    
    var body: some View {
        HStack(spacing: 16) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(Color("chicken"))
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(Color("chicken").opacity(0.1))
                    )
            }
            
            VStack(alignment: .leading, spacing: 2) {
                Text(title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(.primary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
            }
            
            Spacer()
            
            // Custom Switch
            ZStack {
                // Background
                RoundedRectangle(cornerRadius: 20)
                    .fill(isOn ? Color("chicken") : Color("cream").opacity(0.3))
                    .frame(width: 50, height: 30)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
                
                // Thumb
                Circle()
                    .fill(.white)
                    .frame(width: 26, height: 26)
                    .shadow(color: .black.opacity(0.1), radius: 2, x: 0, y: 1)
                    .offset(x: isOn ? 10 : -10)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isOn)
                    .gesture(
                        DragGesture()
                            .onChanged { value in
                                if !isAnimating {
                                    dragOffset = value.translation.width
                                }
                            }
                            .onEnded { value in
                                let threshold: CGFloat = 15
                                if abs(value.translation.width) > threshold {
                                    withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                        isOn.toggle()
                                    }
                                }
                                dragOffset = 0
                            }
                    )
            }
            .onTapGesture {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isOn.toggle()
                }
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("cream").opacity(0.1))
        )
        .scaleEffect(isAnimating ? 0.98 : 1.0)
        .onChange(of: isOn) { _ in
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isAnimating = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isAnimating = false
                }
            }
        }
    }
}

struct CustomSlider: View {
    @Binding var value: Double
    let range: ClosedRange<Double>
    let title: String
    let subtitle: String?
    
    @State private var isDragging = false
    
    init(value: Binding<Double>, range: ClosedRange<Double>, title: String, subtitle: String? = nil) {
        self._value = value
        self.range = range
        self.title = title
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.primary)
                    
                    if let subtitle = subtitle {
                        Text(subtitle)
                            .font(.system(size: 14, weight: .regular))
                            .foregroundColor(.secondary)
                    }
                }
                
                Spacer()
                
                Text("\(Int(value))")
                    .font(.system(size: 18, weight: .semibold))
                    .foregroundColor(Color("chicken"))
            }
            
            // Custom Slider
            ZStack(alignment: .leading) {
                // Track
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("cream").opacity(0.3))
                    .frame(height: 8)
                
                // Progress
                RoundedRectangle(cornerRadius: 8)
                    .fill(Color("chicken"))
                    .frame(width: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * UIScreen.main.bounds.width * 0.7, height: 8)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: value)
                
                // Thumb
                Circle()
                    .fill(.white)
                    .frame(width: 24, height: 24)
                    .shadow(color: Color("chicken").opacity(0.3), radius: 4, x: 0, y: 2)
                    .offset(x: CGFloat((value - range.lowerBound) / (range.upperBound - range.lowerBound)) * UIScreen.main.bounds.width * 0.7 - 12)
                    .scaleEffect(isDragging ? 1.2 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isDragging)
                    .gesture(
                        DragGesture()
                            .onChanged { gesture in
                                isDragging = true
                                let newValue = range.lowerBound + Double(gesture.location.x / (UIScreen.main.bounds.width * 0.7)) * (range.upperBound - range.lowerBound)
                                value = max(range.lowerBound, min(range.upperBound, newValue))
                            }
                            .onEnded { _ in
                                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                    isDragging = false
                                }
                            }
                    )
            }
        }
        .padding(.vertical, 12)
        .padding(.horizontal, 16)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("cream").opacity(0.1))
        )
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomSwitch(isOn: .constant(true), title: "Dark Mode", subtitle: "Use dark theme", icon: "moon.fill")
        
        CustomSwitch(isOn: .constant(false), title: "Notifications", subtitle: "Receive daily reminders", icon: "bell.fill")
        
        CustomSlider(value: .constant(15), range: 5...30, title: "Meditation Duration", subtitle: "Minutes per session")
        
        CustomSlider(value: .constant(50), range: 0...100, title: "Volume", subtitle: "Sound level")
    }
    .padding()
    .background(Color("darkBackground"))
}
