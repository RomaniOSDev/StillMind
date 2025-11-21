import SwiftUI

struct CustomTabBar: View {
    @Binding var selectedTab: Int
    let tabs: [TabItem]
    
    @State private var previousTab: Int = 0
    
    var body: some View {
        ZStack {
            // Background
            RoundedRectangle(cornerRadius: 16)
                .fill(Color("cream").opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(Color("chicken").opacity(0.1), lineWidth: 0.5)
                )
                .shadow(color: Color("chicken").opacity(0.08), radius: 8, x: 0, y: 4)
                .frame(height: 50)
            
            // Selection indicator behind tabs
            GeometryReader { geometry in
                let tabWidth = (geometry.size.width - 16) / CGFloat(tabs.count)
                let indicatorWidth = tabWidth - 8
                
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color("chicken"))
                    .frame(width: indicatorWidth)
                    .offset(x: CGFloat(selectedTab) * tabWidth + (tabWidth - indicatorWidth) / 2 + 8)
                    .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedTab)
            }
            .frame(height: 32)
            
            // Tab buttons
            HStack(spacing: 0) {
                ForEach(Array(tabs.enumerated()), id: \.element.id) { index, tab in
                    TabBarButton(
                        tab: tab,
                        isSelected: selectedTab == index,
                        action: {
                            withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                previousTab = selectedTab
                                selectedTab = index
                            }
                        }
                    )
                }
            }
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
        }
    }
}

struct TabBarButton: View {
    let tab: TabItem
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.2, dampingFraction: 0.6)) {
                    isPressed = false
                }
            }
            
            action()
        }) {
            VStack(spacing: 2) {
                Image(systemName: isSelected ? tab.selectedIcon : tab.icon)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(isSelected ? .white : tab.color.opacity(0.9))
                    .scaleEffect(isSelected ? 1.15 : 1.0)
                    .animation(.spring(response: 0.3, dampingFraction: 0.7), value: isSelected)
            }
            .frame(maxWidth: .infinity, minHeight: 32)
            .padding(.vertical, 2)
            .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct CustomNavigationBar: View {
    let title: String
    let leftButton: NavigationButton?
    let rightButton: NavigationButton?
    
    var body: some View {
        HStack {
            if let leftButton = leftButton {
                CustomIconButton(
                    icon: leftButton.icon,
                    size: 44,
                    color: leftButton.color
                ) {
                    leftButton.action()
                }
            } else {
                Spacer()
                    .frame(width: 44)
            }
            
            Spacer()
            
            Text(title)
                .font(.system(size: 20, weight: .semibold))
                .foregroundColor(.primary)
                .animation(.easeInOut(duration: 0.3), value: title)
            
            Spacer()
            
            if let rightButton = rightButton {
                CustomIconButton(
                    icon: rightButton.icon,
                    size: 44,
                    color: rightButton.color
                ) {
                    rightButton.action()
                }
            } else {
                Spacer()
                    .frame(width: 44)
            }
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
        .background(
            Rectangle()
                .fill(Color("darkBackground"))
                .shadow(color: .black.opacity(0.1), radius: 8, x: 0, y: 4)
        )
    }
}

struct NavigationButton {
    let icon: String
    let color: Color
    let action: () -> Void
    
    init(icon: String, color: Color = Color("chicken"), action: @escaping () -> Void) {
        self.icon = icon
        self.color = color
        self.action = action
    }
}

#Preview {
    VStack {
        CustomNavigationBar(
            title: "Sample Screen",
            leftButton: NavigationButton(icon: "arrow.left") { print("Back") },
            rightButton: NavigationButton(icon: "plus") { print("Add") }
        )
        
        Spacer()
        
        CustomTabBar(
            selectedTab: .constant(0),
            tabs: [
                TabItem(title: "Home", icon: "house", selectedIcon: "house.fill", color: Color("chicken")),
                TabItem(title: "Notes", icon: "note.text", selectedIcon: "note.text", color: Color("warmOrange")),
                TabItem(title: "Timer", icon: "timer", selectedIcon: "timer", color: Color("softYellow")),
                TabItem(title: "Settings", icon: "gearshape", selectedIcon: "gearshape.fill", color: Color("cream"))
            ]
        )
    }
    .background(Color("darkBackground"))
}
