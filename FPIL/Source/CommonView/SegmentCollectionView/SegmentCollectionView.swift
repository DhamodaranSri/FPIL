//
//  SegmentCollectionView.swift
//  FPIL
//
//  Created by OrganicFarmers on 03/09/25.
//

//import SwiftUI
//
//struct SegmentCollectionView: View {
//    var body: some View {
//        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
//    }
//}
//
//#Preview {
//    SegmentCollectionView()
//}

import SwiftUI

struct HorizontalSelectorView: View {
    @ObservedObject var viewModel: HorizontalSelectorViewModel
    
    var selectedColor: Color = .appPrimary
    var unselectedColor: Color = .tabbarIconSelected
    
    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            LazyHStack(spacing: 12) {
                ForEach(viewModel.items) { item in
                    Button(action: {
                        viewModel.selectItem(id: item.id ?? "")
                    }) {
                        Text(item.title)
                            .font(.headline)
                            .padding(.horizontal, 16)
                            .padding(.vertical, 4)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(viewModel.selectedId == item.id ? selectedColor.opacity(0.3) : unselectedColor.opacity(0.1))
                            )
                            .foregroundColor(.white)
                            .overlay(
                                RoundedRectangle(cornerRadius: 20)
                                    .stroke(viewModel.selectedId == item.id ? selectedColor : unselectedColor, lineWidth: 1)
                            )
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
        }
        .onAppear {
            viewModel.fetchButtons()
        }
    }
}

struct HorizontalSelectorView_Previews: PreviewProvider {
    
    static var previews: some View {
        HorizontalSelectorView(viewModel: MockVM())
            .previewLayout(.sizeThatFits)
            .padding()
    }
}

class MockVM: HorizontalSelectorViewModel {
    override init() {
        super.init()
        self.items = [
            SelectableButton(id: "1", title: "Home"),
            SelectableButton(id: "2", title: "Search"),
            SelectableButton(id: "3", title: "Cart"),
            SelectableButton(id: "4", title: "Profile"),
            SelectableButton(id: "5", title: "Settings"),
            SelectableButton(id: "6", title: "More")
        ]
        self.selectedId = "1"
    }
    
    override func fetchButtons() {
        // No Firebase call in preview
    }
}

@MainActor
class HorizontalSelectorViewModel: ObservableObject {
    @Published var items: [SelectableButton] = []
    @Published var selectedId: String? = nil
    
    private let service = FirebaseService<SelectableButton>(collectionName: "Buttons")
    
    func fetchButtons() {
        service.fetchAll { [weak self] result in
            switch result {
            case .success(let buttons):
                DispatchQueue.main.async {
                    self?.items = buttons
                    self?.selectedId = buttons.first?.id // select first by default
                }
            case .failure(let error):
                print("Error fetching buttons: \(error)")
            }
        }
    }
    
    func selectItem(id: String) {
        selectedId = id
    }
}

struct SelectableButton: Identifiable, Codable {
    var id: String?
    var title: String
}
