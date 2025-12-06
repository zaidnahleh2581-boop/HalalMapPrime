import SwiftUI

struct AddStoreScreen: View {
    @StateObject private var vm = AddStoreViewModel()

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {

                    Text("Add a new halal place")
                        .font(.title2.bold())

                    Text("Please fill in the details below. We'll verify it and add it to Halal Map Prime.")
                        .font(.subheadline)
                        .foregroundColor(.secondary)

                    // MARK: - Category
                    Text("Category")
                        .font(.headline)

                    ScrollView(.horizontal, showsIndicators: false) {
                        HStack(spacing: 8) {
                            ForEach(PlaceCategory.allCases) { category in
                                Button {
                                    vm.selectedCategory = category
                                } label: {
                                    Text(category.rawValue)
                                        .font(.subheadline)
                                        .padding(.horizontal, 12)
                                        .padding(.vertical, 8)
                                        .background(
                                            vm.selectedCategory == category
                                            ? Color.yellow.opacity(0.9)
                                            : Color(.systemGray6)
                                        )
                                        .cornerRadius(16)
                                }
                            }
                        }
                    }

                    // MARK: - Fields
                    Group {
                        TextField("Store name", text: $vm.name)
                            .textFieldStyle(.roundedBorder)

                        TextField("Street address", text: $vm.address)
                            .textFieldStyle(.roundedBorder)

                        HStack {
                            TextField("City", text: $vm.city)
                                .textFieldStyle(.roundedBorder)

                            TextField("State", text: $vm.state)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                        }

                        TextField("Phone (optional)", text: $vm.phone)
                            .keyboardType(.phonePad)
                            .textFieldStyle(.roundedBorder)

                        TextField("Website / Instagram (optional)", text: $vm.website)
                            .keyboardType(.URL)
                            .textFieldStyle(.roundedBorder)

                        TextField("Notes for review (optional)", text: $vm.notes, axis: .vertical)
                            .textFieldStyle(.roundedBorder)
                    }

                    // MARK: - Submit Button
                    Button {
                        vm.submit()
                    } label: {
                        HStack {
                            if vm.isSubmitting {
                                ProgressView()
                            }
                            Text("Submit place")
                                .fontWeight(.semibold)
                        }
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(vm.isSubmitting ? Color.gray : Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                    }
                    .disabled(vm.isSubmitting)
                    .padding(.top, 8)
                }
                .padding()
            }
            .navigationTitle("Add Store")
            .alert("Thank you!", isPresented: $vm.showSuccessAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Your submission has been received. We'll review it and add it to the map in shaa Allah.")
            }
            .alert("Please fill all required fields", isPresented: $vm.showValidationAlert) {
                Button("OK", role: .cancel) { }
            }
        }
    }
}
