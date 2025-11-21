import SwiftUI

struct MainTabView: View {
    @State private var selectedTab = 0
    @State private var isAnimating = false
    
    private let tabs: [TabItem] = [
        TabItem(title: "Home", icon: "house", selectedIcon: "house.fill", color: Color("chicken")),
        TabItem(title: "Notes", icon: "note.text", selectedIcon: "note.text", color: Color("warmOrange")),
        TabItem(title: "Motivation", icon: "quote.bubble", selectedIcon: "quote.bubble.fill", color: Color("softYellow")),
        TabItem(title: "Timer", icon: "timer", selectedIcon: "timer", color: Color("cream")),
        TabItem(title: "Journal", icon: "calendar", selectedIcon: "calendar", color: Color("beige")),
                    TabItem(title: "Settings", icon: "gearshape", selectedIcon: "gearshape.fill", color: Color("chicken"))
    ]
    
    var body: some View {
        ZStack {
            // Beautiful gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color("darkBackground"),
                    Color("darkBackground").opacity(0.95),
                    Color("chicken").opacity(0.05),
                    Color("warmOrange")//.opacity(0.03)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()
            
            // Subtle pattern overlay for texture
            GeometryReader { geometry in
                ZStack {
                    // Soft dots pattern
                    ForEach(0..<30, id: \.self) { _ in
                        Circle()
                            .fill(Color("chicken").opacity(0.02))
                            .frame(width: .random(in: 1...3), height: .random(in: 1...3))
                            .position(
                                x: .random(in: 0...geometry.size.width),
                                y: .random(in: 0...geometry.size.height)
                            )
                    }
                    
                    // Gentle flowing lines
                    Path { path in
                        let width = geometry.size.width
                        let height = geometry.size.height
                        
                        path.move(to: CGPoint(x: 0, y: height * 0.3))
                        path.addCurve(
                            to: CGPoint(x: width, y: height * 0.4),
                            control1: CGPoint(x: width * 0.3, y: height * 0.25),
                            control2: CGPoint(x: width * 0.7, y: height * 0.45)
                        )
                        
                        path.move(to: CGPoint(x: 0, y: height * 0.7))
                        path.addCurve(
                            to: CGPoint(x: width, y: height * 0.6),
                            control1: CGPoint(x: width * 0.4, y: height * 0.75),
                            control2: CGPoint(x: width * 0.6, y: height * 0.55)
                        )
                    }
                    .stroke(Color("chicken").opacity(0.03), lineWidth: 1)
                }
            }
            .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // Content area
                ZStack {
                    switch selectedTab {
                    case 0:
                        HomeView(selectedTab: $selectedTab)
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    case 1:
                        NotesView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    case 2:
                        MotivationView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    case 3:
                        MeditationTimerView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    case 4:
                        JournalView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    case 5:
                        SettingsView()
                            .transition(.asymmetric(
                                insertion: .move(edge: .trailing).combined(with: .opacity),
                                removal: .move(edge: .leading).combined(with: .opacity)
                            ))
                    default:
                        HomeView()
                    }
                }
                .animation(.easeInOut(duration: 0.3), value: selectedTab)
                
                // Custom Tab Bar
                CustomTabBar(selectedTab: $selectedTab, tabs: tabs)
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 50)
                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.3), value: isAnimating)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                isAnimating = true
            }
        }
    }
}

#Preview {
    MainTabView()
}
