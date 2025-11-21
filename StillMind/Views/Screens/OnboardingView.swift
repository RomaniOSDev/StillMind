import SwiftUI

struct OnboardingView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var currentPage = 0
    @State private var dragOffset: CGFloat = 0
    @State private var showMainApp = false
    
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            title: "Welcome to StillMind",
            subtitle: "Calm your mind — bring order",
            description: "Begin your journey to inner peace and mindfulness with guided meditation and reflection tools.",
            imageName: "brain.head.profile",
            backgroundColor: Color("chicken")
        ),
        OnboardingPage(
            title: "Find Your Stillness",
            subtitle: "Meditation & Reflection",
            description: "Discover powerful meditation techniques and journal your thoughts to maintain mental clarity.",
            imageName: "heart.fill",
            backgroundColor: Color("warmOrange")
        ),
        OnboardingPage(
            title: "Track Your Progress",
            subtitle: "Mindful Living",
            description: "Monitor your meditation sessions, mood changes, and personal growth over time.",
            imageName: "chart.line.uptrend.xyaxis",
            backgroundColor: Color("softYellow")
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
                // Page content
                TabView(selection: $currentPage) {
                    ForEach(Array(pages.enumerated()), id: \.element.id) { index, page in
                        OnboardingPageView(page: page, index: index)
                            .tag(index)
                    }
                }
                .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
                .animation(.easeInOut(duration: 0.5), value: currentPage)
                
                // Bottom section
                VStack(spacing: 24) {
                    // Page indicators
                    HStack(spacing: 12) {
                        ForEach(0..<pages.count, id: \.self) { index in
                            Circle()
                                .fill(index == currentPage ? Color("chicken") : Color("cream").opacity(0.3))
                                .frame(width: 12, height: 12)
                                .scaleEffect(index == currentPage ? 1.2 : 1.0)
                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: currentPage)
                        }
                    }
                    
                    // Action buttons
                    if currentPage == pages.count - 1 {
                        CustomButton(
                            title: "Start Your Journey",
                            icon: "arrow.right",
                            style: .primary
                        ) {
                            withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                dataManager.isOnboardingCompleted = true
                                showMainApp = true
                            }
                        }
                    } else {
                        HStack(spacing: 16) {
                            CustomButton(
                                title: "Skip",
                                style: .secondary
                            ) {
                                withAnimation(.spring(response: 0.6, dampingFraction: 0.8)) {
                                    dataManager.isOnboardingCompleted = true
                                    showMainApp = true
                                }
                            }
                            
                            CustomButton(
                                title: "Next",
                                icon: "arrow.right",
                                style: .primary
                            ) {
                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                    currentPage = min(currentPage + 1, pages.count - 1)
                                }
                            }
                        }
                    }
                }
                .padding(.horizontal, 32)
                .padding(.bottom, 50)
        }
        .fullScreenCover(isPresented: $showMainApp) {
            MainTabView()
        }
    }
}

struct OnboardingPageView: View {
    let page: OnboardingPage
    let index: Int
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 40) {
            Spacer()
            
            // Icon with background
            ZStack {
                Circle()
                    .fill(page.backgroundColor.opacity(0.2))
                    .frame(width: 120, height: 120)
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                
                Image(systemName: page.imageName)
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(page.backgroundColor)
                    .scaleEffect(isAnimating ? 1.05 : 1.0)
                    .animation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true), value: isAnimating)
            }
            
            // Text content
            VStack(spacing: 16) {
                Text(page.title)
                    .font(.system(size: 32, weight: .bold))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.2), value: isAnimating)
                
                Text(page.subtitle)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(page.backgroundColor)
                    .multilineTextAlignment(.center)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: isAnimating)
                
                Text(page.description)
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(4)
                    .padding(.horizontal, 32)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 20)
                    .animation(.easeOut(duration: 0.8).delay(0.6), value: isAnimating)
            }
            
            Spacer()
        }
        .padding(.horizontal, 32)
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
        .onDisappear {
            isAnimating = false
        }
    }
}

#Preview {
    OnboardingView()
}
