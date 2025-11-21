import SwiftUI

struct JournalView: View {
    @StateObject private var dataManager = DataManager.shared
    @State private var selectedDate = Date()
    @State private var showingAddEntry = false
    @State private var editingEntry: JournalEntry?
    @State private var isAnimating = false
    
    private let calendar = Calendar.current
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter
    }()
    
    var body: some View {
        VStack(spacing: 0) {
                // Custom Navigation Bar
                CustomNavigationBar(
                    title: "Journal",
                    leftButton: nil,
                    rightButton: NavigationButton(icon: "plus") {
                        showingAddEntry = true
                    }
                )
                
                ScrollView {
                    VStack(spacing: 24) {
                        // Calendar section
                        CustomCalendarView(
                            selectedDate: $selectedDate,
                            entries: dataManager.journalEntries
                        )
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(0.2), value: isAnimating)
                        
                        // Selected date entries
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("Entries for \(selectedDate, style: .date)")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.primary)
                                
                                Spacer()
                                
                                if !entriesForSelectedDate.isEmpty {
                                    Text("\(entriesForSelectedDate.count) entry\(entriesForSelectedDate.count == 1 ? "" : "s")")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.secondary)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 6)
                                        .background(
                                            RoundedRectangle(cornerRadius: 12)
                                                .fill(Color("chicken").opacity(0.1))
                                        )
                                }
                            }
                            .padding(.horizontal, 24)
                            
                            if entriesForSelectedDate.isEmpty {
                                EmptyJournalView(selectedDate: selectedDate)
                            } else {
                                LazyVStack(spacing: 16) {
                                    ForEach(entriesForSelectedDate) { entry in
                                        JournalEntryCard(
                                            entry: entry,
                                            onEdit: {
                                                editingEntry = entry
                                            },
                                            onDelete: {
                                                withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
                                                    dataManager.deleteJournalEntry(entry)
                                                }
                                            }
                                        )
                                    }
                                }
                                .padding(.horizontal, 24)
                            }
                        }
                        .opacity(isAnimating ? 1.0 : 0.0)
                        .offset(y: isAnimating ? 0 : 30)
                        .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimating)
                        
                        // Recent entries summary
                        if !dataManager.journalEntries.isEmpty {
                            VStack(alignment: .leading, spacing: 16) {
                                Text("Recent Entries")
                                    .font(.system(size: 20, weight: .semibold))
                                    .foregroundColor(.primary)
                                    .padding(.horizontal, 24)
                                
                                ScrollView(.horizontal, showsIndicators: false) {
                                    HStack(spacing: 16) {
                                        ForEach(Array(dataManager.journalEntries.prefix(5).enumerated()), id: \.element.id) { index, entry in
                                            RecentJournalCard(entry: entry)
                                                .opacity(isAnimating ? 1.0 : 0.0)
                                                .offset(y: isAnimating ? 0 : 30)
                                                .animation(.easeOut(duration: 0.6).delay(0.6 + Double(index) * 0.1), value: isAnimating)
                                        }
                                    }
                                    .padding(.horizontal, 24)
                                }
                            }
                            .opacity(isAnimating ? 1.0 : 0.0)
                            .offset(y: isAnimating ? 0 : 30)
                            .animation(.easeOut(duration: 0.6).delay(0.6), value: isAnimating)
                        }
                        
                        Spacer(minLength: 100)
                    }
                }
            }
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                isAnimating = true
            }
        }
        .sheet(isPresented: $showingAddEntry) {
            AddEditJournalEntryView(entry: nil, selectedDate: selectedDate) { entry in
                dataManager.addJournalEntry(entry)
            }
        }
        .sheet(item: $editingEntry) { entry in
            AddEditJournalEntryView(entry: entry, selectedDate: entry.date) { updatedEntry in
                dataManager.updateJournalEntry(updatedEntry)
            }
        }
    }
    
    private var entriesForSelectedDate: [JournalEntry] {
        dataManager.journalEntries.filter { entry in
            calendar.isDate(entry.date, inSameDayAs: selectedDate)
        }.sorted { $0.date > $1.date }
    }
}

struct CustomCalendarView: View {
    @Binding var selectedDate: Date
    let entries: [JournalEntry]
    
    private let calendar = Calendar.current
    private let daysInWeek = ["Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat"]
    
    var body: some View {
        VStack(spacing: 20) {
            // Month header
            HStack {
                Button(action: previousMonth) {
                    Image(systemName: "chevron.left")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color("chicken"))
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color("chicken").opacity(0.1))
                        )
                }
                
                Spacer()
                
                Text(monthYearString)
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Spacer()
                
                Button(action: nextMonth) {
                    Image(systemName: "chevron.right")
                        .font(.system(size: 20, weight: .semibold))
                        .foregroundColor(Color("chicken"))
                        .frame(width: 44, height: 44)
                        .background(
                            Circle()
                                .fill(Color("chicken").opacity(0.1))
                        )
                }
            }
            .padding(.horizontal, 24)
            
            // Days of week header
            HStack(spacing: 0) {
                ForEach(daysInWeek, id: \.self) { day in
                    Text(day)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                        .frame(maxWidth: .infinity)
                }
            }
            .padding(.horizontal, 24)
            
            // Calendar grid
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 7), spacing: 8) {
                ForEach(calendarDays, id: \.self) { date in
                    if let date = date {
                        CalendarDayView(
                            date: date,
                            isSelected: calendar.isDate(date, inSameDayAs: selectedDate),
                            hasEntries: hasEntries(for: date),
                            isCurrentMonth: calendar.isDate(date, equalTo: selectedDate, toGranularity: .month)
                        ) {
                            selectedDate = date
                        }
                    } else {
                        Color.clear
                            .frame(height: 40)
                    }
                }
            }
            .padding(.horizontal, 24)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(Color("cream").opacity(0.1))
        )
        .padding(.horizontal, 24)
    }
    
    private var monthYearString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
    
    private var calendarDays: [Date?] {
        let startOfMonth = calendar.dateInterval(of: .month, for: selectedDate)?.start ?? selectedDate
        let firstWeekday = calendar.component(.weekday, from: startOfMonth)
        let daysInMonth = calendar.range(of: .day, in: .month, for: selectedDate)?.count ?? 0
        
        var days: [Date?] = []
        
        // Add empty days for previous month
        for _ in 1..<firstWeekday {
            days.append(nil)
        }
        
        // Add days of current month
        for day in 1...daysInMonth {
            if let date = calendar.date(byAdding: .day, value: day - 1, to: startOfMonth) {
                days.append(date)
            }
        }
        
        // Add empty days to complete the grid
        while days.count % 7 != 0 {
            days.append(nil)
        }
        
        return days
    }
    
    private func hasEntries(for date: Date) -> Bool {
        entries.contains { entry in
            calendar.isDate(entry.date, inSameDayAs: date)
        }
    }
    
    private func previousMonth() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if let newDate = calendar.date(byAdding: .month, value: -1, to: selectedDate) {
                selectedDate = newDate
            }
        }
    }
    
    private func nextMonth() {
        withAnimation(.spring(response: 0.4, dampingFraction: 0.8)) {
            if let newDate = calendar.date(byAdding: .month, value: 1, to: selectedDate) {
                selectedDate = newDate
            }
        }
    }
}

struct CalendarDayView: View {
    let date: Date
    let isSelected: Bool
    let hasEntries: Bool
    let isCurrentMonth: Bool
    let action: () -> Void
    
    private let calendar = Calendar.current
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text("\(calendar.component(.day, from: date))")
                    .font(.system(size: 16, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .white : (isCurrentMonth ? .primary : .secondary))
                
                if hasEntries {
                    Circle()
                        .fill(isSelected ? .white : Color("chicken"))
                        .frame(width: 6, height: 6)
                } else {
                    Spacer()
                        .frame(height: 6)
                }
            }
            .frame(height: 40)
            .frame(maxWidth: .infinity)
            .background(
                Circle()
                    .fill(isSelected ? Color("chicken") : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct JournalEntryCard: View {
    let entry: JournalEntry
    let onEdit: () -> Void
    let onDelete: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(entry.title)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(.primary)
                        .lineLimit(1)
                    
                    Text(entry.date, style: .time)
                        .font(.system(size: 14, weight: .regular))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                HStack(spacing: 8) {
                    Text(entry.mood.emoji)
                        .font(.system(size: 20))
                    
                    Circle()
                        .fill(entry.mood.color)
                        .frame(width: 8, height: 8)
                }
            }
            
            Text(entry.content)
                .font(.system(size: 16, weight: .regular))
                .foregroundColor(.primary)
                .lineLimit(3)
                .multilineTextAlignment(.leading)
            
            if !entry.tags.isEmpty {
                ScrollView(.horizontal, showsIndicators: false) {
                    HStack(spacing: 8) {
                        ForEach(entry.tags, id: \.self) { tag in
                            Text(tag)
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color("chicken"))
                                .padding(.horizontal, 8)
                                .padding(.vertical, 4)
                                .background(
                                    RoundedRectangle(cornerRadius: 8)
                                        .fill(Color("chicken").opacity(0.1))
                                )
                        }
                    }
                }
            }
            
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
                .shadow(color: entry.mood.color.opacity(0.2), radius: 8, x: 0, y: 4)
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

struct RecentJournalCard: View {
    let entry: JournalEntry
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "note.text")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(entry.mood.color)
                    .frame(width: 32, height: 32)
                    .background(
                        Circle()
                            .fill(entry.mood.color.opacity(0.1))
                    )
                
                Spacer()
            }
            
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.title)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                
                Text(entry.date, style: .date)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.secondary)
            }
        }
        .padding(16)
        .frame(width: 180)
        .background(
            RoundedRectangle(cornerRadius: 16)
                                .fill(Color("cream").opacity(0.1))
                                .shadow(color: entry.mood.color.opacity(0.2), radius: 8, x: 0, y: 4)
        )
    }
}

struct EmptyJournalView: View {
    let selectedDate: Date
    
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 50, weight: .light))
                .foregroundColor(Color("chicken").opacity(0.6))
            
            Text("No entries for this date")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(.primary)
            
            Text("Tap the + button to add your first journal entry")
                .font(.system(size: 14, weight: .regular))
                .foregroundColor(.secondary)
                .multilineTextAlignment(.center)
                .lineLimit(3)
        }
        .padding(32)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color("cream").opacity(0.05))
        )
        .padding(.horizontal, 24)
    }
}

struct AddEditJournalEntryView: View {
    let entry: JournalEntry?
    let selectedDate: Date
    let onSave: (JournalEntry) -> Void
    
    @Environment(\.dismiss) private var dismiss
    @State private var title = ""
    @State private var content = ""
    @State private var selectedMood: Note.Mood = .calm
    @State private var tags = ""
    @State private var isAnimating = false
    
    init(entry: JournalEntry?, selectedDate: Date, onSave: @escaping (JournalEntry) -> Void) {
        self.entry = entry
        self.selectedDate = selectedDate
        self.onSave = onSave
        
        if let entry = entry {
            _title = State(initialValue: entry.title)
            _content = State(initialValue: entry.content)
            _selectedMood = State(initialValue: entry.mood)
            _tags = State(initialValue: entry.tags.joined(separator: ", "))
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
                        
                        TextField("Journal entry title...", text: $title)
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
                        Text("Journal Entry")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        CustomTextEditor(
                            text: $content,
                            placeholder: "Write your journal entry...",
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
                    
                    // Tags input
                    VStack(alignment: .leading, spacing: 12) {
                        Text("Tags (comma separated)")
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        TextField("mindfulness, gratitude, peace...", text: $tags)
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
                    .animation(.easeOut(duration: 0.6).delay(0.4), value: isAnimating)
                    
                    Spacer()
                }
                .padding(.top, 20)
            }
            .navigationTitle(entry == nil ? "New Journal Entry" : "Edit Journal Entry")
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
                        let tagArray = tags.isEmpty ? [] : tags.components(separatedBy: ",").map { $0.trimmingCharacters(in: .whitespaces) }
                        let newEntry = JournalEntry(
                            date: entry?.date ?? selectedDate,
                            title: title,
                            content: content,
                            mood: selectedMood,
                            tags: tagArray
                        )
                        onSave(newEntry)
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

#Preview {
    JournalView()
}
