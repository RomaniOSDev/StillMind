import SwiftUI

struct MotivationView: View {
    @State private var currentQuoteIndex = 0
    @State private var isAnimating = false
    @State private var showNextQuote = false
    @State private var showPreviousQuote = false
    
    private let quotes: [Quote] = [
        Quote(
            text: "Peace comes from within. Do not seek it without.",
            author: "Buddha",
            category: .meditation
        ),
        Quote(
            text: "The mind is everything. What you think you become.",
            author: "Buddha",
            category: .mindfulness
        ),
        Quote(
            text: "In the midst of movement and chaos, keep stillness inside of you.",
            author: "Deepak Chopra",
            category: .peace
        ),
        Quote(
            text: "Meditation is not about stopping thoughts, but recognizing that we are more than our thoughts and our feelings.",
            author: "Arianna Huffington",
            category: .meditation
        ),
        Quote(
            text: "The present moment is filled with joy and happiness. If you are attentive, you will see it.",
            author: "Thich Nhat Hanh",
            category: .mindfulness
        ),
        Quote(
            text: "Happiness is not something ready made. It comes from your own actions.",
            author: "Dalai Lama",
            category: .wisdom
        ),
        Quote(
            text: "Every morning we are born again. What we do today matters most.",
            author: "Buddha",
            category: .mindfulness
        ),
        Quote(
            text: "The only way to live is to accept each minute as an unrepeatable miracle.",
            author: "Tara Brach",
            category: .wisdom
        ),
        Quote(
            text: "Mindfulness isn't difficult. We just need to remember to do it.",
            author: "Sharon Salzberg",
            category: .mindfulness
        ),
        Quote(
            text: "Your calm mind is the ultimate weapon against your challenges.",
            author: "Bryant McGill",
            category: .peace
        )
    ]
    
    var body: some View {
        VStack(spacing: 0) {
                // Custom Navigation Bar
                CustomNavigationBar(
                    title: "Daily Inspiration",
                    leftButton: nil,
                    rightButton: NavigationButton(icon: "heart.fill", color: Color("warmOrange")) {
                        // Favorite quote functionality
                    }
                )
                
                // Quote display
                ZStack {
                    // Previous quote (fading out)
                    if showPreviousQuote {
                        QuoteCard(
                            quote: quotes[previousQuoteIndex],
                            onNext: {},
                            onPrevious: {}
                        )
                        .opacity(showPreviousQuote ? 0.0 : 1.0)
                        .scaleEffect(showPreviousQuote ? 0.8 : 1.0)
                        .animation(.easeInOut(duration: 0.5), value: showPreviousQuote)
                    }
                    
                    // Current quote
                    QuoteCard(
                        quote: quotes[currentQuoteIndex],
                        onNext: {
                            showNextQuote = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                currentQuoteIndex = (currentQuoteIndex + 1) % quotes.count
                                showNextQuote = false
                            }
                        },
                        onPrevious: {
                            showPreviousQuote = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                                currentQuoteIndex = currentQuoteIndex == 0 ? quotes.count - 1 : currentQuoteIndex - 1
                                showPreviousQuote = false
                            }
                        }
                    )
                    .opacity(showNextQuote || showPreviousQuote ? 0.0 : 1.0)
                    .scaleEffect(showNextQuote || showPreviousQuote ? 0.8 : 1.0)
                    .animation(.easeInOut(duration: 0.5), value: showNextQuote || showPreviousQuote)
                }
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 50)
                .animation(.easeOut(duration: 0.8).delay(0.2), value: isAnimating)
                
                // Additional controls
                VStack(spacing: 24) {
                    // Quote category indicator
                    HStack {
                        Text("Category:")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(.secondary)
                        
                        Text(quotes[currentQuoteIndex].category.rawValue.capitalized)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(Color("chicken"))
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("chicken").opacity(0.1))
                            )
                        
                        Spacer()
                        
                        Text("\(currentQuoteIndex + 1) of \(quotes.count)")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.secondary)
                    }
                    .padding(.horizontal, 24)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(0.4), value: isAnimating)
                    
                    // Share button
                    CustomButton(
                        title: "Share Quote",
                        icon: "square.and.arrow.up",
                        style: .secondary
                    ) {
                        // Share functionality
                        let quote = quotes[currentQuoteIndex]
                        let shareText = "\"\(quote.text)\" — \(quote.author)"
                        let activityVC = UIActivityViewController(activityItems: [shareText], applicationActivities: nil)
                        
                        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                           let window = windowScene.windows.first {
                            window.rootViewController?.present(activityVC, animated: true)
                        }
                    }
                    .padding(.horizontal, 24)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeOut(duration: 0.8).delay(0.8), value: isAnimating)
                    
                    Spacer(minLength: 100)
                }
            }
        .onAppear {
            withAnimation(.easeOut(duration: 0.8)) {
                isAnimating = true
            }
        }
        .gesture(
            DragGesture()
                .onEnded { value in
                    let threshold: CGFloat = 50
                    if value.translation.width > threshold {
                        // Swipe right - previous quote
                        showPreviousQuote = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            currentQuoteIndex = currentQuoteIndex == 0 ? quotes.count - 1 : currentQuoteIndex - 1
                            showPreviousQuote = false
                        }
                    } else if value.translation.width < -threshold {
                        // Swipe left - next quote
                        showNextQuote = true
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
                            currentQuoteIndex = (currentQuoteIndex + 1) % quotes.count
                            showNextQuote = false
                        }
                    }
                }
        )
    }
    
    private var previousQuoteIndex: Int {
        currentQuoteIndex == 0 ? quotes.count - 1 : currentQuoteIndex - 1
    }
}

#Preview {
    MotivationView()
}
