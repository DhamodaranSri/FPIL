//
//  SearchView.swift
//  FPIL
//
//  Created by OrganicFarmers on 27/09/25.
//

import SwiftUI

struct SearchView: View {
    @Binding var searchText: String
    var searchPlaceholder: String = ""
    var body: some View {
        HStack {
            TextField(
                searchPlaceholder,
                    text: $searchText,
                    prompt: Text(searchPlaceholder).foregroundColor(.gray) // placeholder gray
                )
                .foregroundColor(.white) // search text white
                .padding()
            Image(systemName: "magnifyingglass")
                .foregroundColor(.white)
                .padding()
        }
        .padding(.horizontal, 10)
        .background(RoundedRectangle(cornerRadius: 12).stroke(Color.red, lineWidth: 1))
        .background(Color.inspectionCellBG)
        .cornerRadius(12)
        .contentShape(Rectangle())
        .padding(.horizontal, 15)
        .padding(.vertical, 10)
    }
}
