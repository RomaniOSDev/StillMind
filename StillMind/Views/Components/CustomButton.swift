import SwiftUI

struct CustomButton: View {
    let title: String
    let icon: String?
    let action: () -> Void
    let style: ButtonStyle
    let isEnabled: Bool
    
    @State private var isPressed = false
    
    init(
        title: String,
        icon: String? = nil,
        style: ButtonStyle = .primary,
        isEnabled: Bool = true,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.style = style
        self.isEnabled = isEnabled
        self.action = action
    }
    
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
            HStack(spacing: 8) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .medium))
                }
                
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
            }
            .foregroundColor(style.textColor)
            .padding(.horizontal, 20)
            .padding(.vertical, 14)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(style.backgroundColor)
                    .shadow(color: style.shadowColor.opacity(0.3), radius: 8, x: 0, y: 4)
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .opacity(isEnabled ? 1.0 : 0.6)
        }
        .disabled(!isEnabled)
        .buttonStyle(PlainButtonStyle())
    }
    
    enum ButtonStyle {
        case primary
        case secondary
        case accent
        case destructive
        
        var backgroundColor: Color {
            switch self {
            case .primary:
                return Color("chicken")
            case .secondary:
                return Color("cream")
            case .accent:
                return Color("warmOrange")
            case .destructive:
                return Color.red.opacity(0.8)
            }
        }
        
        var textColor: Color {
            switch self {
            case .primary, .accent, .destructive:
                return .white
            case .secondary:
                return Color("chicken")
            }
        }
        
        var shadowColor: Color {
            switch self {
            case .primary:
                return Color("chicken")
            case .secondary:
                return Color("cream")
            case .accent:
                return Color("warmOrange")
            case .destructive:
                return .red
            }
        }
    }
}

struct CustomIconButton: View {
    let icon: String
    let action: () -> Void
    let size: CGFloat
    let color: Color
    
    @State private var isPressed = false
    
    init(icon: String, size: CGFloat = 44, color: Color = Color("chicken"), action: @escaping () -> Void) {
        self.icon = icon
        self.size = size
        self.color = color
        self.action = action
    }
    
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
            Image(systemName: icon)
                .font(.system(size: size * 0.4, weight: .medium))
                .foregroundColor(color)
                .frame(width: size, height: size)
                .background(
                    Circle()
                        .fill(Color("cream").opacity(0.2))
                        .shadow(color: color.opacity(0.2), radius: 6, x: 0, y: 3)
                )
                .scaleEffect(isPressed ? 0.9 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    VStack(spacing: 20) {
        CustomButton(title: "Primary Button", icon: "heart.fill", style: .primary) {
            print("Primary tapped")
        }
        
        CustomButton(title: "Secondary Button", icon: "star.fill", style: .secondary) {
            print("Secondary tapped")
        }
        
        CustomButton(title: "Accent Button", icon: "bolt.fill", style: .accent) {
            print("Accent tapped")
        }
        
        CustomIconButton(icon: "plus", size: 50) {
            print("Icon button tapped")
        }
    }
    .padding()
    .background(Color("darkBackground"))
}
