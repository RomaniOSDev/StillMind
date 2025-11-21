import Foundation
import SwiftUI

// MARK: - User Profile
struct UserProfile: Codable {
    var name: String
    var avatarColor: String
    var isDarkMode: Bool
    var soundEnabled: Bool
    var notificationsEnabled: Bool
    
    static let `default` = UserProfile(
        name: "Mindful User",
        avatarColor: "chicken",
        isDarkMode: true,
        soundEnabled: true,
        notificationsEnabled: true
    )
}

// MARK: - Note/Reflection
struct Note: Codable, Identifiable {
    let id = UUID()
    var title: String
    var content: String
    var date: Date
    var mood: Mood
    
    enum Mood: String, CaseIterable, Codable {
        case calm = "calm"
        case peaceful = "peaceful"
        case grateful = "grateful"
        case mindful = "mindful"
        case centered = "centered"
        
        var emoji: String {
            switch self {
            case .calm: return "😌"
            case .peaceful: return "🕊️"
            case .grateful: return "🙏"
            case .mindful: return "🧘"
            case .centered: return "⚖️"
            }
        }
        
        var color: Color {
            switch self {
            case .calm: return Color("chicken")
            case .peaceful: return Color("softYellow")
            case .grateful: return Color("warmOrange")
            case .mindful: return Color("cream")
            case .centered: return Color("beige")
            }
        }
    }
}

// MARK: - Motivation Quote
struct Quote: Codable, Identifiable {
    let id = UUID()
    let text: String
    let author: String
    let category: QuoteCategory
    
    enum QuoteCategory: String, CaseIterable, Codable {
        case meditation = "meditation"
        case mindfulness = "mindfulness"
        case peace = "peace"
        case wisdom = "wisdom"
    }
}

// MARK: - Journal Entry
struct JournalEntry: Codable, Identifiable {
    let id = UUID()
    var date: Date
    var title: String
    var content: String
    var mood: Note.Mood
    var tags: [String]
}

// MARK: - Meditation Session
struct MeditationSession: Codable, Identifiable {
    let id = UUID()
    var duration: TimeInterval
    var date: Date
    var type: MeditationType
    
    enum MeditationType: String, CaseIterable, Codable {
        case breathing = "breathing"
        case mindfulness = "mindfulness"
        case lovingKindness = "lovingKindness"
        case bodyScan = "bodyScan"
        case walking = "walking"
        
        var displayName: String {
            switch self {
            case .breathing: return "Breathing"
            case .mindfulness: return "Mindfulness"
            case .lovingKindness: return "Loving Kindness"
            case .bodyScan: return "Body Scan"
            case .walking: return "Walking"
            }
        }
        
        var icon: String {
            switch self {
            case .breathing: return "lungs.fill"
            case .mindfulness: return "brain.head.profile"
            case .lovingKindness: return "heart.fill"
            case .bodyScan: return "figure.walk"
            case .walking: return "figure.walk"
            }
        }
        
        var color: Color {
            switch self {
            case .breathing: return Color("chicken")
            case .mindfulness: return Color("warmOrange")
            case .lovingKindness: return Color("softYellow")
            case .bodyScan: return Color("cream")
            case .walking: return Color("beige")
            }
        }
    }
}

// MARK: - Onboarding Page
struct OnboardingPage: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let description: String
    let imageName: String
    let backgroundColor: Color
}

// MARK: - Tab Item
struct TabItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String
    let selectedIcon: String
    let color: Color
}
