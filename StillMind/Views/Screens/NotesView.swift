import SwiftUI

struct NotesView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var showingAddNote = false
    @State private var editingNote: Note?
    @State private var searchText = ""
    @State private var selectedMood: Note.Mood?
    @State private var isAnimating = false
    
    private var filteredNotes: [Note] {
        var notes = dataManager.notes
        
        if !searchText.isEmpty {
            notes = notes.filter { note in
                note.title.localizedCaseInsensitiveContains(searchText) ||
                note.content.localizedCaseInsensitiveContains(searchText)
            }
        }
        
        if let selectedMood = selectedMood {
            notes = notes.filter { $0.mood == selectedMood }
        }
        
        return notes.sorted { $0.date > $1.date }
    }
    
    var body: some View {
        VStack(spacing: 0) {
                // Custom Navigation Bar
                CustomNavigationBar(
                    title: "Reflections",
                    leftButton: nil,
                    rightButton: NavigationButton(icon: "plus") {
                        showingAddNote = true
                    }
                )
                
                // Search and filter section
                VStack(spacing: 16) {
                    // Search bar
                    HStack {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.secondary)
                            .font(.system(size: 16, weight: .medium))
                        
                        TextField("Search reflections...", text: $searchText)
                            .textFieldStyle(PlainTextFieldStyle())
                            .font(.system(size: 16, weight: .regular))
                        
                        if !searchText.isEmpty {
                            Button(action: {
                                searchText = ""
                            }) {
                                Image(systemName: "xmark.circle.fill")
                                    .foregroundColor(.secondary)
                                    .font(.system(size: 16, weight: .medium))
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 16)
                            .fill(Color("cream").opacity(0.1))
                    )
                    
                    // Mood filter
                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 12) {
                            MoodFilterButton(
                                title: "All",
                                isSelected: selectedMood == nil,
                                color: Color("chicken")
                            ) {
                                selectedMood = nil
                            }
                            
                            ForEach(Note.Mood.allCases, id: \.self) { mood in
                                MoodFilterButton(
                                    title: mood.emoji + " " + mood.rawValue.capitalized,
                                    isSelected: selectedMood == mood,
                                    color: mood.color
                                ) {
                                    selectedMood = selectedMood == mood ? nil : mood
                                }
                            }
                        }
                        .padding(.horizontal, 24)
                    }
                }
                .padding(.horizontal, 24)
                .padding(.bottom, 20)
                .opacity(isAnimating ? 1.0 : 0.0)
                .offset(y: isAnimating ? 0 : 20)
                .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)
                
                // Notes list
                if filteredNotes.isEmpty {
                    EmptyNotesView(
                        searchText: searchText,
                        selectedMood: selectedMood
                    )
                } else {
                    ScrollView {
                        LazyVStack(spacing: 16) {
                            ForEach(Array(filteredNotes.enumerated()), id: \.element.id) { index, note in
                                NoteCard(
                                    note: note,
                                    onEdit: {
                                        editingNote = note
                                    },
                                    onDelete: {
                                        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                            dataManager.deleteNote(note)
                                        }
                                    }
                                )
                                .opacity(isAnimating ? 1.0 : 0.0)
                                .offset(y: isAnimating ? 0 : 30)
                                .animation(.easeOut(duration: 0.6).delay(0.4 + Double(index) * 0.1), value: isAnimating)
                            }
                        }
                        .padding(.horizontal, 24)
                        .padding(.bottom, 100)
                    }
                }
            }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
        }
        .sheet(isPresented: $showingAddNote) {
            AddEditNoteView(note: nil) { note in
                dataManager.addNote(note)
            }
        }
        .sheet(item: $editingNote) { note in
            AddEditNoteView(note: note) { updatedNote in
                dataManager.updateNote(updatedNote)
            }
        }
    }
}

struct MoodFilterButton: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                isPressed = true
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    isPressed = false
                }
            }
            
            action()
        }) {
            Text(title)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(isSelected ? .white : color)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    RoundedRectangle(cornerRadius: 20)
                        .fill(isSelected ? color : color.opacity(0.1))
                )
                .scaleEffect(isPressed ? 0.95 : 1.0)
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct EmptyNotesView: View {
    let searchText: String
    let selectedMood: Note.Mood?
    
    var body: some View {
        VStack(spacing: 20) {
            Spacer()
            
            if !searchText.isEmpty || selectedMood != nil {
                VStack(spacing: 16) {
                    Image(systemName: "magnifyingglass")
                        .font(.system(size: 50, weight: .light))
                        .foregroundColor(Color("chicken").opacity(0.6))
                    
                    Text("No reflections found")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Try adjusting your search or mood filter")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
            } else {
                VStack(spacing: 16) {
                    Image(systemName: "note.text")
                        .font(.system(size: 50, weight: .light))
                        .foregroundColor(Color("chicken").opacity(0.6))
                    
                    Text("No reflections yet")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(.primary)
                    
                    Text("Start your mindfulness journey by writing your first reflection")
                        .font(.system(size: 16, weight: .regular))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                        .lineLimit(3)
                }
            }
            
            Spacer()
        }
        .padding(32)
    }
}

struct AddEditNoteView: View {
    let note: Note?
    let onSave: (Note) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: Note.Mood = .calm
    @State private var isAnimating = false
    
    init(note: Note?, onSave: @escaping (Note) -> Void) {
        self.note = note
        self.onSave = onSave
        
        if let note = note {
            _title = State(initialValue: note.title)
            _content = State(initialValue: note.content)
            _selectedMood = State(initialValue: note.mood)
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color("darkBackground")
                    .ignoresSafeArea()
                
                VStack(spacing: 24) {
                    // Mood selection
                    VStack(alignment: .leading, spacing: 16) {
                        Text("How are you feeling?")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                            ForEach(Note.Mood.allCases, id: \.self) { mood in
                                MoodSelectionButton(
                                    mood: mood,
                                    isSelected: selectedMood == mood
                                ) {
                                    selectedMood = mood
                                }
                            }
                        }
                    }
                    .padding(.horizontal, 24)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeOut(duration: 0.6).delay(0.1), value: isAnimating)
                    
                    // Title input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Title")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("Reflection title...", text: $title)
                            .font(.system(size: 16, weight: .regular))
                            .padding(.horizontal, 16)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: 12)
                                    .fill(Color("cream").opacity(0.1))
                            )
                    }
                    .padding(.horizontal, 24)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)
                    
                    // Content input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Reflection")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        CustomTextEditor(
                            text: $content,
                            placeholder: "Write your reflection...",
                            textColor: .white,
                            backgroundColor: .clear
                        )
                        .frame(minHeight: 120)
                        .background(
                            RoundedRectangle(cornerRadius: 12)
                                .fill(Color("cream").opacity(0.1))
                        )
                    }
                    .padding(.horizontal, 24)
                    .opacity(isAnimating ? 1.0 : 0.0)
                    .offset(y: isAnimating ? 0 : 30)
                    .animation(.easeOut(duration: 0.6).delay(0.3), value: isAnimating)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle(note == nil ? "New Reflection" : "Edit Reflection")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                    .foregroundColor(Color("chicken"))
                }
                
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Save") {
                        let newNote = Note(
                            title: title,
                            content: content,
                            date: note?.date ?? Date(),
                            mood: selectedMood
                        )
                        onSave(newNote)
                        dismiss()
                    }
                    .foregroundColor(Color("chicken"))
                    .disabled(title.isEmpty || content.isEmpty)
                }
            }
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
        }
    }
}

struct MoodSelectionButton: View {
    let mood: Note.Mood
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Text(mood.emoji)
                    .font(.system(size: 24))
                
                Text(mood.rawValue.capitalized)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? mood.color : Color("cream").opacity(0.1))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(mood.color, lineWidth: isSelected ? 0 : 1)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

#Preview {
    NotesView()
}
