import SwiftUI

struct AddStoreSubmitButton: View {
    var isSubmitting: Bool
    var isFormValid: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack {
                if isSubmitting {
                    ProgressView()
                } else {
                    Image(systemName: "paperplane.fill")
                }
                
                Text(isSubmitting ? "Submitting..." : "Submit place")
                    .fontWeight(.semibold)
            }
            .frame(maxWidth: .infinity)
            .padding()
            .background(isFormValid ? Color.blue : Color.gray.opacity(0.4))
            .foregroundColor(.white)
            .cornerRadius(12)
        }
        .disabled(!isFormValid || isSubmitting)
    }
}
