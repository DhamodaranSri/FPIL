//
//  AppleLocationSearchView.swift
//  FPIL
//
//  Created by OrganicFarmers on 05/10/25.
//

import SwiftUI
import MapKit

// MARK: - ViewModel for search
final class LocationSearchViewModel: NSObject, ObservableObject, MKLocalSearchCompleterDelegate {
    @Published var searchQuery = "" {
        didSet {
            completer.queryFragment = searchQuery
        }
    }
    @Published var results: [MKLocalSearchCompletion] = []

    private var completer: MKLocalSearchCompleter

    override init() {
        self.completer = MKLocalSearchCompleter()
        super.init()
        self.completer.delegate = self
    }

    func completerDidUpdateResults(_ completer: MKLocalSearchCompleter) {
        DispatchQueue.main.async {
            self.results = completer.results
        }
    }

    func completer(_ completer: MKLocalSearchCompleter, didFailWithError error: Error) {
        print("Completer error: \(error.localizedDescription)")
    }
}

// MARK: - Search View
struct AppleLocationSearchView: View {
    @Environment(\.dismiss) private var dismiss
    @ObservedObject private var viewModel = LocationSearchViewModel()
    @Binding var selectedAddress: String
    @Binding var coordinate: CLLocationCoordinate2D

    var body: some View {
        NavigationStack {
            VStack {
                TextField("Search for a place...", text: $viewModel.searchQuery)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .padding()

                List(viewModel.results, id: \.title) { result in
                    VStack(alignment: .leading) {
                        Text(result.title).font(.headline)
                        if !result.subtitle.isEmpty {
                            Text(result.subtitle).font(.subheadline).foregroundColor(.gray)
                        }
                    }
                    .onTapGesture {
                        selectLocation(result)
                    }
                }
            }
            .navigationTitle("Search Location")
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("Cancel") { dismiss() }
                }
            }
        }
    }

    private func selectLocation(_ result: MKLocalSearchCompletion) {
        let request = MKLocalSearch.Request(completion: result)
        let search = MKLocalSearch(request: request)
        search.start { response, error in
            guard let item = response?.mapItems.first else { return }
            DispatchQueue.main.async {
                selectedAddress = item.placemark.title ?? result.title
                coordinate = item.placemark.coordinate
                dismiss()
            }
        }
    }
}

