import SwiftUI

struct AddStoreHeaderSection: View {
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("Add a new halal place")
                .font(.title2).bold()
            Text("Please fill in the details below.")
                .font(.subheadline)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}
