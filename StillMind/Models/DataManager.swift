import Foundation
import SwiftUI
import Combine

class DataManager: ObservableObject {
    static let shared = DataManager()
    
    @AppStorage("isOnboardingCompleted") var isOnboardingCompleted: Bool = false
    @AppStorage("userProfile") private var userProfileData: Data = Data()
    @AppStorage("notes") private var notesData: Data = Data()
    @AppStorage("journalEntries") private var journalData: Data = Data()
    @AppStorage("meditationSessions") private var sessionsData: Data = Data()
    
    @Published var userProfile: UserProfile = .default
    @Published var notes: [Note] = []
    @Published var journalEntries: [JournalEntry] = []
    @Published var meditationSessions: [MeditationSession] = []
    
    private init() {
        loadData()
        setupSampleData()
    }
    
    // MARK: - User Profile
    func updateUserProfile(_ profile: UserProfile) {
        userProfile = profile
        saveUserProfile()
    }
    
    private func saveUserProfile() {
        if let encoded = try? JSONEncoder().encode(userProfile) {
            userProfileData = encoded
        }
    }
    
    private func loadUserProfile() {
        if let profile = try? JSONDecoder().decode(UserProfile.self, from: userProfileData) {
            userProfile = profile
        }
    }
    
    // MARK: - Notes
    func addNote(_ note: Note) {
        notes.append(note)
        saveNotes()
    }
    
    func updateNote(_ note: Note) {
        if let index = notes.firstIndex(where: { $0.id == note.id }) {
            notes[index] = note
            saveNotes()
        }
    }
    
    func deleteNote(_ note: Note) {
        notes.removeAll { $0.id == note.id }
        saveNotes()
    }
    
    private func saveNotes() {
        if let encoded = try? JSONEncoder().encode(notes) {
            notesData = encoded
        }
    }
    
    private func loadNotes() {
        if let notes = try? JSONDecoder().decode([Note].self, from: notesData) {
            self.notes = notes
        }
    }
    
    // MARK: - Journal Entries
    func addJournalEntry(_ entry: JournalEntry) {
        journalEntries.append(entry)
        saveJournalEntries()
    }
    
    func updateJournalEntry(_ entry: JournalEntry) {
        if let index = journalEntries.firstIndex(where: { $0.id == entry.id }) {
            journalEntries[index] = entry
            saveJournalEntries()
        }
    }
    
    func deleteJournalEntry(_ entry: JournalEntry) {
        journalEntries.removeAll { $0.id == entry.id }
        saveJournalEntries()
    }
    
    private func saveJournalEntries() {
        if let encoded = try? JSONEncoder().encode(journalEntries) {
            journalData = encoded
        }
    }
    
    private func loadJournalEntries() {
        if let entries = try? JSONDecoder().decode([JournalEntry].self, from: journalData) {
            self.journalEntries = entries
        }
    }
    
    // MARK: - Meditation Sessions
    func addMeditationSession(_ session: MeditationSession) {
        meditationSessions.append(session)
        saveMeditationSessions()
    }
    
    private func saveMeditationSessions() {
        if let encoded = try? JSONEncoder().encode(meditationSessions) {
            sessionsData = encoded
        }
    }
    
    private func loadMeditationSessions() {
        if let sessions = try? JSONDecoder().decode([MeditationSession].self, from: sessionsData) {
            self.meditationSessions = sessions
        }
    }
    
    // MARK: - Data Loading
    private func loadData() {
        loadUserProfile()
        loadNotes()
        loadJournalEntries()
        loadMeditationSessions()
    }
    
    // MARK: - Sample Data
    private func setupSampleData() {
        if notes.isEmpty {
            let sampleNotes = [
                Note(title: "Morning Reflection", content: "Today I feel grateful for the peaceful morning and the opportunity to start fresh.", date: Date(), mood: .grateful),
                Note(title: "Mindful Moment", content: "Taking deep breaths and feeling the present moment. Everything is temporary.", date: Date().addingTimeInterval(-86400), mood: .mindful),
                Note(title: "Inner Peace", content: "Finding stillness within despite the chaos around. Peace comes from within.", date: Date().addingTimeInterval(-172800), mood: .peaceful)
            ]
            notes = sampleNotes
            saveNotes()
        }
        
        if journalEntries.isEmpty {
            let sampleEntries = [
                JournalEntry(date: Date(), title: "Gratitude Day", content: "Today I'm grateful for my health, family, and the beautiful weather.", mood: .grateful, tags: ["gratitude", "family", "health"]),
                JournalEntry(date: Date().addingTimeInterval(-86400), title: "Mindful Walk", content: "Took a peaceful walk in the park, feeling connected to nature.", mood: .peaceful, tags: ["nature", "walking", "mindfulness"])
            ]
            journalEntries = sampleEntries
            saveJournalEntries()
        }
    }
    
    // MARK: - Reset Data
    func resetAllData() {
        notes.removeAll()
        journalEntries.removeAll()
        meditationSessions.removeAll()
        userProfile = .default
        
        saveNotes()
        saveJournalEntries()
        saveMeditationSessions()
        saveUserProfile()
    }
}
