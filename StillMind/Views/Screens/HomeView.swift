import SwiftUI

struct HomeView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedFeature: String?
    @State private var isAnimating = false
    @Binding var selectedTab: Int
    
    init(selectedTab: Binding<Int> = .constant(0)) {
        self._selectedTab = selectedTab
    }
    
    private let features = [
        ("Meditation", "Find your inner peace", "brain.head.profile", Color("chicken")),
        ("Reflections", "Journal your thoughts", "note.text", Color("warmOrange")),
        ("Motivation", "Daily inspiration", "quote.bubble.fill", Color("softYellow")),
        ("Journal", "Track your journey", "calendar", Color("cream")),
        ("Timer", "Set meditation time", "timer", Color("beige")),
        ("Settings", "App settings", "gearshape.fill", Color("chicken"))
    ]
    
    var body: some View {
        ScrollView {
                VStack(spacing: 32) {
                    // Header section
                    VStack(spacing: 16) {
                        HStack {
                            VStack(alignment: .leading, spacing: 8) {
                                Text("Welcome back,")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.secondary)
                                    .opacity(isAnimating ? 1.0 : 0.0)
                                    .offset(y: isAnimating ? 0 : 20)
                                    .animation(.easeOut(duration: 0.8).delay(0.1), value: isAnimating)
                                
                                Text("find your stillness")
                                    .font(.system(size: 32, weight: .bold))
                                    .foregroundColor(.primary)
                                    .opacity(isAnimating ? 1.0 : 0.0)
                                    .offset(y: isAnimating ? 0 : 20)
                                    .animation(.easeOut(duration: 0.8).delay(0.2), value: isAnimating)
                            }
                            
                            Spacer()
                            
                            // Avatar
                            ZStack {
                                Circle()
                                    .fill(Color("chicken"))
                                    .frame(width: 60, height: 60)
                                    .scaleEffect(isAnimating ? 1.0 : 0.8)
                                    .animation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.4), value: isAnimating)
                                
                                Image(systemName: "person.fill")
                                    .font(.system(size: 24, weight: .medium))
                                    .foregroundColor(.white)
                            }
                        }
                        
                        // Stats row
                        HStack(spacing: 20) {
                            StatCard(
                                title: "Sessions",
                                value: "\(dataManager.meditationSessions.count)",
                                subtitle: "Total sessions",
                                color: Color("chicken")
                            )
                            
                            StatCard(
                                title: "Notes",
                                value: "\(dataManager.notes.count)",
                                subtitle: "Total notes",
                                color: Color("warmOrange")
                            )
                            
                            StatCard(
                                title: "Days",
                                value: "\(Calendar.current.dateComponents([.day], from: Date()).day ?? 0)",
                                subtitle: "Current day",
                                color: Color("softYellow")
                            )
                        }
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.easeOut(duration: 0.8).delay(0.5), value: isAnimating)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 16)
                    
                    // Features grid
                    LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 16), count: 2), spacing: 16) {
                        ForEach(Array(features.enumerated()), id: \.offset) { index, feature in
                            FeatureCard(
                                title: feature.0,
                                subtitle: feature.1,
                                icon: feature.2,
                                color: feature.3
                            ) {
                                selectedFeature = feature.0
                                navigateToFeature(feature.0)
                            }
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .offset(y: isAnimating ? 0 : 50)
                            .animation(.easeOut(duration: 0.8).delay(0.6 + Double(index) * 0.1), value: isAnimating)
                        }
                    }
                    .padding(.horizontal, 20)
                    
                    // Recent activity
                    VStack(alignment: .leading, spacing: 16) {
                        Text("Recent Activity")
                            .font(.system(size: 20, weight: .semibold))
                            .foregroundColor(.primary)
                            .padding(.horizontal, 20)
                        
                        if dataManager.notes.isEmpty && dataManager.meditationSessions.isEmpty {
                            EmptyStateView(
                                title: "No activity yet",
                                message: "Start your mindfulness journey by creating your first note or meditation session",
                                icon: "sparkles"
                            )
                        } else {
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack(spacing: 16) {
                                    if let lastNote = dataManager.notes.last {
                                        RecentActivityCard(
                                            title: lastNote.title,
                                            subtitle: "Note • \(formatRelativeDate(lastNote.date))",
                                            icon: "note.text",
                                            color: lastNote.mood.color
                                        )
                                    }
                                    
                                    if let lastSession = dataManager.meditationSessions.last {
                                        RecentActivityCard(
                                            title: "\(Int(lastSession.duration / 60)) min meditation",
                                            subtitle: "Session • \(formatRelativeDate(lastSession.date))",
                                            icon: "brain.head.profile",
                                            color: Color("chicken")
                                        )
                                    }
                                }
                                .padding(.horizontal, 20)
                            }
                        }
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(0.8), value: isAnimating)
                    
                    Spacer(minLength: 80)
                }
            }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
        .sheet(item: $selectedFeature) { feature in
            // Handle feature selection
            Text("Selected: \(feature)")
        }
    }
}



struct RecentActivityCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(color.opacity(0.1))
                    )
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(subtitle)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(width: 200)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("cream").opacity(0.1))
                .shadow(color: color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
}



#Preview {
    HomeView()
}

// MARK: - Helper Functions
extension HomeView {
    private func formatRelativeDate(_ date: Date) -> String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: date, relativeTo: Date())
    }
    
    private func navigateToFeature(_ featureName: String) {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            switch featureName {
            case "Meditation":
                selectedTab = 3  // Timer tab
            case "Reflections":
                selectedTab = 1  // Notes tab
            case "Motivation":
                selectedTab = 2  // Motivation tab
            case "Journal":
                selectedTab = 4  // Journal tab
            case "Timer":
                selectedTab = 3  // Timer tab
            case "Settings":
                selectedTab = 5  // Settings tab
            default:
                break
            }
        }
    }
}
