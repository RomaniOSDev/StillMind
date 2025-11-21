//
//  ContentView.swift
//  StillMind
//
//  Created by Роман Главацкий on 21.11.2025.
//

import SwiftUI


struct ContentView: View {
    @StateObject private var dataManager = DataManager.shared
    var body: some View {
        Group {
            if dataManager.isOnboardingCompleted {
                MainTabView()
                  //  .preferredColorScheme(.dark)
            } else {
                OnboardingView()
                  //  .preferredColorScheme(.dark)
            }
        }
        .preferredColorScheme(.dark) // Default to dark mode
        .environmentObject(dataManager)
    }
}

#Preview {
    ContentView()
}
