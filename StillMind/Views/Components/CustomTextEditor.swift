import SwiftUI
import UIKit

struct CustomTextEditor: UIViewRepresentable {
    @Binding var text: String
    let placeholder: String
    let textColor: UIColor
    let backgroundColor: UIColor
    
    init(text: Binding<String>, placeholder: String = "", textColor: UIColor = .white, backgroundColor: UIColor = .clear) {
        self._text = text
        self.placeholder = placeholder
        self.textColor = textColor
        self.backgroundColor = backgroundColor
    }
    
    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.delegate = context.coordinator
        
        // Убираем фон
        textView.backgroundColor = backgroundColor
        
        // Настройка текста
        textView.textColor = textColor
        textView.font = UIFont.systemFont(ofSize: 16)
        
        // Убираем отступы и границы
        textView.textContainerInset = UIEdgeInsets(top: 12, left: 12, bottom: 12, right: 12)
        textView.textContainer.lineFragmentPadding = 0
        
        // Убираем скролл индикаторы
        textView.showsVerticalScrollIndicator = false
        textView.showsHorizontalScrollIndicator = false
        
        // Настройка placeholder
        if text.isEmpty {
            textView.text = placeholder
            textView.textColor = textColor.withAlphaComponent(0.6)
        }
        
        // Убираем автокоррекцию и автокапитализацию
        textView.autocorrectionType = .no
        textView.autocapitalizationType = .sentences
        
        return textView
    }
    
    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text.isEmpty ? placeholder : text
            uiView.textColor = text.isEmpty ? textColor.withAlphaComponent(0.6) : textColor
        }
    }
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UITextViewDelegate {
        var parent: CustomTextEditor
        
        init(_ parent: CustomTextEditor) {
            self.parent = parent
        }
        
        func textViewDidBeginEditing(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                textView.text = ""
                textView.textColor = parent.textColor
            }
        }
        
        func textViewDidEndEditing(_ textView: UITextView) {
            if textView.text.isEmpty {
                textView.text = parent.placeholder
                textView.textColor = parent.textColor.withAlphaComponent(0.6)
            }
        }
        
        func textViewDidChange(_ textView: UITextView) {
            if textView.text == parent.placeholder {
                parent.text = ""
            } else {
                parent.text = textView.text
            }
        }
    }
}

// MARK: - Preview
#Preview {
    VStack(spacing: 20) {
        CustomTextEditor(
            text: .constant(""),
            placeholder: "Введите текст...",
            textColor: .white,
            backgroundColor: .clear
        )
        .frame(height: 200)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .padding()
        
        CustomTextEditor(
            text: .constant("Это пример текста"),
            placeholder: "Введите текст...",
            textColor: .white,
            backgroundColor: .clear
        )
        .frame(height: 200)
        .background(Color.gray.opacity(0.2))
        .cornerRadius(12)
        .padding()
    }
    .background(Color.black)
}
