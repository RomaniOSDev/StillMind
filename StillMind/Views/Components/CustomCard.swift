import SwiftUI

struct CustomCard<Content: View>: View {
    let content: Content
    let backgroundColor: Color
    let shadowColor: Color
    let cornerRadius: CGFloat
    
    @State private var isPressed = false
    
    init(
        backgroundColor: Color = Color("cream").opacity(0.1),
        shadowColor: Color = Color("chicken").opacity(0.1),
        cornerRadius: CGFloat = 20,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.shadowColor = shadowColor
        self.cornerRadius = cornerRadius
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: cornerRadius)
                    .fill(backgroundColor)
                    .shadow(color: shadowColor, radius: 12, x: 0, y: 6)
            )
            .scaleEffect(isPressed ? 0.98 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
            .onTapGesture {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isPressed = true
                }
                
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                    withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                        isPressed = false
                    }
                }
            }
    }
}

struct FeatureCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.6)) {
                    isPressed = false
                }
                action()
            }
        }) {
            VStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.system(size: 32, weight: .medium))
                    .foregroundColor(color)
                    .frame(width: 60, height: 60)
                    .background(
                        Circle()
                            .fill(color.opacity(0.1))
                    )
                
                VStack(spacing: 8) {
                    Text(title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    Text(subtitle)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(2)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color("cream").opacity(0.1))
                    .shadow(color: color.opacity(0.2), radius: 12, x: 0, y: 6)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct NoteCard: View {
    let note: Note
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    @State private var showActions = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(note.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(note.date, style: .date)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text(note.mood.emoji)
                        .font(.system(size: 20))
                    
                    Circle()
                        .fill(note.mood.color)
                        .frame(width: 8, height: 8)
                }
            }
            
            Text(note.content)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            HStack {
                Spacer()
                
                Button(action: onEdit) {
                    Image(systemName: "pencil")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color("chicken"))
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color("chicken").opacity(0.1))
                        )
                }
                
                Button(action: onDelete) {
                    Image(systemName: "trash")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.red)
                        .frame(width: 32, height: 32)
                        .background(
                            Circle()
                                .fill(Color.red.opacity(0.1))
                        )
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("cream").opacity(0.1))
                .shadow(color: note.mood.color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
        .scaleEffect(isPressed ? 0.98 : 1.0)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onTapGesture {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
        }
    }
}

struct QuoteCard: View {
    let quote: Quote
    let onNext: () -> Void
    let onPrevious: () -> Void
    
    @State private var isAnimating = false
    
    var body: some View {
        VStack(spacing: 24) {
            Spacer()
            
            VStack(spacing: 20) {
                Image(systemName: "quote.bubble.fill")
                    .font(.system(size: 40, weight: .light))
                    .foregroundColor(Color("chicken").opacity(0.6))
                    .scaleEffect(isAnimating ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 2).repeatForever(autoreverses: true), value: isAnimating)
                
                Text(quote.text)
                    .font(.system(size: 20, weight: .medium))
                    .foregroundColor(.primary)
                    .multilineTextAlignment(.center)
                    .lineLimit(6)
                    .padding(.horizontal, 20)
                
                Text("— \(quote.author)")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color("chicken"))
            }
            .padding(32)
            .background(
                RoundedRectangle(cornerRadius: 24)
                    .fill(Color("cream").opacity(0.1))
                    .shadow(color: Color("chicken").opacity(0.2), radius: 16, x: 0, y: 8)
            )
            
            Spacer()
            
            HStack(spacing: 40) {
                CustomIconButton(icon: "arrow.left", size: 50, color: Color("warmOrange")) {
                    onPrevious()
                }
                
                CustomIconButton(icon: "arrow.right", size: 50, color: Color("warmOrange")) {
                    onNext()
                }
            }
        }
        .onAppear {
            isAnimating = true
        }
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomCard {
            VStack(alignment: .leading, spacing: 12) {
                Text("Sample Card")
                    .font(.title2)
                    .fontWeight(.semibold)
                Text("This is a custom card with content")
                    .foregroundColor(.secondary)
            }
        }
        
        FeatureCard(
            title: "Meditation",
            subtitle: "Find your inner peace",
            icon: "brain.head.profile",
            color: Color("chicken")
        ) {
            print("Meditation tapped")
        }
        
        NoteCard(
            note: Note(
                title: "Sample Note",
                content: "This is a sample note content that demonstrates the card layout.",
                date: Date(),
                mood: .peaceful
            ),
            onEdit: { print("Edit tapped") },
            onDelete: { print("Delete tapped") }
        )
    }
    .padding()
    .background(Color("darkBackground"))
}
