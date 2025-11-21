import SwiftUI
import StoreKit

struct SettingsView: View {
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 0) {
            // Custom Navigation Bar
            CustomNavigationBar(
                title: "Settings",
                leftButton: nil,
                rightButton: nil
            )
            
            ScrollView {
                VStack(spacing: 24) {
                    // App Info section
                    VStack(spacing: 20) {
                        HStack {
                            Text("App Info")
                                .font(.system(size: 20, weight: .semibold))
                                .foregroundColor(.primary)
                            
                            Spacer()
                        }
                        .padding(.horizontal, 24)
                        
                        VStack(spacing: 16) {
                            Button(action: {
                                SKStoreReviewController.requestReview()
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "star.fill")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(Color("chicken"))
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(Color("chicken").opacity(0.1))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Rate Us")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Share your feedback")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color("cream").opacity(0.1))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                            
                            Button(action: {
                                // Privacy policy action
                                if let url = URL(string: "https://stillmind.app/privacy") {
                                    UIApplication.shared.open(url)
                                }
                            }) {
                                HStack(spacing: 16) {
                                    Image(systemName: "hand.raised.fill")
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(Color("warmOrange"))
                                        .frame(width: 40, height: 40)
                                        .background(
                                            Circle()
                                                .fill(Color("warmOrange").opacity(0.1))
                                        )
                                    
                                    VStack(alignment: .leading, spacing: 4) {
                                        Text("Privacy Policy")
                                            .font(.system(size: 16, weight: .semibold))
                                            .foregroundColor(.primary)
                                        
                                        Text("Read our privacy policy")
                                            .font(.system(size: 14, weight: .regular))
                                            .foregroundColor(.secondary)
                                    }
                                    
                                    Spacer()
                                    
                                    Image(systemName: "chevron.right")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(Color("cream").opacity(0.1))
                                )
                            }
                            .buttonStyle(PlainButtonStyle())
                        }
                        .padding(.horizontal, 24)
                    }
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: isAnimating)
                    
                    Spacer(minLength: 100)
                }
                .padding(.top, 20)
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
}





#Preview {
    SettingsView()
}
